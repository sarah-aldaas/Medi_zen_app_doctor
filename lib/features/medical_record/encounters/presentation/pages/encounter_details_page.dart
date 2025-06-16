import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/create_edit_encounter_page.dart';
import 'package:medi_zen_app_doctor/features/services/pages/cubits/service_cubit/service_cubit.dart';
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
    context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId);

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
// <<<<<<< HEAD
//     final primaryColor = Theme.of(context).primaryColor;
//     final subTextColor = Colors.grey.shade500;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title: Text('Encounter Details', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24)),
//         leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: subTextColor), onPressed: () => context.pop()),
//         actions: [
//           BlocBuilder<EncounterCubit, EncounterState>(
//             builder: (context, state) {
//               if (state is EncounterDetailsSuccess && state.encounter!.status?.display?.toLowerCase() != 'finalized') {
//                 return Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit),
// =======
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
            color: AppColors.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryColor,
          ),
          onPressed: () => context.pop(),
          tooltip: 'Back to Encounters',
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
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
// <<<<<<< HEAD
                                (context) => CreateEditEncounterPage(patientId: widget.patientId, encounterId: state.encounter!.id!, encounter: state.encounter),
                          ),
                        ).then((_) => context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId));

                      },
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.check_circle),
                    //   onPressed: () => _showFinalizeConfirmationDialog(context, state.encounter),
                    // ),
// =======
//                                 (context) => CreateEditEncounterPage(
//                                   patientId: widget.patientId,
//                                   encounterId: state.encounter.id!,
//                                   encounter: state.encounter,
//                                 ),
//                           ),
//                         ).then((_) => _fetchEncounterDetails());
//                       },
//                       tooltip: 'Edit Encounter',
//                     ),
//                     IconButton(
//                       icon: const Icon(
//                         Icons.check_circle_outline,
//                         color: AppColors.primaryColor,
//                       ),
//                       onPressed:
//                           () => _showFinalizeConfirmationDialog(
//                             context,
//                             state.encounter,
//                           ),
//                       tooltip: 'Finalize Encounter',
//                     ),
//                     const Gap(8),
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
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
// <<<<<<< HEAD
            context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId);
// =======
//             ShowToast.showToastSuccess(
//               message: 'Encounter updated successfully',
//             ); // Updated toast message
//             _fetchEncounterDetails();
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
          }
        },
        builder: (context, state) {
          if (state is EncounterDetailsSuccess) {
// <<<<<<< HEAD
//             return _buildEncounterDetails(state.encounter!, primaryColor, subTextColor);
//           } else if (state is EncounterError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
//                   const SizedBox(height: 16),
//                   Text(state.error, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () => context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
// =======
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
                      'Oops! Something went wrong.',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
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
                      onPressed:()=> context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId),
                      icon: Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
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
//
// <<<<<<< HEAD
//   Widget _buildEncounterDetails(EncounterModel encounter, Color primaryColor, Color subTextColor) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(encounter.reason ?? 'No reason specified', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//           const Gap(10),
//           Text('Status: ${encounter.status?.display ?? 'N/A'}', style: TextStyle(fontSize: 18, color: subTextColor)),
//           Text('Type: ${encounter.type?.display ?? 'N/A'}', style: TextStyle(fontSize: 18, color: subTextColor)),
//           const Gap(30),
//           Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//           const Gap(20),
//           Text('Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           const Gap(10),
//           Row(
//             children: [Icon(Icons.calendar_today, color: primaryColor, size: 26), const Gap(10), Text('Start: ${formatDateTime(encounter.actualStartDate)}')],
//           ),
//           const Gap(10),
//           Row(children: [Icon(Icons.calendar_today, color: primaryColor, size: 26), const Gap(10), Text('End: ${formatDateTime(encounter.actualEndDate)}')]),
//           const Gap(10),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(Icons.note, color: primaryColor, size: 26),
//               const Gap(10),
//               SizedBox(
//                   width: context.width/1.3,
//                   child: Text('Special Arrangement: ${encounter.specialArrangement ?? 'N/A'}', overflow: TextOverflow.ellipsis, maxLines: 3)),
//             ],
//           ),
//           const Gap(30),
//           Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//           const Gap(20),
//           Text('Appointment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           const Gap(10),
//           Text(encounter.appointment?.reason ?? 'N/A', style: TextStyle(fontSize: 18)),
//           const Gap(30),
//           Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//           const Gap(20),
//           Text('Services', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           const Gap(10),
//           if (encounter.healthCareServices != null && encounter.healthCareServices!.isNotEmpty)
//             ...encounter.healthCareServices!.map(
//               (service) => ListTile(
//                 title: Text(service.name ?? 'Unknown Service'),
//                 trailing:
//                     encounter.status?.display?.toLowerCase() != 'finalized'
//                         ? IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _showUnassignServiceDialog(context, encounter, service),
//                         )
//                         : null,
//               ),
//             )
//           else
//             Text('No services assigned', style: TextStyle(fontSize: 18, color: subTextColor)),
//           if (encounter.status?.display?.toLowerCase() != 'finalized') ...[
//             const Gap(10),
//             ElevatedButton(
//               onPressed: () => _showAssignServiceDialog(context, encounter,encounter.healthCareServices!),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// =======
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
                  'Status: ${encounter.status?.display ?? 'Unknown'}',
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
                  'Type: ${encounter.type?.display ?? 'Unknown'}',
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

          _buildSectionHeader('Encounter Details'),
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
                        label: 'Appointment Reason',
                        value:
                            encounter.appointment!.reason ??
                            'No reason specified',
                      )
                      : Text(
                        'No associated appointment.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: textTheme.bodyLarge?.color,
                        ),
                      ),
            ),
          ),

          _buildSectionHeader('Health Care Services'),
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
                                service.name ?? 'Unknown Service',
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
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              'Assign New Service',
                              style: TextStyle(color: AppColors.primaryColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primaryColor),
                              foregroundColor: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
              ),
            ),
          ),
        ],
      ),
    );
  }

