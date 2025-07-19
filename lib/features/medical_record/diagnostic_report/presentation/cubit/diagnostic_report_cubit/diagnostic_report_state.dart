part of 'diagnostic_report_cubit.dart';

sealed class DiagnosticReportState {
  const DiagnosticReportState();
}

final class DiagnosticReportInitial extends DiagnosticReportState {}

class DiagnosticReportLoading extends DiagnosticReportState {
  final bool isLoadMore;

  const DiagnosticReportLoading({this.isLoadMore = false});
}

class DiagnosticReportSuccess extends DiagnosticReportState {
  final bool hasMore;
  final PaginatedResponse<DiagnosticReportModel> paginatedResponse;

  const DiagnosticReportSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class DiagnosticReportDetailsSuccess extends DiagnosticReportState {
  final DiagnosticReportModel diagnosticReport;

  const DiagnosticReportDetailsSuccess({
    required this.diagnosticReport,
  });
}


class DiagnosticReportOperationSuccess extends DiagnosticReportState {}
class DiagnosticReportOperationLoading extends DiagnosticReportState {}

  class DiagnosticReportError extends DiagnosticReportState {
  final String error;

  const DiagnosticReportError({required this.error});
}