import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';
import 'package:medi_zen_app_doctor/features/services/data/model/health_care_services_model.dart';

import '../end_points/encounter_end_points.dart';
import '../models/encounter_model.dart';

abstract class EncounterRemoteDataSource {
  Future<Resource<PaginatedResponse<EncounterModel>>> getPatientEncounters({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<EncounterResponseModel>> getAppointmentEncounters({
    required String patientId,
    required String appointmentId,
  });

  Future<Resource<EncounterModel>> getEncounterDetails({required String patientId, required String encounterId});

  Future<Resource<PublicResponseModel>> createEncounter({required String patientId, required EncounterModel encounter,required String appointmentId});

  Future<Resource<EncounterModel>> updateEncounter({required String patientId, required String encounterId, required EncounterModel encounter});

  Future<Resource<PublicResponseModel>> finalizeEncounter({required int patientId, required int encounterId});

  Future<Resource<PublicResponseModel>> assignService({required int encounterId, required int serviceId});

  Future<Resource<PublicResponseModel>> unassignService({required int encounterId, required int serviceId});

  Future<Resource<List<HealthCareServiceModel>>> getAppointmentServices({required int patientId, required int appointmentId});
}

class EncounterRemoteDataSourceImpl implements EncounterRemoteDataSource {
  final NetworkClient networkClient;

  EncounterRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<EncounterModel>>> getPatientEncounters({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(EncounterEndPoints.forPatient(patientId: patientId), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<EncounterModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<EncounterModel>.fromJson(json, 'encounters', (dataJson) => EncounterModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<EncounterResponseModel>> getAppointmentEncounters({
    required String patientId,
    required String appointmentId,
  }) async {
    final response = await networkClient.invoke(
      EncounterEndPoints.forAppointment(patientId: patientId, appointmentId: appointmentId),
      RequestType.get,
    );

    return ResponseHandler<EncounterResponseModel>(
      response,
    ).processResponse(fromJson: (json) => EncounterResponseModel.fromJson(json));
  }

  @override
  Future<Resource<EncounterModel>> getEncounterDetails({required String patientId, required String encounterId}) async {
    final response = await networkClient.invoke(EncounterEndPoints.details(patientId: patientId, encounterId: encounterId), RequestType.get);

    return ResponseHandler<EncounterModel>(response).processResponse(fromJson: (json) => EncounterModel.fromJson(json['encounter']));
  }

  @override
  Future<Resource<PublicResponseModel>> createEncounter({required String patientId, required EncounterModel encounter,required String appointmentId}) async {
    final response = await networkClient.invoke(EncounterEndPoints.create(patientId: patientId,appointmentId: appointmentId), RequestType.post, body: encounter.createJson(appointmentId: appointmentId));

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<EncounterModel>> updateEncounter({required String patientId, required String encounterId, required EncounterModel encounter}) async {
    final response = await networkClient.invoke(
      EncounterEndPoints.update(patientId: patientId, encounterId: encounterId),
      RequestType.post,
      body: encounter.updateJson(),
    );

    return ResponseHandler<EncounterModel>(response).processResponse(fromJson: (json) => EncounterModel.fromJson(json['encounter']));
  }

  @override
  Future<Resource<PublicResponseModel>> finalizeEncounter({required int patientId, required int encounterId}) async {
    final response = await networkClient.invoke(EncounterEndPoints.finalize(patientId: patientId, encounterId: encounterId), RequestType.post);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> assignService({required int encounterId, required int serviceId}) async {
    final response = await networkClient.invoke(
      EncounterEndPoints.assignService,
      RequestType.post,
      body: {'encounter_id': encounterId, 'health_care_service_id': serviceId},
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> unassignService({required int encounterId, required int serviceId}) async {
    final response = await networkClient.invoke(
      EncounterEndPoints.unassignService,
      RequestType.post,
      body: {'encounter_id': encounterId, 'health_care_service_id': serviceId},
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<List<HealthCareServiceModel>>> getAppointmentServices({required int patientId, required int appointmentId}) async {
    final response = await networkClient.invoke(EncounterEndPoints.appointmentServices(patientId: patientId, appointmentId: appointmentId), RequestType.get);

    return ResponseHandler<List<HealthCareServiceModel>>(
      response,
    ).processResponse(fromJson: (json) => (json['health_care_services'] as List).map((serviceJson) => HealthCareServiceModel.fromJson(serviceJson)).toList());
  }
}
