import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_filter_model.dart';
import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';
import 'medication_details_page.dart';

class MyMedicationsOfAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final String patientId;
  final MedicationFilterModel filter;

  const MyMedicationsOfAppointmentPage({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.filter,
  });

  @override
  _MyMedicationsOfAppointmentPageState createState() =>
      _MyMedicationsOfAppointmentPageState();
}

class _MyMedicationsOfAppointmentPageState
    extends State<MyMedicationsOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialMedications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMedications() {
    setState(() => _isLoadingMore = false);
    context.read<MedicationCubit>().getMedicationsForAppointment(
      context: context,
      filters: widget.filter.toJson(),
      appointmentId: widget.appointmentId,
      patientId: widget.patientId,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationCubit>()
          .getMedicationsForAppointment(
            filters: widget.filter.toJson(),
            loadMore: true,
            context: context,
            appointmentId: widget.appointmentId,
            patientId: widget.patientId,
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  void didUpdateWidget(MyMedicationsOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _loadInitialMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medications =
              state is MedicationSuccess
                  ? state.paginatedResponse.paginatedData?.items ?? []
                  : [];
          final hasMore = state is MedicationSuccess ? state.hasMore : false;

          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 64,
                    color: AppColors.primaryColor.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "myMedicationsOfAppointment.noMedications".tr(context),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _loadInitialMedications(),
                    icon: Icon(Icons.refresh, color: AppColors.whiteColor),
                    label: Text(
                      "myMedicationsOfAppointment.refresh".tr(context),
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 16,
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
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadInitialMedications(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: medications.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < medications.length) {
                  return _buildMedicationCard(context, medications[index]);
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

  Widget _buildMedicationCard(
    BuildContext context,
    MedicationModel medication,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MedicationDetailsPage(
                    medicationId: medication.id.toString(),
                    patientId: widget.patientId,
                    isAppointment: true,
                  ),
            ),
          ).then((_) => _loadInitialMedications()),
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
                    Icons.medication_liquid,
                    color: AppColors.primaryColor,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name ??
                              'myMedicationsOfAppointment.unknownMedication'.tr(
                                context,
                              ),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.dosageInstructions ??
                              'myMedicationsOfAppointment.noInstructions'.tr(
                                context,
                              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (medication.status != null)
                    _buildStatusChip(
                      context,
                      medication.status!.display,
                      medication.status!.code,
                    ),
                  if (medication.effectiveMedicationStartDate != null)
                    Text(
                      DateFormat(
                        'MMM d, y',
                      ).format(medication.effectiveMedicationStartDate!),
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
}
