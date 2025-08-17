import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';

import '../../../../../base/services/di/injection_container_common.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../../data/data_source/service_request_remote_data_source.dart';
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
    context.read<EncounterCubit>().getAppointmentEncounters(
      patientId: widget.patientId,
      appointmentId: widget.appointmentId,
    );
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

  bool _hasEncounters(EncounterState state) {
    if (state is EncounterError) {
      return false;
    }

    final encounters =
        state is EncounterDetailsSuccess
            ? [state.encounter]
            : state is EncounterListSuccess
            ? state.paginatedResponse.paginatedData!.items
            : <EncounterModel>[];
    return encounters.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocBuilder<EncounterCubit, EncounterState>(
      builder: (context, _state) {
        final hasEncounters = _hasEncounters(_state);
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              if (hasEncounters) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateServiceRequestPage(
                          patientId: widget.patientId,
                          appointmentId: widget.appointmentId,
                        ),
                  ),
                ).then((_) => _loadInitialRequests());
              } else {
                ShowToast.showToastInfo(
                  message: 'serviceRequestsOfAppointment.should_add_encounter'
                      .tr(context),
                );
              }
            },

            tooltip: 'serviceRequestsOfAppointment.createServiceRequest'.tr(
              context,
            ),
            child:
                _state is EncounterLoading
                    ? LoadingButton(isWhite: true)
                    : Icon(Icons.add, color: AppColors.whiteColor),
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
                          state.message,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _loadInitialRequests,
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context)
                                .outlinedButtonTheme
                                .style
                                ?.foregroundColor
                                ?.resolve({MaterialState.pressed}),
                          ),
                          label: Text(
                            "encounterPage.try_again".tr(context),
                            style:
                                Theme.of(context)
                                            .outlinedButtonTheme
                                            .style
                                            ?.foregroundColor
                                            ?.resolve({
                                              MaterialState.pressed,
                                            }) !=
                                        null
                                    ? TextStyle(
                                      color: Theme.of(context)
                                          .outlinedButtonTheme
                                          .style!
                                          .foregroundColor!
                                          .resolve({MaterialState.pressed}),
                                    )
                                    : null,
                          ),
                          style: Theme.of(context).outlinedButtonTheme.style,
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
                          Icons.folder_open,
                          size: 80,
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'serviceRequestsOfAppointment.noServiceRequestsFound'
                              .tr(context),
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _loadInitialRequests,
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context)
                                .outlinedButtonTheme
                                .style
                                ?.foregroundColor
                                ?.resolve({MaterialState.pressed}),
                          ),
                          label: Text(
                            "encounterPage.try_again".tr(context),
                            style:
                                Theme.of(context)
                                            .outlinedButtonTheme
                                            .style
                                            ?.foregroundColor
                                            ?.resolve({
                                              MaterialState.pressed,
                                            }) !=
                                        null
                                    ? TextStyle(
                                      color: Theme.of(context)
                                          .outlinedButtonTheme
                                          .style!
                                          .foregroundColor!
                                          .resolve({MaterialState.pressed}),
                                    )
                                    : null,
                          ),
                          style: Theme.of(context).outlinedButtonTheme.style,
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
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: LoadingButton()),
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
      },
    );
  }

  Widget _buildRequestItem(BuildContext context, ServiceRequestModel request) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider(
                    create:
                        (context) => ServiceRequestCubit(
                          networkInfo: serviceLocator(),
                          remoteDataSource:
                              serviceLocator<ServiceRequestRemoteDataSource>(),
                        )..getServiceRequestDetails(
                          serviceId: request.id!,
                          patientId: widget.patientId,
                          context: context,
                        ),
                    child: ServiceRequestDetailsPage(
                      serviceId: request.id!,
                      patientId: widget.patientId,
                      appointmentId: widget.appointmentId,
                    ),
                  ),
            ),
          ).then((_){
            _loadInitialRequests();

          });
        },
        borderRadius: BorderRadius.circular(20.0),
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      request.healthCareService?.name ??
                          'serviceRequestsPage.unknownService'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 18),
                  _buildStatusChip(
                    context,
                    request.serviceRequestStatus?.code,
                    request.serviceRequestStatus?.display,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Divider(
                  height: 1,
                  thickness: 1.8,
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
              ),

              if (request.orderDetails != null) ...[
                _buildInfoRow(
                  context,
                  'serviceRequestsPage.orderDetails'.tr(context),
                  request.orderDetails!,
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 10),
              ],

              if (request.reason != null) ...[
                _buildInfoRow(
                  context,
                  'serviceRequestsPage.reason'.tr(context),
                  request.reason!,
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 10),
              ],

              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  if (request.serviceRequestCategory != null)
                    _buildInfoRowSome(
                      context,
                      'serviceRequestsPage.category'.tr(context),
                      request.serviceRequestCategory!.display,
                      icon: Icons.category,
                    ),
                  const SizedBox(height: 10),
                  if (request.serviceRequestPriority != null)
                    _buildInfoRowSome(
                      context,
                      'serviceRequestsPage.priority'.tr(context),
                      request.serviceRequestPriority!.display,
                      icon: Icons.paste,
                    ),
                  const SizedBox(height: 10),
                  if (request.serviceRequestBodySite != null)
                    _buildInfoRowSome(
                      context,
                      'serviceRequestsPage.bodySite'.tr(context),
                      request.serviceRequestBodySite!.display,
                      icon: Icons.emoji_people,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (request.encounter?.appointment?.doctor != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildInfoRow(
                    context,
                    'serviceRequestsPage.doctor'.tr(context),
                    '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.given} ${request.encounter!.appointment!.doctor!.family}',
                    icon: Icons.person_outline,
                  ),
                ),

              if (request.encounter?.actualStartDate != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'serviceRequestsPage.date'.tr(context) +
                        ': ${_formatDate(DateTime.parse(request.encounter!.actualStartDate!))}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
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
    String title,
    String value, {
    IconData? icon,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22, color: AppColors.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title:',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowSome(
    BuildContext context,
    String title,
    String value, {
    IconData? icon,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22, color: AppColors.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '$title:',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.cyan1,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String? statusCode,
    String? statusDisplay,
  ) {
    final statusColor = _getStatusColor(statusCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.0),
      ),
      child: Text(
        statusDisplay ?? 'serviceRequestDetailsPage.unknownStatus'.tr(context),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: statusColor.withAlpha(130),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
        return Colors.blue;
      case 'on-hold':
        return Colors.orange;
      case 'revoked':
        return Colors.red;
      case 'entered-in-error':
        return Colors.purple;
      case 'rejected':
        return Colors.red.shade800;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}
