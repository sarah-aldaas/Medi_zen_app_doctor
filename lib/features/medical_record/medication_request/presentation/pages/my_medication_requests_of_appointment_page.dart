import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_request_filter.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';
import '../widgets/create_medication_request_page.dart';
import 'medication_request_details_page.dart';

class MyMedicationRequestsOfAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final MedicationRequestFilterModel filter;
  final String patientId;

  const MyMedicationRequestsOfAppointmentPage({
    super.key,
    required this.filter,
    required this.appointmentId,
    required this.patientId,
  });

  @override
  _MyMedicationRequestsOfAppointmentPageState createState() =>
      _MyMedicationRequestsOfAppointmentPageState();
}

class _MyMedicationRequestsOfAppointmentPageState
    extends State<MyMedicationRequestsOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialMedicationRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMedicationRequests() {
    setState(() => _isLoadingMore = false);
    context.read<MedicationRequestCubit>().getMedicationRequestsForAppointment(
      patientId: widget.patientId,
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
          .read<MedicationRequestCubit>()
          .getMedicationRequestsForAppointment(
            patientId: widget.patientId,
            filters: widget.filter.toJson(),
            loadMore: true,
            context: context,
            appointmentId: widget.appointmentId,
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  void didUpdateWidget(MyMedicationRequestsOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialMedicationRequests();
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
                    (context) => CreateMedicationRequestPage(
                      patientId: widget.patientId,
                    ),
              ),
            ).then((_) => _loadInitialMedicationRequests()),
        child: Icon(Icons.add, color: AppColors.whiteColor),
        tooltip: 'Add Medication Request'.tr(context),
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medicationRequests =
              state is MedicationRequestSuccess
                  ? state.paginatedResponse.paginatedData?.items ?? []
                  : [];
          final hasMore =
              state is MedicationRequestSuccess ? state.hasMore : false;

          if (medicationRequests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_add,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "myMedicationRequestsOfAppointment.noRequests".tr(
                        context,
                      ),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _loadInitialMedicationRequests(),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        "myMedicationRequestsOfAppointment.refresh".tr(context),
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
          }

          return RefreshIndicator(
            onRefresh: () async => _loadInitialMedicationRequests(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: medicationRequests.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < medicationRequests.length) {
                  return _buildMedicationRequestCard(
                    context,
                    medicationRequests[index],
                  );
                } else if (hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationRequestCard(
    BuildContext context,
    MedicationRequestModel request,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MedicationRequestDetailsPage(
                    isAppointment: true,
                    medicationRequestId: request.id.toString(),
                    patientId: widget.patientId,
                  ),
            ),
          ).then((_) => _loadInitialMedicationRequests()),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: colorScheme.primary,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.reason ??
                              'myMedicationRequestsOfAppointment.defaultMedicationRequest'
                                  .tr(context),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.note ??
                              'myMedicationRequestsOfAppointment.noAdditionalNotes'
                                  .tr(context),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (request.status != null)
                    _buildStatusChip(
                      context,
                      request.status!.display,
                      request.status!.code,
                    ),
                  if (request.statusChanged != null)
                    Text(
                      _formatDate(request.statusChanged!),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String statusDisplay,
    String? statusCode,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    Color chipColor = Colors.grey;
    Color textColor = Colors.white;

    switch (statusCode) {
      case 'active':
        chipColor = Colors.green.shade600;
        break;
      case 'on-hold':
        chipColor = Colors.orange.shade600;
        break;
      case 'cancelled':
        chipColor = Colors.red.shade600;
        break;
      case 'completed':
        chipColor = Colors.blue.shade600;
        break;
      case 'draft':
        chipColor = Colors.grey.shade500;
        break;
      case 'stopped':
        chipColor = Colors.purple.shade600;
        break;
      case 'entered-in-error':
        chipColor = Colors.deepOrange.shade600;
        break;
      default:
        chipColor = colorScheme.outline;
    }

    if (chipColor.computeLuminance() > 0.5) {
      textColor = Colors.black;
    }

    return Chip(
      label: Text(
        statusDisplay,
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

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
