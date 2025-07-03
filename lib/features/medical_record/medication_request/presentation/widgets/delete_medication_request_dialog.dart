import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class DeleteMedicationRequestDialog extends StatelessWidget {
  final String medicationRequestId;
  final String patientId;
  final VoidCallback onConfirm;

  const DeleteMedicationRequestDialog({
    super.key,
    required this.medicationRequestId,
    required this.patientId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Medication Request'.tr(context)),
      content: Text('Are you sure you want to delete this medication request? This action cannot be undone.'.tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.tr(context)),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('Delete'.tr(context), style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}