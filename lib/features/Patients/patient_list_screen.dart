import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../base/theme/app_color.dart';
import '../../base/theme/app_style.dart';
import '../medical_record/Medical_Record.dart';
import 'cubit/patients_cubit.dart';
import 'cubit/patients_state.dart';
import 'model/patient_model.dart';

class PatientListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة المرضى', style: AppStyles.titleStyle),
          backgroundColor: AppColors.primaryColor,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<PatientCubit, PatientState>(
            builder: (context, state) {
              return ListView.builder(
                itemCount: state.patients.length,
                itemBuilder: (context, index) {
                  final patient = state.patients[index];
                  return _buildPatientCard(context, patient);
                },
              );
            },
          ),
        ),
        backgroundColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MedicalRecordPage(patientName: patient.name),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        children: [
                          const Text(
                            'الحالة:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            patient.condition,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getConditionColor(patient.condition),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'مستقرة':
        return Colors.green[400]!;
      case 'يتحسن':
        return Colors.orange[400]!;
      case 'بحاجة لمتابعة':
        return Colors.red[400]!;
      case 'تحت العلاج':
        return Colors.blue[400]!;
      case 'متعافية':
        return Colors.teal[400]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
