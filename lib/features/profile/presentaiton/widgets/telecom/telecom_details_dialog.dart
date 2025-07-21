import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../data/models/telecom_model.dart';

Widget _buildDetailRow(BuildContext context, String titleKey, String? value) {
  final ThemeData theme = Theme.of(context);
  final bool isDarkMode = theme.brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(Icons.star_border_purple500, color: theme.primaryColor),
        const SizedBox(width: 12),
        Text(
          titleKey.tr(context),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value ?? 'telecomPage.notAvailable'.tr(context),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}

void showTelecomDetailsDialog({
  required BuildContext context,
  required TelecomModel telecom,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        surfaceTintColor: theme.dialogTheme.surfaceTintColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'telecomPage.telecomDetails'.tr(dialogContext),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(dialogContext),
              child: Icon(Icons.close, color: theme.secondaryHeaderColor),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                dialogContext,
                "telecomPage.valueLabel",
                telecom.value,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                dialogContext,
                'telecomPage.typeLabel',
                telecom.type?.display,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                dialogContext,
                'telecomPage.useLabel',
                telecom.use?.display,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                dialogContext,
                'telecomPage.startDateLabel',
                telecom.startDate,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                dialogContext,
                'telecomPage.endDateLabel',
                telecom.endDate,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'telecomPage.cancel'.tr(dialogContext),
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 15,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
