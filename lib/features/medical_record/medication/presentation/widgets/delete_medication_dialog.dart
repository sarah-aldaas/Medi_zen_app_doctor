import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';

class DeleteMedicationDialog extends StatelessWidget {
  final String medicationId;
  final String patientId;
  final VoidCallback onConfirm;

  const DeleteMedicationDialog({
    super.key,
    required this.medicationId,
    required this.patientId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "deleteMedicationDialog.title".tr(context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text("deleteMedicationDialog.confirm".tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "deleteMedicationDialog.cancel".tr(context),
            style: TextStyle(
              color: AppColors.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "deleteMedicationDialog.delete".tr(context),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
