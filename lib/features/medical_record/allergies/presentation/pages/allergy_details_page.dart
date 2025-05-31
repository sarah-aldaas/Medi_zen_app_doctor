import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_form_page.dart';


class AllergyDetailsPage extends StatefulWidget {
  final int patientId;
  final int allergyId;
  const AllergyDetailsPage({
    super.key,
    required this.patientId,
    required this.allergyId,
  });

  @override
  State<AllergyDetailsPage> createState() => _AllergyDetailsPageState();
}

class _AllergyDetailsPageState extends State<AllergyDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AllergyCubit>().getAllergyDetails(
      patientId: widget.patientId,
      allergyId: widget.allergyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergy Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyDeleted) {
            Navigator.pop(context);
            ShowToast.showToastSuccess(message: 'Allergy deleted successfully');
          }
          if (state is AllergyError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AllergyDetailsLoaded) {
            return _buildAllergyDetails(state.allergy);
          }
          if (state is AllergyLoading) {
            return const Center(child: LoadingPage());
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAllergyDetails(AllergyModel allergy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Name', allergy.name),
          _buildDetailItem('Onset Age', allergy.onSetAge),
          _buildDetailItem('Last Occurrence', allergy.lastOccurrence),
          _buildDetailItem('Discovered During Encounter',
              allergy.discoveredDuringEncounter == "1" ? "Yes" : "No"),
          if (allergy.note != null && allergy.note!.isNotEmpty)
            _buildDetailItem('Notes', allergy.note),

          // Code type details
          if (allergy.type != null)
            _buildDetailItem('Type', allergy.type!.display),
          if (allergy.clinicalStatus != null)
            _buildDetailItem('Clinical Status', allergy.clinicalStatus!.display),
          if (allergy.verificationStatus != null)
            _buildDetailItem('Verification Status', allergy.verificationStatus!.display),
          if (allergy.category != null)
            _buildDetailItem('Category', allergy.category!.display),
          if (allergy.criticality != null)
            _buildDetailItem('Criticality', allergy.criticality!.display),

          // Reactions section
          if (allergy.reactions != null && allergy.reactions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Reactions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(),
            ...allergy.reactions!.map((reaction) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Substance', reaction.substance),
                    _buildDetailItem('Manifestation', reaction.manifestation),
                    _buildDetailItem('Description', reaction.description),
                    _buildDetailItem('Onset', reaction.onSet),
                    if (reaction.note != null && reaction.note!.isNotEmpty)
                      _buildDetailItem('Notes', reaction.note),
                    if (reaction.severity != null)
                      _buildDetailItem('Severity', reaction.severity!.display),
                    if (reaction.exposureRoute != null)
                      _buildDetailItem('Exposure Route', reaction.exposureRoute!.display),
                    const Divider(thickness: 2),
                  ],
                )
            ).toList(),
          ],

          // Encounter details
          if (allergy.encounter != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Encounter Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(),
            _buildDetailItem('Reason', allergy.encounter!.reason),
            _buildDetailItem('Start Date', allergy.encounter!.actualStartDate),
            _buildDetailItem('End Date', allergy.encounter!.actualEndDate),
            if (allergy.encounter!.specialArrangement != null &&
                allergy.encounter!.specialArrangement!.isNotEmpty)
              _buildDetailItem('Special Arrangement', allergy.encounter!.specialArrangement),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value ?? 'Not specified',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this allergy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<AllergyCubit>().deleteAllergy(
        patientId: widget.patientId,
        allergyId: widget.allergyId,
      );
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllergyFormPage(
          patientId: widget.patientId,
          allergyId: widget.allergyId,
        ),
      ),
    );
  }
}