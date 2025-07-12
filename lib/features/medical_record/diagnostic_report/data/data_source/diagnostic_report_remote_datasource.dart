import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/diagnostic_report_end_points.dart';
import '../models/diagnostic_report_model.dart';

abstract class DiagnosticReportRemoteDataSource {
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>> getAllDiagnosticReport({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  });

  Future<Resource<PaginatedResponse<DiagnosticReportModel>>> getAllDiagnosticReportOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  });

  Future<Resource<DiagnosticReportModel>> getDetailsDiagnosticReport({required String diagnosticReportId, required String patientId});

  Future<Resource<PublicResponseModel>> makeAsFinalDiagnosticReport({required String diagnosticReportId, required String patientId});

  Future<Resource<PublicResponseModel>> deleteDiagnosticReport({required String diagnosticReportId, required String patientId});

  Future<Resource<PublicResponseModel>> updateDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
    required DiagnosticReportModel diagnostic,
  });

  Future<Resource<PublicResponseModel>> createDiagnosticReport({required String patientId, required DiagnosticReportModel diagnostic});

  Future<Resource<DiagnosticReportModel>> getDiagnosticReportOfCondition({required String conditionId, required String patientId});
}

class DiagnosticReportRemoteDataSourceImpl implements DiagnosticReportRemoteDataSource {
  final NetworkClient networkClient;

  DiagnosticReportRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>> getAllDiagnosticReport({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getAllDiagnosticReport(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(json, 'diagnostic_reports', (dataJson) => DiagnosticReportModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>> getAllDiagnosticReportOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getAllDiagnosticReportOfAppointment(appointmentId: appointmentId, patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(json, 'diagnostic_reports', (dataJson) => DiagnosticReportModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<DiagnosticReportModel>> getDetailsDiagnosticReport({required String diagnosticReportId, required String patientId}) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getDetailsDiagnosticReport(diagnosticReportId: diagnosticReportId, patientId: patientId),
      RequestType.get,
    );
    return ResponseHandler<DiagnosticReportModel>(response).processResponse(fromJson: (json) => DiagnosticReportModel.fromJson(json['diagnostic_report']));
  }

  @override
  Future<Resource<DiagnosticReportModel>> getDiagnosticReportOfCondition({required String conditionId, required String patientId}) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getAllDiagnosticReportOfCondition(conditionId: conditionId, patientId: patientId),
      RequestType.get,
    );
    return ResponseHandler<DiagnosticReportModel>(response).processResponse(fromJson: (json) => DiagnosticReportModel.fromJson(json['diagnostic_report']));
  }

  @override
  Future<Resource<PublicResponseModel>> createDiagnosticReport({required String patientId, required DiagnosticReportModel diagnostic}) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.createDiagnosticReport(patientId: patientId),
      body: diagnostic.createJson(),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteDiagnosticReport({required String diagnosticReportId, required String patientId}) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.deleteDiagnosticReport(patientId: patientId, diagnosticReportId: diagnosticReportId),
      RequestType.delete,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> makeAsFinalDiagnosticReport({required String diagnosticReportId, required String patientId}) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.makeAsFinal(patientId: patientId, diagnosticReportId: diagnosticReportId),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
    required DiagnosticReportModel diagnostic,
  }) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.updateDiagnosticReport(patientId: patientId, diagnosticReportId: diagnosticReportId),
      body: diagnostic.createJson(),
      RequestType.post,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
