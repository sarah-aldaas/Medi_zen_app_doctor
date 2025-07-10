import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/diagnostic_report_filter_model.dart';
import '../../data/models/diagnostic_report_model.dart';
import '../cubit/diagnostic_report_cubit/diagnostic_report_cubit.dart';
import 'diagnostic_report_details_page.dart';

class DiagnosticReportListOfAppointmentPage extends StatefulWidget {
  final DiagnosticReportFilterModel filter;
  final String appointmentId;
  const DiagnosticReportListOfAppointmentPage({
    super.key,
    required this.filter,
    required this.appointmentId,
  });

  @override
  _DiagnosticReportListOfAppointmentPageState createState() =>
      _DiagnosticReportListOfAppointmentPageState();
}

class _DiagnosticReportListOfAppointmentPageState
    extends State<DiagnosticReportListOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DiagnosticReportListOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialReports();
    }
  }

  void _loadInitialReports() {
    _isLoadingMore = false;
    context.read<DiagnosticReportCubit>().getDiagnosticReportsForAppointment(
      context: context,
      filters: widget.filter.toJson(),
      appointmentId: widget.appointmentId,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<DiagnosticReportCubit>()
          .getDiagnosticReportsForAppointment(
            loadMore: true,
            context: context,
            appointmentId: widget.appointmentId,
            filters: widget.filter.toJson(),
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DiagnosticReportCubit, DiagnosticReportState>(
        listener: (context, state) {
          if (state is DiagnosticReportError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is DiagnosticReportLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final reports =
              state is DiagnosticReportSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : [];
          final hasMore =
              state is DiagnosticReportSuccess ? state.hasMore : false;

          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.blueGrey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "diagnosticListAppointmentPage.diagnosticReportListAppointment_noReportsFound"
                        .tr(context),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "diagnosticListAppointmentPage.diagnosticReportListAppointment_tapToRefresh"
                        .tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey[400]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _loadInitialReports(),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      "diagnosticListAppointmentPage.diagnosticReportListAppointment_refresh"
                          .tr(context),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadInitialReports();
            },
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: reports.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < reports.length) {
                  return _buildReportItem(reports[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportItem(DiagnosticReportModel report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DiagnosticReportDetailsPage(
                      diagnosticReportId: report.id!,
                    ),
              ),
            ).then((value) {
              _loadInitialReports();
            }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.name ??
                          'diagnosticListAppointmentPage.diagnosticReportListAppointment_unnamedReport'
                              .tr(context),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.green),
                ],
              ),
              Divider(height: 20, thickness: 1, color: Colors.grey[200]),
              const Gap(10),

              if (report.note != null && report.note!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.note,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_note'
                          .tr(context),
                  value: report.note!,
                  color: Colors.blue,
                ),

              if (report.condition != null) ...[
                _buildInfoRow(
                  icon: Icons.medical_services,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_condition'
                          .tr(context),
                  value:
                      report.condition!.healthIssue ??
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_unknownCondition'
                          .tr(context),
                  color: Colors.teal,
                ),

                if (report.condition!.clinicalStatus != null)
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_clinicalStatus'
                            .tr(context),
                    value: report.condition!.clinicalStatus!.display,
                    color: _getStatusColor(
                      report.condition!.clinicalStatus!.code,
                    ),
                  ),

                if (report.condition!.verificationStatus != null)
                  _buildInfoRow(
                    icon: Icons.verified,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_verificationStatus'
                            .tr(context),
                    value: report.condition!.verificationStatus!.display,
                    color: _getStatusColor(
                      report.condition!.verificationStatus!.code,
                    ),
                  ),

                if (report.condition!.bodySite != null)
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_bodySite'
                            .tr(context),
                    value: report.condition!.bodySite!.display,
                    color: Colors.deepPurple,
                  ),

                if (report.condition!.stage != null)
                  _buildInfoRow(
                    icon: Icons.stacked_line_chart,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_stage'
                            .tr(context),
                    value: report.condition!.stage!.display,
                    color: Colors.orange,
                  ),

                if (report.condition!.onSetDate != null)
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label:
                        'diagnosticListAppointmentPage.diagnosticReportListAppointment_onset_date'
                            .tr(context),
                    value: _formatDate(report.condition!.onSetDate!),
                    color: Colors.brown,
                  ),
              ],

              if (report.conclusion != null && report.conclusion!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.assignment_turned_in,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_conclusion'
                          .tr(context),
                  value: report.conclusion!,
                  color: Colors.indigo,
                  maxLines: 3,
                ),

              if (report.status != null)
                _buildInfoRow(
                  icon: Icons.star,
                  label:
                      'diagnosticListAppointmentPage.diagnosticReportListAppointment_reportStatus'
                          .tr(context),
                  value: report.status!.display,
                  color: _getStatusColor(report.status!.code),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.label,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.blueGrey[600]),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd,EEEE').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'final':
      case 'completed':
      case 'condition_confirmed':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'preliminary':
        return Colors.blue;
      case 'amended':
        return Colors.purple;
      case 'corrected':
        return Colors.teal;
      case 'appended':
        return Colors.indigo;
      case 'cancelled':
        return Colors.red;
      case 'entered-in-error':
        return Colors.redAccent;
      case 'unknown':
        return Colors.grey;
      case 'condition_active':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }
}
