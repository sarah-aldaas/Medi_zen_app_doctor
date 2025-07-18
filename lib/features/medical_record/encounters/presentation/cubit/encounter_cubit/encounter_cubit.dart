import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/services/data/model/health_care_services_model.dart';

import '../../../../../../base/data/models/public_response_model.dart';
import '../../../data/data_source/encounters_remote_data_source.dart';
import '../../../data/models/encounter_model.dart';

part 'encounter_state.dart';

class EncounterCubit extends Cubit<EncounterState> {
  final EncounterRemoteDataSource remoteDataSource;
  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<EncounterModel> _allEncounters = [];

  EncounterCubit({required this.remoteDataSource}) : super(EncounterInitial());

  Future<void> getPatientEncounters({required String patientId, Map<String, dynamic>? filters, bool loadMore = false, int? perPage}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allEncounters = [];
      emit(EncounterLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getPatientEncounters(
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: perPage??8,
    );

    if (result is Success<PaginatedResponse<EncounterModel>>) {
      try {
        if(result.data.status!){

          _allEncounters.addAll(result.data.paginatedData!.items);
          _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
          _currentPage++;

          emit(
            EncounterListSuccess(
              paginatedResponse: PaginatedResponse<EncounterModel>(
                paginatedData: PaginatedData<EncounterModel>(items: _allEncounters),
                meta: result.data.meta,
                links: result.data.links,
              ),
              hasMore: _hasMore,
            ),
          );
        }else{
          emit(EncounterError(error: result.data.msg ?? 'Error loading encounters'));

        }

      } catch (e) {
        emit(EncounterError(error: result.data.msg ?? 'Error loading encounters'));
      }
    } else if (result is ResponseError<PaginatedResponse<EncounterModel>>) {
      emit(EncounterError(error: result.message ?? 'Error loading encounters'));
    }
  }

  Future<void> getAppointmentEncounters({required String patientId, required String appointmentId}) async {
    emit(EncounterLoading());
    try{
    final result = await remoteDataSource.getAppointmentEncounters(patientId: patientId, appointmentId: appointmentId);
    if (result is Success<EncounterResponseModel>) {
      if(result.data.status){
        emit(EncounterDetailsSuccess(encounter: result.data.encounterModel));
      }else{
        emit(EncounterError(error: result.data.msg));

      }

    } else if (result is ResponseError<EncounterResponseModel>) {
      emit(EncounterError(error: result.message.toString()));
    }}catch(e){
      emit(EncounterError(error: e.toString()));

    }
  }

  Future<void> getEncounterDetails({required String patientId, required String encounterId}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.getEncounterDetails(patientId: patientId, encounterId: encounterId);
      if (result is Success<EncounterModel>) {
        emit(EncounterDetailsSuccess(encounter: result.data));
      } else if (result is ResponseError<EncounterModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error fetching encounter details');
        emit(EncounterError(error: result.message ?? 'Error fetching encounter details'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  Future<void> createEncounter({required String patientId, required EncounterModel encounter, required String appointmentId}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.createEncounter(patientId: patientId, encounter: encounter, appointmentId: appointmentId);
      if (result is Success<PublicResponseModel>) {
        if (result.data.status) {
          ShowToast.showToastSuccess(message: result.data.msg);
          emit(EncounterActionSuccess());
        } else {
          ShowToast.showToastError(message: result.data.msg ?? 'Error creating encounter');
          emit(EncounterError(error: result.data.msg ?? 'Error creating encounter'));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.data!.msg ?? 'Error creating encounter');
        emit(EncounterError(error: result.data!.msg ?? 'Error creating encounter'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  Future<void> updateEncounter({required String patientId, required String encounterId, required EncounterModel encounter}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.updateEncounter(patientId: patientId, encounterId: encounterId, encounter: encounter);
      if (result is Success<EncounterModel>) {
        ShowToast.showToastSuccess(message: 'Encounter updated successfully');
        emit(EncounterActionSuccess());
      } else if (result is ResponseError<EncounterModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error updating encounter');
        emit(EncounterError(error: result.message ?? 'Error updating encounter'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  Future<void> finalizeEncounter({required int patientId, required int encounterId}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.finalizeEncounter(patientId: patientId, encounterId: encounterId);
      if (result is Success<PublicResponseModel>) {
        ShowToast.showToastSuccess(message: 'Encounter finalized successfully');
        emit(EncounterActionSuccess());
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error finalizing encounter');
        emit(EncounterError(error: result.message ?? 'Error finalizing encounter'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  Future<void> assignService({required int encounterId, required int serviceId}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.assignService(encounterId: encounterId, serviceId: serviceId);
      if (result is Success<PublicResponseModel>) {
        ShowToast.showToastSuccess(message: 'Service assigned successfully');
        emit(EncounterActionSuccess());
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error assigning service');
        emit(EncounterError(error: result.message ?? 'Error assigning service'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  Future<void> unassignService({required int encounterId, required int serviceId}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.unassignService(encounterId: encounterId, serviceId: serviceId);
      if (result is Success<PublicResponseModel>) {
        if (result.data.status) {
          ShowToast.showToastSuccess(message: result.data.msg);
          emit(EncounterActionSuccess());
        } else {
          ShowToast.showToastError(message: result.data.msg);
          emit(EncounterError(error: result.data.msg ?? 'Error unassigning service'));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error unassigning service');
        emit(EncounterError(error: result.message ?? 'Error unassigning service'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  Future<void> getAppointmentServices({required int patientId, required int appointmentId}) async {
    emit(EncounterLoading());
    try {
      final result = await remoteDataSource.getAppointmentServices(patientId: patientId, appointmentId: appointmentId);
      if (result is Success<List<HealthCareServiceModel>>) {
        emit(AppointmentServicesSuccess(services: result.data));
      } else if (result is ResponseError<List<HealthCareServiceModel>>) {
        ShowToast.showToastError(message: result.message ?? 'Error fetching services');
        emit(EncounterError(error: result.message ?? 'Error fetching services'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(EncounterError(error: e.toString()));
    }
  }

  void checkAndReload({required String patientId, String? appointmentId}) {
    if (state is! EncounterListSuccess) {
      if (appointmentId != null) {
        getAppointmentEncounters(patientId: patientId, appointmentId: appointmentId);
      } else {
        getPatientEncounters(patientId: patientId);
      }
    }
  }
}
