import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';

import '../../data/model/schedule_model.dart';

class ScheduleItem extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;

  const ScheduleItem({required this.schedule, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bool isActive = schedule.active;
    final Color statusColor =
        isActive ? Colors.green.shade600 : Colors.red.shade600;

    final Color statusLightColor =
        isActive
            ? (isDarkMode ? Colors.green.shade900 : Colors.green.shade100)
            : (isDarkMode ? Colors.red.shade900 : Colors.red.shade100);

    final IconData statusIcon =
        isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined;

    final Color scheduleNameColor = isDarkMode ? Colors.white : Colors.black87;

    final Color detailTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusLightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const Gap(6),
                        Text(
                          isActive
                              ? 'schedulePage.status_active'.tr(context)
                              : 'schedulePage.status_inactive'.tr(context),
                          style: textTheme.labelLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ],
              ),
              const Gap(15),
              Text(
                schedule.name,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheduleNameColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: primaryColor,
                    size: 16,
                  ),
                  const Gap(8),
                  Text(
                    '${DateFormat('MMM d, y').format(schedule.planningHorizonStart)} - '
                    '${DateFormat('MMM d, y').format(schedule.planningHorizonEnd)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: detailTextColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (schedule.comment != null && schedule.comment!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    Row(
                      children: [
                        Icon(
                          Icons.notes_outlined,
                          color: primaryColor,
                          size: 16,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            schedule.comment!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: detailTextColor,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
