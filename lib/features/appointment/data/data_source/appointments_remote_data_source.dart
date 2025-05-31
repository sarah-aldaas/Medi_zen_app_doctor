import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';
import 'package:medi_zen_app_doctor/features/appointment/data/models/appointment_model.dart';

import '../end_points/appointment_end_points.dart';


abstract class AppointmentRemoteDataSource {
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointments({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<AppointmentModel>>> getAppointmentsByPatient({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<AppointmentModel>> getAppointmentDetails({required int appointmentId});

  Future<Resource<PublicResponseModel>> finishAppointment({required int appointmentId});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final NetworkClient networkClient;

  AppointmentRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointments({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(AppointmentEndPoints.getMyAppointments, RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<AppointmentModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<AppointmentModel>.fromJson(json, 'appointments', (dataJson) => AppointmentModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<AppointmentModel>>> getAppointmentsByPatient({
    required String patientId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(AppointmentEndPoints.getAppointmentsByPatient(patientId: patientId), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<AppointmentModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<AppointmentModel>.fromJson(json, 'appointments', (dataJson) => AppointmentModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<AppointmentModel>> getAppointmentDetails({required int appointmentId}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.getDetailsAppointment(appointmentId: appointmentId), RequestType.get);

    return ResponseHandler<AppointmentModel>(response).processResponse(fromJson: (json) => AppointmentModel.fromJson(json['appointment']));
  }

  @override
  Future<Resource<PublicResponseModel>> finishAppointment({required int appointmentId}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.finishAppointment(appointmentId: appointmentId), RequestType.post);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
