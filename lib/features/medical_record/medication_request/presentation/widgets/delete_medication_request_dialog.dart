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
      title: Text('deleteMedicationRequestDialog.title'.tr(context)),
      content: Text('deleteMedicationRequestDialog.confirm'.tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('deleteMedicationRequestDialog.cancel'.tr(context)),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(
            'deleteMedicationRequestDialog.delete'.tr(context),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
