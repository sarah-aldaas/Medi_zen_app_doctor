import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';

import '../end_points/allergy_end_points.dart';
import '../models/allergy_model.dart';

abstract class AllergyRemoteDataSource {
  Future<Resource<PaginatedResponse<AllergyModel>>> getPatientAllergies({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<PaginatedResponse<AllergyModel>>> getAppointmentAllergies({
    required String patientId,
    required String appointmentId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<AllergyModel>> getAllergyDetails({
    required String patientId,
    required String allergyId,
  });

  Future<Resource<PublicResponseModel>> createAllergy({
    required String patientId,
    required String appointmentId,
    required AllergyModel allergy,
  });

  Future<Resource<PublicResponseModel>> updateAllergy({
    required String patientId,
    required String appointmentId,
    required String allergyId,
    required AllergyModel allergy,
  });

  Future<Resource<PublicResponseModel>> deleteAllergy({
    required String patientId,
    required String allergyId,
  });
}

class AllergyRemoteDataSourceImpl implements AllergyRemoteDataSource {
  final NetworkClient networkClient;

  AllergyRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<AllergyModel>>> getPatientAllergies({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      AllergyEndPoints.forPatient(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<AllergyModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<AllergyModel>.fromJson(
            json,
            'allergies',
            (dataJson) => AllergyModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<PaginatedResponse<AllergyModel>>> getAppointmentAllergies({
    required String patientId,
    required String appointmentId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      AllergyEndPoints.byAppointment(
        patientId: patientId,
        appointmentId: appointmentId,
      ),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<AllergyModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<AllergyModel>.fromJson(
            json,
            'allergies',
            (dataJson) => AllergyModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<AllergyModel>> getAllergyDetails({
    required String patientId,
    required String allergyId,
  }) async {
    final response = await networkClient.invoke(
      AllergyEndPoints.view(patientId: patientId, allergyId: allergyId),
      RequestType.get,
    );

    return ResponseHandler<AllergyModel>(response).processResponse(
      fromJson: (json) => AllergyModel.fromJson(json['allergy']),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> createAllergy({
    required String patientId,
    required String appointmentId,
    required AllergyModel allergy,
  }) async {
    final response = await networkClient.invoke(
      AllergyEndPoints.create(patientId: patientId,appointmentId: appointmentId),
      RequestType.post,
      body: allergy.createJson(patientId: patientId),
    );

    return ResponseHandler<PublicResponseModel>(
      response,
    ).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateAllergy({
    required String patientId,
    required String appointmentId,
    required String allergyId,
    required AllergyModel allergy,
  }) async {
    final response = await networkClient.invoke(
      AllergyEndPoints.update(
        appointmentId: appointmentId,
        patientId: patientId,
        allergyId: allergyId,
      ),
      RequestType.post,
      body: allergy.createJson(patientId: patientId),
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> deleteAllergy({
    required String patientId,
    required String allergyId,
  }) async {
    final response = await networkClient.invoke(
      AllergyEndPoints.delete(patientId: patientId, allergyId: allergyId),
      RequestType.delete,
    );

    return ResponseHandler<PublicResponseModel>(
      response,
    ).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
