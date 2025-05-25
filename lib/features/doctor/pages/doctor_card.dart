import 'package:flutter/material.dart';

import '../../../base/theme/app_color.dart';
import '../../../base/theme/app_style.dart';

class DoctorCard extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String imagePath;

  DoctorCard({
    required this.doctorName,
    required this.specialization,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Card(
        color: AppColors.backgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctorName, style: AppStyles.titleStyle),
                    SizedBox(height: 8),
                    Text(specialization, style: AppStyles.primaryButtonStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
