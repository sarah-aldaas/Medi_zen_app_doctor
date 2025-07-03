import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/service_request_end_points.dart';
import '../models/service_request_model.dart';

abstract class ServiceRequestRemoteDataSource {
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequest({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  });

  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  });

  Future<Resource<ServiceRequestModel>> getDetailsServiceRequest({required String serviceId, required String patientId});

  Future<Resource<PublicResponseModel>> createServiceRequest({
    required String patientId,
    required String appointmentId,
    required ServiceRequestModel serviceRequest,
  });

  Future<Resource<PublicResponseModel>> deleteServiceRequest({required String serviceId, required String patientId});

  Future<Resource<PublicResponseModel>> updateServiceRequest({
    required String serviceId,
    required String patientId,
    required ServiceRequestModel serviceRequest,
  });

  Future<Resource<PublicResponseModel>> changeServiceRequestToActive({required String serviceId, required String patientId});

  Future<Resource<PublicResponseModel>> changeServiceRequestToEnteredInError({required String serviceId, required String patientId});

  Future<Resource<PublicResponseModel>> changeServiceRequestOnHoldStatus({required String serviceId, required String patientId});

  Future<Resource<PublicResponseModel>> changeServiceRequestRevokeStatus({required String serviceId, required String patientId});
}

class ServiceRequestRemoteDataSourceImpl implements ServiceRequestRemoteDataSource {
  final NetworkClient networkClient;

  ServiceRequestRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequest({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ServiceRequestEndPoints.getAllServiceRequestForPatient(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ServiceRequestModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ServiceRequestModel>.fromJson(json, 'service_requests', (dataJson) => ServiceRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ServiceRequestEndPoints.getAllServiceRequestForAppointment(appointmentId: appointmentId, patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ServiceRequestModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ServiceRequestModel>.fromJson(json, 'service_requests', (dataJson) => ServiceRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<ServiceRequestModel>> getDetailsServiceRequest({required String serviceId, required String patientId}) async {
    final response = await networkClient.invoke(ServiceRequestEndPoints.getDetailsService(serviceRequestId: serviceId, patientId: patientId), RequestType.get);
    return ResponseHandler<ServiceRequestModel>(response).processResponse(fromJson: (json) => ServiceRequestModel.fromJson(json['service_request']));
  }

  @override
  Future<Resource<PublicResponseModel>> changeServiceRequestOnHoldStatus({required String serviceId, required String patientId}) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.changeServiceRequestOnHoldStatus(serviceRequestId: serviceId, patientId: patientId),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> changeServiceRequestRevokeStatus({required String serviceId, required String patientId}) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.changeServiceRequestRevokeStatus(serviceRequestId: serviceId, patientId: patientId),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> changeServiceRequestToActive({required String serviceId, required String patientId}) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.changeServiceRequestToActive(serviceRequestId: serviceId, patientId: patientId),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> changeServiceRequestToEnteredInError({required String serviceId, required String patientId}) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.changeServiceRequestToEnteredInError(serviceRequestId: serviceId, patientId: patientId),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> createServiceRequest({
    required String patientId,
    required String appointmentId,
    required ServiceRequestModel serviceRequest,
  }) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.createServiceRequest(appointmentId: appointmentId, patientId: patientId),
      RequestType.post,
      body: serviceRequest.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteServiceRequest({required String serviceId, required String patientId}) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.deleteServiceRequest(serviceRequestId: serviceId, patientId: patientId),
      RequestType.delete,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateServiceRequest({
    required String serviceId,
    required String patientId,
    required ServiceRequestModel serviceRequest,
  }) async {
    final response = await networkClient.invoke(
      ServiceRequestEndPoints.updateServiceRequest(serviceRequestId: serviceId, patientId: patientId),
      RequestType.post,
      body: serviceRequest.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
