import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/patient_model.dart';

class PatientItem extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const PatientItem({
    required this.patient,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            patient.fName?.substring(0, 1) ?? 'P',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('${patient.fName} ${patient.lName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.email),
            if (patient.dateOfBirth != null)
              Text('DOB: ${DateFormat('MMM d, y').format(DateTime.parse(patient.dateOfBirth!))}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              patient.active == '1' ? Icons.check_circle : Icons.cancel,
              color: patient.active == '1' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}