import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class RemoveFromFavoritesBottomSheet extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviews;

  RemoveFromFavoritesBottomSheet({
    required this.imageUrl,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(12.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("favorites.removeTitle".tr(context), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.0),
          ListTile(
            leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
            title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("favorites.doctorInfo.specialtyHospital".tr(context).format([specialty, hospital])),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.blue),
                    Text("favorites.doctorInfo.rating".tr(context).format([rating.toString(), reviews.toString()])),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("favorites.buttons.cancel".tr(context)),
                style: TextButton.styleFrom(backgroundColor: Colors.grey),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("favorites.buttons.confirmRemove".tr(context)),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.blue, backgroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage remains the same:
// showModalBottomSheet(
//   context: context,
//   builder: (BuildContext context) {
//     return RemoveFromFavoritesBottomSheet(
//       imageUrl: 'YOUR_IMAGE_URL',
//       name: 'Dr. Travis Westaby',
//       specialty: 'Cardiologists',
//       hospital: 'Alka Hospital',
//       rating: 4.3,
//       reviews: 5376,
//     );
//   },
// ).then((value) {
//   if (value == true) {
//     // Handle removal
//   }
// });
