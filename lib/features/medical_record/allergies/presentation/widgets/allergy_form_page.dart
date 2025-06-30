import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/data/models/allergy_model.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../../../encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyFormPage extends StatefulWidget {
  final String patientId;
  final String? encounterId;
  final AllergyModel? allergy;
  String? appointmentId;

   AllergyFormPage({
    super.key,
    required this.patientId,
    this.encounterId,
    this.allergy,
    this.appointmentId
  });

  @override
  State<AllergyFormPage> createState() => _AllergyFormPageState();
}

class _AllergyFormPageState extends State<AllergyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _onSetAgeController = TextEditingController();
  final TextEditingController _lastOccurrenceController =
  TextEditingController();
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
    context.read<EncounterCubit>().getPatientEncounters(
      patientId: widget.patientId,
      perPage: 100,
    );

    if (widget.allergy != null) {
      _nameController.text = widget.allergy!.name ?? '';
      _onSetAgeController.text = widget.allergy!.onSetAge ?? '';
      _lastOccurrenceController.text = widget.allergy!.lastOccurrence ?? '';
      _noteController.text = widget.allergy!.note ?? '';
      _discoveredDuringEncounter =
          widget.allergy!.discoveredDuringEncounter == "1";
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
        title: Text(
          widget.allergy == null
              ? 'allergyFormPage.appBarTitleAdd'.tr(context)
              : 'allergyFormPage.appBarTitleEdit'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.primaryColor,
          ),
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
                decoration: InputDecoration(
                  labelText: 'allergyFormPage.allergyNameLabel'.tr(context),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                value?.isEmpty ?? true
                    ? 'allergyFormPage.allergyNameRequired'.tr(context)
                    : null,
              ),
              const SizedBox(height: 20),

              _buildCodeDropdown(
                codeType: 'allergy_type',
                selectedItem: _selectedType,

                label: 'allergyFormPage.typeLabel'.tr(context),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 20),

              _buildCodeDropdown(
                codeType: 'allergy_clinical_status',
                selectedItem: _selectedClinicalStatus,
                label: 'allergyFormPage.clinicalStatusLabel'.tr(context),
                onChanged:
                    (value) => setState(() => _selectedClinicalStatus = value),
              ),
              const SizedBox(height: 20),

              _buildCodeDropdown(
                codeType: 'allergy_verification_status',
                selectedItem: _selectedVerificationStatus,
                label: 'allergyFormPage.verificationStatusLabel'.tr(context),
                onChanged:
                    (value) =>
                    setState(() => _selectedVerificationStatus = value),
              ),
              const SizedBox(height: 20),

              _buildCodeDropdown(
                codeType: 'allergy_category',
                selectedItem: _selectedCategory,
                label: 'allergyFormPage.categoryLabel'.tr(context),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 20),

              _buildCodeDropdown(
                codeType: 'allergy_criticality',
                selectedItem: _selectedCriticality,
                label: 'allergyFormPage.criticalityLabel'.tr(context),
                onChanged:
                    (value) => setState(() => _selectedCriticality = value),
              ),
              const SizedBox(height: 20),
              _buildEncounterDropdown(),
              const SizedBox(height: 20),

              TextFormField(
                controller: _onSetAgeController,
                decoration: InputDecoration(
                  labelText: 'allergyFormPage.onsetAgeLabel'.tr(context),
                  border: const OutlineInputBorder(),
                  suffixText: 'allergyFormPage.yearsSuffix'.tr(context),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _lastOccurrenceController,
                decoration: InputDecoration(
                  labelText: 'allergyFormPage.lastOccurrenceLabel'.tr(context),
                  border: const OutlineInputBorder(),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _lastOccurrenceController.text =
                    date.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 20),

              SwitchListTile(
                title: Text(
                  'allergyFormPage.discoveredDuringEncounter'.tr(context),
                ),
                value: _discoveredDuringEncounter,
                onChanged: (value) {
                  setState(() {
                    _discoveredDuringEncounter = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'allergyFormPage.notesLabel'.tr(context),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 35),

              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.allergy == null
                        ? 'allergyFormPage.saveAllergy'.tr(context)
                        : 'allergyFormPage.updateAllergy'.tr(context),
                  ),
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

          if (widget.allergy != null &&
              widget.allergy!.encounter == null &&
              widget.encounterId != null &&
              encounters.isNotEmpty) {
            _selectedEncounter = encounters.firstWhere(
                  (e) => e.id == widget.encounterId,
              orElse: () => encounters.first,
            );
          } else if (widget.allergy?.encounter != null) {
            _selectedEncounter = widget.allergy!.encounter;
          }

          return DropdownButtonFormField<EncounterModel>(
            decoration: InputDecoration(
              labelText: 'allergyFormPage.encounterLabel'.tr(context),
              border: const OutlineInputBorder(),
            ),
            value: _selectedEncounter,
            selectedItemBuilder: (context) {
              return encounters.map((encounter) {
                return Text(
                  encounter.reason ?? 'allergyFormPage.noReason'.tr(context),
                  style: TextStyle(fontSize: 14),
                );
              }).toList();
            },
            items:
            encounters.map((encounter) {
              return DropdownMenuItem<EncounterModel>(
                value: encounter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${encounter.reason}\n ${encounter.actualStartDate}" ??
                          'allergyFormPage.unknownType'.tr(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(),
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
          return const Center(child: CircularProgressIndicator());
        } else if (state is EncounterError) {
          return Text('allergyFormPage.errorLoadingEncounters'.tr(context));
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
          List<CodeModel> items =
              state.codes
                  ?.where((code) => code.codeTypeModel?.name == codeType)
                  .toList() ??
                  [];

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
            items:
            items.map((item) {
              return DropdownMenuItem<CodeModel>(
                value: item,
                child: Text(item.display),
              );
            }).toList(),
            onChanged: onChanged,
            validator:
                (value) =>
            value == null
                ? 'allergyFormPage.fieldRequired'.tr(context)
                : null,
          );
        }
        return const Center(child: CircularProgressIndicator());
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
    context: context, patientId: widget.patientId,
    appointmentId: widget.appointmentId!, allergy: allergy);
      } else {
        context.read<AllergyCubit>().updateAllergy( patientId: widget.patientId,appointmentId: widget.appointmentId!, allergyId: widget.allergy!.id!, allergy: allergy);
      }

      ShowToast.showToastSuccess(
        message:
        widget.allergy == null
            ? 'allergyFormPage.allergyCreatedSuccess'.tr(context)
            : 'allergyFormPage.allergyUpdatedSuccess'.tr(context),
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
