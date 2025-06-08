import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/create_edit_encounter_page.dart';
import 'package:medi_zen_app_doctor/features/services/pages/cubits/service_cubit/service_cubit.dart';
import '../../../../services/data/model/health_care_services_model.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';

class EncounterDetailsPage extends StatefulWidget {
  final String patientId;
  final String encounterId;

  const EncounterDetailsPage({super.key, required this.patientId, required this.encounterId});

  @override
  State<EncounterDetailsPage> createState() => _EncounterDetailsPageState();
}

class _EncounterDetailsPageState extends State<EncounterDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final subTextColor = Colors.grey.shade500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Encounter Details', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: subTextColor), onPressed: () => context.pop()),
        actions: [
          BlocBuilder<EncounterCubit, EncounterState>(
            builder: (context, state) {
              if (state is EncounterDetailsSuccess && state.encounter.status?.display?.toLowerCase() != 'finalized') {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CreateEditEncounterPage(patientId: widget.patientId, encounterId: state.encounter.id!, encounter: state.encounter),
                          ),
                        ).then((_) => context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId));

                      },
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.check_circle),
                    //   onPressed: () => _showFinalizeConfirmationDialog(context, state.encounter),
                    // ),
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
            context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId);
          }
        },
        builder: (context, state) {
          if (state is EncounterDetailsSuccess) {
            return _buildEncounterDetails(state.encounter, primaryColor, subTextColor);
          } else if (state is EncounterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(state.error, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<EncounterCubit>().getEncounterDetails(patientId: widget.patientId, encounterId: widget.encounterId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    child: const Text('Retry Loading'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildEncounterDetails(EncounterModel encounter, Color primaryColor, Color subTextColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(encounter.reason ?? 'No reason specified', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Gap(10),
          Text('Status: ${encounter.status?.display ?? 'N/A'}', style: TextStyle(fontSize: 18, color: subTextColor)),
          Text('Type: ${encounter.type?.display ?? 'N/A'}', style: TextStyle(fontSize: 18, color: subTextColor)),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text('Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Gap(10),
          Row(
            children: [Icon(Icons.calendar_today, color: primaryColor, size: 26), const Gap(10), Text('Start: ${formatDateTime(encounter.actualStartDate)}')],
          ),
          const Gap(10),
          Row(children: [Icon(Icons.calendar_today, color: primaryColor, size: 26), const Gap(10), Text('End: ${formatDateTime(encounter.actualEndDate)}')]),
          const Gap(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.note, color: primaryColor, size: 26),
              const Gap(10),
              SizedBox(
                  width: context.width/1.3,
                  child: Text('Special Arrangement: ${encounter.specialArrangement ?? 'N/A'}', overflow: TextOverflow.ellipsis, maxLines: 3)),
            ],
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text('Appointment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Gap(10),
          Text(encounter.appointment?.reason ?? 'N/A', style: TextStyle(fontSize: 18)),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text('Services', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Gap(10),
          if (encounter.healthCareServices != null && encounter.healthCareServices!.isNotEmpty)
            ...encounter.healthCareServices!.map(
              (service) => ListTile(
                title: Text(service.name ?? 'Unknown Service'),
                trailing:
                    encounter.status?.display?.toLowerCase() != 'finalized'
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showUnassignServiceDialog(context, encounter, service),
                        )
                        : null,
              ),
            )
          else
            Text('No services assigned', style: TextStyle(fontSize: 18, color: subTextColor)),
          if (encounter.status?.display?.toLowerCase() != 'finalized') ...[
            const Gap(10),
            ElevatedButton(
              onPressed: () => _showAssignServiceDialog(context, encounter,encounter.healthCareServices!),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Assign Service'),
            ),
          ],
        ],
      ),
    );
  }

  // void _showFinalizeConfirmationDialog(BuildContext context, EncounterModel encounter) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Finalize Encounter'),
  //           content: const Text('Are you sure you want to finalize this encounter? This action cannot be undone.'),
  //           actions: [
  //             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
  //             ElevatedButton(
  //               onPressed: () {
  //                 context.read<EncounterCubit>().finalizeEncounter(patientId: int.parse(widget.patientId), encounterId: int.parse(encounter.id!));
  //                 Navigator.pop(context);
  //               },
  //               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //               child: const Text('Finalize'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void _showAssignServiceDialog(BuildContext context, EncounterModel encounter, List<HealthCareServiceModel> assignList) {
    context.read<ServiceCubit>().getAllServiceHealthCare(perPage: 100);
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          if (state is ServiceHealthCareSuccess) {
            return AlertDialog(
              title: const Text('Assign Service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.paginatedResponse.paginatedData!.items.map((service) {
                    // Check if service is already assigned
                    bool isAssigned = assignList.any((assignedService) => assignedService.id == service.id);

                    return ListTile(
                      title: Text(service.name ?? 'Unknown Service'),
                      onTap: isAssigned
                          ? null // Disable tap if already assigned
                          : () {
                        context.read<EncounterCubit>().assignService(
                            encounterId: int.parse(encounter.id!),
                            serviceId: int.parse(service.id!)
                        );
                        context.pop();
                      },
                      trailing: isAssigned
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.add),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')
                )
              ],
            );
          }
          return AlertDialog(
              title: const Text('Loading Services'),
              content:  Center(child: LoadingButton())
          );
        },
      ),
    );
  }
  void _showUnassignServiceDialog(BuildContext context, EncounterModel encounter, HealthCareServiceModel service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unassign Service'),
            content: Text('Are you sure you want to unassign ${service.name ?? 'this service'}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  context.read<EncounterCubit>().unassignService(encounterId: int.parse(encounter.id!), serviceId: int.parse(service.id!));
                  context.pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Unassign'),
              ),
            ],
          ),
    );
  }

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
