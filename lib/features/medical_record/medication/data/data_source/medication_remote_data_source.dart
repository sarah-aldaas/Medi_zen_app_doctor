import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/medication_end_points.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedication({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  });

  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedicationForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  });

  Future<Resource<MedicationModel>> getDetailsMedication({required String medicationId, required String patientId});

  Future<Resource<PublicResponseModel>> createMedication({required MedicationModel medication, required String patientId});

  Future<Resource<PublicResponseModel>> updateMedication({required MedicationModel medication, required String patientId, required String medicationId});

  Future<Resource<PublicResponseModel>> deleteMedication({required MedicationModel medication, required String patientId, required String medicationId});

  Future<Resource<PublicResponseModel>> changeStatusMedication({required String patientId, required String medicationId, required String statusId});

  Future<Resource<List<MedicationModel>>> getAllMedicationForMedicationRequest({required String medicationRequestId, required String patientId});
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final NetworkClient networkClient;

  MedicationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedication({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(MedicationEndPoints.getAllMedication(patientId: patientId), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<MedicationModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<MedicationModel>.fromJson(json, 'medications', (dataJson) => MedicationModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedicationForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      MedicationEndPoints.getAllMedicationForAppointment(appointmentId: appointmentId, patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<MedicationModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<MedicationModel>.fromJson(json, 'medications', (dataJson) => MedicationModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<MedicationModel>> getDetailsMedication({required String medicationId, required String patientId}) async {
    final response = await networkClient.invoke(MedicationEndPoints.getDetailsMedication(medicationId: medicationId, patientId: patientId), RequestType.get);
    return ResponseHandler<MedicationModel>(response).processResponse(fromJson: (json) => MedicationModel.fromJson(json['medication']));
  }

  @override
  Future<Resource<List<MedicationModel>>> getAllMedicationForMedicationRequest({required String medicationRequestId, required String patientId}) async {
    final response = await networkClient.invoke(
      MedicationEndPoints.getAllMedicationForMedicationRequest(medicationRequestId: medicationRequestId, patientId: patientId),
      RequestType.get,
    );

    return ResponseHandler<List<MedicationModel>>(
      response,
    ).processResponse(fromJson: (json) => List<MedicationModel>.from(json['medications'].map((x) => MedicationModel.fromJson(x))));
  }

  @override
  Future<Resource<PublicResponseModel>> changeStatusMedication({required String patientId, required String medicationId, required String statusId}) async {
    final response = await networkClient.invoke(MedicationEndPoints.changeStatusMedication(medicationId: medicationId, patientId: patientId), RequestType.post,body: {
      "status_id":statusId
    });
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> createMedication({required MedicationModel medication, required String patientId}) async {
    final response = await networkClient.invoke(MedicationEndPoints.createMedication(patientId: patientId), RequestType.post, body: medication.createJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteMedication({required MedicationModel medication, required String patientId, required String medicationId}) async {
    final response = await networkClient.invoke(MedicationEndPoints.deleteMedication(medicationId: medicationId, patientId: patientId), RequestType.delete);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateMedication({required MedicationModel medication, required String patientId, required String medicationId}) async {
    final response = await networkClient.invoke(
      MedicationEndPoints.updateMedication(patientId: patientId, medicationId: medicationId),
      RequestType.post,
      body: medication.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
