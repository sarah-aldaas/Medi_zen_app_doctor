import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class QualificationErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const QualificationErrorWidget(this.error, this.onRetry, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: isDarkMode ? Colors.red[300] : Colors.red,
              size: 60,
            ),
            const Gap(16),
            Text(
              '${'qualificationPage.errorMessage'.tr(context)}: $error',
              style: TextStyle(
                color: isDarkMode ? Colors.red[300] : Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                color:
                    Theme.of(context).buttonTheme.colorScheme?.onPrimary ??
                    Colors.white,
              ),
              label: Text(
                'common.retry'.tr(context),
                style: TextStyle(
                  color:
                      Theme.of(context).buttonTheme.colorScheme?.onPrimary ??
                      Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