// <<<<<<< HEAD
//   // void _showFinalizeConfirmationDialog(BuildContext context, EncounterModel encounter) {
//   //   showDialog(
//   //     context: context,
//   //     builder:
//   //         (context) => AlertDialog(
//   //           title: const Text('Finalize Encounter'),
//   //           content: const Text('Are you sure you want to finalize this encounter? This action cannot be undone.'),
//   //           actions: [
//   //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//   //             ElevatedButton(
//   //               onPressed: () {
//   //                 context.read<EncounterCubit>().finalizeEncounter(patientId: int.parse(widget.patientId), encounterId: int.parse(encounter.id!));
//   //                 Navigator.pop(context);
//   //               },
//   //               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//   //               child: const Text('Finalize'),
//   //             ),
//   //           ],
//   //         ),
//   //   );
//   // }
//
//   void _showAssignServiceDialog(BuildContext context, EncounterModel encounter, List<HealthCareServiceModel> assignList) {
//     context.read<ServiceCubit>().getAllServiceHealthCare(perPage: 100);
//     showDialog(
//       context: context,
//       builder: (context) => BlocBuilder<ServiceCubit, ServiceState>(
//         builder: (context, state) {
//           if (state is ServiceHealthCareSuccess) {
//             return AlertDialog(
//               title: const Text('Assign Service'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: state.paginatedResponse.paginatedData!.items.map((service) {
//                     // Check if service is already assigned
//                     bool isAssigned = assignList.any((assignedService) => assignedService.id == service.id);
//
//                     return ListTile(
//                       title: Text(service.name ?? 'Unknown Service'),
//                       onTap: isAssigned
//                           ? null // Disable tap if already assigned
//                           : () {
//                         context.read<EncounterCubit>().assignService(
//                             encounterId: int.parse(encounter.id!),
//                             serviceId: int.parse(service.id!)
// =======
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
              'Finalize Encounter ?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'Are you sure you want to finalize this encounter? This action cannot be undone and no further changes or service assignments can be made.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
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
                        Theme.of(context).dialogTheme.backgroundColor,
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
                      Theme.of(context).dialogTheme.backgroundColor,
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
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
                        );
                        context.pop();
                      },
// <<<<<<< HEAD
//                       trailing: isAssigned
//                           ? const Icon(Icons.check, color: Colors.green)
//                           : const Icon(Icons.add),
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel')
//                 )
//               ],
//             );
//           }
//           return AlertDialog(
//               title: const Text('Loading Services'),
//               content:  Center(child: LoadingButton())
//           );
//         },
//       ),
//     );
//   }
//   void _showUnassignServiceDialog(BuildContext context, EncounterModel encounter, HealthCareServiceModel service) {
// =======
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
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
// <<<<<<< HEAD
//             title: const Text('Unassign Service'),
//             content: Text('Are you sure you want to unassign ${service.name ?? 'this service'}?'),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//               ElevatedButton(
//                 onPressed: () {
//                   context.read<EncounterCubit>().unassignService(encounterId: int.parse(encounter.id!), serviceId: int.parse(service.id!));
//                   context.pop();
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// =======
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
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
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
                child: const Text('Unassign'),
              ),
            ],
          ),
    );
  }
// <<<<<<< HEAD

  String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateString);
      final formattedDate = DateFormat('yyyy-MM-dd / hh:mm a').format(dateTime);
      return formattedDate;
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
