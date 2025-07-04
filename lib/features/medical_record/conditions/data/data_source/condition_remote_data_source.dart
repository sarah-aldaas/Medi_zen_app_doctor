import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_model.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../end_points/conditions_end_points.dart';
import '../models/conditions_model.dart';

abstract class ConditionRemoteDataSource {
  Future<Resource<PaginatedResponse<ConditionsModel>>> getAllConditions({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  });

  Future<Resource<PaginatedResponse<ConditionsModel>>> getAllConditionForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  });

  Future<Resource<ConditionsModel>> getDetailsConditions({required String conditionId, required String patientId});

  Future<Resource<PublicResponseModel>> createConditions({required ConditionsModel condition, required String patientId});

  Future<Resource<PublicResponseModel>> updateConditions({required ConditionsModel condition, required String conditionId, required String patientId});

  Future<Resource<PublicResponseModel>> deleteConditions({required String conditionId, required String patientId});

  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllObservationServiceRequest({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllImagingStudyServiceRequest({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<List<EncounterModel>>> getLast10Encounters({required String patientId});
}

class ConditionRemoteDataSourceImpl implements ConditionRemoteDataSource {
  final NetworkClient networkClient;

  ConditionRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ConditionsModel>>> getAllConditions({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ConditionsEndPoints.getAllConditions(patientId: patientId), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ConditionsModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ConditionsModel>.fromJson(json, 'conditions', (dataJson) => ConditionsModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<ConditionsModel>>> getAllConditionForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
    required String appointmentId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ConditionsEndPoints.getAllConditionsForAppointment(patientId: patientId, appointmentId: appointmentId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ConditionsModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ConditionsModel>.fromJson(json, 'conditions', (dataJson) => ConditionsModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<ConditionsModel>> getDetailsConditions({required String conditionId, required String patientId}) async {
    final response = await networkClient.invoke(ConditionsEndPoints.getDetailsCondition(patientId: patientId, conditionId: conditionId), RequestType.get);
    return ResponseHandler<ConditionsModel>(response).processResponse(fromJson: (json) => ConditionsModel.fromJson(json['condition']));
  }

  @override
  Future<Resource<PublicResponseModel>> createConditions({required ConditionsModel condition, required String patientId}) async {
    final response = await networkClient.invoke(ConditionsEndPoints.createCondition(patientId: patientId), RequestType.post, body: condition.createJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteConditions({required String conditionId, required String patientId}) async {
    final response = await networkClient.invoke(ConditionsEndPoints.deleteCondition(conditionId: conditionId, patientId: patientId), RequestType.delete);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllImagingStudyServiceRequest({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ConditionsEndPoints.getAllImagingStudyServiceRequest(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ServiceRequestModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ServiceRequestModel>.fromJson(json, 'service_requests', (dataJson) => ServiceRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllObservationServiceRequest({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ConditionsEndPoints.getAllObservationServiceRequest(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ServiceRequestModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ServiceRequestModel>.fromJson(json, 'service_requests', (dataJson) => ServiceRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<List<EncounterModel>>> getLast10Encounters({required String patientId}) async {
    final response = await networkClient.invoke(ConditionsEndPoints.getLast10Encounters(patientId: patientId), RequestType.get);

    return ResponseHandler<List<EncounterModel>>(response).processResponse(
      fromJson: (json) => (json['encounters'] != null ? json['encounters'] as List : []).map((serviceJson) => EncounterModel.fromJson(serviceJson)).toList(),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> updateConditions({required ConditionsModel condition, required String conditionId, required String patientId}) async {
    final response = await networkClient.invoke(
      ConditionsEndPoints.updateCondition(patientId: patientId, conditionId: conditionId),
      RequestType.post,
      body: condition.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
