import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/conditions_filter_model.dart';
import '../../data/models/conditions_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';
import '../widgets/create_condition_page.dart';
import 'condition_details_page.dart';

class ConditionsListOfAppointmentPage extends StatefulWidget {
  final ConditionsFilterModel filter;
  final String appointmentId;
  final String patientId;

  const ConditionsListOfAppointmentPage({
    super.key,
    required this.filter,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  _ConditionsListOfAppointmentPageState createState() =>
      _ConditionsListOfAppointmentPageState();
}

class _ConditionsListOfAppointmentPageState
    extends State<ConditionsListOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialConditions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConditionsListOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter ||
        widget.patientId != oldWidget.patientId) {
      _loadInitialConditions();
    }
  }

  void _loadInitialConditions() {
    setState(() => _isLoadingMore = false);
    context.read<ConditionsCubit>().getConditionsForAppointment(
      appointmentId: widget.appointmentId,
      patientId: widget.patientId,
      context: context,
      filters: widget.filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future = context
          .read<ConditionsCubit>()
          .getConditionsForAppointment(
            appointmentId: widget.appointmentId,
            patientId: widget.patientId,
            loadMore: true,
            context: context,
            filters: widget.filter.toJson(),
          );

      future.then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        CreateConditionPage(patientId: widget.patientId),
              ),
            ).then((_) => _loadInitialConditions()),
        child: Icon(Icons.add, color: AppColors.whiteColor),
        backgroundColor: AppColors.primaryColor,
        tooltip: 'conditionsOfAppointment.addCondition'.tr(context),
      ),
      body: BlocConsumer<ConditionsCubit, ConditionsState>(
        listener: (context, state) {
          if (state is ConditionsError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is ConditionCreatedSuccess ||
              state is ConditionUpdatedSuccess ||
              state is ConditionDeletedSuccess) {
            _loadInitialConditions();
          }
        },
        builder: (context, state) {
          if (state is ConditionsLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final conditions =
              state is ConditionsSuccess
                  ? state.paginatedResponse.paginatedData?.items ?? []
                  : [];
          final hasMore = state is ConditionsSuccess ? state.hasMore : false;

          if (conditions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "conditionsOfAppointment.noConditionsFound".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _loadInitialConditions(),
                      icon: Icon(Icons.refresh, color: AppColors.whiteColor),
                      label: Text(
                        "conditionsOfAppointment.refresh".tr(context),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadInitialConditions(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: conditions.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < conditions.length) {
                  return _buildConditionItem(context, conditions[index]);
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

  Widget _buildConditionItem(BuildContext context, ConditionsModel condition) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ConditionDetailsPage(
                      conditionId: condition.id!,
                      patientId: widget.patientId,
                      isAppointment: true,
                    ),
              ),
            ).then((_) => _loadInitialConditions()),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.healing,
                    color: AppColors.green.withOpacity(0.9),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      condition.healthIssue ??
                          'conditionsOfAppointment.unknownCondition'.tr(
                            context,
                          ),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              _buildInfoRow(
                context: context,
                icon: Icons.date_range,
                label: 'conditionsOfAppointment.onset'.tr(context),
                value:
                    condition.onSetDate != null
                        ? DateFormat(
                          'MMM d, y',
                        ).format(DateTime.parse(condition.onSetDate!))
                        : 'N/A',
                color: colorScheme.onSurfaceVariant,
              ),
              _buildInfoRow(
                context: context,
                icon: Icons.info_outline,
                label: 'conditionsOfAppointment.status'.tr(context),
                value: condition.clinicalStatus?.display ?? 'N/A',
                valueColor: _getClinicalStatusColor(
                  condition.clinicalStatus?.code,
                ),
              ),
              _buildInfoRow(
                context: context,
                icon: Icons.check_circle_outline,
                label: 'conditionsOfAppointment.verification'.tr(context),
                value: condition.verificationStatus?.display ?? 'N/A',
                valueColor: _getVerificationStatusColor(
                  condition.verificationStatus?.code,
                ),
              ),
              _buildInfoRow(
                context: context,
                icon: Icons.analytics_outlined,
                label: 'conditionsOfAppointment.stage'.tr(context),
                value: condition.stage?.display ?? 'N/A',
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    Color? valueColor,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color:
                        valueColor ??
                        Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getClinicalStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
        return Colors.green.shade600;
      case 'recurrence':
        return Colors.blue.shade600;
      case 'inactive':
        return Colors.orange.shade600;
      case 'remission':
        return Colors.lightGreen.shade600;
      case 'resolved':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  Color _getVerificationStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'unconfirmed':
        return Colors.orange.shade600;
      case 'provisional':
        return Colors.blue.shade600;
      case 'differential':
        return Colors.purple.shade600;
      case 'confirmed':
        return Colors.green.shade600;
      case 'refuted':
        return Colors.red.shade600;
      case 'entered-in-error':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade400;
    }
  }
}
