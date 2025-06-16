import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart'; // Import your localization extension
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/cubit/patient_cubit/patient_cubit.dart';

import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/theme/app_color.dart';

class PatientFormPage extends StatefulWidget {
  final PatientModel initialPatient;

  const PatientFormPage({required this.initialPatient, super.key});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _familyController;
  late TextEditingController _givenController;
  late TextEditingController _prefixController;
  late TextEditingController _suffixController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _smokerController;
  late TextEditingController _alcoholDrinkerController;
  late TextEditingController _deceasedDateController;

  // Changed from String? to CodeModel?
  // Initialize with dummy or safe values if patient.gender is null,
  // ensure they are valid CodeModel instances or handle nulls properly later.
  late CodeModel _selectedGender = CodeModel(
    id: '',
    display: '',
    code: '',
    description: '',
    codeTypeId: '',
  );
  late CodeModel _selectedMaritalStatus = CodeModel(
    id: '',
    display: '',
    code: '',
    description: '',
    codeTypeId: '',
  );
  late CodeModel _selectedBloodType = CodeModel(
    id: '',
    display: '',
    code: '',
    description: '',
    codeTypeId: '',
  );

  DateTime? _dateOfBirth;
  DateTime? _deceasedDate;

  @override
  void initState() {
    super.initState();
    final patient = widget.initialPatient;

    _textController = TextEditingController(text: patient.text ?? '');
    _familyController = TextEditingController(text: patient.family ?? '');
    _givenController = TextEditingController(text: patient.given ?? '');
    _prefixController = TextEditingController(text: patient.prefix ?? '');
    _suffixController = TextEditingController(text: patient.suffix ?? '');
    _heightController = TextEditingController(text: patient.height ?? '');
    _weightController = TextEditingController(text: patient.weight ?? '');
    _smokerController = TextEditingController(text: patient.smoker ?? '0');
    _alcoholDrinkerController = TextEditingController(
      text: patient.alcoholDrinker ?? '0',
    );

    _dateOfBirthController = TextEditingController(
      text:
          patient.dateOfBirth != null
              ? DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.parse(patient.dateOfBirth!))
              : '',
    );

