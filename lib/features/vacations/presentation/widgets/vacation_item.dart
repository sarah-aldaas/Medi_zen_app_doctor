import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../data/model/vacation_model.dart';

class VacationItem extends StatelessWidget {
  final VacationModel vacation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const VacationItem({
    required this.vacation,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.beach_access, color: Colors.white),
        ),
        title: Text(
          vacation.reason ?? 'vacationItem.defaultVacationTitle'.tr(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMM d, y').format(vacation.startDate!)} - '
              '${DateFormat('MMM d, y').format(vacation.endDate!)}',
            ),
            if (vacation.schedule != null)
              Text('vacationItem.scheduleLabel'.tr(context)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
