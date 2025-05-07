// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';
//
// import '../cubit/appointment_cubit.dart';
//
// class MyAppointmentPage extends StatefulWidget {
//   const MyAppointmentPage({super.key});
//
//   @override
//   State<MyAppointmentPage> createState() => _MyAppointmentPageState();
// }
//
// class _MyAppointmentPageState extends State<MyAppointmentPage> {
//   int _selectedTab = 0; // 0 for Upcoming, 1 for Completed
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AppointmentCubit(),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           title: Text(
//             "مواعيدي",
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.search, color: Colors.grey),
//               onPressed: () {
//                 // Handle search
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.more_vert, color: Colors.grey),
//               onPressed: () {
//                 // Handle more options
//               },
//             ),
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(48.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildTabButton("المواعيد القادمة", 0),
//                 _buildTabButton("المواعيد المكتملة", 1),
//               ],
//             ),
//           ),
//         ),
//         body: _buildAppointmentList(),
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String label, int index) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTab = index),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: _selectedTab == index
//                   ? Theme.of(context).primaryColor
//                   : Colors.transparent,
//               width: 2.0,
//             ),
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: _selectedTab == index
//                 ? Theme.of(context).primaryColor
//                 : Colors.grey,
//             fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppointmentList() {
//     List<Appointment> appointments = [];
//     final cubit = context.read<AppointmentCubit>();
//
//     if (_selectedTab == 0) {
//       appointments = cubit.state.upcomingAppointments;
//     } else if (_selectedTab == 1) {
//       appointments = cubit.state.completedAppointments;
//     }
//
//     return ListView.builder(
//       itemCount: appointments.length,
//       itemBuilder: (context, index) {
//         return _buildAppointmentItem(appointments[index]);
//       },
//     );
//   }
//
//   Widget _buildAppointmentItem(Appointment appointment) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.asset(
//                   appointment.imageUrl,
//                   height: 80,
//                   width: 80,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const Gap(15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       appointment.patientFullName,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       appointment.appointmentType,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     const Gap(5),
//                     Text(
//                       '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} | ${appointment.appointmentTime}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                     const Gap(5),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8.0,
//                         vertical: 4.0,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).primaryColor.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Text(
//                         appointment.status!,
//                         style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
