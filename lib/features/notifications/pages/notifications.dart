// import 'package:flutter/material.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
//
// class NotificationPage extends StatelessWidget {
//   const NotificationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title: Text(
//           'notificationPage.notification'.tr(context),
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.grey),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert, color: Colors.grey),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: ListView(
//         children: <Widget>[
//           _buildNotificationItem(
//             context: context,
//
//             icon: Icons.cancel,
//             title: 'Appointment Cancelled!',
//             date: 'Today | 15:36 PM',
//             message:
//                 'You have successfully canceled your appointment with Dr. Alan Watson on December 24, 2024. 13:00 p.m. 80% of the funds will be returned to your account.',
//           ),
//           _buildNotificationItem(
//             context: context,
//
//             icon: Icons.calendar_today,
//             title: 'Schedule Changed',
//             date: 'Yesterday | 09:23 AM',
//             message:
//                 'You have successfully changed schedule an appointment with Dr. Alan Watson on December 24, 2024, 13:00 pm. Don\'t forget to activate your reminder.',
//           ),
//           _buildNotificationItem(
//             context: context,
//
//             icon: Icons.check_circle,
//             title: 'Appointment Success!',
//             date: '19 Dec, 2022 | 18:35 PM',
//             message:
//                 'You have successfully booked an appointment with Dr. Alan Watson on December 24, 2024, 10:00 am. Don\'t forget to activate your reminder.',
//           ),
//           _buildNotificationItem(
//             context: context,
//
//             icon: Icons.stars,
//             title: 'New Services Available!',
//             date: '14 Dec, 2022 | 10:52 AM',
//             message:
//                 'You can now make multiple doctoral appointments at once. You can also cancel your appointment.',
//           ),
//           _buildNotificationItem(
//             context: context,
//             icon: Icons.credit_card,
//             title: 'Credit Card Connected!',
//             date: '12 Dec, 2022 | 15:38 PM',
//             message:
//                 'Your credit card has been successfully linked with Medica. Enjoy our service.',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationItem({
//     required IconData icon,
//     required String title,
//     required String date,
//     required String message,
//     required BuildContext context,
//   }) {
//     return Column(
//       children: [
//         ListTile(
//           leading: Container(
//             padding: EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Icon(icon, color: Theme.of(context).primaryColor),
//           ),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Text(
//                   'notificationPage.new'.tr(context),
//                   style: TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//               ),
//             ],
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
//               SizedBox(height: 4),
//               Text(message),
//             ],
//           ),
//           onTap: () {},
//         ),
//         Divider(),
//       ],
//     );
//   }
// }
