import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/service_request_filter.dart';
import '../../data/models/service_request_model.dart';
import '../cubit/service_request_cubit/service_request_cubit.dart';
import '../widgets/create_service_request_page.dart';
import 'service_request_details_page.dart';

class ServiceRequestsOfAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final String patientId;
  final ServiceRequestFilter filter;

  const ServiceRequestsOfAppointmentPage({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.filter,
  });

  @override
  _ServiceRequestsOfAppointmentPageState createState() =>
      _ServiceRequestsOfAppointmentPageState();
}

class _ServiceRequestsOfAppointmentPageState
    extends State<ServiceRequestsOfAppointmentPage> {
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
    context.read<ServiceRequestCubit>().getServiceRequestsOfAppointment(
      appointmentId: widget.appointmentId,
      patientId: widget.patientId,
      filters: widget.filter.toJson(),
      context: context,
    );
  }

  @override
  void didUpdateWidget(ServiceRequestsOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _loadInitialRequests();
      _scrollController.jumpTo(0.0);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ServiceRequestCubit>()
          .getServiceRequestsOfAppointment(
            appointmentId: widget.appointmentId,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateServiceRequestPage(
                      patientId: widget.patientId,
                      appointmentId: widget.appointmentId,
                    ),
              ),
            ).then((_) => _loadInitialRequests()),
        child: Icon(Icons.add, color: AppColors.whiteColor),

        tooltip: 'serviceRequestsOfAppointment.createServiceRequest'.tr(
          context,
        ),
      ),
      body: BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
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
                      color: colorScheme.error,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'serviceRequestsOfAppointment.errorLoading'.tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadInitialRequests,
                      icon: Icon(Icons.refresh,color: AppColors.whiteColor),
                      label: Text(
                        'serviceRequestsOfAppointment.retryButton'.tr(context),
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
                      'serviceRequestsOfAppointment.noServiceRequestsFound'.tr(
                        context,
                      ),
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.whiteColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _loadInitialRequests(),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        "serviceRequestsOfAppointment.refresh".tr(context),
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
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadInitialRequests(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: requests.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < requests.length) {
                    return _buildRequestItem(context, requests[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ServiceRequestDetailsPage(
                      serviceId: request.id!,
                      patientId: widget.patientId,
                      isAppointment: true,
                    ),
              ),
            ).then((_) {
              _loadInitialRequests();
            }),
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
                          'serviceRequestsOfAppointment.unknownService'.tr(
                            context,
                          ),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildStatusChip(context, request.serviceRequestStatus?.code),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              if (request.orderDetails != null &&
                  request.orderDetails!.isNotEmpty)
                _buildInfoRow(
                  context,
                  Icons.description,
                  'serviceRequestsOfAppointment.orderDetails'.tr(context),
                  request.orderDetails!,
                ),
              if (request.reason != null && request.reason!.isNotEmpty)
                _buildInfoRow(
                  context,
                  Icons.lightbulb_outline,
                  'serviceRequestsOfAppointment.reason'.tr(context),
                  request.reason!,
                ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 16.0,
                runSpacing: 8.0,
                children: [
                  if (request.serviceRequestCategory != null)
                    _buildCompactInfo(
                      context,
                      Icons.category,
                      'serviceRequestsOfAppointment.category'.tr(context),
                      request.serviceRequestCategory!.display,
                    ),
                  if (request.serviceRequestPriority != null)
                    _buildCompactInfo(
                      context,
                      Icons.priority_high,
                      'serviceRequestsOfAppointment.priority'.tr(context),
                      request.serviceRequestPriority!.display,
                    ),
                  if (request.serviceRequestBodySite != null)
                    _buildCompactInfo(
                      context,
                      Icons.accessibility_new,
                      'serviceRequestsOfAppointment.bodySite'.tr(context),
                      request.serviceRequestBodySite!.display,
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (request.encounter?.appointment?.doctor != null)
                _buildInfoRow(
                  context,
                  Icons.person,
                  'serviceRequestsOfAppointment.doctor'.tr(context),
                  '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.given} ${request.encounter!.appointment!.doctor!.family}',
                ),
              if (request.encounter?.actualStartDate != null)
                _buildInfoRow(
                  context,
                  Icons.calendar_today,
                  'serviceRequestsOfAppointment.date'.tr(context),
                  _formatDate(
                    DateTime.parse(request.encounter!.actualStartDate!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label:",
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String? statusCode) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    Color chipColor = Colors.grey;
    Color textColor = Colors.white;
    String displayText = 'serviceRequestsOfAppointment.unknownStatus'.tr(
      context,
    );

    switch (statusCode) {
      case 'completed':
        chipColor = Colors.green.shade600;
        displayText = 'serviceRequestsOfAppointment.statusCompleted'.tr(
          context,
        );
        break;
      case 'in-progress':
        chipColor = Colors.blue.shade600;
        displayText = 'serviceRequestsOfAppointment.statusInProgress'.tr(
          context,
        );
        break;
      case 'cancelled':
        chipColor = Colors.red.shade600;
        displayText = 'serviceRequestsOfAppointment.statusCancelled'.tr(
          context,
        );
        break;
      case 'on-hold':
        chipColor = Colors.orange.shade600;
        displayText = 'serviceRequestsOfAppointment.statusOnHold'.tr(context);
        break;
      case 'revoked':
        chipColor = Colors.purple.shade600;
        displayText = 'Revoked';
        break;
      case 'draft':
        chipColor = Colors.grey.shade500;
        displayText = 'Draft';
        break;
      default:
        chipColor = colorScheme.outline;
        textColor = colorScheme.onSurface;
    }

    if (chipColor.computeLuminance() > 0.5) {
      textColor = Colors.black;
    }

    return Chip(
      label: Text(
        displayText,
        style: textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}
