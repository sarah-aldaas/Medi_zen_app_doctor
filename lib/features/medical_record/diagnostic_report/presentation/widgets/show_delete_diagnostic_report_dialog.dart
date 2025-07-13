import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

Future<bool?> showDeleteDiagnosticReportDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "diagnosticReportDelete.confirmDelete".tr(context),
      ),
      content: Text(
        "diagnosticReportDelete.deleteConfirmationMessage".tr(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            "diagnosticReportDelete.cancel".tr(context),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            "diagnosticReportDelete.delete".tr(context),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

Future<bool?> showMakeFinalDiagnosticReportDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "diagnosticReportMakeFinal.confirmFinal".tr(context),
      ),
      content: Text(
        "diagnosticReportMakeFinal.makeFinalConfirmationMessage".tr(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            "diagnosticReportMakeFinal.cancel".tr(context),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            "diagnosticReportMakeFinal.confirm".tr(context),
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ],
    ),
  );
}