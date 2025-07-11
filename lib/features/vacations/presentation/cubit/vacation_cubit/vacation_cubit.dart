import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/base/error/exception.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/vacations_remote_data_source.dart';
import '../../../data/model/vacation_filter_model.dart';
import '../../../data/model/vacation_model.dart';

part 'vacation_state.dart';

class VacationCubit extends Cubit<VacationState> {
  final VacationRemoteDataSource remoteDataSource;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  VacationFilterModel currentFilter = VacationFilterModel();
  List<VacationModel> _allVacations = [];
  String? _currentScheduleId;

  VacationCubit({required this.remoteDataSource}) : super(VacationInitial());

  Future<void> getVacations({
    required String scheduleId,
    VacationFilterModel? filter,
    bool loadMore = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allVacations.clear();
      _currentScheduleId = scheduleId;
      emit(VacationLoading());
    } else if (!_hasMore) {
      _isLoading = false;
      return;
    }

    if (filter != null) {
      currentFilter = filter;
    }

    try {
      final result = await remoteDataSource.getVacations(
        scheduleId: scheduleId,
        filters: currentFilter.toJson(),
        page: _currentPage,
        perPage: 10,
      );

      if (result is Success<PaginatedResponse<VacationModel>>) {
        final newVacations = result.data.paginatedData?.items ?? [];
        _allVacations.addAll(newVacations);
        _hasMore = result.data.meta?.currentPage != null &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(VacationSuccess(
          vacations: _allVacations,
          hasMore: _hasMore,
          paginatedResponse: result.data,
        ));
      } else if (result is ResponseError<PaginatedResponse<VacationModel>>) {
        emit(VacationError(error: result.message ?? 'Failed to fetch vacations'));

      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> getVacationDetails(String id) async {
    emit(VacationLoading());
    final result = await remoteDataSource.getVacationDetails(id);
    if (result is Success<VacationModel>) {
      emit(VacationDetailsLoaded(vacation: result.data));
    } else if (result is ResponseError<VacationModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch vacation details');
      emit(VacationError(error: result.message ?? 'Failed to fetch vacation details'));
    }
  }

  Future<void> deleteVacation(int id) async {
    emit(VacationLoading());
    final result = await remoteDataSource.deleteVacation(id);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        emit(VacationDeleted());
        if (_currentScheduleId != null) {
          await getVacations(scheduleId: _currentScheduleId!);
        }

        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(VacationError(error: result.data.msg ?? 'Failed to update vacation'));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to delete vacation');
      emit(VacationError(error: result.message ?? 'Failed to update vacation'));

    }
  }

  Future<void> createVacation(VacationModel vacation) async {
    emit(VacationLoading());
    final result = await remoteDataSource.createVacation(vacation);
    if (result is Success<PublicResponseModel>) {
      if(result.data.status){
        emit(VacationCreated());
        if (_currentScheduleId != null) {
          await getVacations(scheduleId: _currentScheduleId!);
        }
        ShowToast.showToastSuccess(message: 'Vacation created successfully');
      }else{
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to create vacation');
        emit(VacationError(error: result.data.msg ?? 'Failed to create vacation'));

      }

    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.data!.msg ?? 'Failed to create vacation');
      emit(VacationError(error: result.message ?? 'Failed to create vacation'));
    }
  }

  Future<void> updateVacation(VacationModel vacation) async {
    emit(VacationLoading());
    try{
      final result = await remoteDataSource.updateVacation(vacation);
      if (result is Success<PublicResponseModel>) {
       if(result.data.status)
        {
          emit(VacationUpdated());
          if (_currentScheduleId != null) {
            await getVacations(scheduleId: _currentScheduleId!);
          }
          ShowToast.showToastSuccess(message: 'Vacation updated successfully');
        }else{
         ShowToast.showToastError(message: result.data.msg ?? 'Failed to update vacation');
         emit(VacationError(error: result.data.msg ?? 'Failed to update vacation'));

       }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to update vacation');
        emit(VacationError(error: result.message ?? 'Failed to update vacation'));
      }
    }on ServerException catch (e) {
      emit(VacationError(error:e.message+" This vacation period overlaps with an existing vacation for the same schedule."   ?? 'Failed to update vacation'));

    }
  }

  void clearFilters() {
    currentFilter = VacationFilterModel();
    if (_currentScheduleId != null) {
      getVacations(scheduleId: _currentScheduleId!);
    }
  }
}