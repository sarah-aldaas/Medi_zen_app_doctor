import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorScheduleScreen extends StatefulWidget {
  @override
  _DoctorScheduleScreenState createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  late DateTime _currentMonth;
  late Map<int, Set<int>> _schedule;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _schedule = _loadInitialSchedule(_currentMonth);
  }

  Map<int, Set<int>> _loadInitialSchedule(DateTime month) {
    final daysInMonth =
        DateTimeRange(
          start: DateTime(month.year, month.month, 1),
          end: DateTime(month.year, month.month + 1, 0),
        ).duration.inDays;
    final initialSchedule = <int, Set<int>>{};
    for (int i = 1; i <= daysInMonth; i++) {
      initialSchedule[i] = <int>{};
    }
    return initialSchedule;
  }

  String _formatTime(int hour) {
    final time = DateTime(2023, 1, 1, hour);
    return DateFormat('hh:mm a').format(time);
  }

  void _toggleAvailability(int dayOfMonth, int hour) {
    setState(() {
      if (_schedule.containsKey(dayOfMonth)) {
        if (_schedule[dayOfMonth]!.contains(hour)) {
          _schedule[dayOfMonth]!.remove(hour);
        } else {
          _schedule[dayOfMonth]!.add(hour);
        }
      }
    });
  }

  Widget _buildAvailableDays(BuildContext context) {
    final availableDays =
        _schedule.entries.where((entry) => entry.value.isNotEmpty).toList();
    final primaryColor = Theme.of(context).primaryColor;
    final onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    if (availableDays.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'لا يوجد دوام محدد لهذا الشهر.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: availableDays.length,
      separatorBuilder:
          (context, index) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final dayEntry = availableDays[index];
        final dayOfMonth = dayEntry.key;
        final availableHours = dayEntry.value.toList()..sort();
        final firstDayOfMonth = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          1,
        );
        final weekday = DateFormat('EEEE', 'ar_SA').format(
          firstDayOfMonth.add(Duration(days: dayOfMonth - 1)),
        ); // عرض اسم اليوم باللغة العربية

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.8),
            foregroundColor: Colors.white,
            child: Text(
              '$dayOfMonth',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            weekday,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: onBackgroundColor,
            ),
          ),
          subtitle: Text(
            availableHours.map((hour) => _formatTime(hour)).join(', '),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM yyyy', 'ar_SA').format(_currentMonth),
          style: TextStyle(fontWeight: FontWeight.bold, color: onPrimary),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: onPrimary),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
                _schedule = _loadInitialSchedule(_currentMonth);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: onPrimary),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
                _schedule = _loadInitialSchedule(_currentMonth);
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'أيام وساعات الدوام المحددة:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(child: _buildAvailableDays(context)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                print('Schedule to be saved: $_schedule');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ الجدول! (لم يتم التنفيذ الفعلي)'),
                  ),
                );
              },
              child: const Text('حفظ الجدول', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
