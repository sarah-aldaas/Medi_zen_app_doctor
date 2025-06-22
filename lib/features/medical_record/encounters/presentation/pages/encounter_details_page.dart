import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/create_edit_encounter_page.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../services/data/model/health_care_services_model.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';

class EncounterDetailsPage extends StatefulWidget {
  final String patientId;
  final String encounterId;

  const EncounterDetailsPage({
    super.key,
    required this.patientId,
    required this.encounterId,
  });

  @override
  State<EncounterDetailsPage> createState() => _EncounterDetailsPageState();
}

class _EncounterDetailsPageState extends State<EncounterDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EncounterCubit>().getEncounterDetails(
      patientId: widget.patientId,
      encounterId: widget.encounterId,
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'in_progress':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'planned':
        return Colors.blue.shade600;
      case 'finalized':
        return AppColors.primaryColor;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'encounterPage.encounter_details_title'.tr(context),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryColor,
          ),
          onPressed: () => context.pop(),
          tooltip: 'encounterPage.back_to_encounters_tooltip'.tr(context),
        ),
        actions: [
          BlocBuilder<EncounterCubit, EncounterState>(
            builder: (context, state) {
              if (state is EncounterDetailsSuccess &&
                  state.encounter!.status?.display?.toLowerCase() !=
                      'finalized') {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CreateEditEncounterPage(
                                  patientId: widget.patientId,
                                  encounterId: state.encounter!.id!,
                                  encounter: state.encounter,
                                ),
                          ),
                        ).then(
                          (_) => context
                              .read<EncounterCubit>()
                              .getEncounterDetails(
                                patientId: widget.patientId,
                                encounterId: widget.encounterId,
                              ),
                        );
                      },
                      tooltip: 'encounterPage.edit_encounter_tooltip'.tr(
                        context,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is EncounterActionSuccess) {
            context.read<EncounterCubit>().getEncounterDetails(
              patientId: widget.patientId,
              encounterId: widget.encounterId,
            );
          }
        },
        builder: (context, state) {
          if (state is EncounterDetailsSuccess) {
            return _buildEncounterDetails(context, state.encounter!);
          } else if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
          } else if (state is EncounterError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: colorScheme.error,
                    ),
                    const Gap(20),
                    Text(
                      'encounterPage.error_something_went_wrong'.tr(context),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    Text(
                      state.error,
                      style: textTheme.bodyMedium?.copyWith(
                        color: textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(30),
                    ElevatedButton.icon(
                      onPressed:
                          () => context
                              .read<EncounterCubit>()
                              .getEncounterDetails(
                                patientId: widget.patientId,
                                encounterId: widget.encounterId,
                              ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'encounterPage.retry'.tr(context),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEncounterDetails(
    BuildContext context,
    EncounterModel encounter,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final isFinalized = encounter.status?.display?.toLowerCase() == 'finalized';

    Widget _buildInfoRow({
      required IconData icon,
      required String label,
      required String value,
      Color? iconColor,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor ?? AppColors.primaryColor, size: 22),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSectionHeader(String title) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(24),
          Divider(thickness: 2, color: Theme.of(context).dividerColor),
          const Gap(16),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const Gap(12),
        ],
      );
    }

    String formattedStartDate = 'encounterPage.not_available_short'.tr(context);
    String formattedEndDate = 'encounterPage.not_available_short'.tr(context);
    try {
      if (encounter.actualStartDate != null) {
        formattedStartDate = DateFormat(
          'EEE, MMM d, yyyy - hh:mm a',
        ).format(DateTime.parse(encounter.actualStartDate!));
      }
      if (encounter.actualEndDate != null) {
        formattedEndDate = DateFormat(
          'EEE, MMM d, yyyy - hh:mm a',
        ).format(DateTime.parse(encounter.actualEndDate!));
      }
    } catch (e) {
      print('Date parsing error: $e');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            encounter.reason ??
                'encounterPage.encounter_reason_not_specified'.tr(context),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textTheme.headlineSmall?.color,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(
                label: Text(
                  '${encounter.status?.display ?? 'encounterPage.unknown_status'.tr(context)}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(encounter.status?.display),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Chip(
                label: Text(
                  '${encounter.type?.display ?? 'encounterPage.unknown_status'.tr(context)}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          _buildSectionHeader(
            'encounterPage.encounter_details_section'.tr(context),
          ),
          Card(
            color: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'encounterPage.start_date_time_label'.tr(context),
                    value: formattedStartDate,
                  ),
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'encounterPage.end_date_time_label'.tr(context),
                    value: formattedEndDate,
                  ),
                  _buildInfoRow(
                    icon: Icons.event_note_outlined,
                    label: 'encounterPage.special_arrangement_label'.tr(
                      context,
                    ),
                    value:
                        encounter.specialArrangement ??
                        'encounterPage.not_available_short'.tr(context),
                  ),
                ],
              ),
            ),
          ),

          _buildSectionHeader(
            'encounterPage.associated_appointment_section'.tr(context),
          ),
          Card(
            color: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  encounter.appointment != null
                      ? _buildInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'encounterPage.appointment_reason_label'.tr(
                          context,
                        ),
                        value:
                            encounter.appointment!.reason ??
                            'encounterPage.no_reason_specified'.tr(context),
                      )
                      : Text(
                        'encounterPage.no_associated_appointment'.tr(context),
                        style: textTheme.bodyLarge?.copyWith(
                          color: textTheme.bodyLarge?.color,
                        ),
                      ),
            ),
          ),

          _buildSectionHeader(
            'encounterPage.health_care_services_section'.tr(context),
          ),
          Card(
            color: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (encounter.healthCareServices != null &&
                      encounter.healthCareServices!.isNotEmpty)
                    ...encounter.healthCareServices!.map(
                      (service) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.name ??
                                    'encounterPage.unknown_service'.tr(context),
                                style: textTheme.bodyLarge?.copyWith(
                                  color: textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isFinalized)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: colorScheme.error,
                                ),
                                onPressed:
                                    () => _showUnassignServiceDialog(
                                      context,
                                      encounter,
                                      service,
                                    ),
                                tooltip:
                                    'encounterPage.unassign_service_tooltip'.tr(
                                      context,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      'encounterPage.no_services_assigned'.tr(context),
                      style: textTheme.bodyLarge?.copyWith(
                        color: textTheme.bodyLarge?.color,
                      ),
                    ),
                  if (!isFinalized)
                    Column(
                      children: [
                        const Gap(16),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed:
                                () => _showAssignServiceDialog(
                                  context,
                                  encounter,
                                ),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              'encounterPage.assign_new_service'.tr(context),
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              foregroundColor: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalizeConfirmationDialog(
    BuildContext context,
    EncounterModel encounter,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'encounterPage.finalize_encounter_dialog_title'.tr(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'encounterPage.finalize_encounter_dialog_content'.tr(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'encounterPage.cancel_button'.tr(context),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textButtonTheme
                        .style
                        ?.foregroundColor
                        ?.resolve({MaterialState.pressed}),
                  ),
                ),
                style: Theme.of(context).textButtonTheme.style,
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<EncounterCubit>().finalizeEncounter(
                    patientId: int.parse(widget.patientId),
                    encounterId: int.parse(encounter.id!),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('encounterPage.finalize_button'.tr(context)),
              ),
            ],
          ),
    );
  }

  void _showAssignServiceDialog(
    BuildContext dialogContext,
    EncounterModel encounter,
  ) {
    if (encounter.appointment == null || encounter.appointment!.id == null) {
      ShowToast.showToastError(
        message: 'encounterPage.cannot_assign_service_no_appointment'.tr(
          dialogContext,
        ),
      );
      return;
    }

    dialogContext.read<EncounterCubit>().getAppointmentServices(
      patientId: int.parse(widget.patientId),
      appointmentId: int.parse(encounter.appointment!.id!),
    );

    showDialog(
      context: dialogContext,
      builder:
          (context) => BlocBuilder<EncounterCubit, EncounterState>(
            builder: (context, state) {
              if (state is AppointmentServicesSuccess) {
                final availableServices = state.services;
                if (availableServices.isEmpty) {
                  return AlertDialog(
                    backgroundColor:
                        Theme.of(context).dialogTheme.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'encounterPage.no_services_available_dialog_title'.tr(
                        context,
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    content: Text(
                      'encounterPage.no_services_available_dialog_content'.tr(
                        context,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'encounterPage.okay_button'.tr(context),
                          style: TextStyle(
                            color: Theme.of(context)
                                .textButtonTheme
                                .style
                                ?.foregroundColor
                                ?.resolve({MaterialState.pressed}),
                          ),
                        ),
                        style: Theme.of(context).textButtonTheme.style,
                      ),
                    ],
                  );
                }
                return AlertDialog(
                  backgroundColor:
                      Theme.of(context).dialogTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'encounterPage.assign_new_service'.tr(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableServices.length,
                      itemBuilder: (context, index) {
                        final service = availableServices[index];
                        return Card(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 2.0,
                          ),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              service.name ??
                                  'encounterPage.unknown_service'.tr(context),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.add_box_outlined,
                              color: AppColors.primaryColor,
                            ),
                            onTap: () {
                              context.read<EncounterCubit>().assignService(
                                encounterId: int.parse(encounter.id!),
                                serviceId: int.parse(service.id!),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'encounterPage.cancel_button'.tr(context),
                        style: TextStyle(
                          color: Theme.of(context)
                              .textButtonTheme
                              .style
                              ?.foregroundColor
                              ?.resolve({MaterialState.pressed}),
                        ),
                      ),
                      style: Theme.of(context).textButtonTheme.style,
                    ),
                  ],
                );
              } else if (state is EncounterLoading) {
                return AlertDialog(
                  backgroundColor:
                      Theme.of(context).dialogTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Loading Services',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  content: SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).progressIndicatorTheme.color,
                      ),
                    ),
                  ),
                );
              }

              return AlertDialog(
                backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                content: Text(
                  'Could not load services. ${state is EncounterError ? state.error : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({MaterialState.pressed}),
                      ),
                    ),
                    style: Theme.of(context).textButtonTheme.style,
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showUnassignServiceDialog(
    BuildContext context,
    EncounterModel encounter,
    HealthCareServiceModel service,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'encounterPage.unassign_service_tooltip'.tr(context) +
                  '?', // Reusing tooltip key for dialog title
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'Are you sure you want to unassign "${service.name ?? 'encounterPage.unknown_service'.tr(context)}"?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'encounterPage.cancel_button'.tr(context),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textButtonTheme
                        .style
                        ?.foregroundColor
                        ?.resolve({MaterialState.pressed}),
                  ),
                ),
                style: Theme.of(context).textButtonTheme.style,
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<EncounterCubit>().unassignService(
                    encounterId: int.parse(encounter.id!),
                    serviceId: int.parse(service.id!),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Unassign'),
              ),
            ],
          ),
    );
  }

  String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'encounterPage.not_available_short'.tr(context);
    }

    try {
      final dateTime = DateTime.parse(dateString);
      final formattedDate = DateFormat('yyyy-MM-dd / hh:mm a').format(dateTime);
      return formattedDate;
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
