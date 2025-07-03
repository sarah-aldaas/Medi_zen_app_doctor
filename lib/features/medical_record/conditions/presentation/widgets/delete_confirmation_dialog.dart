import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String conditionId;
  final String patientId;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.conditionId,
    required this.patientId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Condition'.tr(context)),
      content: Text('Are you sure you want to delete this condition? This action cannot be undone.'.tr(context)),
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