import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/diagnostic_report_end_points.dart';
import '../models/diagnostic_report_model.dart';

abstract class DiagnosticReportRemoteDataSource {
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReport({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String patientId,
  });

  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReportOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  });

  Future<Resource<DiagnosticReportModel>> getDetailsDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  });

  Future<Resource<DiagnosticReportModel>> getDiagnosticReportOfCondition({
    required String conditionId,
    required String patientId,
  });
}

class DiagnosticReportRemoteDataSourceImpl
    implements DiagnosticReportRemoteDataSource {
  final NetworkClient networkClient;

  DiagnosticReportRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReport({
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
      DiagnosticReportEndPoints.getAllDiagnosticReport(patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(
            json,
            'diagnostic_reports',
            (dataJson) => DiagnosticReportModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReportOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String patientId,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getAllDiagnosticReportOfAppointment(
        appointmentId: appointmentId,
        patientId: patientId,
      ),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(
            json,
            'diagnostic_reports',
            (dataJson) => DiagnosticReportModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<DiagnosticReportModel>> getDetailsDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  }) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getDetailsDiagnosticReport(
        diagnosticReportId: diagnosticReportId,
        patientId: patientId,
      ),
      RequestType.get,
    );
    return ResponseHandler<DiagnosticReportModel>(response).processResponse(
      fromJson:
          (json) => DiagnosticReportModel.fromJson(json['diagnostic_report']),
    );
  }

  @override
  Future<Resource<DiagnosticReportModel>> getDiagnosticReportOfCondition({
    required String conditionId,
    required String patientId,
  }) {
    // TODO: implement getDiagnosticReportOfCondition
    throw UnimplementedError();
  }

  //
  // @override
  // Future<Resource<DiagnosticReportModel>> getDiagnosticReportOfCondition({
  //   required String patientId,
  //   required String conditionId,
  // }) async {
  //   final response = await networkClient.invoke(
  //     DiagnosticReportEndPoints.getAllDiagnosticReportOfCondition(
  //       conditionId: conditionId,
  //       patientId: patientId,
  //     ),
  //     RequestType.get,
  //   );
  //   return ResponseHandler<DiagnosticReportModel>(response).processResponse(
  //     fromJson:
  //         (json) => DiagnosticReportModel.fromJson(json['diagnostic_report']),
  //   );
}
