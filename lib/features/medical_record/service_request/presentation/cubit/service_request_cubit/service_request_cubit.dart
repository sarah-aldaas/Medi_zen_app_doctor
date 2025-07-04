import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/data/models/public_response_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/service_request_remote_data_source.dart';
import '../../../data/models/service_request_model.dart';

part 'service_request_state.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final ServiceRequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  int _currentPage = 1;
  bool _hasMore = true;
  List<ServiceRequestModel> _allRequests = [];
  Map<String, dynamic> _currentFilters = {};

  ServiceRequestCubit({required this.remoteDataSource, required this.networkInfo}) : super(ServiceRequestInitial());

  Future<void> getServiceRequests({
    required BuildContext context,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String patientId,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allRequests = [];
      emit(ServiceRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError("No internet connection"));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.getAllServiceRequest(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId,
    );

    if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status!) {
        _allRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ServiceRequestLoaded(
          paginatedResponse: PaginatedResponse<ServiceRequestModel>(
            paginatedData: PaginatedData<ServiceRequestModel>(items: _allRequests),
            meta: result.data.meta,
            links: result.data.links,
          ),
          hasMore: _hasMore,
        ));
      } else {
        emit(ServiceRequestError(result.data.msg ?? 'Failed to load service requests'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to load service requests');
      }
    } else if (result is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
      emit(ServiceRequestError(result.message ?? 'Failed to load service requests'));
      ShowToast.showToastError(message: result.message ?? 'Failed to load service requests');
    }
  }

  Future<void> getServiceRequestsOfAppointment({
    required BuildContext context,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String appointmentId,
    required String patientId,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allRequests = [];
      emit(ServiceRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError("No internet connection"));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.getAllServiceRequestForAppointment(
      appointmentId: appointmentId,
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status!) {
        _allRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ServiceRequestLoaded(
          paginatedResponse: PaginatedResponse<ServiceRequestModel>(
            paginatedData: PaginatedData<ServiceRequestModel>(items: _allRequests),
            meta: result.data.meta,
            links: result.data.links,
          ),
          hasMore: _hasMore,
        ));
      } else {
        emit(ServiceRequestError(result.data.msg ?? 'Failed to load service requests'));
        ShowToast.showToastError(message: result.data.msg ?? 'Failed to load service requests');
      }
    } else if (result is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
      emit(ServiceRequestError(result.message ?? 'Failed to load service requests'));
      ShowToast.showToastError(message: result.message ?? 'Failed to load service requests');
    }
  }

  Future<void> getServiceRequestDetails({
    required String serviceId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading(isDetailsLoading: true));

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.getDetailsServiceRequest(
      serviceId: serviceId,
      patientId: patientId,
    );

    if (result is Success<ServiceRequestModel>) {
      if (result.data.toString().contains("Unauthorized. Please login first.") ) {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ServiceRequestLoaded(
        serviceRequestDetails: result.data,
        hasMore: _hasMore,
        paginatedResponse: state is ServiceRequestLoaded
            ? (state as ServiceRequestLoaded).paginatedResponse
            : null,
      ));
    } else {
      emit(ServiceRequestError('Failed to load service request details'));
      ShowToast.showToastError(message: 'Failed to load service request details');
    }
  }

  Future<void> createServiceRequest({
    required String patientId,
    required String appointmentId,
    required ServiceRequestModel serviceRequest,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.createServiceRequest(
      patientId: patientId,
      appointmentId: appointmentId,
      serviceRequest: serviceRequest,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if(result.data.status){
        emit(ServiceRequestCreated(message: result.data.msg ));
        ShowToast.showToastSuccess(message: result.data.msg );

      }else{

        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
      } else if(result is ResponseError<PublicResponseModel>){
      emit(ServiceRequestError(result.message ?? 'Failed to create service request'));
      ShowToast.showToastError(message: result.message ?? 'Failed to create service request');
    }
  }
  Future<void> updateServiceRequest({
    required String serviceId,
    required String patientId,
    required ServiceRequestModel serviceRequest,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.updateServiceRequest(
      serviceId: serviceId,
      patientId: patientId,
      serviceRequest: serviceRequest,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(ServiceRequestUpdated(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ServiceRequestError(result.message ?? 'Failed to update service request'));
      ShowToast.showToastError(message: result.message ?? 'Failed to update service request');
    }
  }

  Future<void> deleteServiceRequest({
    required String serviceId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.deleteServiceRequest(
      serviceId: serviceId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(ServiceRequestDeleted(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ServiceRequestError(result.message ?? 'Failed to delete service request'));
      ShowToast.showToastError(message: result.message ?? 'Failed to delete service request');
    }
  }

  Future<void> changeServiceRequestToActive({
    required String serviceId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.changeServiceRequestToActive(
      serviceId: serviceId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(ServiceRequestStatusChanged(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ServiceRequestError(result.message ?? 'Failed to change service request status'));
      ShowToast.showToastError(message: result.message ?? 'Failed to change service request status');
    }
  }

  Future<void> changeServiceRequestToEnteredInError({
    required String serviceId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.changeServiceRequestToEnteredInError(
      serviceId: serviceId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(ServiceRequestStatusChanged(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ServiceRequestError(result.message ?? 'Failed to change service request status'));
      ShowToast.showToastError(message: result.message ?? 'Failed to change service request status');
    }
  }

  Future<void> changeServiceRequestOnHoldStatus({
    required String serviceId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.changeServiceRequestOnHoldStatus(
      serviceId: serviceId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(ServiceRequestStatusChanged(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ServiceRequestError(result.message ?? 'Failed to change service request status'));
      ShowToast.showToastError(message: result.message ?? 'Failed to change service request status');
    }
  }

  Future<void> changeServiceRequestRevokeStatus({
    required String serviceId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ServiceRequestLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      ShowToast.showToastError(message: 'No internet connection');
      return;
    }

    final result = await remoteDataSource.changeServiceRequestRevokeStatus(
      serviceId: serviceId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if (result.data.status) {
        emit(ServiceRequestStatusChanged(message: result.data.msg));
        ShowToast.showToastSuccess(message: result.data.msg);
      } else {
        emit(ServiceRequestError(result.data.msg));
        ShowToast.showToastError(message: result.data.msg);
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ServiceRequestError(result.message ?? 'Failed to change service request status'));
      ShowToast.showToastError(message: result.message ?? 'Failed to change service request status');
    }
  }

  void clearDetails() {
    if (state is ServiceRequestLoaded) {
      emit(ServiceRequestLoaded(
        paginatedResponse: (state as ServiceRequestLoaded).paginatedResponse,
        hasMore: _hasMore,
      ));
    }
  }
}