import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyFormPage extends StatefulWidget {
  final int patientId;
  final int? allergyId;
  const AllergyFormPage({
    super.key,
    required this.patientId,
    this.allergyId,
  });

  @override
  State<AllergyFormPage> createState() => _AllergyFormPageState();
}

// class _AllergyFormPageState extends State<AllergyFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _substanceController = TextEditingController();
//   final _manifestationController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _onSetController = TextEditingController();
//   final _notesController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.allergyId != null) {
//       context.read<AllergyCubit>().getAllergyDetails(
//         patientId: widget.patientId,
//         allergyId: widget.allergyId!,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.allergyId == null ? 'Add Allergy' : 'Edit Allergy'),
//       ),
//       body: BlocConsumer<AllergyCubit, AllergyState>(
//         listener: (context, state) {
//           if (state is AllergyDetailsLoaded) {
//             _populateForm(state.allergy);
//           }
//           if (state is AllergyCreated || state is AllergyUpdated) {
//             Navigator.pop(context);
//           }
//           if (state is AllergyError) {
//             ShowToast.showToastError(message: state.error);
//           }
//         },
//         builder: (context, state) {
//           if (state is AllergyLoading && widget.allergyId != null) {
//             return const Center(child: LoadingPage());
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _substanceController,
//                     decoration: const InputDecoration(labelText: 'Substance*'),
//                     validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required field' : null,
//                   ),
//                   TextFormField(
//                     controller: _manifestationController,
//                     decoration: const InputDecoration(labelText: 'Manifestation*'),
//                     validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required field' : null,
//                   ),
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(labelText: 'Description'),
//                     maxLines: 3,
//                   ),
//                   TextFormField(
//                     controller: _onSetController,
//                     decoration: const InputDecoration(labelText: 'Onset Date'),
//                     onTap: () => _selectDate(context),
//                   ),
//                   TextFormField(
//                     controller: _notesController,
//                     decoration: const InputDecoration(labelText: 'Notes'),
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _submitForm,
//                     child: Text(widget.allergyId == null ? 'Create' : 'Update'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _populateForm(AllergyModel allergy) {
//     _substanceController.text = allergy.substance ?? '';
//     _manifestationController.text = allergy.manifestation ?? '';
//     _descriptionController.text = allergy.description ?? '';
//     _onSetController.text = allergy.onSet ?? '';
//     _notesController.text = allergy.note ?? '';
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       _onSetController.text = picked.toIso8601String().split('T')[0];
//     }
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState?.validate() ?? false) {
//       final allergy = AllergyModel(
//         id: widget.allergyId?.toString(),
//         substance: _substanceController.text,
//         manifestation: _manifestationController.text,
//         description: _descriptionController.text,
//         onSet: _onSetController.text,
//         note: _notesController.text.isEmpty ? null : _notesController.text,
//       );
//
//       if (widget.allergyId == null) {
//         context.read<AllergyCubit>().createAllergy(
//           patientId: widget.patientId,
//           allergy: allergy,
//         );
//       } else {
//         context.read<AllergyCubit>().updateAllergy(
//           patientId: widget.patientId,
//           allergyId: widget.allergyId!,
//           allergy: allergy,
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _substanceController.dispose();
//     _manifestationController.dispose();
//     _descriptionController.dispose();
//     _onSetController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
// }

class _AllergyFormPageState extends State<AllergyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _onSetAgeController = TextEditingController();
  final _lastOccurrenceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _discoveredDuringEncounter = false;

  // Add controllers/dropdowns for code types (type, clinicalStatus, etc.)
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
    // Load code types here using your CodeTypesCubit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allergyId == null ? 'Add Allergy' : 'Edit Allergy'),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name*'),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),

                  // Add similar fields for other properties
                  TextFormField(
                    controller: _onSetAgeController,
                    decoration: const InputDecoration(labelText: 'Onset Age'),
                  ),

                  // Date picker for last occurrence
                  TextFormField(
                    controller: _lastOccurrenceController,
                    decoration: const InputDecoration(labelText: 'Last Occurrence'),
                    onTap: () => _selectDate(context, _lastOccurrenceController),
                  ),

                  // Code type dropdowns (example for type)
                  // DropdownButtonFormField<CodeModel>(
                  //   value: _selectedType,
                  //   decoration: const InputDecoration(labelText: 'Type'),
                  //   items: context.read<CodeTypesCubit>().state.allergyTypes.map((type) {
                  //     return DropdownMenuItem(
                  //       value: type,
                  //       child: Text(type.display),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) => setState(() => _selectedType = value),
                  // ),

                  // Add similar dropdowns for other code types

                  // Checkbox for discovered during encounter
                  CheckboxListTile(
                    title: const Text('Discovered during encounter'),
                    value: _discoveredDuringEncounter,
                    onChanged: (value) => setState(() => _discoveredDuringEncounter = value ?? false),
                  ),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.allergyId == null ? 'Create' : 'Update'),
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
    _nameController.text = allergy.name ?? '';
    _onSetAgeController.text = allergy.onSetAge ?? '';
    _lastOccurrenceController.text = allergy.lastOccurrence ?? '';
    _discoveredDuringEncounter = allergy.discoveredDuringEncounter == "1";
    _notesController.text = allergy.note ?? '';
    _selectedType = allergy.type;
    _selectedClinicalStatus = allergy.clinicalStatus;
    // Set other code type values similarly
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
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
        reactions: [], // You'll need to handle reactions separately
        encounter: null, // You'll need to handle encounter separately
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