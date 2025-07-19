import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/medication_request_end_points.dart';
import '../models/medication_request_model.dart';

abstract class MedicationRequestRemoteDataSource {
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequest({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  });

  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
    required String conditionId,
  });

  Future<Resource<MedicationRequestModel>> getDetailsMedicationRequest({required String medicationRequestId, required String patientId});

  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequestForCondition({required String conditionId,  Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,});

  Future<Resource<PublicResponseModel>> createMedicationRequest({required MedicationRequestModel medicationRequest, required String patientId, required String appointmentId, required String conditionId});

  Future<Resource<PublicResponseModel>> updateMedicationRequest({
    required MedicationRequestModel medicationRequest,
    required String patientId,
    required String medicationRequestId,
    required String conditionId,
  });

  Future<Resource<PublicResponseModel>> deleteMedicationRequest({required String medicationRequestId, required String patientId, required String conditionId});

  Future<Resource<PublicResponseModel>> changeStatusMedicationRequest({
    required String medicationRequestId,
    required String patientId,
    required String statusId,
    required String statusReason,
  });
}

class MedicationRequestRemoteDataSourceImpl implements MedicationRequestRemoteDataSource {
  final NetworkClient networkClient;

  MedicationRequestRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequest({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      MedicationRequestEndPoints.getAllMedicationRequest(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<MedicationRequestModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<MedicationRequestModel>.fromJson(json, 'medication_requests', (dataJson) => MedicationRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
    required String conditionId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      MedicationRequestEndPoints.getAllMedicationRequestForAppointment(appointmentId: appointmentId, patientId: patientId, conditionId: conditionId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<MedicationRequestModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<MedicationRequestModel>.fromJson(json, 'medication_requests', (dataJson) => MedicationRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<MedicationRequestModel>> getDetailsMedicationRequest({required String medicationRequestId, required String patientId}) async {
    final response = await networkClient.invoke(
      MedicationRequestEndPoints.getDetailsMedicationRequest(medicationRequestId: medicationRequestId, patientId: patientId),
      RequestType.get,
    );
    return ResponseHandler<MedicationRequestModel>(response).processResponse(fromJson: (json) => MedicationRequestModel.fromJson(json['medication_request']));
  }

  @override
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequestForCondition({required String conditionId,  Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      MedicationRequestEndPoints.getAllMedicationRequestForCondition(patientId: patientId,conditionId: conditionId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<MedicationRequestModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<MedicationRequestModel>.fromJson(json, 'medication_requests', (dataJson) => MedicationRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> changeStatusMedicationRequest({
    required String medicationRequestId,
    required String patientId,
    required String statusId,
    required String statusReason,
  }) async {
    final response = await networkClient.invoke(
      MedicationRequestEndPoints.changeStatusMedicationRequest(medicationRequestId: medicationRequestId, patientId: patientId),
      RequestType.post,
      body: {"status_id": statusId, "status_reason": statusReason},
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> createMedicationRequest({required MedicationRequestModel medicationRequest, required String patientId, required String appointmentId, required String conditionId}) async {
    final response = await networkClient.invoke(
      MedicationRequestEndPoints.createMedicationRequest(patientId: patientId,appointmentId: appointmentId,conditionId: conditionId),
      RequestType.post,
      body: medicationRequest.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteMedicationRequest({required String medicationRequestId, required String patientId, required String conditionId}) async {
    final response = await networkClient.invoke(
      MedicationRequestEndPoints.deleteMedicationRequest(medicationRequestId: medicationRequestId, patientId: patientId,conditionId: conditionId),
      RequestType.delete,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateMedicationRequest({
    required MedicationRequestModel medicationRequest,
    required String patientId,
    required String medicationRequestId,
    required String conditionId,
  }) async {
    final response = await networkClient.invoke(
      MedicationRequestEndPoints.updateMedicationRequest(medicationRequestId: medicationRequestId, patientId: patientId,conditionId: conditionId),
      RequestType.post,
      body: medicationRequest.updateJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
