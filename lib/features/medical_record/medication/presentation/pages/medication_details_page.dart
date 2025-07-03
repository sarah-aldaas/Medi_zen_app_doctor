import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';
import '../widgets/delete_medication_dialog.dart';
import '../widgets/edit_medication_page.dart';

class MedicationDetailsPage extends StatefulWidget {
  final String medicationId;
  final String patientId;

  const MedicationDetailsPage({
    super.key,
    required this.medicationId,
    required this.patientId,
  });

  @override
  _MedicationDetailsPageState createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    context.read<MedicationCubit>().getMedicationDetails(
      context: context,
      medicationId: widget.medicationId,
      patientId: widget.patientId,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteMedicationDialog(
        medicationId: widget.medicationId,
        patientId: widget.patientId,
        onConfirm: () {
          context.read<MedicationCubit>().deleteMedication(
            medication: MedicationModel(id: widget.medicationId),
            patientId: widget.patientId,
            medicationId: widget.medicationId,
            context: context,
          ).then((_) {
            if (context.read<MedicationCubit>().state is MedicationDeleted) {
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop details page
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
        title: const Text(
          "Medication Details",
          style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () {
              final state = context.read<MedicationCubit>().state;
              if (state is MedicationDetailsSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMedicationPage(
                      medication: state.medication,
                      patientId: widget.patientId,
                    ),
                  ),
                ).then((_) => _refresh());
              }
            },
            tooltip: 'Edit Medication',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.primaryColor),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Medication',
          ),
        ],
      ),
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is MedicationDeleted) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is MedicationDetailsSuccess) {
            return _buildMedicationDetails(state.medication);
          } else if (state is MedicationLoading) {
            return const Center(child: LoadingPage());
          } else {
            return const Center(child: Text("Failed to load medication details"));
          }
        },
      ),
    );
  }

  Widget _buildMedicationDetails(MedicationModel medication) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(medication),
          const SizedBox(height: 20),
          _buildDosageInfo(medication),
          const SizedBox(height: 20),
          _buildInstructions(medication),
          const SizedBox(height: 20),
          _buildStatusAndDates(medication),
          const SizedBox(height: 20),
          _buildRelatedMedicationRequest(medication),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationModel medication) {
    return Row(
      children: [
        const Icon(Icons.medication, color: AppColors.primaryColor, size: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name ?? 'Unknown Medication',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                medication.definition ?? 'No description available',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDosageInfo(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dosage Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.dose != null && medication.doseUnit != null)
          Text("Dose: ${medication.dose} ${medication.doseUnit}"),
        if (medication.maxDosePerPeriod != null)
          Text(
              "Max Dose: ${medication.maxDosePerPeriod!.numerator.value} ${medication.maxDosePerPeriod!.numerator.unit} per ${medication.maxDosePerPeriod!.denominator.value} ${medication.maxDosePerPeriod!.denominator.unit}"),
        if (medication.dosageInstructions != null)
          Text("Instructions: ${medication.dosageInstructions}"),
        if (medication.doseForm != null)
          Text("Dose Form: ${medication.doseForm!.display}"),
        if (medication.route != null)
          Text("Route: ${medication.route!.display}"),
        if (medication.site != null)
          Text("Site: ${medication.site!.display}"),
      ],
    );
  }

  Widget _buildInstructions(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Instructions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.patientInstructions != null)
          Text("Patient Instructions: ${medication.patientInstructions}"),
        if (medication.additionalInstructions != null)
          Text("Additional Instructions: ${medication.additionalInstructions}"),
        if (medication.asNeeded != null)
          Text("As Needed: ${medication.asNeeded! ? 'Yes' : 'No'}"),
        if (medication.event != null)
          Text("Event: ${medication.event}"),
        if (medication.when != null)
          Text("When: ${medication.when}"),
        if (medication.offset != null && medication.offsetUnit != null)
          Text("Offset: ${medication.offset} ${medication.offsetUnit}"),
      ],
    );
  }

  Widget _buildStatusAndDates(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Status and Dates",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.status != null)
          Text("Status: ${medication.status!.display}"),
        if (medication.effectiveMedicationStartDate != null)
          Text("Start Date: ${DateFormat('MMM d, y').format(medication.effectiveMedicationStartDate!)}"),
        if (medication.effectiveMedicationEndDate != null)
          Text("End Date: ${DateFormat('MMM d, y').format(medication.effectiveMedicationEndDate!)}"),
      ],
    );
  }

  Widget _buildRelatedMedicationRequest(MedicationModel medication) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Related Medication Request",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan),
        ),
        const SizedBox(height: 8),
        if (medication.medicationRequest != null)
          GestureDetector(
            onTap: () => context.push('/medication-requests/details', extra: {
              'medicationRequestId': medication.medicationRequest!.id,
              'patientId': widget.patientId,
            }),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        medication.medicationRequest!.reason ?? 'Unknown Request',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          const Text("No related medication request"),
      ],
    );
  }
}