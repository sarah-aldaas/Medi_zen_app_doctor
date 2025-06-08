import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/data/models/allergy_model.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../../../encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyFormPage extends StatefulWidget {
  final String patientId;
  final String? encounterId;
  final AllergyModel? allergy;

  const AllergyFormPage({
    super.key,
    required this.patientId,
    this.encounterId,
    this.allergy,
  });

  @override
  State<AllergyFormPage> createState() => _AllergyFormPageState();
}

class _AllergyFormPageState extends State<AllergyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _onSetAgeController = TextEditingController();
  final TextEditingController _lastOccurrenceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _discoveredDuringEncounter = false;
  CodeModel? _selectedType;
  CodeModel? _selectedClinicalStatus;
  CodeModel? _selectedVerificationStatus;
  CodeModel? _selectedCategory;
  CodeModel? _selectedCriticality;
  EncounterModel? _selectedEncounter;
  List<EncounterModel> encounters = [];
  List<CodeModel> types = [];
  List<CodeModel> clinicalStatuses = [];
  List<CodeModel> verificationStatuses = [];
  List<CodeModel> categories = [];
  List<CodeModel> criticalities = [];

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getAllergyTypeCodes();
    context.read<CodeTypesCubit>().getAllergyClinicalStatusCodes();
    context.read<CodeTypesCubit>().getAllergyVerificationStatusCodes();
    context.read<CodeTypesCubit>().getAllergyCategoryCodes();
    context.read<CodeTypesCubit>().getAllergyCriticalityCodes();
    context.read<EncounterCubit>().getPatientEncounters(patientId: widget.patientId,perPage: 100);

    if (widget.allergy != null) {
      _nameController.text = widget.allergy!.name ?? '';
      _onSetAgeController.text = widget.allergy!.onSetAge ?? '';
      _lastOccurrenceController.text = widget.allergy!.lastOccurrence ?? '';
      _noteController.text = widget.allergy!.note ?? '';
      _discoveredDuringEncounter = widget.allergy!.discoveredDuringEncounter == "1";
      _selectedType = widget.allergy!.type;
      _selectedClinicalStatus = widget.allergy!.clinicalStatus;
      _selectedVerificationStatus = widget.allergy!.verificationStatus;
      _selectedCategory = widget.allergy!.category;
      _selectedCriticality = widget.allergy!.criticality;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allergy == null ? 'Add Allergy' : 'Edit Allergy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Allergy Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Allergy name is required' : null,
              ),
              const SizedBox(height: 16),

              // Type Dropdown
              _buildCodeDropdown(
                codeType: 'allergy_type',
                selectedItem: _selectedType,
                label: 'Type*',
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 16),

// Clinical Status Dropdown
              _buildCodeDropdown(
                codeType: 'allergy_clinical_status',
                selectedItem: _selectedClinicalStatus,
                label: 'Clinical Status*',
                onChanged: (value) => setState(() => _selectedClinicalStatus = value),
              ),
              const SizedBox(height: 16),

// Verification Status Dropdown
              _buildCodeDropdown(
                codeType: 'allergy_verification_status',
                selectedItem: _selectedVerificationStatus,
                label: 'Verification Status*',
                onChanged: (value) => setState(() => _selectedVerificationStatus = value),
              ),
              const SizedBox(height: 16),

// Category Dropdown
              _buildCodeDropdown(
                codeType: 'allergy_category',
                selectedItem: _selectedCategory,
                label: 'Category*',
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),

