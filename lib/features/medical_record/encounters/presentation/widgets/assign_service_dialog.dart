// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
// import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
// import '../data/models/health_care_services_model.dart';
// import 'encounter_cubit.dart';
//
// class AssignServiceDialog extends StatefulWidget {
//   final int encounterId;
//   final int patientId;
//   final List<HealthCareServiceModel> currentServices;
//   final int? appointmentId;
//
//   const AssignServiceDialog({
//     super.key,
//     required this.encounterId,
//     required this.patientId,
//     required this.currentServices,
//     this.appointmentId,
//   });
//
//   @override
//   State<AssignServiceDialog> createState() => _AssignServiceDialogState();
// }
//
// class _AssignServiceDialogState extends State<AssignServiceDialog> {
//   List<HealthCareServiceModel> _availableServices = [];
//   List<String> _selectedServiceIds = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedServiceIds = widget.currentServices.map((s) => s.id!).toList();
//     if (widget.appointmentId != null) {
//       context.read<EncounterCubit>().getAppointmentServices(
//         patientId: widget.patientId,
//         appointmentId: widget.appointmentId!,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Assign/Unassign Services',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             BlocConsumer<EncounterCubit, EncounterState>(
//               listener: (context, state) {
//                 if (state is AppointmentServicesSuccess) {
//                   setState(() {
//                     _availableServices = state.services;
//                   });
//                 } else if (state is EncounterError) {
//                   ShowToast.showToastError(message: state.error);
//                 } else if (state is EncounterActionSuccess) {
//                   context.read<EncounterCubit>().getEncounterDetails(
//                     patientId: widget.patientId,
//                     encounterId: widget.encounterId,
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 if (state is EncounterLoading) {
//                   return const Center(child: LoadingButton());
//                 }
//                 return _availableServices.isEmpty
//                     ? const Center(child: Text('No services available')),
//                     : Flexible(
//                 child: ListView(
//                 shrinkWrap: true,
//                 children: _availableServices.map((service) => CheckboxListTile(
//                 title: Text(service.name ?? 'N/A'),
//                 subtitle: Text(service.comment ?? 'No comment'),
//                 value: _selectedServiceIds.contains(service.id),
//                 onChanged: (bool? value) {
//                 setState(() {
//                 if (value == true) {
//                 _selectedServiceIds.add(service.id!);
//                 } else {
//                 _selectedServiceIds.remove(service.id!);
//                 }
//                 });
//                 },
//                 )).toList(),
//                 ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     _updateServices(context);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _updateServices(BuildContext context) {
//     final newServiceIds = _selectedServiceIds.toSet();
//     final currentServiceIds = widget.currentServices.map((s) => s.id!).toSet();
//
//     // Assign new services
//     for (var serviceId in newServiceIds.difference(currentServiceIds)) {
//       context.read<EncounterCubit>().assignService(
//         encounterId: widget.encounterId,
//         serviceId: int.parse(serviceId),
//       );
//     }
//
//     // Unassign removed services
//     for (var serviceId in currentServiceIds.difference(newServiceIds)) {
//       context.read<EncounterCubit>().unassignService(
//         encounterId: widget.encounterId,
//         serviceId: int.parse(serviceId),
//       );
//     }
//   }