import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../data/models/reaction_model.dart';

class ReactionListItem extends StatelessWidget {
  final ReactionModel reaction;
  final VoidCallback onTap;

  const ReactionListItem({
    super.key,
    required this.reaction,
    required this.onTap,
  });

  String _formatDateTime(BuildContext context, String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return 'reactionsPage.notApplicable'.tr(context);
    }
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM d, y - h:mm a').format(dateTime);
    } catch (e) {
      return 'reactionsPage.invalidDate'.tr(context);
    }
  }

  Widget _buildSeverityChip(BuildContext context, CodeModel? severity) {
    final ThemeData theme = Theme.of(context);
    Color chipColor;
    String displayText;

    switch (severity?.code?.toLowerCase()) {
      case 'mild':
        chipColor = Colors.green.withAlpha(40);
        displayText = 'reactions.severity.mild'.tr(context);
        break;
      case 'moderate':
        chipColor = Colors.orange.withAlpha(40);
        displayText = 'reactions.severity.moderate'.tr(context);
        break;
      case 'severe':
        chipColor = Colors.red.withAlpha(40);
        displayText = 'reactions.severity.severe'.tr(context);
        break;
      default:
        chipColor =
            (theme.textTheme.bodySmall?.color?.withAlpha(20)) ??
            Colors.grey.withAlpha(20);
        displayText = 'reactions.severity.not_applicable'.tr(context);
    }

    return Chip(
      label: Text(
        displayText,
        style: TextStyle(
          color: chipColor.withAlpha(200),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: chipColor.withAlpha(150), width: 0.8),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        reaction.manifestation ??
                            'reactionsPage.unknownReaction'.tr(
                              context,
                            ), // Translated
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildSeverityChip(context, reaction.severity),
                  ],
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  icon: Icons.science_outlined,
                  label: 'reactionsPage.substance'.tr(context),
                  value: reaction.substance,
                  context: context,
                ),
                const SizedBox(height: 8),

                _buildInfoRow(
                  icon: Icons.route_outlined,
                  label: 'reactionsPage.exposure'.tr(context),
                  value: reaction.exposureRoute?.display,
                  context: context,
                ),
                const SizedBox(height: 8),

                _buildInfoRowWithBackground(
                  icon: Icons.calendar_today_outlined,
                  label: 'reactionsPage.onset'.tr(context),
                  value: _formatDateTime(context, reaction.onSet),
                  context: context,
                ),
                const SizedBox(height: 8),

                if (reaction.description?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.description_outlined,
                    label: 'reactionsPage.description'.tr(context),
                    value: reaction.description,
                    context: context,
                  ),
                if (reaction.description?.isNotEmpty ?? false)
                  const SizedBox(height: 8),

                if (reaction.note?.isNotEmpty ?? false)
                  _buildInfoRow(
                    icon: Icons.note_alt_outlined,
                    label: 'reactionsPage.notes'.tr(context),
                    value: reaction.note,
                    context: context,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String? value,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.cyan,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'reactionsPage.notSpecified'.tr(context),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithBackground({
    required IconData icon,
    required String label,
    required String? value,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.label,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value ?? 'reactionsPage.notSpecified'.tr(context),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
