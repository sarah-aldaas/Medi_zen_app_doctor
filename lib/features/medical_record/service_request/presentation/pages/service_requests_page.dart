import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_filter.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/pages/service_request_details_page.dart';

import '../../../../../base/theme/app_color.dart';
import '../cubit/service_request_cubit/service_request_cubit.dart';

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
                      icon: Icon(Icons.refresh, color: AppColors.whiteColor),
                      label: Text(
                        'serviceRequests.retryButton'.tr(context),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
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
                      color: AppColors.primaryColor.withOpacity(0.4),
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
                        color: AppColors.backGroundLogo,
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
                    _buildInfoRow(
                      context: context,
                      icon: Icons.category,
                      label: 'serviceRequests.category'.tr(context),
                      value: request.serviceRequestCategory!.display,
                    ),
                  if (request.serviceRequestPriority != null)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.priority_high,
                      label: 'serviceRequests.priority'.tr(context),
                      value: request.serviceRequestPriority!.display,
                    ),
                  if (request.serviceRequestBodySite != null)
                    _buildInfoRow(
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
              const SizedBox(height: 12.0),
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
            color: AppColors.secondaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.cyan1,
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
        return 'serviceRequests.unknownStatus'.tr(context);
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
