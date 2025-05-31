import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/patients_remote_data_source.dart';
import '../../../data/models/patient_filter_model.dart';
import '../../../data/models/patient_model.dart';


part 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final PatientRemoteDataSource remoteDataSource;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  PatientFilterModel currentFilter = PatientFilterModel();
  List<PatientModel> _allPatients = [];

  PatientCubit({required this.remoteDataSource}) : super(PatientInitial());

  Future<void> listPatients({
    PatientFilterModel? filter,
    bool loadMore = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allPatients.clear();
      emit(PatientLoading());
    } else if (!_hasMore) {
      _isLoading = false;
      return;
    }

    if (filter != null) {
      currentFilter = filter;
    }

    try {
      final result = await remoteDataSource.listPatients(
        filters: currentFilter.toJson(),
        page: _currentPage,
        perPage: 10,
      );

      if (result is Success<PaginatedResponse<PatientModel>>) {
        final newPatients = result.data.paginatedData?.items ?? [];
        _allPatients.addAll(newPatients);
        _hasMore = result.data.meta?.currentPage != null &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(PatientSuccess(
          patients: _allPatients,
          hasMore: _hasMore,
          paginatedResponse: result.data,
        ));
      } else if (result is ResponseError<PaginatedResponse<PatientModel>>) {
        emit(PatientError(error: result.message ?? 'Failed to fetch patients'));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> showPatient(int id) async {
    emit(PatientLoading());
    final result = await remoteDataSource.showPatient(id);
    if (result is Success<PatientModel>) {
      emit(PatientDetailsLoaded(patient: result.data));
    } else if (result is ResponseError<PatientModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch patient details');
      emit(PatientError(error: result.message ?? 'Failed to fetch patient details'));
    }
  }

  Future<void> updatePatient(PatientModel patient) async {
    emit(PatientLoading());
    final result = await remoteDataSource.updatePatient(patient);
    if (result is Success<PatientModel>) {
      emit(PatientUpdated(patient: result.data));
      await listPatients();
      ShowToast.showToastSuccess(message: 'Patient updated successfully');
    } else if (result is ResponseError<PatientModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to update patient');
      emit(PatientError(error: result.message ?? 'Failed to update patient'));
    }
  }

  Future<void> toggleActiveStatus(int id) async {
    emit(PatientLoading());
    final result = await remoteDataSource.toggleActiveStatus(id);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await listPatients();
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to toggle active status');
    }
  }

  Future<void> toggleDeceasedStatus(int id) async {
    emit(PatientLoading());
    final result = await remoteDataSource.toggleDeceasedStatus(id);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await listPatients();
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to toggle deceased status');
    }
  }

  void clearFilters() {
    currentFilter = PatientFilterModel();
    listPatients();
  }
}