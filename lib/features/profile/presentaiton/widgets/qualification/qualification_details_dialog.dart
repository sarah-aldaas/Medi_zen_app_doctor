import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';

void showQualificationDetailsDialog(
  BuildContext context,
  QualificationModel qualification,
  Map<String, double> downloadProgress,
  Map<String, bool> downloadComplete,
  Function(String pdfUrl, String qualificationId) onDownloadAndViewPdf,
) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,

              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,

                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'qualificationPage.qualificationsDetails'.tr(context),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(dialogContext),
                icon: Icon(Icons.close, color: theme.secondaryHeaderColor),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'qualificationPage.issuer'.tr(context),
                  qualification.issuer!,
                ),
                Gap(10),
                _buildDetailRow(
                  'qualificationPage.type'.tr(context),
                  qualification.type!.display,
                ),
                Gap(10),
                _buildDetailRow(
                  'qualificationPage.startDate'.tr(context),
                  qualification.startDate!,
                ),
                Gap(10),
                _buildDetailRow(
                  'qualificationPage.endDate'.tr(context),
                  qualification.endDate ??
                      'qualificationPage.notApplicable'.tr(context),
                ),
                Gap(10),
                if (qualification.pdfFileName != null &&
                    qualification.pdfUrl != null) ...[
                  const Gap(10),
                  _buildDetailRow(
                    'qualificationPage.pdf'.tr(context),
                    qualification.pdfFileName!,
                  ),
                  const Gap(12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (downloadProgress.containsKey(
                        qualification.id.toString(),
                      ))
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value:
                                downloadProgress[qualification.id.toString()],
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),

                            backgroundColor:
                                isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade200,
                          ),
                        ),
                      ElevatedButton.icon(
                        icon: Icon(
                          downloadComplete[qualification.id.toString()] ?? false
                              ? Icons.check_circle
                              : Icons.visibility,
                          color:
                              theme.buttonTheme.colorScheme?.onPrimary ??
                              Colors.white,
                        ),
                        label: Text(
                          'qualificationPage.viewPdf'.tr(context),
                          style: TextStyle(
                            color:
                                theme.buttonTheme.colorScheme?.onPrimary ??
                                Colors.white,
                          ),
                        ),
                        onPressed:
                            downloadProgress.containsKey(
                                  qualification.id.toString(),
                                )
                                ? null
                                : () {
                                  onDownloadAndViewPdf(
                                    qualification.pdfUrl!,
                                    qualification.id.toString(),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'qualificationPage.close'.tr(context),
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
          ],
        ),
  );
}
