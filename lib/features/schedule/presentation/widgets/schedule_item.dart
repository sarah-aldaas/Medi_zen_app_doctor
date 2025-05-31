import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/model/schedule_model.dart';

class ScheduleItem extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;

  const ScheduleItem({
    required this.schedule,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: schedule.active
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            schedule.active ? Icons.check : Icons.close,
            color: schedule.active ? Colors.green : Colors.red,
          ),
        ),
        title: Text(schedule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${DateFormat('MMM d, y').format(schedule.planningHorizonStart)} - '
                '${DateFormat('MMM d, y').format(schedule.planningHorizonEnd)}'),
            if (schedule.comment != null)
              Text(schedule.comment!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}