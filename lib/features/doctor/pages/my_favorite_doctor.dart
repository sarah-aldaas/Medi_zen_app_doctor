// import 'package:flutter/material.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
//
// class MyFavoriteDoctorPage extends StatefulWidget {
//   @override
//   _MyFavoriteDoctorPageState createState() => _MyFavoriteDoctorPageState();
// }
//
// class _MyFavoriteDoctorPageState extends State<MyFavoriteDoctorPage> {
//   int _selectedFilter = 0;
//
//   List<Doctor> _doctors = [
//     Doctor(
//       imageUrl: 'YOUR_IMAGE_URL_1',
//       name: 'Dr. Travis Westaby',
//       specialty: 'Cardiologists',
//       hospital: 'Alka Hospital',
//       rating: 4.3,
//       reviews: 5376,
//     ),
//     // Add more doctors...
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("favoriteDoctors.title".tr(context)),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             tooltip: "favoriteDoctors.actions.search".tr(context),
//             onPressed: () {
//               // Handle search
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.more_vert),
//             tooltip: "favoriteDoctors.actions.more".tr(context),
//             onPressed: () {
//               // Handle more options
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(48.0),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterButton("favoriteDoctors.filters.all".tr(context), 0),
//                 _buildFilterButton("favoriteDoctors.filters.general".tr(context), 1),
//                 _buildFilterButton("favoriteDoctors.filters.dentist".tr(context), 2),
//                 _buildFilterButton("favoriteDoctors.filters.nutritionist".tr(context), 3),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: _filteredDoctors().length,
//         itemBuilder: (context, index) => _buildDoctorItem(_filteredDoctors()[index]),
//       ),
//     );
//   }
//
//   Widget _buildFilterButton(String text, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: ElevatedButton(
//           onPressed: () => setState(() => _selectedFilter = index),
//           child: Text(text),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _selectedFilter == index ? Colors.blue : Colors.grey[300],
//             foregroundColor: _selectedFilter == index ? Colors.white : Colors.black,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           )
//       ),
//     );
//   }
//
//   Widget _buildDoctorItem(Doctor doctor) {
//     return Column(
//       children: [
//         ListTile(
//           leading: CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage(doctor.imageUrl),
//           ),
//           title: Text(doctor.name, style: TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("favoriteDoctors.doctorInfo.specialtyHospital".tr(context).format([doctor.specialty, doctor.hospital])),
//               Row(
//                 children: [
//                   Icon(Icons.star, size: 16, color: Colors.blue),
//                   Text("favoriteDoctors.doctorInfo.rating".tr(context).format([doctor.rating.toString(), doctor.reviews.toString()])),
//                 ],
//               ),
//             ],
//           ),
//           trailing: IconButton(
//             icon: Icon(Icons.favorite_border),
//             onPressed: () => _showRemoveDialog(context, doctor),
//           ),
//           onTap: () {
//             // Navigate to doctor details
//           },
//         ),
//         Divider(),
//       ],
//     );
//   }
//
//   List<Doctor> _filteredDoctors() {
//     if (_selectedFilter == 0) return _doctors;
//
//     return _doctors.where((doctor) =>
//     doctor.specialty.toLowerCase() == _getFilterText(_selectedFilter).toLowerCase()
//     ).toList();
//   }
//
//   String _getFilterText(int index) {
//     switch (index) {
//       case 1: return "favoriteDoctors.filters.general".tr(context);
//       case 2: return "favoriteDoctors.filters.dentist".tr(context);
//       case 3: return "favoriteDoctors.filters.nutritionist".tr(context);
//       default: return '';
//     }
//   }
//
//   void _showRemoveDialog(BuildContext context, Doctor doctor) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("favoriteDoctors.removeDialog.title".tr(context)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: CircleAvatar(
//                   radius: 30,
//                   backgroundImage: NetworkImage(doctor.imageUrl),
//                 ),
//                 title: Text(doctor.name, style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("favoriteDoctors.doctorInfo.specialtyHospital".tr(context).format([doctor.specialty, doctor.hospital])),
//                     Row(
//                       children: [
//                         Icon(Icons.star, size: 16, color: Colors.blue),
//                         Text("favoriteDoctors.doctorInfo.rating".tr(context).format([doctor.rating.toString(), doctor.reviews.toString()])),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("favoriteDoctors.removeDialog.cancel".tr(context)),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() => _doctors.remove(doctor));
//                 Navigator.of(context).pop();
//               },
//               child: Text("favoriteDoctors.removeDialog.confirm".tr(context)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class Doctor {
//   final String imageUrl;
//   final String name;
//   final String specialty;
//   final String hospital;
//   final double rating;
//   final int reviews;
//
//   Doctor({
//     required this.imageUrl,
//     required this.name,
//     required this.specialty,
//     required this.hospital,
//     required this.rating,
//     required this.reviews,
//   });
// }