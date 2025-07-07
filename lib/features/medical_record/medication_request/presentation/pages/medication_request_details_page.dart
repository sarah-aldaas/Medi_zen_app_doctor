import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../conditions/data/models/conditions_filter_model.dart';
import '../../../conditions/data/models/conditions_model.dart';
import '../../../conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import '../../../conditions/presentation/pages/condition_details_page.dart';
import '../../../service_request/data/models/service_request_filter.dart';
import '../../../service_request/data/models/service_request_model.dart';
import '../../../service_request/presentation/cubit/service_request_cubit/service_request_cubit.dart';
import '../../../service_request/presentation/pages/service_request_details_page.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';
import '../widgets/delete_medication_request_dialog.dart';
import '../widgets/edit_medication_request_page.dart';

class ServiceRequestsPage extends StatefulWidget {
  final String patientId;
  final ServiceRequestFilter filter;

  const ServiceRequestsPage({
    super.key,
    required this.patientId,
    required this.filter,
  });

  @override
  _ServiceRequestsPageState createState() => _ServiceRequestsPageState();
}

class _ServiceRequestsPageState extends State<ServiceRequestsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialRequests() {
    setState(() => _isLoadingMore = false);
    context.read<ServiceRequestCubit>().getServiceRequests(
      patientId: widget.patientId,
      filters: widget.filter.toJson(),
      context: context,
    );
  }

  @override
  void didUpdateWidget(ServiceRequestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _loadInitialRequests();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ServiceRequestCubit>()
          .getServiceRequests(
            patientId: widget.patientId,
            context: context,
            filters: widget.filter.toJson(),
            loadMore: true,
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
        listener: (context, state) {
          if (state is ServiceRequestError) {
            ShowToast.showToastError(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ServiceRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          if (state is ServiceRequestError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadInitialRequests,
                      icon: const Icon(Icons.refresh),
                      label: Text('serviceRequests.retry'.tr(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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

          if (state is ServiceRequestLoaded) {
            final requests =
                state.paginatedResponse?.paginatedData?.items ?? [];
            final hasMore = state.hasMore;

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'serviceRequests.noServiceRequestsFound'.tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: requests.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < requests.length) {
                  return _buildRequestItem(context, requests[index]);
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: LoadingButton()),
                  );
                }
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, ServiceRequestModel request) {
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
                    (context) => ServiceRequestDetailsPage(
                      serviceId: request.id!,
                      patientId: widget.patientId,
                      isAppointment: false,
                    ),
              ),
            ).then((_) {
              _loadInitialRequests();
            }),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.healthCareService?.name ??
                          'serviceRequests.unknownService'.tr(context),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        request.serviceRequestStatus?.code,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      _getStatusDisplay(request.serviceRequestStatus?.code) ??
                          'serviceRequests.unknownStatus'.tr(context),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              if (request.orderDetails != null &&
                  request.orderDetails!.isNotEmpty)
                _buildInfoRow(
                  context: context,
                  icon: Icons.description,
                  label: 'serviceRequests.orderDetails'.tr(context),
                  value: request.orderDetails!,
                  color: colorScheme.onSurfaceVariant,
                ),
              if (request.reason != null && request.reason!.isNotEmpty)
                _buildInfoRow(
                  context: context,
                  icon: Icons.notes,
                  label: 'serviceRequests.reason'.tr(context),
                  value: request.reason!,
                  color: colorScheme.onSurfaceVariant,
                ),
              Wrap(
                spacing: 16.0,
                runSpacing: 8.0,
                children: [
                  if (request.serviceRequestCategory != null)
                    _buildAttributeChip(
                      context: context,
                      icon: Icons.category,
                      label: 'serviceRequests.category'.tr(context),
                      value: request.serviceRequestCategory!.display,
                    ),
                  if (request.serviceRequestPriority != null)
                    _buildAttributeChip(
                      context: context,
                      icon: Icons.priority_high,
                      label: 'serviceRequests.priority'.tr(context),
                      value: request.serviceRequestPriority!.display,
                    ),
                  if (request.serviceRequestBodySite != null)
                    _buildAttributeChip(
                      context: context,
                      icon: Icons.medical_information,
                      label: 'serviceRequests.bodySite'.tr(context),
                      value: request.serviceRequestBodySite!.display,
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (request.encounter?.appointment?.doctor != null)
                _buildInfoRow(
                  context: context,
                  icon: Icons.person,
                  label: 'serviceRequests.doctor'.tr(context),
                  value:
                      '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.given} ${request.encounter!.appointment!.doctor!.family}',
                  color: colorScheme.secondary,
                ),
              if (request.encounter?.actualStartDate != null)
                _buildInfoRow(
                  context: context,
                  icon: Icons.calendar_today,
                  label: 'serviceRequests.date'.tr(context),
                  value: _formatDate(
                    DateTime.parse(request.encounter!.actualStartDate!),
                  ),
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
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                color ??
                Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
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
                    color: Theme.of(
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

  Widget _buildAttributeChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Chip(
      avatar: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
      label: Text(
        '$label: $value',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  String? _getStatusDisplay(String? statusCode) {
    switch (statusCode) {
      case 'completed':
        return 'serviceRequests.statusCompleted'.tr(context);
      case 'in-progress':
        return 'serviceRequests.statusInProgress'.tr(context);
      case 'cancelled':
        return 'serviceRequests.statusCancelled'.tr(context);
      case 'on-hold':
        return 'serviceRequests.statusOnHold'.tr(context);
      case 'draft':
        return 'serviceRequests.statusDraft'.tr(context);
      case 'active':
        return 'serviceRequests.statusActive'.tr(context);
      case 'revoked':
        return 'serviceRequests.statusRevoked'.tr(context);
      case 'unknown':
        return 'serviceRequests.statusUnknown'.tr(context);
      default:
        return null;
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'completed':
        return Colors.green.shade600;
      case 'in-progress':
        return Colors.blue.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'on-hold':
        return Colors.orange.shade600;
      case 'draft':
        return Colors.grey.shade500;
      case 'active':
        return Colors.lightGreen.shade600;
      case 'revoked':
        return Colors.deepOrange.shade600;
      case 'unknown':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}

class ConditionsListPage extends StatefulWidget {
  final ConditionsFilterModel filter;
  final String patientId;

  const ConditionsListPage({
    super.key,
    required this.filter,
    required this.patientId,
  });

  @override
  _ConditionsListPageState createState() => _ConditionsListPageState();
}

class _ConditionsListPageState extends State<ConditionsListPage> {
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
  void didUpdateWidget(ConditionsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter ||
        widget.patientId != oldWidget.patientId) {
      _loadInitialConditions();
    }
  }

  void _loadInitialConditions() {
    setState(() => _isLoadingMore = false);
    context.read<ConditionsCubit>().getAllConditions(
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
      final future = context.read<ConditionsCubit>().getAllConditions(
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
                      "conditionsList.noConditionsFound".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadInitialConditions,
                      icon: Icon(Icons.refresh, color: AppColors.whiteColor),
                      label: Text(
                        "conditionsList.refresh".tr(context),
                        style: TextStyle(color: AppColors.whiteColor),
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
                  return _buildConditionItem(conditions[index]);
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

  Widget _buildConditionItem(ConditionsModel condition) {
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
                      isAppointment: false,
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
                  Icon(Icons.healing, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      condition.healthIssue ??
                          'conditionsList.unknownCondition'.tr(context),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              if (condition.onSetDate != null)
                _buildInfoRow(
                  context: context,
                  icon: Icons.date_range,
                  label: 'conditionsList.onsetDate'.tr(context),
                  value: DateFormat(
                    'MMM d, y',
                  ).format(DateTime.parse(condition.onSetDate!)),
                  color: colorScheme.onSurfaceVariant,
                ),
              if (condition.clinicalStatus != null)
                _buildInfoRow(
                  context: context,
                  icon: Icons.info_outline,
                  label: 'conditionsList.clinicalStatus'.tr(context),
                  value: condition.clinicalStatus!.display,
                  valueColor: _getStatusColor(condition.clinicalStatus!.code),
                ),
              if (condition.verificationStatus != null)
                _buildInfoRow(
                  context: context,
                  icon: Icons.check_circle_outline,
                  label: 'conditionsList.verificationStatus'.tr(context),
                  value: condition.verificationStatus!.display,
                  valueColor: _getVerificationStatusColor(
                    condition.verificationStatus!.code,
                  ),
                ),
              if (condition.stage != null)
                _buildInfoRow(
                  context: context,
                  icon: Icons.analytics_outlined,
                  label: 'conditionsList.stage'.tr(context),
                  value: condition.stage!.display,
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
          Icon(
            icon,
            size: 18,
            color: AppColors.secondaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
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

  Color _getStatusColor(String? statusCode) {
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

class MedicationRequestDetailsPage extends StatefulWidget {
  final String medicationRequestId;
  final String patientId;
  final bool isAppointment;

  const MedicationRequestDetailsPage({
    super.key,
    required this.medicationRequestId,
    required this.patientId,
    required this.isAppointment,
  });

  @override
  _MedicationRequestDetailsPageState createState() =>
      _MedicationRequestDetailsPageState();
}

class _MedicationRequestDetailsPageState
    extends State<MedicationRequestDetailsPage> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    context.read<MedicationRequestCubit>().getMedicationRequestDetails(
      patientId: widget.patientId,
      context: context,
      medicationRequestId: widget.medicationRequestId,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => DeleteMedicationRequestDialog(
            medicationRequestId: widget.medicationRequestId,
            patientId: widget.patientId,
            onConfirm: () {
              context
                  .read<MedicationRequestCubit>()
                  .deleteMedicationRequest(
                    medicationRequestId: widget.medicationRequestId,
                    patientId: widget.patientId,
                    context: context,
                  )
                  .then((_) {
                    if (context.read<MedicationRequestCubit>().state
                        is MedicationRequestDeleted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "medicationRequestDetailsPage.title".tr(context),
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (widget.isAppointment) ...[
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primaryColor),
              onPressed: () {
                final state = context.read<MedicationRequestCubit>().state;
                if (state is MedicationRequestDetailsSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditMedicationRequestPage(
                            medicationRequest: state.medicationRequest,
                            patientId: widget.patientId,
                          ),
                    ),
                  ).then((_) => _refresh());
                }
              },
              tooltip: 'medicationRequestDetailsPage.editTooltip'.tr(context),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: colorScheme.error),
              onPressed: _showDeleteConfirmation,
              tooltip: 'medicationRequestDetailsPage.deleteTooltip'.tr(context),
            ),
          ],
        ],
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(
              message: 'medicationRequestDetailsPage.errorToast'.tr(context),
            );
          } else if (state is MedicationRequestDeleted) {
            ShowToast.showToastSuccess(
              message: 'medicationRequestDetailsPage.deletedToast'.tr(context),
            );
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestDetailsSuccess) {
            return _buildMedicationRequestDetails(
              context,
              state.medicationRequest,
            );
          } else if (state is MedicationRequestLoading) {
            return const Center(child: LoadingPage());
          } else if (state is MedicationRequestError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "medicationRequestDetailsPage.loadErrorText".tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'medicationRequestDetailsPage.retryButton'.tr(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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
          } else {
            return Center(
              child: Text(
                "medicationRequestDetailsPage.noDetails".tr(context),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMedicationRequestDetails(
    BuildContext context,
    MedicationRequestModel request,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: colorScheme.onPrimaryContainer,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.reason ??
                            'medicationRequestDetailsPage.medicationRequestDefaultReason'
                                .tr(context),
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(
                        context,
                        request.status?.display,
                        request.status?.code,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: "medicationRequestDetailsPage.requestInformation".tr(
              context,
            ),
            icon: Icons.assignment,
            children: [
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.intentLabel",
                request.intent?.display,
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.priorityLabel",
                request.priority?.display,
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.statusReasonLabel",
                request.statusReason,
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.statusChangedLabel",
                request.statusChanged,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: "medicationRequestDetailsPage.conditionInformation".tr(
              context,
            ),
            icon: Icons.medical_information,
            children: [
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.conditionLabel",
                request.condition?.healthIssue ??
                    'medicationRequestDetailsPage.noCondition'.tr(context),
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.clinicalStatusLabel",
                request.condition?.clinicalStatus?.display,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: "medicationRequestDetailsPage.additionalInformation".tr(
              context,
            ),
            icon: Icons.more_horiz,
            children: [
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.courseOfTherapyLabel",
                request.courseOfTherapyType?.display,
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.repeatsAllowedLabel",
                request.numberOfRepeatsAllowed?.toString(),
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.noteLabel",
                request.note,
              ),
              _buildDetailRow(
                context,
                "medicationRequestDetailsPage.doNotPerformLabel",
                request.doNotPerform != null
                    ? (request.doNotPerform!
                        ? 'medicationRequestDetailsPage.yes'.tr(context)
                        : 'medicationRequestDetailsPage.no'.tr(context))
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String? statusDisplay,
    String? statusCode,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    Color statusColor = Colors.grey;

    switch (statusCode) {
      case 'active':
        statusColor = Colors.green.shade600;
        break;
      case 'on-hold':
        statusColor = Colors.orange.shade600;
        break;
      case 'cancelled':
        statusColor = Colors.red.shade600;
        break;
      case 'completed':
        statusColor = Colors.blue.shade600;
        break;
      case 'draft':
        statusColor = Colors.grey.shade500;
        break;
      case 'entered-in-error':
        statusColor = Colors.deepOrange.shade600;
        break;
      case 'stopped':
        statusColor = Colors.purple.shade600;
        break;
      case 'unknown':
        statusColor = Colors.brown.shade600;
        break;
      default:
        statusColor = colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusDisplay ??
            'medicationRequestDetailsPage.notAvailable'.tr(context),
        style: textTheme.labelMedium?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.secondaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String labelKey, String? value) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    final String localizedLabel = labelKey.tr(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$localizedLabel:",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.cyan1
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
