import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';

import '../end_points/patients_end_points.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<Resource<PaginatedResponse<PatientModel>>> listPatients({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<PatientModel>> showPatient(int id);
  Future<Resource<PatientModel>> updatePatient(PatientModel patient);
  Future<Resource<PublicResponseModel>> toggleActiveStatus(int id);
  Future<Resource<PublicResponseModel>> toggleDeceasedStatus(int id);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final NetworkClient networkClient;

  PatientRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<PatientModel>>> listPatients({
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
      PatientEndPoints.listPatients,
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<PatientModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<PatientModel>.fromJson(
        json,
        'patients',
            (dataJson) => PatientModel.fromJson(dataJson),
      ),
    );
  }

  @override
  Future<Resource<PatientModel>> showPatient(int id) async {
    final response = await networkClient.invoke(
      PatientEndPoints.showPatient(id: id),
      RequestType.get,
    );
    return ResponseHandler<PatientModel>(response).processResponse(
      fromJson: (json) => PatientModel.fromJson(json['patient']),
    );
  }

  @override
  Future<Resource<PatientModel>> updatePatient(PatientModel patient) async {
    final response = await networkClient.invoke(
      PatientEndPoints.updatePatient(id: int.parse(patient.id!)),
      RequestType.put,
      body: patient.toJson(),
    );
    return ResponseHandler<PatientModel>(response).processResponse(
      fromJson: (json) => PatientModel.fromJson(json['patient']),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> toggleActiveStatus(int id) async {
    final response = await networkClient.invoke(
      PatientEndPoints.toggleActiveStatus(id: id),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> toggleDeceasedStatus(int id) async {
    final response = await networkClient.invoke(
      PatientEndPoints.toggleDeceasedStatus(id: id),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }
}