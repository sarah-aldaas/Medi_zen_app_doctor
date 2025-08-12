import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';

import '../../cubit/qualification_cubit/qualification_cubit.dart';

class QualificationCard extends StatelessWidget {
  final QualificationModel qualification;
  final double? downloadProgress;
  final bool downloadComplete;
  final Function(String pdfUrl, String qualificationId) onDownloadAndViewPdf;
  final Function(QualificationModel qual) onEdit;
  final Function(String id) onDelete;
  final Function(QualificationModel qual) onViewDetails;

  const QualificationCard({
    super.key,
    required this.qualification,
    this.downloadProgress,
    required this.downloadComplete,
    required this.onDownloadAndViewPdf,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school_outlined, size: 22, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              qualification.issuer!,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDarkMode ? Colors.white : Colors.black87),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 22, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 10),
                          Text(qualification.type!.display, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 17, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(15),

            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 20, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 10),
                Text(
                  '${'qualificationPage.startDate'.tr(context)}: ${qualification.startDate}',
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                ),
              ],
            ),
            const Gap(15),
            if (qualification.endDate != null && qualification.endDate!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.event_note_outlined, size: 20, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 10),
                  Text(
                    '${'qualificationPage.endDate'.tr(context)}: ${qualification.endDate}',
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ],
              ),
            const Gap(15),

            if (qualification.pdfFileName != null && qualification.pdfUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        qualification.pdfFileName!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.blue[300] : Colors.blueAccent),
                      ),
                    ),

                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (downloadProgress != null)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: downloadProgress,
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(downloadComplete ? Colors.green.shade700 : Theme.of(context).primaryColor),

                                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                              ),
                            ),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                            },
                            child: IconButton(
                              key: ValueKey(downloadComplete ? 'check' : 'visibility'),
                              icon: Icon(
                                downloadComplete ? Icons.check : Icons.visibility,
                                color: downloadComplete ? Colors.green.shade700 : Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              onPressed: downloadProgress != null ? null : () => onDownloadAndViewPdf(qualification.pdfUrl!, qualification.id.toString()),
                              tooltip: 'qualificationPage.viewPdf'.tr(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Gap(16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: isDarkMode ? Colors.blueAccent : Colors.teal),
                  onPressed: () => onEdit(qualification),
                  tooltip: 'qualificationPage.edit'.tr(context),
                ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(qualification.id.toString()),
                      tooltip: 'qualificationPage.delete'.tr(context),

                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: isDarkMode ? Colors.orangeAccent : Colors.amber),
                  onPressed: () => onViewDetails(qualification),
                  tooltip: 'qualificationPage.details'.tr(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
