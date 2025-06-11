import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyFormPage extends StatefulWidget {
  final int patientId;
  final int? allergyId;

  const AllergyFormPage({super.key, required this.patientId, this.allergyId});

  @override
  State<AllergyFormPage> createState() => _AllergyFormPageState();
}

class _AllergyFormPageState extends State<AllergyFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _onSetAgeController = TextEditingController();
  final _lastOccurrenceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _discoveredDuringEncounter = false;

  CodeModel? _selectedType;
  CodeModel? _selectedClinicalStatus;
  CodeModel? _selectedVerificationStatus;
  CodeModel? _selectedCategory;
  CodeModel? _selectedCriticality;

  @override
  void initState() {
    super.initState();
    if (widget.allergyId != null) {
      context.read<AllergyCubit>().getAllergyDetails(
        patientId: widget.patientId,
        allergyId: widget.allergyId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.allergyId == null ? 'Add New Allergy' : 'Edit Allergy Details',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyDetailsLoaded) {
            _populateForm(state.allergy);
          }
          if (state is AllergyCreated || state is AllergyUpdated) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading && widget.allergyId != null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AllergyError) {
            return Center(child: Text('Error: ${state.error}'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please enter allergy details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Allergy Name*',
                      hintText: 'e.g., Penicillin Allergy',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    validator:
                        (value) =>
                            (value?.isEmpty ?? true)
                                ? 'This field is required'
                                : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _onSetAgeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Onset Age',
                      hintText: 'e.g., 5 years',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.hourglass_empty),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _lastOccurrenceController,
                    decoration: const InputDecoration(
                      labelText: 'Last Occurrence Date',
                      hintText: 'Tap to select date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap:
                        () => _selectDate(context, _lastOccurrenceController),
                  ),
                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text(
                      'Discovered during encounter',
                      style: TextStyle(fontSize: 16),
                    ),
                    value: _discoveredDuringEncounter,
                    onChanged: (value) {
                      setState(() {
                        _discoveredDuringEncounter = value;
                      });
                    },
                    secondary: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                    ),

                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes',
                      hintText: 'Type any important details here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      alignLabelWithHint: true,

                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 4,
                    minLines: 1,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: Icon(
                        widget.allergyId == null
                            ? Icons.add_circle_outline
                            : Icons.save,
                      ),
                      label: Text(
                        widget.allergyId == null
                            ? 'Create Allergy'
                            : 'Update Allergy',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _populateForm(AllergyModel allergy) {
    setState(() {
      _nameController.text = allergy.name ?? '';
      _onSetAgeController.text = allergy.onSetAge ?? '';
      _lastOccurrenceController.text = allergy.lastOccurrence ?? '';
      _discoveredDuringEncounter = allergy.discoveredDuringEncounter == "1";
      _notesController.text = allergy.note ?? '';

      _selectedType = allergy.type;
      _selectedClinicalStatus = allergy.clinicalStatus;
      _selectedVerificationStatus = allergy.verificationStatus;
      _selectedCategory = allergy.category;
      _selectedCriticality = allergy.criticality;
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          controller.text.isNotEmpty
              ? DateTime.tryParse(controller.text) ?? DateTime.now()
              : DateTime.now(),
      firstDate: DateTime(1900),

      lastDate: DateTime.now(),

      helpText: 'Select last occurrence date',

      cancelText: 'Cancel',
      confirmText: 'Confirm',
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final allergy = AllergyModel(
        id: widget.allergyId?.toString(),

        name: _nameController.text,
        onSetAge: _onSetAgeController.text,
        lastOccurrence: _lastOccurrenceController.text,
        discoveredDuringEncounter: _discoveredDuringEncounter ? "1" : "0",
        note: _notesController.text.isEmpty ? null : _notesController.text,
        type: _selectedType,
        clinicalStatus: _selectedClinicalStatus,
        verificationStatus: _selectedVerificationStatus,
        category: _selectedCategory,
        criticality: _selectedCriticality,
        reactions: [],
        encounter: null,
      );

      if (widget.allergyId == null) {
        context.read<AllergyCubit>().createAllergy(
          patientId: widget.patientId,
          allergy: allergy,
        );
      } else {
        context.read<AllergyCubit>().updateAllergy(
          patientId: widget.patientId,
          allergyId: widget.allergyId!,
          allergy: allergy,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _onSetAgeController.dispose();
    _lastOccurrenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
