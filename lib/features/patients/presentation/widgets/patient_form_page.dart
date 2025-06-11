import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/pages/edit_profile_screen.dart';

import '../../data/models/patient_model.dart';
import '../cubit/patient_cubit/patient_cubit.dart';


class PatientFormPage extends StatefulWidget {
  final PatientModel? initialPatient;

  const PatientFormPage({this.initialPatient, super.key});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fNameController;
  late TextEditingController _lNameController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    final patient = widget.initialPatient;
    _fNameController = TextEditingController(text: patient?.fName ?? '');
    _lNameController = TextEditingController(text: patient?.lName ?? '');
    _emailController = TextEditingController(text: patient?.email ?? '');
    _dateOfBirthController = TextEditingController(
      text: patient?.dateOfBirth != null
          ? DateFormat('MMM d, y').format(DateTime.parse(patient!.dateOfBirth!))
          : '',
    );
    _dateOfBirth = patient?.dateOfBirth != null
        ? DateTime.parse(patient!.dateOfBirth!)
        : null;
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('MMM d, y').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final patient = PatientModel(
        id: widget.initialPatient?.id,
        fName: _fNameController.text,
        lName: _lNameController.text,
        email: _emailController.text,
        dateOfBirth: _dateOfBirth?.toIso8601String(),
        active: widget.initialPatient?.active ?? '1',
        genderId: widget.initialPatient?.genderId,
        maritalStatusId: widget.initialPatient?.maritalStatusId,
        bloodId: widget.initialPatient?.bloodId,
        createdAt: widget.initialPatient?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        gender: widget.initialPatient?.gender,
        maritalStatus: widget.initialPatient?.maritalStatus,
        bloodType: widget.initialPatient?.bloodType,
        addressModel: widget.initialPatient?.addressModel,
        telecoms: widget.initialPatient?.telecoms,
      );

      if (widget.initialPatient == null) {

      } else {
        context.read<PatientCubit>().updatePatient(patient);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialPatient == null
            ? 'Create Patient'
            : 'Edit Patient'),
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
                  TextFormField(
                    controller: _fNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateOfBirthController,
                    decoration: const InputDecoration(labelText: 'Date of Birth'),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select date of birth';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  if (state is PatientLoading)
                     Center(child: LoadingButton())
                  else
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Save Patient'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}