import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/data/models/public_response_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/medication_remote_data_source.dart';
import '../../../data/models/medication_model.dart';

part 'medication_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MedicationCubit({required this.remoteDataSource, required this.networkInfo})
      : super(MedicationInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<MedicationModel> _allMedications = [];

  Future<void> getAllMedications({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String patientId,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedications = [];
      emit(MedicationLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllMedication(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId,
    );

    if (result is Success<PaginatedResponse<MedicationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        _allMedications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationModel>(
            paginatedData: PaginatedData<MedicationModel>(items: _allMedications),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } else {
        emit(MedicationError(error: result.data.msg ?? 'Failed to fetch medications'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to fetch medications');
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationModel>>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medications'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medications');
    }
  }

  Future<void> getMedicationsForAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String patientId,
    required String conditionId,
    required String medicationRequestId,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedications = [];
      emit(MedicationLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getAllMedicationForAppointment(
      appointmentId: appointmentId,
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10, conditionId: conditionId, medicationRequestId: medicationRequestId,
    );

    if (result is Success<PaginatedResponse<MedicationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        _allMedications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationModel>(
            paginatedData: PaginatedData<MedicationModel>(items: _allMedications),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } else {
        emit(MedicationError(error: result.data.msg ?? 'Failed to fetch medications'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to fetch medications');
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationModel>>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medications'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medications');
    }
  }

  Future<void> getMedicationDetails({
    required String medicationId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(MedicationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getDetailsMedication(
      medicationId: medicationId,
      patientId: patientId,
    );

    if (result is Success<MedicationModel>) {
      if (result.data.name == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(MedicationDetailsSuccess(medication: result.data));
    } else if (result is ResponseError<MedicationModel>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medication details'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medication details');
    }
  }

  Future<void> getAllMedicationForMedicationRequest({
    required String medicationRequestId,
    required String patientId,
    required String conditionId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedications = [];
      emit(MedicationLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllMedicationForMedicationRequest(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId,
      medicationRequestId: medicationRequestId,conditionId: conditionId
    );

    if (result is Success<PaginatedResponse<MedicationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        _allMedications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationModel>(
            paginatedData: PaginatedData<MedicationModel>(items: _allMedications),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } else {
        emit(MedicationError(error: result.data.msg ?? 'Failed to fetch medications'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to fetch medications');
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationModel>>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medications'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medications');
    }
  }

  Future<void> createMedication({
    required MedicationModel medication,
    required String patientId,
    required String appointmentId,
    required String conditionId,
    required String medicationRequestId,
    required BuildContext context,
  }) async {
    emit(MedicationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.createMedication(
      medication: medication,
      patientId: patientId,
      conditionId: conditionId,
      appointmentId: appointmentId,medicationRequestId: medicationRequestId
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(MedicationCreated(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationError(error: result.message ?? 'Failed to create medication'));
      ShowToast.showToastError(message: result.message ?? 'Failed to create medication');
    }
  }

  Future<void> updateMedication({
    required MedicationModel medication,
    required String patientId,
    required String medicationId,
    required String medicationRequestId,
    required String conditionId,
    required BuildContext context,
  }) async {
    emit(MedicationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.updateMedication(
      medication: medication,
      patientId: patientId,
      medicationId: medicationId,
      medicationRequestId: medicationRequestId,
      conditionId: conditionId
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(MedicationUpdated(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationError(error: result.message ?? 'Failed to update medication'));
      ShowToast.showToastError(message: result.message ?? 'Failed to update medication');
    }
  }

  Future<void> deleteMedication({
    required String patientId,
    required String medicationId,
    required String conditionId,
    required String medicationRequestId,
    required BuildContext context,
  }) async {
    emit(MedicationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.deleteMedication(
      patientId: patientId,
      medicationId: medicationId,
      conditionId: conditionId,
      medicationRequestId: medicationRequestId
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(MedicationDeleted(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationError(error: result.message ?? 'Failed to delete medication'));
      ShowToast.showToastError(message: result.message ?? 'Failed to delete medication');
    }
  }

  Future<void> changeStatusMedication({
    required String patientId,
    required String medicationId,
    required String statusId,
    required BuildContext context,
  }) async {
    emit(MedicationLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.changeStatusMedication(
      patientId: patientId,
      medicationId: medicationId,
      statusId: statusId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(MedicationStatusChanged(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationError(error: result.message ?? 'Failed to change medication status'));
      ShowToast.showToastError(message: result.message ?? 'Failed to change medication status');
    }
  }
}