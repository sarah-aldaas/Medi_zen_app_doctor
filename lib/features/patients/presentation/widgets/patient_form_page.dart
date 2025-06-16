import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  late CodeModel _selectedGender;
  late CodeModel _selectedMaritalStatus;
  late CodeModel _selectedBloodType;

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

    if (patient.gender != null) {
      _selectedGender = patient.gender!;
    }

    if (patient.maritalStatus != null) {
      _selectedMaritalStatus = patient.maritalStatus!;
    }

    if (patient.bloodType != null) {
      _selectedBloodType = patient.bloodType!;
    }
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
    required String label,
    bool isDateField = false,
    bool isBirthDate = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isDateField ? const Icon(Icons.calendar_today) : null,
        ),
        readOnly: isDateField,
        onTap: isDateField ? () => _selectDate(context, isBirthDate) : null,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildToggleField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

 Widget _buildCodeDropdown({
    required String label,
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
            return Text('Error loading $label');
          }

          final codes = snapshot.data ?? [];

          final validSelectedValue =
              selectedValue ??
              (codes.isNotEmpty
                  ? (codes.firstWhere(
                    (code) => code.id == selectedValue!.id,
                    orElse: () => codes.first,
                  ))
                  : null);

          return codes.isNotEmpty
              ? DropdownButtonFormField<CodeModel>(
                value: validSelectedValue,
               decoration: InputDecoration(
                  labelText: label,
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
                  if (value == null) {
                    return 'Please select $label';
                  }
                  return null;
                },
              )
              : const Center(child: Text("No data available"));
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
            'Edit Patient Details',
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
              context.pop();
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
                      label: 'Additional Text',
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _familyController,
                      label: 'Family Name',
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _givenController,
                      label: 'Given Name',
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _prefixController,
                      label: 'Prefix',
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _suffixController,
                      label: 'Suffix',
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _dateOfBirthController,
                      label: 'Date of Birth',
                      isDateField: true,
                      isBirthDate: true,
                    ),
                    Gap(10),
                    // Health Information
                    _buildFormField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      keyboardType: TextInputType.number,
                    ),
                    Gap(10),
                    _buildFormField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      keyboardType: TextInputType.number,
                    ),
                    Gap(10),
         _buildToggleField(
                      label: 'Smoker',
                      value: _smokerController.text == '1',
                      onChanged: (value) {
                        setState(() {
                          _smokerController.text = value ? '1' : '0';
                        });
                      },
                    ),
                    Gap(10),
                    _buildToggleField(
                      label: 'Alcohol Drinker',
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
                      label: 'Gender',
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
                      label: 'Marital Status',
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

                    _buildCodeDropdown(
                      label: 'Blood Type',
                      codesFuture: context.read<CodeTypesCubit>().getBloodGroupCodes(),
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
                              : const Text('Save Changes'),
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
        genderId: _selectedGender.id,
        maritalStatusId: _selectedMaritalStatus.id,
        bloodId: _selectedBloodType.id,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        bloodType: _selectedBloodType,
      );

      context.read<PatientCubit>().updatePatient(updatedPatient,context);
    } else {
      ShowToast.showToastError(message: "All field is required.");
    }
  }
}
