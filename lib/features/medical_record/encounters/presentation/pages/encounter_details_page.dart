import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    _fetchEncounterDetails();
  }

  void _fetchEncounterDetails() {
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
        return AppColors.secondaryColor;
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
          'Encounter Details',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => context.pop(),
          tooltip: 'Back to Encounters',
        ),
        actions: [
          BlocBuilder<EncounterCubit, EncounterState>(
            builder: (context, state) {
              if (state is EncounterDetailsSuccess &&
                  state.encounter.status?.display?.toLowerCase() !=
                      'finalized') {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).appBarTheme.iconTheme?.color,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CreateEditEncounterPage(
                                  patientId: widget.patientId,
                                  encounterId: state.encounter.id!,
                                  encounter: state.encounter,
                                ),
                          ),
                        ).then(
                          (_) => _fetchEncounterDetails(),
                        );
                      },
                      tooltip: 'Edit Encounter',
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.check_circle_outline,
                        color:
                            Theme.of(context)
                                .appBarTheme
                                .iconTheme
                                ?.color,
                      ),
                      onPressed:
                          () => _showFinalizeConfirmationDialog(
                            context,
                            state.encounter,
                          ),
                      tooltip: 'Finalize Encounter',
                    ),
                    const Gap(8),
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
            ShowToast.showToastSuccess(
              message: 'message',
            );
            _fetchEncounterDetails();
          }
        },
        builder: (context, state) {
          if (state is EncounterDetailsSuccess) {
            return _buildEncounterDetails(context, state.encounter);
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
                      'Oops! Something went wrong.',
                      style: textTheme.headlineSmall?.copyWith(
                        color:
                            colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    Text(
                      state.error,
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(30),
                    ElevatedButton.icon(
                      onPressed: _fetchEncounterDetails,
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({MaterialState.pressed}),
                      ),
                      label: Text(
                        'Retry',
                        style: TextStyle(
                          color: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.foregroundColor
                              ?.resolve({MaterialState.pressed}),
                        ),
                      ),
                      style: Theme.of(context).elevatedButtonTheme.style,
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
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  iconColor ??
                  colorScheme.primary,
              size: 22,
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textTheme.labelLarge?.color,
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
          Divider(
            thickness: 2,
            color:
                Theme.of(
                  context,
                ).dividerColor,
          ),
          const Gap(16),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  colorScheme
                      .secondary,
            ),
          ),
          const Gap(12),
        ],
      );
    }

    String formattedStartDate = 'N/A';
    String formattedEndDate = 'N/A';
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
            encounter.reason ?? 'Encounter Reason Not Specified',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  textTheme
                      .headlineSmall
                      ?.color,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(
                label: Text(
                  'Status: ${encounter.status?.display ?? 'Unknown'}',
                  style: textTheme.labelMedium?.copyWith(
                    color:
                        colorScheme
                            .onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(
                  encounter.status?.display,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  'Type: ${encounter.type?.display ?? 'Unknown'}',
                  style: textTheme.labelMedium?.copyWith(
                    color:
                        colorScheme
                            .onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor:
                    colorScheme.primary,
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

          _buildSectionHeader('Encounter Details'),
          Card(
            color: Theme.of(context).cardColor,
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
                    label: 'Start Date & Time',
                    value: formattedStartDate,
                  ),
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'End Date & Time',
                    value: formattedEndDate,
                  ),
                  _buildInfoRow(
                    icon: Icons.event_note_outlined,
                    label: 'Special Arrangement',
                    value: encounter.specialArrangement ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),

          _buildSectionHeader('Associated Appointment'),
          Card(
            color: Theme.of(context).cardColor,
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
                        label: 'Appointment Reason',
                        value:
                            encounter.appointment!.reason ??
                            'No reason specified',
                      )
                      : Text(
                        'No associated appointment.',
                        style: textTheme.bodyLarge?.copyWith(
                          color:
                              textTheme.bodyLarge?.color,
                        ),
                      ),
            ),
          ),

          _buildSectionHeader('Health Care Services'),
          Card(
            color: Theme.of(context).cardColor,
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.name ?? 'Unknown Service',
                                style: textTheme.bodyLarge?.copyWith(
                                  color:
                                      textTheme
                                          .bodyLarge
                                          ?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isFinalized)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color:
                                      colorScheme.error,
                                ),
                                onPressed:
                                    () => _showUnassignServiceDialog(
                                      context,
                                      encounter,
                                      service,
                                    ),
                                tooltip: 'Unassign Service',
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      'No services assigned to this encounter.',
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
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Theme.of(context)
                                  .outlinedButtonTheme
                                  .style
                                  ?.foregroundColor
                                  ?.resolve({MaterialState.pressed}),
                            ),
                            label: Text(
                              'Assign New Service',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .outlinedButtonTheme
                                    .style
                                    ?.foregroundColor
                                    ?.resolve({MaterialState.pressed}),
                              ),
                            ),
                            style: Theme.of(context).outlinedButtonTheme.style,
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
            backgroundColor:
                Theme.of(
                  context,
                ).dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Finalize Encounter ?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(
                      context,
                    ).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'Are you sure you want to finalize this encounter? This action cannot be undone and no further changes or service assignments can be made.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
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
                  backgroundColor:
                      AppColors
                          .secondaryColor,
                  foregroundColor: AppColors.secondaryColor,
                ),
                child: const Text('Finalize'),
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
        message:
            "Cannot assign service: No associated appointment found or appointment ID is missing.",
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
                        Theme.of(context)
                            .dialogTheme
                            .backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'No Services Available',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    content: Text(
                      'There are no services assigned to the associated appointment that can be assigned to this encounter.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Okay',
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
                      Theme.of(context)
                          .dialogTheme
                          .backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Assign Service',
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
                          color:
                              Theme.of(
                                context,
                              ).cardColor,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 2.0,
                          ),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              service.name ?? 'Unknown Service',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            trailing: Icon(
                              Icons.add_box_outlined,
                              color:
                                  AppColors.primaryColor,
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
                        'Cancel',
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
                      Theme.of(context)
                          .dialogTheme
                          .backgroundColor,
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
                        color:
                            Theme.of(context)
                                .progressIndicatorTheme
                                .color,
                      ),
                    ),
                  ),
                );
              }

              return AlertDialog(
                backgroundColor:
                    Theme.of(
                      context,
                    ).dialogTheme.backgroundColor,
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
            backgroundColor:
                Theme.of(
                  context,
                ).dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Unassign Service?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'Are you sure you want to unassign "${service.name ?? 'this service'}"?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
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
                  backgroundColor:
                      Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Unassign'),
              ),
            ],
          ),
    );
  }
}
