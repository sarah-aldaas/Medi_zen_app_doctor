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
import '../../../../services/pages/cubits/service_cubit/service_cubit.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';

class EncounterDetailsPage extends StatefulWidget {
  final String patientId;
  final String encounterId;
  final String? appointmentId;

  const EncounterDetailsPage({
    super.key,
    required this.patientId,
    required this.encounterId,
    required this.appointmentId,
  });

  @override
  State<EncounterDetailsPage> createState() => _EncounterDetailsPageState();
}

class _EncounterDetailsPageState extends State<EncounterDetailsPage> {

  void _showDescriptionTooltip(
      BuildContext context,
      String message,
      Offset offset,
      ) {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx.clamp(10.0, screenWidth - 250),
        top: offset.dy + 30,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 250,
            maxHeight: screenHeight * 0.4, // Limit height to 40% of screen
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  Widget _buildClickableChip({
    required BuildContext context,
    required String label,
    required Color backgroundColor,
    required String? description,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        if (description != null && description.isNotEmpty) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);
          _showDescriptionTooltip(context, description, offset);
        }
      },
      child: MouseRegion(
        cursor:
            description != null && description.isNotEmpty
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  // color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<EncounterCubit>().getEncounterDetails(
      patientId: widget.patientId,
      encounterId: widget.encounterId,
    );
    context.read<ServiceCubit>().getAllServiceHealthCare();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'final':
        return AppColors.primaryColor;
      case 'in-progress':
        return Colors.orange.shade600;
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
          if (widget.appointmentId != null)
            BlocBuilder<EncounterCubit, EncounterState>(
              builder: (context, state) {
                if (state is EncounterDetailsSuccess &&
                    state.encounter!.status?.code.toLowerCase() !=
                        'final') {
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
    final isFinalized = encounter.status?.code.toLowerCase() == 'final';

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
              _buildClickableChip(
                context: context,
                label: encounter.status!.display,
                backgroundColor: _getStatusColor(encounter.status?.code),
                description: encounter.status?.description,
              ),
              _buildClickableChip(
                context: context,
                label:
                    '${encounter.type?.display ?? 'encounterPage.unknown_status'.tr(context)}',
                backgroundColor: AppColors.primaryColor,
                description: encounter.type?.description,
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
          if (!isFinalized)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => _showFinalizeConfirmationDialog(
                            context,
                            encounter,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'encounterPage.finalize_encounter_button'.tr(context),
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
                style: Theme.of(context).textButtonTheme.style,
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

    dialogContext.read<ServiceCubit>().getAllServiceHealthCare();

    showDialog(
      context: dialogContext,
      builder:
          (context) => BlocBuilder<ServiceCubit, ServiceState>(
            builder: (context, state) {
              if (state is ServiceHealthCareSuccess) {
                final availableServices =
                    state.paginatedResponse.paginatedData!.items;
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
                        style: Theme.of(context).textButtonTheme.style,
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
                        bool isFind = false;
                        encounter.healthCareServices!.map((e) {
                          if (e.id == service.id) {
                            isFind = true;
                          }
                        }).toList();
                        if (isFind) {
                          return const SizedBox.shrink();
                        }
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
                      style: Theme.of(context).textButtonTheme.style,
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
                    ),
                  ],
                );
              }
              else if (state is ServiceHealthCareLoading) {
                return AlertDialog(
                  backgroundColor:
                      Theme.of(context).dialogTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'encounterPage.loadingServices'.tr(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  content:  SizedBox(
                    height: 100,
                    child: Center(child: LoadingButton()),
                  ),
                );
              }

              return AlertDialog(
                backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'encounterPage.error'.tr(context),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                content: Text(
                  "encounterPage.could_not_load".tr(context) +
                      (state is ServiceHealthCareError ? state.error : ''),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: Theme.of(context).textButtonTheme.style,
                    child: Text(
                      'encounterPage.close'.tr(context),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({MaterialState.pressed}),
                      ),
                    ),
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
              'encounterPage.unassign_service_tooltip'.tr(context) + '?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              "encounterPage.are_you_sure".tr(context) +
                  "${service.name ?? 'encounterPage.unknown_service'.tr(context)}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: Theme.of(context).textButtonTheme.style,
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
                child: Text('encounterPage.unassign'.tr(context)),
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
