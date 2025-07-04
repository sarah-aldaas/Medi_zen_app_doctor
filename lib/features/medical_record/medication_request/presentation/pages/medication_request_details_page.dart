import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';
import '../widgets/edit_medication_request_page.dart';
import '../widgets/delete_medication_request_dialog.dart';

class MedicationRequestDetailsPage extends StatefulWidget {
  final String medicationRequestId;
  final String patientId;
  final bool isAppointment;

  const MedicationRequestDetailsPage({super.key, required this.medicationRequestId, required this.patientId, required this.isAppointment});

  @override
  _MedicationRequestDetailsPageState createState() => _MedicationRequestDetailsPageState();
}

class _MedicationRequestDetailsPageState extends State<MedicationRequestDetailsPage> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    context.read<MedicationRequestCubit>().getMedicationRequestDetails(
      patientId: widget.patientId,
      context: context,
      medicationRequestId: widget.medicationRequestId,
    );
  }

  // Widget _buildRelatedMedications(MedicationRequestModel request) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             "medicationRequestDetails.relatedMedications",
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.add, color: AppColors.primaryColor),
  //             onPressed: () => context.pushNamed(
  //               AppRouter.createMedication.name,
  //               extra: {
  //                 'patientId': widget.patientId,
  //                 'medicationRequest': request,
  //               },
  //             ).then((_) => _refresh()),
  //             tooltip: 'medicationRequestDetails.createMedication',
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 8),
  //       BlocBuilder<MedicationCubit, MedicationState>(
  //         builder: (context, state) {
  //           if (state is MedicationRequestSuccess) {
  //             return Column(
  //               children: state.medications.isNotEmpty
  //                   ? state.medications.map((medication) => GestureDetector(
  //                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicationDetailsPage(medicationId: medicationId, patientId: patientId))).then((_) => _refresh()),
  //                 child: Card(
  //                   elevation: 4,
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                   margin: const EdgeInsets.symmetric(vertical: 8),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(16.0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Icon(Icons.medication, color: AppColors.primaryColor, size: 40),
  //                             const SizedBox(width: 16),
  //                             Expanded(
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     medication.name ?? 'medicationRequestDetails.unknownMedication',
  //                                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text(
  //                                     medication.dosageInstructions ?? 'medicationRequestDetails.noInstructions',
  //                                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               )).toList()
  //                   : [
  //                 Text("medicationRequestDetails.noMedications"),
  //               ],
  //             );
  //           } else if (state is MedicationLoading) {
  //             return const Center(child: CircularProgressIndicator());
  //           }
  //           return Text("medicationRequestDetails.noMedications");
  //         },
  //       ),
  //     ],
  //   );
  // }
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => DeleteMedicationRequestDialog(
            medicationRequestId: widget.medicationRequestId,
            patientId: widget.patientId,
            onConfirm: () {
              context
                  .read<MedicationRequestCubit>()
                  .deleteMedicationRequest(medicationRequestId: widget.medicationRequestId, patientId: widget.patientId, context: context)
                  .then((_) {
                    if (context.read<MedicationRequestCubit>().state is MedicationRequestDeleted) {
                      Navigator.pop(context); // Pop the details page after deletion
                    }
                  });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("medicationRequestDetails", style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: AppColors.primaryColor), onPressed: () => context.pop()),
        actions: [
          if (widget.isAppointment) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryColor),
              onPressed: () {
                final state = context.read<MedicationRequestCubit>().state;
                if (state is MedicationRequestDetailsSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditMedicationRequestPage(medicationRequest: state.medicationRequest, patientId: widget.patientId)),
                  ).then((_) => _refresh()); // Refresh details after editing
                }
              },
              tooltip: 'Edit Medication Request',
            ),
            IconButton(icon: const Icon(Icons.delete, color: AppColors.primaryColor), onPressed: _showDeleteConfirmation, tooltip: 'Delete Medication Request'),
          ],
        ],
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is MedicationRequestDeleted) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestDetailsSuccess) {
            return _buildMedicationRequestDetails(state.medicationRequest);
          } else if (state is MedicationRequestLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(child: Text("failedToLoad"));
          }
        },
      ),
    );
  }

  Widget _buildMedicationRequestDetails(MedicationRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(request),
          const SizedBox(height: 20),
          _buildRequestInfo(request),
          const SizedBox(height: 20),
          _buildConditionInfo(request),
          const SizedBox(height: 20),
          _buildAdditionalInfo(request),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationRequestModel request) {
    return Row(
      children: [
        Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.reason ?? 'Medication Request', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(request.status?.display ?? 'No status', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestInfo(MedicationRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("requestInfo", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan)),
        const SizedBox(height: 8),
        if (request.status != null) Text("Status: ${request.status!.display}"),
        if (request.statusReason != null) Text("Status Reason: ${request.statusReason}"),
        if (request.statusChanged != null) Text("Status Changed: ${request.statusChanged}"),
        if (request.intent != null) Text("Intent: ${request.intent!.display}"),
        if (request.priority != null) Text("Priority: ${request.priority!.display}"),
      ],
    );
  }

  Widget _buildConditionInfo(MedicationRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("conditionInfo", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan)),
        const SizedBox(height: 8),
        if (request.condition != null) Text("Condition: ${request.condition!.healthIssue ?? 'No condition'}"),
        if (request.condition?.clinicalStatus != null) Text("Clinical Status: ${request.condition!.clinicalStatus!.display}"),
      ],
    );
  }

  Widget _buildAdditionalInfo(MedicationRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("additionalInfo", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan)),
        const SizedBox(height: 8),
        if (request.courseOfTherapyType != null) Text("Course of Therapy: ${request.courseOfTherapyType!.display}"),
        if (request.numberOfRepeatsAllowed != null) Text("Repeats Allowed: ${request.numberOfRepeatsAllowed}"),
        if (request.note != null) Text("Note: ${request.note}"),
        if (request.doNotPerform != null) Text("Do Not Perform: ${request.doNotPerform! ? 'Yes' : 'No'}"),
      ],
    );
  }
}