    _deceasedDateController = TextEditingController(
      text:
          patient.deceasedDate != null
              ? DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.parse(patient.deceasedDate!))
              : '',
    );

    // Initialize _selectedGender, _selectedMaritalStatus, _selectedBloodType
    // with actual patient data or fallback to a default/empty CodeModel
    _selectedGender =
        patient.gender ??
        CodeModel(
          id: '',
          display: '',
          code: '',
          description: '',
          codeTypeId: '',
        );
    _selectedMaritalStatus =
        patient.maritalStatus ??
        CodeModel(
          id: '',
          display: '',
          code: '',
          description: '',
          codeTypeId: '',
        );
    _selectedBloodType =
        patient.bloodType ??
        CodeModel(
          id: '',
          display: '',
          code: '',
          description: '',
          codeTypeId: '',
        );
  }

  @override
  void dispose() {
    _textController.dispose();
    _familyController.dispose();
    _givenController.dispose();
    _prefixController.dispose();
    _suffixController.dispose();
    _dateOfBirthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _smokerController.dispose();
    _alcoholDrinkerController.dispose();
    _deceasedDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final initialDate =
        isBirthDate
            ? (_dateOfBirth ?? DateTime.now())
            : (_deceasedDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
          _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _deceasedDate = picked;
          _deceasedDateController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(picked);
        }
      });
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelKey, // Changed to label key
    bool isDateField = false,
    bool isBirthDate = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelKey.tr(context), // Localized label
          border: const OutlineInputBorder(),
          suffixIcon: isDateField ? const Icon(Icons.calendar_today) : null,
        ),
        readOnly: isDateField,
        onTap: isDateField ? () => _selectDate(context, isBirthDate) : null,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'patientPage.please_enter'.tr(context) +
                labelKey.tr(context); // Localized validation
          }
          return null;
        },
      ),
    );
  }

  // This _buildDropdownField is not used for CodeModels, keep it as is if needed elsewhere,
  // otherwise it can be removed.
  // Widget _buildDropdownField({
  //   required String label,
  //   required List<DropdownMenuItem<String>> items,
  //   required String? value,
  //   required Function(String?) onChanged,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: DropdownButtonFormField<String>(
  //       value: value,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         border: const OutlineInputBorder(),
  //       ),
  //       items: items,
  //       onChanged: onChanged,
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return 'Please select $label';
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }

  Widget _buildToggleField({
    required String labelKey, // Changed to label key
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            labelKey.tr(context),
            style: const TextStyle(fontSize: 16),
          ), // Localized label
          const Spacer(),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildCodeDropdown({
    required String labelKey, // Changed to label key
    required Future<List<CodeModel>> codesFuture,
    required CodeModel? selectedValue,
    required Function(CodeModel?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FutureBuilder<List<CodeModel>>(
        future: codesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingButton();
          }

          if (snapshot.hasError) {
            return Text(
              'patientPage.error_loading'.tr(context) + labelKey.tr(context),
            ); // Localized error
          }

          final codes = snapshot.data ?? [];

          // Ensure selectedValue is one of the available codes or null
          // This logic can be simplified if initial setup handles it correctly
          final CodeModel? validSelectedValue;
          if (selectedValue != null &&
              codes.any((code) => code.id == selectedValue.id)) {
            validSelectedValue = codes.firstWhere(
              (code) => code.id == selectedValue.id,
            );
          } else if (codes.isNotEmpty) {
            // If initial selectedValue is not found, default to first available code or null
            // This prevents "There should be exactly one item with [DropdownButton]'s value" error
            validSelectedValue =
                null; // Or codes.first if you want a default selection
          } else {
            validSelectedValue = null;
          }

          return codes.isNotEmpty
              ? DropdownButtonFormField<CodeModel>(
                value: validSelectedValue,
                decoration: InputDecoration(
                  labelText: labelKey.tr(context), // Localized label
                  border: const OutlineInputBorder(),
                ),
                items:
                    codes.map((code) {
                      return DropdownMenuItem<CodeModel>(
                        value: code,
                        child: Text(code.display),
                      );
                    }).toList(),
                onChanged: onChanged,
                validator: (value) {
                  if (value == null || value.id.isEmpty) {
                    // Check value.id for emptiness
                    return 'patientPage.please_select'.tr(context) +
                        labelKey.tr(context); // Localized validation
                  }
                  return null;
                },
              )
              : Center(
                child: Text("patientPage.no_data_available".tr(context)),
              ); // Localized
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()),
        BlocProvider.value(value: context.read<PatientCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'patientPage.edit_patient_details'.tr(context), // Localized
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _submitForm,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        body: BlocConsumer<PatientCubit, PatientState>(
          listener: (context, state) {
            if (state is PatientUpdated) {
              // Assuming you want to go back to patient details page
              // after update. You might need to refresh the details page.
              context.pop();
            } else if (state is PatientError) {
              ShowToast.showToastError(message: state.error);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormField(
                      controller: _textController,
                      labelKey: 'patientPage.additional_text', // Key
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _familyController,
                      labelKey: 'patientPage.family_name', // Key
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _givenController,
                      labelKey: 'patientPage.given_name', // Key
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _prefixController,
                      labelKey: 'patientPage.prefix', // Key
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _suffixController,
                      labelKey: 'patientPage.suffix', // Key
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _dateOfBirthController,
                      labelKey: 'patientPage.date_of_birth', // Key
                      isDateField: true,
                      isBirthDate: true,
                    ),
                    Gap(10),
                    // Health Information
                    _buildFormField(
                      controller: _heightController,
                      labelKey: 'patientPage.height_cm', // Key
                      keyboardType: TextInputType.number,
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _weightController,
                      labelKey: 'patientPage.weight_kg', // Key
                      keyboardType: TextInputType.number,
                    ),
                    Gap(10),
                    _buildToggleField(
                      labelKey: 'patientPage.smoker_toggle', // Key
                      value: _smokerController.text == '1',
                      onChanged: (value) {
                        setState(() {
                          _smokerController.text = value ? '1' : '0';
                        });
                      },
                    ),
                    Gap(10),
                    _buildToggleField(
                      labelKey: 'patientPage.alcohol_drinker_toggle', // Key
                      value: _alcoholDrinkerController.text == '1',
                      onChanged: (value) {
                        setState(() {
                          _alcoholDrinkerController.text = value ? '1' : '0';
                        });
                      },
                    ),
                    Gap(10),
                    // Gender Dropdown
                    _buildCodeDropdown(
                      labelKey: 'patientPage.gender_dropdown', // Key
                      codesFuture:
                          context.read<CodeTypesCubit>().getGenderCodes(),
                      selectedValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    Gap(10),
                    // Marital Status Dropdown
                    _buildCodeDropdown(
                      labelKey: 'patientPage.marital_status_dropdown', // Key
                      codesFuture:
                          context
                              .read<CodeTypesCubit>()
                              .getMaritalStatusCodes(),
                      selectedValue: _selectedMaritalStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedMaritalStatus = value!;
                        });
                      },
                    ),

                    // Blood Type Dropdown - Uncomment and localize if needed
                    _buildCodeDropdown(
                      labelKey: 'patientPage.blood_type_dropdown',
                      codesFuture:
                          context.read<CodeTypesCubit>().getBloodGroupCodes(),
                      selectedValue: _selectedBloodType,
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value!;
                        });
                      },
                    ),
                    const Gap(20),
                    ElevatedButton(
                      onPressed: state is PatientLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.withOpacity(
                          0.7,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 3,
                      ),
                      child:
                          state is PatientLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'patientPage.save_changes'.tr(context),
                              ), // Localized
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedPatient = widget.initialPatient.copyWith(
        text: _textController.text,
        family: _familyController.text,
        given: _givenController.text,
        prefix: _prefixController.text,
        suffix: _suffixController.text,
        dateOfBirth: _dateOfBirth?.toIso8601String(),
        height: _heightController.text,
        weight: _weightController.text,
        smoker: _smokerController.text,
        alcoholDrinker: _alcoholDrinkerController.text,
        deceasedDate: _deceasedDate?.toIso8601String(),
        // Ensure that _selectedGender, _selectedMaritalStatus, _selectedBloodType
        // are not null before accessing their properties.
        genderId: _selectedGender.id.isNotEmpty ? _selectedGender.id : null,
        maritalStatusId:
            _selectedMaritalStatus.id.isNotEmpty
                ? _selectedMaritalStatus.id
                : null,
        bloodId:
            _selectedBloodType.id.isNotEmpty ? _selectedBloodType.id : null,
        gender: _selectedGender.id.isNotEmpty ? _selectedGender : null,
        maritalStatus:
            _selectedMaritalStatus.id.isNotEmpty
                ? _selectedMaritalStatus
                : null,
        bloodType: _selectedBloodType.id.isNotEmpty ? _selectedBloodType : null,
      );

      context.read<PatientCubit>().updatePatient(updatedPatient);
    } else {
      ShowToast.showToastError(
        message: "patientPage.all_fields_required".tr(context),
      ); // Localized toast
    }
  }
}
