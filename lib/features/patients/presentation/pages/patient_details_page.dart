import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';

import '../../data/models/patient_model.dart';
import '../cubit/patient_cubit/patient_cubit.dart';


class PatientDetailsPage extends StatelessWidget {
  final String patientId;

  const PatientDetailsPage({required this.patientId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/patients/$patientId/edit'),
          ),
        ],
      ),
      body: BlocConsumer<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is PatientDetailsLoaded) {
            return _buildPatientDetails(context, state.patient);
          } else if (state is PatientLoading) {
            return const Center(child: LoadingPage());
          } else {
            context.read<PatientCubit>().showPatient(int.parse(patientId));
            return const Center(child: LoadingPage());
          }
        },
      ),
    );
  }

  Widget _buildPatientDetails(BuildContext context, PatientModel patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                patient.fName?.substring(0, 1) ?? 'P',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${patient.fName} ${patient.lName}',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          const Divider(),
          _buildDetailItem(context, 'Email', patient.email, Icons.email),
          if (patient.dateOfBirth != null)
            _buildDetailItem(
              context,
              'Date of Birth',
              DateFormat('MMM d, y').format(DateTime.parse(patient.dateOfBirth!)),
              Icons.cake,
            ),
          if (patient.gender != null)
            _buildDetailItem(
              context,
              'Gender',
              patient.gender!.display,
              Icons.person,
            ),
          if (patient.maritalStatus != null)
            _buildDetailItem(
              context,
              'Marital Status',
              patient.maritalStatus!.display,
              Icons.favorite,
            ),
          if (patient.bloodType != null)
            _buildDetailItem(
              context,
              'Blood Type',
              patient.bloodType!.display,
              Icons.bloodtype,
            ),
          _buildDetailItem(
            context,
            'Status',
            patient.active == '1' ? 'Active' : 'Inactive',
            patient.active == '1' ? Icons.check_circle : Icons.cancel,
            color: patient.active == '1' ? Colors.green : Colors.red,
          ),
          _buildDetailItem(
            context,
            'Deceased',
            patient.deceasedDate != null ? 'Yes' : 'No',
            patient.deceasedDate != null ? Icons.warning : Icons.check,
            color: patient.deceasedDate != null ? Colors.red : Colors.green,
          ),
          if (patient.addressModel != null) ...[
            const Divider(),
            const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildDetailItem(
              context,
              'Address',
              patient.addressModel!.line ?? '',
              Icons.location_on,
            ),
            _buildDetailItem(
              context,
              'City',
              patient.addressModel!.city ?? '',
              Icons.location_city,
            ),
            _buildDetailItem(
              context,
              'Postal Code',
              patient.addressModel!.postalCode ?? '',
              Icons.markunread_mailbox,
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => context.read<PatientCubit>().toggleActiveStatus(int.parse(patient.id!)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: patient.active == '1' ? Colors.red : Colors.green,
                ),
                child: Text(patient.active == '1' ? 'Deactivate' : 'Activate'),
              ),
              ElevatedButton(
                onPressed: () => context.read<PatientCubit>().toggleDeceasedStatus(int.parse(patient.id!)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: patient.deceasedDate != null ? Colors.green : Colors.red,
                ),
                child: Text(patient.deceasedDate != null ? 'Mark Alive' : 'Mark Deceased'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context,
      String title,
      String value,
      IconData icon, {
        Color color = Colors.blue,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}