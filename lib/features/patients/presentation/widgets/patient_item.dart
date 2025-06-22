import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/patient_model.dart';

class PatientItem extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const PatientItem({required this.patient, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            patient.fName?.substring(0, 1).toUpperCase() ?? 'P',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${patient.fName ?? ''} ${patient.lName ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(6),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(patient.email ?? '', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Gap(12),
            if (patient.dateOfBirth != null)
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${'patientPage.dob_short'.tr(context)}: ${DateFormat('MMM d, y').format(DateTime.parse(patient.dateOfBirth!))}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              patient.active == '1' ? Icons.check_circle : Icons.cancel,
              color:
                  patient.active == '1'
                      ? Colors.green.shade600
                      : Colors.red.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
