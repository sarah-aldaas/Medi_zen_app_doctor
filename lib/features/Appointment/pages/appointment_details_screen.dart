import 'package:flutter/material.dart';

import '../../../base/theme/app_color.dart';
import '../model/appointments_model.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final onBackgroundColor = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الموعد',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 3,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.2),
                    radius: 40.0,
                    child: Icon(
                      Icons.person_outline,
                      color: primaryColor,
                      size: 40.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    appointment.patientName,
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      color: onBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: primaryColor,
                        size: 24.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        appointment.formattedTime,
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: primaryColor,
                        size: 24.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        appointment.formattedDate,
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      side: BorderSide(color: Colors.red[400]!),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إلغاء الموعد')),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 24.0,
                      color: Colors.red[400],
                    ),
                    label: Text(
                      'إلغاء الموعد',
                      style: TextStyle(fontSize: 18.0, color: Colors.red[400]),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تأكيد الموعد')),
                      );
                    },
                    icon: const Icon(Icons.check, size: 24.0),
                    label: const Text(
                      'تأكيد الموعد',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
