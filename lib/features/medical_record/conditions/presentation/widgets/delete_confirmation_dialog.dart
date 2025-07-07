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
      title: Text('deleteConfirmationDialog.title'.tr(context)), // Localized
      content: Text('deleteConfirmationDialog.content'.tr(context)), // Localized
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('deleteConfirmationDialog.cancelButton'.tr(context)), // Localized
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('deleteConfirmationDialog.deleteButton'.tr(context), style: const TextStyle(color: Colors.red)), // Localized
        ),
      ],
    );
  }
}