// Criticality Dropdown
              _buildCodeDropdown(
                codeType: 'allergy_criticality',
                selectedItem: _selectedCriticality,
                label: 'Criticality*',
                onChanged: (value) => setState(() => _selectedCriticality = value),
              ),
              const SizedBox(height: 16),
              _buildEncounterDropdown(),
              const SizedBox(height: 16),

              TextFormField(
                controller: _onSetAgeController,
                decoration: const InputDecoration(
                  labelText: 'Onset Age',
                  border: OutlineInputBorder(),
                  suffixText: 'years',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lastOccurrenceController,
                decoration: const InputDecoration(
                  labelText: 'Last Occurrence',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _lastOccurrenceController.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Discovered during this encounter?'),
                value: _discoveredDuringEncounter,
                onChanged: (value) {
                  setState(() {
                    _discoveredDuringEncounter = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.allergy == null ? 'Save Allergy' : 'Update Allergy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildEncounterDropdown() {
    return BlocBuilder<EncounterCubit, EncounterState>(
      builder: (context, state) {
        if (state is EncounterListSuccess) {
          encounters = state.paginatedResponse.paginatedData!.items;

          // If editing an existing allergy and encounter is not already set
          if (widget.allergy != null && widget.allergy!.encounter == null && encounters.isNotEmpty) {
            _selectedEncounter = encounters.firstWhere(
                  (e) => e.id == widget.encounterId,
              orElse: () => encounters.first,
            );
          }

          return DropdownButtonFormField<EncounterModel>(
            decoration: const InputDecoration(
              labelText: 'Encounter',
              border: OutlineInputBorder(),
            ),
            value: _selectedEncounter,
            selectedItemBuilder: (context) {
              return encounters.map((encounter) {
                return Text(encounter.reason ?? 'No reason',
                    style: TextStyle(fontSize: 14));
              }).toList();
            },
            items: encounters.map((encounter) {
              return DropdownMenuItem<EncounterModel>(
                value: encounter,
                child: Column(
                  children: [
                    Text(
                      "${encounter.reason}\n ${encounter.actualStartDate}" ?? 'Unknown type',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Divider()
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEncounter = value;
              });
            },
          );
        } else if (state is EncounterLoading) {
          return const CircularProgressIndicator();
        } else if (state is EncounterError) {
          return Text('Error loading encounters: ${state.error}');
        }
        return const SizedBox.shrink();
      },
    );
  }
  Widget _buildCodeDropdown({
    required String codeType,
    required CodeModel? selectedItem,
    required String label,
    required Function(CodeModel?) onChanged,
  }) {
    return BlocBuilder<CodeTypesCubit, CodeTypesState>(
      builder: (context, state) {
        if (state is CodeTypesSuccess) {
          // Filter codes by type and update state
          List<CodeModel> items = state.codes?.where((code) => code.codeTypeModel?.name == codeType).toList() ?? [];

          // Update the corresponding state variable
          switch (codeType) {
            case 'allergy_type':
              types = items;
              break;
            case 'allergy_clinical_status':
              clinicalStatuses = items;
              break;
            case 'allergy_verification_status':
              verificationStatuses = items;
              break;
            case 'allergy_category':
              categories = items;
              break;
            case 'allergy_criticality':
              criticalities = items;
              break;
          }

          return DropdownButtonFormField<CodeModel>(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            value: selectedItem,
            items: items.map((item) {
              return DropdownMenuItem<CodeModel>(
                value: item,
                child: Text(item.display),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) => value == null ? '$label is required' : null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final allergy = AllergyModel(
        id: widget.allergy?.id ?? '',
        name: _nameController.text,
        onSetAge: _onSetAgeController.text,
        lastOccurrence: _lastOccurrenceController.text,
        discoveredDuringEncounter: _discoveredDuringEncounter ? "1" : "0",
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        type: _selectedType,
        clinicalStatus: _selectedClinicalStatus,
        verificationStatus: _selectedVerificationStatus,
        category: _selectedCategory,
        criticality: _selectedCriticality,
        reactions: widget.allergy?.reactions ?? [],
        encounter: _selectedEncounter,
      );

      if (widget.allergy == null) {
        context.read<AllergyCubit>().createAllergy(
          patientId: widget.patientId,
          allergy: allergy,
        );
      } else {
        context.read<AllergyCubit>().updateAllergy(
          patientId: widget.patientId,
          allergyId: widget.allergy!.id!,
          allergy: allergy,
        );
      }

      ShowToast.showToastSuccess(
        message: widget.allergy == null
            ? 'Allergy created successfully'
            : 'Allergy updated successfully',
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _onSetAgeController.dispose();
    _lastOccurrenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
// import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
// import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
// import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
// import 'package:medi_zen_app_doctor/features/medical_record/allergies/data/models/allergy_model.dart';
//
// import '../cubit/allergy_cubit/allergy_cubit.dart';
//
// class AllergyFormPage extends StatefulWidget {
//   final String patientId;
//   final String? encounterId;
//   final AllergyModel allergy;
//
//   const AllergyFormPage({
//     super.key,
//     required this.patientId,
//     this.encounterId,
//     this.allergy,
//   });
//
//   @override
//   State<AllergyFormPage> createState() => _AllergyFormPageState();
// }
//
// class _AllergyFormPageState extends State<AllergyFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _onSetAgeController = TextEditingController();
//   final TextEditingController _lastOccurrenceController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//
//   bool _discoveredDuringEncounter = false;
//   String? _selectedTypeId;
//   String? _selectedClinicalStatusId;
//   String? _selectedVerificationStatusId;
//   String? _selectedCategoryId;
//   String? _selectedCriticalityId;
//
//   List<CodeModel> types = [];
//   List<CodeModel> clinicalStatuses = [];
//   List<CodeModel> verificationStatuses = [];
//   List<CodeModel> categories = [];
//   List<CodeModel> criticalities = [];
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<CodeTypesCubit>().getAllergyTypeCodes();
//     context.read<CodeTypesCubit>().getAllergyClinicalStatusCodes();
//     context.read<CodeTypesCubit>().getAllergyVerificationStatusCodes();
//     context.read<CodeTypesCubit>().getAllergyCategoryCodes();
//     context.read<CodeTypesCubit>().getAllergyCriticalityCodes();
//
//     if (widget.allergy != null) {
//       _nameController.text = widget.allergy!['name'] ?? '';
//       _onSetAgeController.text = widget.allergy!['on_set_age']?.toString() ?? '';
//       _lastOccurrenceController.text = widget.allergy!['last_occurrence']?.toString() ?? '';
//       _noteController.text = widget.allergy.note?? '';
//       _discoveredDuringEncounter = widget.allergy!['discovered_during_encounter'] ?? false;
//       _selectedTypeId = widget.allergy.type!.id;
//       _selectedClinicalStatusId = widget.allergy!['clinical_status_id']?.toString();
//       _selectedVerificationStatusId = widget.allergy!['verification_status_id']?.toString();
//       _selectedCategoryId = widget.allergy!['category_id']?.toString();
//       _selectedCriticalityId = widget.allergy!['criticality_id']?.toString();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.allergy == null ? 'Add Allergy' : 'Edit Allergy'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Allergy Name*',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value?.isEmpty ?? true ? 'Allergy name is required' : null,
//               ),
//               const SizedBox(height: 16),
//
//               // Type Dropdown
//               BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                 builder: (context, state) {
//                   if (state is CodeTypesSuccess) {
//                     types = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_type').toList() ?? [];
//                     return DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Type*',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedTypeId,
//                       items: types.map((type) {
//                         return DropdownMenuItem<String>(
//                           value: type.id,
//                           child: Text(type.display),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedTypeId = value;
//                         });
//                       },
//                       validator: (value) => value == null ? 'Type is required' : null,
//                     );
//                   }
//                   return const CircularProgressIndicator();
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Clinical Status Dropdown
//               BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                 builder: (context, state) {
//                   if (state is CodeTypesSuccess) {
//                     clinicalStatuses = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_clinical_status').toList() ?? [];
//                     return DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Clinical Status*',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedClinicalStatusId,
//                       items: clinicalStatuses.map((status) {
//                         return DropdownMenuItem<String>(
//                           value: status.id,
//                           child: Text(status.display),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedClinicalStatusId = value;
//                         });
//                       },
//                       validator: (value) => value == null ? 'Clinical status is required' : null,
//                     );
//                   }
//                   return const CircularProgressIndicator();
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Verification Status Dropdown
//               BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                 builder: (context, state) {
//                   if (state is CodeTypesSuccess) {
//                     verificationStatuses = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_verification_status').toList() ?? [];
//                     return DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Verification Status*',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedVerificationStatusId,
//                       items: verificationStatuses.map((status) {
//                         return DropdownMenuItem<String>(
//                           value: status.id,
//                           child: Text(status.display),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedVerificationStatusId = value;
//                         });
//                       },
//                       validator: (value) => value == null ? 'Verification status is required' : null,
//                     );
//                   }
//                   return const CircularProgressIndicator();
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Category Dropdown
//               BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                 builder: (context, state) {
//                   if (state is CodeTypesSuccess) {
//                     categories = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_category').toList() ?? [];
//                     return DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Category*',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedCategoryId,
//                       items: categories.map((category) {
//                         return DropdownMenuItem<String>(
//                           value: category.id,
//                           child: Text(category.display),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategoryId = value;
//                         });
//                       },
//                       validator: (value) => value == null ? 'Category is required' : null,
//                     );
//                   }
//                   return const CircularProgressIndicator();
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Criticality Dropdown
//               BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                 builder: (context, state) {
//                   if (state is CodeTypesSuccess) {
//                     criticalities = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_criticality').toList() ?? [];
//                     return DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Criticality*',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedCriticalityId,
//                       items: criticalities.map((criticality) {
//                         return DropdownMenuItem<String>(
//                           value: criticality.id,
//                           child: Text(criticality.display),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCriticalityId = value;
//                         });
//                       },
//                       validator: (value) => value == null ? 'Criticality is required' : null,
//                     );
//                   }
//                   return const CircularProgressIndicator();
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _onSetAgeController,
//                 decoration: const InputDecoration(
//                   labelText: 'Onset Age',
//                   border: OutlineInputBorder(),
//                   suffixText: 'years',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _lastOccurrenceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Last Occurrence',
//                   border: OutlineInputBorder(),
//                 ),
//                 onTap: () async {
//                   final date = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(1900),
//                     lastDate: DateTime.now(),
//                   );
//                   if (date != null) {
//                     _lastOccurrenceController.text = date.toIso8601String().split('T')[0];
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               SwitchListTile(
//                 title: const Text('Discovered during this encounter?'),
//                 value: _discoveredDuringEncounter,
//                 onChanged: (value) {
//                   setState(() {
//                     _discoveredDuringEncounter = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _noteController,
//                 decoration: const InputDecoration(
//                   labelText: 'Notes',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 24),
//
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(widget.allergy == null ? 'Save Allergy' : 'Update Allergy'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // void _submitForm() {
//   //   if (_formKey.currentState!.validate()) {
//   //     final allergyData = {
//   //       'name': _nameController.text,
//   //       'on_set_age': _onSetAgeController.text.isNotEmpty ? int.tryParse(_onSetAgeController.text) : null,
//   //       'last_occurrence': _lastOccurrenceController.text.isNotEmpty ? _lastOccurrenceController.text : null,
//   //       'discovered_during_encounter': _discoveredDuringEncounter,
//   //       'note': _noteController.text.isNotEmpty ? _noteController.text : null,
//   //       'type_id': _selectedTypeId,
//   //       'clinical_status_id': _selectedClinicalStatusId,
//   //       'verification_status_id': _selectedVerificationStatusId,
//   //       'category_id': _selectedCategoryId,
//   //       'criticality_id': _selectedCriticalityId,
//   //       'patient_id': widget.patientId,
//   //       'encounter_id': widget.encounterId,
//   //     };
//   //
//   //     // Here you would call your API to save/update the allergy
//   //     // For example:
//   //     if (widget.allergy == null) {
//   //       context.read<AllergyCubit>().createAllergy(patientId:  widget.patientId,allergy: AllergyModel(id: "", name: name, onSetAge: onSetAge, lastOccurrence: lastOccurrence, discoveredDuringEncounter: discoveredDuringEncounter, type: type, clinicalStatus: clinicalStatus, verificationStatus: verificationStatus, category: category, criticality: criticality, reactions: reactions, encounter: encounter));
//   //     } else {
//   //       context.read<AllergyCubit>().updateAllergy(
//   //         allergyId: widget.allergy!['id'],
//   //         allergyData: allergyData,
//   //       );
//   //     }
//   //
//   //     ShowToast.showToastSuccess(
//   //       message: widget.allergy == null
//   //           ? 'Allergy created successfully'
//   //           : 'Allergy updated successfully',
//   //     );
//   //     Navigator.pop(context);
//   //   }
//   // }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Find the selected code models
//       final type = types.firstWhereOrNull((t) => t.id == _selectedTypeId);
//       final clinicalStatus = clinicalStatuses.firstWhereOrNull((s) => s.id == _selectedClinicalStatusId);
//       final verificationStatus = verificationStatuses.firstWhereOrNull((s) => s.id == _selectedVerificationStatusId);
//       final category = categories.firstWhereOrNull((c) => c.id == _selectedCategoryId);
//       final criticality = criticalities.firstWhereOrNull((c) => c.id == _selectedCriticalityId);
//
//       final allergy = AllergyModel(
//         id: widget.allergy?['id'] ?? '', // Empty string for new allergies
//         name: _nameController.text,
//         onSetAge: _onSetAgeController.text.isNotEmpty ? int.tryParse(_onSetAgeController.text) : null,
//         lastOccurrence: _lastOccurrenceController.text.isNotEmpty ? _lastOccurrenceController.text : null,
//         discoveredDuringEncounter: _discoveredDuringEncounter,
//         note: _noteController.text.isNotEmpty ? _noteController.text : null,
//         type: type,
//         clinicalStatus: clinicalStatus,
//         verificationStatus: verificationStatus,
//         category: category,
//         criticality: criticality,
//         reactions: widget.allergy?['reactions'] ?? [],
//         encounterId: widget.encounterId,
//         patientId: widget.patientId,
//       );
//
//       if (widget.allergy == null) {
//         context.read<AllergyCubit>().createAllergy(
//           patientId: widget.patientId,
//           allergy: allergy,
//         );
//       } else {
//         context.read<AllergyCubit>().updateAllergy(
//           allergyId: widget.allergy.,
//           allergy: allergy,
//         );
//       }
//
//       ShowToast.showToastSuccess(
//         message: widget.allergy == null
//             ? 'Allergy created successfully'
//             : 'Allergy updated successfully',
//       );
//       Navigator.pop(context);
//     }
//   }
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _onSetAgeController.dispose();
//     _lastOccurrenceController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
// // import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
// //
// // import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
// // import '../../../../../base/data/models/code_type_model.dart';
// // import '../../data/models/allergy_model.dart';
// // import '../cubit/allergy_cubit/allergy_cubit.dart';
// //
// // class AllergyFormPage extends StatefulWidget {
// //   final String patientId;
// //   final String? allergyId;
// //   const AllergyFormPage({
// //     super.key,
// //     required this.patientId,
// //     this.allergyId,
// //   });
// //
// //   @override
// //   State<AllergyFormPage> createState() => _AllergyFormPageState();
// // }
// //
// // // class _AllergyFormPageState extends State<AllergyFormPage> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _substanceController = TextEditingController();
// // //   final _manifestationController = TextEditingController();
// // //   final _descriptionController = TextEditingController();
// // //   final _onSetController = TextEditingController();
// // //   final _notesController = TextEditingController();
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     if (widget.allergyId != null) {
// // //       context.read<AllergyCubit>().getAllergyDetails(
// // //         patientId: widget.patientId,
// // //         allergyId: widget.allergyId!,
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text(widget.allergyId == null ? 'Add Allergy' : 'Edit Allergy'),
// // //       ),
// // //       body: BlocConsumer<AllergyCubit, AllergyState>(
// // //         listener: (context, state) {
// // //           if (state is AllergyDetailsLoaded) {
// // //             _populateForm(state.allergy);
// // //           }
// // //           if (state is AllergyCreated || state is AllergyUpdated) {
// // //             Navigator.pop(context);
// // //           }
// // //           if (state is AllergyError) {
// // //             ShowToast.showToastError(message: state.error);
// // //           }
// // //         },
// // //         builder: (context, state) {
// // //           if (state is AllergyLoading && widget.allergyId != null) {
// // //             return const Center(child: LoadingPage());
// // //           }
// // //
// // //           return SingleChildScrollView(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Form(
// // //               key: _formKey,
// // //               child: Column(
// // //                 children: [
// // //                   TextFormField(
// // //                     controller: _substanceController,
// // //                     decoration: const InputDecoration(labelText: 'Substance*'),
// // //                     validator: (value) =>
// // //                     value?.isEmpty ?? true ? 'Required field' : null,
// // //                   ),
// // //                   TextFormField(
// // //                     controller: _manifestationController,
// // //                     decoration: const InputDecoration(labelText: 'Manifestation*'),
// // //                     validator: (value) =>
// // //                     value?.isEmpty ?? true ? 'Required field' : null,
// // //                   ),
// // //                   TextFormField(
// // //                     controller: _descriptionController,
// // //                     decoration: const InputDecoration(labelText: 'Description'),
// // //                     maxLines: 3,
// // //                   ),
// // //                   TextFormField(
// // //                     controller: _onSetController,
// // //                     decoration: const InputDecoration(labelText: 'Onset Date'),
// // //                     onTap: () => _selectDate(context),
// // //                   ),
// // //                   TextFormField(
// // //                     controller: _notesController,
// // //                     decoration: const InputDecoration(labelText: 'Notes'),
// // //                     maxLines: 3,
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   ElevatedButton(
// // //                     onPressed: _submitForm,
// // //                     child: Text(widget.allergyId == null ? 'Create' : 'Update'),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _populateForm(AllergyModel allergy) {
// // //     _substanceController.text = allergy.substance ?? '';
// // //     _manifestationController.text = allergy.manifestation ?? '';
// // //     _descriptionController.text = allergy.description ?? '';
// // //     _onSetController.text = allergy.onSet ?? '';
// // //     _notesController.text = allergy.note ?? '';
// // //   }
// // //
// // //   Future<void> _selectDate(BuildContext context) async {
// // //     final DateTime? picked = await showDatePicker(
// // //       context: context,
// // //       initialDate: DateTime.now(),
// // //       firstDate: DateTime(1900),
// // //       lastDate: DateTime.now(),
// // //     );
// // //     if (picked != null) {
// // //       _onSetController.text = picked.toIso8601String().split('T')[0];
// // //     }
// // //   }
// // //
// // //   void _submitForm() {
// // //     if (_formKey.currentState?.validate() ?? false) {
// // //       final allergy = AllergyModel(
// // //         id: widget.allergyId?.toString(),
// // //         substance: _substanceController.text,
// // //         manifestation: _manifestationController.text,
// // //         description: _descriptionController.text,
// // //         onSet: _onSetController.text,
// // //         note: _notesController.text.isEmpty ? null : _notesController.text,
// // //       );
// // //
// // //       if (widget.allergyId == null) {
// // //         context.read<AllergyCubit>().createAllergy(
// // //           patientId: widget.patientId,
// // //           allergy: allergy,
// // //         );
// // //       } else {
// // //         context.read<AllergyCubit>().updateAllergy(
// // //           patientId: widget.patientId,
// // //           allergyId: widget.allergyId!,
// // //           allergy: allergy,
// // //         );
// // //       }
// // //     }
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _substanceController.dispose();
// // //     _manifestationController.dispose();
// // //     _descriptionController.dispose();
// // //     _onSetController.dispose();
// // //     _notesController.dispose();
// // //     super.dispose();
// // //   }
// // // }
// //
// // class _AllergyFormPageState extends State<AllergyFormPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _nameController = TextEditingController();
// //   final _onSetAgeController = TextEditingController();
// //   final _lastOccurrenceController = TextEditingController();
// //   final _notesController = TextEditingController();
// //   bool _discoveredDuringEncounter = false;
// //
// //   // Add controllers/dropdowns for code types (type, clinicalStatus, etc.)
// //   CodeModel? _selectedType;
// //   CodeModel? _selectedClinicalStatus;
// //   CodeModel? _selectedVerificationStatus;
// //   CodeModel? _selectedCategory;
// //   CodeModel? _selectedCriticality;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.allergyId != null) {
// //       context.read<AllergyCubit>().getAllergyDetails(
// //         patientId: widget.patientId,
// //         allergyId: widget.allergyId!,
// //       );
// //     }
// //     // Load code types here using your CodeTypesCubit
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.allergyId == null ? 'Add Allergy' : 'Edit Allergy'),
// //       ),
// //       body: BlocConsumer<AllergyCubit, AllergyState>(
// //         listener: (context, state) {
// //           if (state is AllergyDetailsLoaded) {
// //             _populateForm(state.allergy);
// //           }
// //           if (state is AllergyCreated || state is AllergyUpdated) {
// //             Navigator.pop(context);
// //           }
// //         },
// //         builder: (context, state) {
// //           return SingleChildScrollView(
// //             padding: const EdgeInsets.all(16),
// //             child: Form(
// //               key: _formKey,
// //               child: Column(
// //                 children: [
// //                   TextFormField(
// //                     controller: _nameController,
// //                     decoration: const InputDecoration(labelText: 'Name*'),
// //                     validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
// //                   ),
// //
// //                   // Add similar fields for other properties
// //                   TextFormField(
// //                     controller: _onSetAgeController,
// //                     decoration: const InputDecoration(labelText: 'Onset Age'),
// //                   ),
// //
// //                   // Date picker for last occurrence
// //                   TextFormField(
// //                     controller: _lastOccurrenceController,
// //                     decoration: const InputDecoration(labelText: 'Last Occurrence'),
// //                     onTap: () => _selectDate(context, _lastOccurrenceController),
// //                   ),
// //
// //                   // Code type dropdowns (example for type)
// //                   // DropdownButtonFormField<CodeModel>(
// //                   //   value: _selectedType,
// //                   //   decoration: const InputDecoration(labelText: 'Type'),
// //                   //   items: context.read<CodeTypesCubit>().state.allergyTypes.map((type) {
// //                   //     return DropdownMenuItem(
// //                   //       value: type,
// //                   //       child: Text(type.display),
// //                   //     );
// //                   //   }).toList(),
// //                   //   onChanged: (value) => setState(() => _selectedType = value),
// //                   // ),
// //
// //                   // Add similar dropdowns for other code types
// //
// //                   // Checkbox for discovered during encounter
// //                   CheckboxListTile(
// //                     title: const Text('Discovered during encounter'),
// //                     value: _discoveredDuringEncounter,
// //                     onChanged: (value) => setState(() => _discoveredDuringEncounter = value ?? false),
// //                   ),
// //
// //                   // Notes field
// //                   TextFormField(
// //                     controller: _notesController,
// //                     decoration: const InputDecoration(labelText: 'Notes'),
// //                     maxLines: 3,
// //                   ),
// //
// //                   const SizedBox(height: 20),
// //                   ElevatedButton(
// //                     onPressed: _submitForm,
// //                     child: Text(widget.allergyId == null ? 'Create' : 'Update'),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   void _populateForm(AllergyModel allergy) {
// //     _nameController.text = allergy.name ?? '';
// //     _onSetAgeController.text = allergy.onSetAge ?? '';
// //     _lastOccurrenceController.text = allergy.lastOccurrence ?? '';
// //     _discoveredDuringEncounter = allergy.discoveredDuringEncounter == "1";
// //     _notesController.text = allergy.note ?? '';
// //     _selectedType = allergy.type;
// //     _selectedClinicalStatus = allergy.clinicalStatus;
// //     // Set other code type values similarly
// //   }
// //
// //   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(1900),
// //       lastDate: DateTime.now(),
// //     );
// //     if (picked != null) {
// //       controller.text = picked.toIso8601String().split('T')[0];
// //     }
// //   }
// //
// //   void _submitForm() {
// //     if (_formKey.currentState?.validate() ?? false) {
// //       final allergy = AllergyModel(
// //         id: widget.allergyId?.toString(),
// //         name: _nameController.text,
// //         onSetAge: _onSetAgeController.text,
// //         lastOccurrence: _lastOccurrenceController.text,
// //         discoveredDuringEncounter: _discoveredDuringEncounter ? "1" : "0",
// //         note: _notesController.text.isEmpty ? null : _notesController.text,
// //         type: _selectedType,
// //         clinicalStatus: _selectedClinicalStatus,
// //         verificationStatus: _selectedVerificationStatus,
// //         category: _selectedCategory,
// //         criticality: _selectedCriticality,
// //         reactions: [], // You'll need to handle reactions separately
// //         encounter: null, // You'll need to handle encounter separately
// //       );
// //
// //       if (widget.allergyId == null) {
// //         context.read<AllergyCubit>().createAllergy(
// //           patientId: widget.patientId,
// //           allergy: allergy,
// //         );
// //       } else {
// //         context.read<AllergyCubit>().updateAllergy(
// //           patientId: widget.patientId,
// //           allergyId: widget.allergyId!,
// //           allergy: allergy,
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _onSetAgeController.dispose();
// //     _lastOccurrenceController.dispose();
// //     _notesController.dispose();
// //     super.dispose();
// //   }
// // }