// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
//
// import '../../../../base/theme/app_color.dart';
// import '../../data/models/communication_model.dart';
//
// class CommunicationsPage extends StatefulWidget {
//   const CommunicationsPage({super.key, required this.list});
//   final List<CommunicationModel> list;
//
//   @override
//   State<CommunicationsPage> createState() => _CommunicationsPageState();
// }
//
// class _CommunicationsPageState extends State<CommunicationsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             context.pop();
//           },
//           icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
//         ),
//         title: Text(
//           'communicationsPage.title'.tr(context),
//           style: TextStyle(
//             color: AppColors.primaryColor,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Icon(Icons.language, color: AppColors.primaryColor),
//           ),
//         ],
//       ),
//       body:
//           widget.list.isEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.info_outline, size: 60, color: Colors.grey),
//                     const SizedBox(height: 16),
//                     Text(
//                       'communicationsPage.noCommunicationsFound'.tr(context),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       'communicationsPage.addCommunicationPreferences'.tr(
//                         context,
//                       ),
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               )
//               : Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Wrap(
//                   spacing: 8.0,
//                   runSpacing: 8.0,
//                   children:
//                       widget.list.map((communication) {
//                         final bool isPreferred =
//                             communication.preferred == true;
//                         return Chip(
//                           avatar: Icon(
//                             isPreferred ? Icons.check_circle : Icons.language,
//                             color:
//                                 isPreferred
//                                     ? Colors.white
//                                     : AppColors.primaryColor,
//                           ),
//                           label: Text(
//                             communication.language?.display ??
//                                 'communicationsPage.unknownLanguage'.tr(
//                                   context,
//                                 ),
//                             style: TextStyle(
//                               color:
//                                   isPreferred ? Colors.white : Colors.black87,
//                               fontWeight:
//                                   isPreferred
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                             ),
//                           ),
//                           backgroundColor:
//                               isPreferred
//                                   ? AppColors.primaryColor
//                                   : Colors.grey[200],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20.0),
//                             side: BorderSide(
//                               color:
//                                   isPreferred
//                                       ? AppColors.primaryColor
//                                       : Colors.grey,
//                               width: 1.0,
//                             ),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 8,
//                           ),
//                         );
//                       }).toList(),
//                 ),
//               ),
//     );
//   }
// }
