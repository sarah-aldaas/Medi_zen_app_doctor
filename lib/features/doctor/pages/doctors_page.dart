// import 'package:flutter/material.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
// import 'package:medizen_app/base/extensions/media_query_extension.dart';
// import '../data/model/doctor_model.dart';
// import 'mixin/doctor_mixin.dart';
//
// class DoctorsPage extends StatefulWidget with DoctorMixin {
//   DoctorsPage({super.key});
//
//   @override
//   allDoctorsPageState createState() => allDoctorsPageState();
// }
//
// class allDoctorsPageState extends State<DoctorsPage> {
//   int _selectedFilter = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(-10),
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title: Text(
//             "doctorsPage.title".tr(context),
//             style: TextStyle(fontWeight: FontWeight.bold)
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.grey),
//             tooltip: "search",
//             onPressed: () {
//               // Handle search
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(48.0),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   _buildFilterButton("doctorsPage.filters.all".tr(context), 0),
//                   _buildFilterButton("doctorsPage.filters.general".tr(context), 1),
//                   _buildFilterButton("doctorsPage.filters.dentist".tr(context), 2),
//                   _buildFilterButton("doctorsPage.filters.nutritionist".tr(context), 3),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(bottom: 20.0),
//         child: ListView.builder(
//           itemCount: _filteredDoctors().length,
//           itemBuilder: (context, index) => _buildDoctorItem(_filteredDoctors()[index]),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterButton(String text, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: ElevatedButton(
//         onPressed: () => setState(() => _selectedFilter = index),
//         child: Text(text),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _selectedFilter == index
//               ? Theme.of(context).primaryColor
//               : Theme.of(context).scaffoldBackgroundColor,
//           foregroundColor: _selectedFilter == index ? Colors.white : Colors.black,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//             side: BorderSide(color: Theme.of(context).primaryColor),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDoctorItem(DoctorModel doctor) {
//     return Column(
//       children: [
//         Container(
//           width: context.width,
//           padding: const EdgeInsets.only(top: 10.0, left: 20, right: 20),
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Image.asset(
//                         doctor.avatar!,
//                         height: 100,
//                         width: 100,
//                         fit: BoxFit.fill
//                     ),
//                   ),
//                   SizedBox(
//                     width: context.width / 1.9,
//                     child: Column(
//                       children: [
//                       Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                             doctor.fName!,
//                             style: TextStyle(fontWeight: FontWeight.bold)
//                         ),
//                         Spacer(),
//                         IconButton(
//                           onPressed: () {},
//                           icon: Icon(Icons.favorite_border)
//                         )],
//                         ),
//                         Divider(),
//                         Text(
//                           '${doctor.text} | ${doctor.text}',
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         Row(
//                           children: [
//                             Icon(
//                                 Icons.star,
//                                 size: 16,
//                                 color: Theme.of(context).primaryColor
//                             ),
//                             Text('${doctor.id} (${doctor.id} ${"doctorsPage.reviews".tr(context)})')
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<DoctorModel> _filteredDoctors() {
//     if (_selectedFilter == 0) return widget.allDoctors;
//
//     return widget.allDoctors.where((doctor) =>
//     doctor.text!.toLowerCase() == _getFilterText(_selectedFilter).toLowerCase()
//     ).toList();
//   }
//
//   String _getFilterText(int index) {
//     switch (index) {
//       case 1: return "doctorsPage.filters.general".tr(context);
//       case 2: return "doctorsPage.filters.dentist".tr(context);
//       case 3: return "doctorsPage.filters.nutritionist".tr(context);
//       default: return '';
//     }
//   }
// }