// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../cubit/appointment_cubit.dart';
// import '../cubit/appointments_state.dart';
// import 'appointment_details_screen.dart';
//
// class AppointmentsListScreen extends StatelessWidget {
//   const AppointmentsListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AppointmentCubit(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'مواعيد المرضى',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           backgroundColor: Theme.of(context).primaryColor,
//           elevation: 2,
//         ),
//         body: BlocBuilder<AppointmentCubit, AppointmentState>(
//           builder: (context, state) {
//             return ListView.separated(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: state.appointments.length,
//               separatorBuilder:
//                   (context, index) => const SizedBox(height: 12.0),
//               itemBuilder: (context, index) {
//                 final appointment = state.appointments[index];
//                 return InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (context) => AppointmentDetailsScreen(
//                               appointment: appointment,
//                             ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10.0),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blueGrey.withOpacity(0.2),
//                           spreadRadius: 1,
//                           blurRadius: 5,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Theme.of(
//                               context,
//                             ).primaryColor.withOpacity(0.8),
//                             foregroundColor: Colors.white,
//                             child: Text(
//                               appointment.patientName[0].toUpperCase(),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16.0),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Text(
//                                   appointment.patientName,
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.w500,
//                                     color:
//                                         Theme.of(
//                                           context,
//                                         ).colorScheme.onBackground,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8.0),
//                                 Row(
//                                   children: <Widget>[
//                                     Icon(
//                                       Icons.access_time_outlined,
//                                       color: Theme.of(context).primaryColor,
//                                       size: 16.0,
//                                     ),
//                                     const SizedBox(width: 4.0),
//                                     Text(
//                                       'الوقت: ${appointment.formattedTime}',
//                                       style: const TextStyle(
//                                         fontSize: 14.0,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4.0),
//                                 Row(
//                                   children: <Widget>[
//                                     Icon(
//                                       Icons.calendar_today_outlined,
//                                       color: Theme.of(context).primaryColor,
//                                       size: 16.0,
//                                     ),
//                                     const SizedBox(width: 4.0),
//                                     Text(
//                                       'اليوم: ${appointment.formattedDate}',
//                                       style: const TextStyle(
//                                         fontSize: 14.0,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
