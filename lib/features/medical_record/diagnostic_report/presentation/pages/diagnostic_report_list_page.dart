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

class DiagnosticReportListPage extends StatefulWidget {
  final DiagnosticReportFilterModel filter;
  final String patientId;
  const DiagnosticReportListPage({
    super.key,
    required this.filter,
    required this.patientId,
  });

  @override
  _DiagnosticReportListPageState createState() =>
      _DiagnosticReportListPageState();
}

class _DiagnosticReportListPageState extends State<DiagnosticReportListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // طباعة patientId للتحقق
    print('DiagnosticReportListPage patientId: ${widget.patientId}');
    _loadInitialReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DiagnosticReportListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialReports();
    }
  }

  void _loadInitialReports() {
    _isLoadingMore = false;
    // التأكد من أن patientId قابل للتحويل إلى int قبل تمريره
    try {
      context.read<DiagnosticReportCubit>().getAllDiagnosticReports(
        patientId: int.parse(
          widget.patientId,
        ), // <-- تمرير patientId بعد التحويل
        context: context,
        filters: widget.filter.toJson(),
      );
    } catch (e) {
      // التعامل مع الخطأ إذا كان patientId غير صالح (ليس رقمًا)
      ShowToast.showToastError(
        message: 'Invalid Patient ID: ${widget.patientId}',
      );
      print('Error parsing patientId in _loadInitialReports: $e');
      // يمكنك هنا إظهار رسالة خطأ للمستخدم أو اتخاذ إجراء آخر
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      try {
        context
            .read<DiagnosticReportCubit>()
            .getAllDiagnosticReports(
              loadMore: true,
              patientId: int.parse(
                widget.patientId,
              ), // <-- تمرير patientId بعد التحويل
              context: context,
              filters: widget.filter.toJson(),
            )
            .then((_) => setState(() => _isLoadingMore = false));
      } catch (e) {
        ShowToast.showToastError(
          message:
              'Error loading more reports. Invalid Patient ID: ${widget.patientId}',
        );
        print('Error parsing patientId in _scrollListener: $e');
        setState(
          () => _isLoadingMore = false,
        ); // إيقاف مؤشر التحميل في حالة الخطأ
      }
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
                    "diagnosticReportList.diagnosticReport_noReportsFound".tr(
                      context,
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "diagnosticReportList.diagnosticReport_tapToRefresh".tr(
                      context,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey[400]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _loadInitialReports(),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      "diagnosticReportList.diagnosticReport_refresh".tr(
                        context,
                      ),
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
                          'diagnosticReportList.diagnosticReport_unnamedReport'
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
                  label: 'diagnosticReportList.diagnosticReport_note'.tr(
                    context,
                  ),
                  value: report.note!,
                ),

              if (report.condition != null) ...[
                _buildInfoRow(
                  icon: Icons.medical_services,
                  label: 'diagnosticReportList.diagnosticReport_condition'.tr(
                    context,
                  ),
                  value:
                      report.condition!.healthIssue ??
                      'diagnosticReportList.diagnosticReport_unknownCondition'
                          .tr(context),
                ),

                if (report.condition!.clinicalStatus != null)
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label:
                        'diagnosticReportList.diagnosticReport_clinicalStatus'
                            .tr(context),
                    value: report.condition!.clinicalStatus!.display,
                  ),

                if (report.condition!.verificationStatus != null)
                  _buildInfoRow(
                    icon: Icons.verified,
                    label:
                        'diagnosticReportList.diagnosticReport_verificationStatus'
                            .tr(context),
                    value: report.condition!.verificationStatus!.display,
                  ),

                if (report.condition!.bodySite != null)
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'diagnosticReportList.diagnosticReport_bodySite'.tr(
                      context,
                    ),
                    value: report.condition!.bodySite!.display,
                  ),

                if (report.condition!.stage != null)
                  _buildInfoRow(
                    icon: Icons.stacked_line_chart,
                    label: 'diagnosticReportList.diagnosticReport_stage'.tr(
                      context,
                    ),
                    value: report.condition!.stage!.display,
                  ),

                if (report.condition!.onSetDate != null)
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'diagnosticReportList.diagnosticReport_onset_date'
                        .tr(context),
                    value: _formatDate(report.condition!.onSetDate!),
                  ),
              ],

              if (report.conclusion != null && report.conclusion!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.assignment_turned_in,
                  label: 'diagnosticReportList.diagnosticReport_conclusion'.tr(
                    context,
                  ),
                  value: report.conclusion!,
                  maxLines: 3,
                ),

              if (report.status != null)
                _buildInfoRow(
                  icon: Icons.star,
                  label: 'diagnosticReportList.diagnosticReport_reportStatus'
                      .tr(context),
                  value: report.status!.display,
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
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.secondaryColor.withOpacity(0.7),
          ),
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
      return DateFormat('MMM dd, yyyy').format(dateTime);
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
