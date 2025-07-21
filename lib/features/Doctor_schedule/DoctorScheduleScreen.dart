// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class DoctorScheduleScreen extends StatefulWidget {
//   @override
//   _DoctorScheduleScreenState createState() => _DoctorScheduleScreenState();
// }
//
// class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
//   late DateTime _currentMonth;
//   late Map<int, Set<int>> _schedule;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentMonth = DateTime.now();
//     _schedule = _loadInitialSchedule(_currentMonth);
//   }
//
//   Map<int, Set<int>> _loadInitialSchedule(DateTime month) {
//     final daysInMonth =
//         DateTimeRange(
//           start: DateTime(month.year, month.month, 1),
//           end: DateTime(month.year, month.month + 1, 0),
//         ).duration.inDays;
//     final initialSchedule = <int, Set<int>>{};
//     for (int i = 1; i <= daysInMonth; i++) {
//       initialSchedule[i] = <int>{9, 10, 11, 12, 13, 14};
//     }
//     return initialSchedule;
//   }
//
//   String _formatTime(int hour) {
//     final time = DateTime(2023, 1, 1, hour);
//     return DateFormat('hh:mm a').format(time);
//   }
//
//   void _addNewSchedule() {
//     print('Adding new schedule...');
//   }
//
//   void _stopSchedule(int day) {
//     setState(() {
//       _schedule[day]?.clear();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('جدول الدوام ', style: TextStyle(color: Colors.white)),
//         backgroundColor: primaryColor,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new_outlined),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(icon: Icon(Icons.add), onPressed: _addNewSchedule),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               DateFormat('MMMM yyyy', 'ar_SA').format(_currentMonth),
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Table(
//                   border: TableBorder.all(color: Colors.grey.shade300),
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(color: primaryColor),
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'اليوم',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'التاريخ',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'الساعات المتاحة',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'إيقاف الجدول',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     for (
//                       int day = 1;
//                       day <=
//                           DateTime(
//                             _currentMonth.year,
//                             _currentMonth.month + 1,
//                             0,
//                           ).day;
//                       day++
//                     )
//                       TableRow(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               DateFormat('EEEE', 'ar_SA').format(
//                                 DateTime(
//                                   _currentMonth.year,
//                                   _currentMonth.month,
//                                   day,
//                                 ),
//                               ),
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text('$day/${_currentMonth.month}'),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children:
//                                   _schedule[day]?.map((hour) {
//                                     return Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(_formatTime(hour)),
//                                         ),
//                                       ],
//                                     );
//                                   }).toList() ??
//                                   [Text('غير متاح')],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: IconButton(
//                               icon: Icon(Icons.stop, color: Colors.red),
//                               onPressed: () => _stopSchedule(day),
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
