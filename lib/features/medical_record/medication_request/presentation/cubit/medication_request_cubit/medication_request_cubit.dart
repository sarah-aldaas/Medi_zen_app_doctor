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
import '../../../data/data_source/medication_request_remote_data_source.dart';
import '../../../data/models/medication_request_model.dart';

part 'medication_request_state.dart';

class MedicationRequestCubit extends Cubit<MedicationRequestState> {
  final MedicationRequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MedicationRequestCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(MedicationRequestInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<MedicationRequestModel> _allMedicationRequests = [];

  Future<void> getAllMedicationRequests({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String patientId,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedicationRequests = [];
      emit(MedicationRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getAllMedicationRequest(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId,
    );

    if (result is Success<PaginatedResponse<MedicationRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        _allMedicationRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationRequestSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationRequestModel>(
            paginatedData: PaginatedData<MedicationRequestModel>(
              items: _allMedicationRequests,
            ),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } else {
        emit(MedicationRequestError(error: result.data.msg ?? 'Failed to fetch medication requests'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to fetch medication requests');
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationRequestModel>>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to fetch medication requests'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medication requests');
    }
  }

  Future<void> getMedicationRequestsForAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String patientId,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedicationRequests = [];
      emit(MedicationRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getAllMedicationRequestForAppointment(
      appointmentId: appointmentId,
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<MedicationRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        _allMedicationRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationRequestSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationRequestModel>(
            paginatedData: PaginatedData<MedicationRequestModel>(
              items: _allMedicationRequests,
            ),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } else {
        emit(MedicationRequestError(error: result.data.msg ?? 'Failed to fetch medication requests'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to fetch medication requests');
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationRequestModel>>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to fetch medication requests'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medication requests');
    }
  }

  Future<void> getMedicationRequestDetails({
    required String medicationRequestId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getDetailsMedicationRequest(
      medicationRequestId: medicationRequestId,
      patientId: patientId,
    );

    if (result is Success<MedicationRequestModel>) {
      if (result.data.statusReason == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(MedicationRequestDetailsSuccess(medicationRequest: result.data));
    } else if (result is ResponseError<MedicationRequestModel>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to fetch medication request details'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medication request details');
    }
  }

  Future<void> getMedicationRequestForCondition({
    required String conditionId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getAllMedicationRequestForCondition(
      conditionId: conditionId,
      patientId: patientId,
    );

    if (result is Success<MedicationRequestModel>) {
      if (result.data.statusReason == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(MedicationRequestForConditionSuccess(medicationRequest: result.data));
    } else if (result is ResponseError<MedicationRequestModel>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to fetch medication request for condition'));
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch medication request for condition');
    }
  }

  Future<void> createMedicationRequest({
    required MedicationRequestModel medicationRequest,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.createMedicationRequest(
      medicationRequest: medicationRequest,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        emit(MedicationRequestCreated(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationRequestError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to create medication request'));
      ShowToast.showToastError(message: result.message ?? 'Failed to create medication request');
    }
  }

  Future<void> updateMedicationRequest({
    required MedicationRequestModel medicationRequest,
    required String patientId,
    required String medicationRequestId,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.updateMedicationRequest(
      medicationRequest: medicationRequest,
      patientId: patientId,
      medicationRequestId: medicationRequestId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        emit(MedicationRequestUpdated(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationRequestError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to update medication request'));
      ShowToast.showToastError(message: result.message ?? 'Failed to update medication request');
    }
  }

  Future<void> deleteMedicationRequest({
    required String medicationRequestId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.deleteMedicationRequest(
      medicationRequestId: medicationRequestId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        emit(MedicationRequestDeleted(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationRequestError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to delete medication request'));
      ShowToast.showToastError(message: result.message ?? 'Failed to delete medication request');
    }
  }

  Future<void> changeStatusMedicationRequest({
    required String medicationRequestId,
    required String patientId,
    required String statusId,
    required String statusReason,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(MedicationRequestError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.changeStatusMedicationRequest(
      medicationRequestId: medicationRequestId,
      patientId: patientId,
      statusId: statusId,
      statusReason: statusReason,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status ?? false) {
        emit(MedicationRequestStatusChanged(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(MedicationRequestError(error: result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(MedicationRequestError(error: result.message ?? 'Failed to change medication request status'));
      ShowToast.showToastError(message: result.message ?? 'Failed to change medication request status');
    }
  }
}