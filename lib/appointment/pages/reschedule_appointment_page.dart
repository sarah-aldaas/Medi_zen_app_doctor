import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class RescheduleAppointmentPage extends StatefulWidget {
  @override
  _RescheduleAppointmentPageState createState() => _RescheduleAppointmentPageState();
}

class _RescheduleAppointmentPageState extends State<RescheduleAppointmentPage> {
  int _selectedValue = 0; // Default selected is "I'm having a schedule clash"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("rescheduleAppointment.title".tr(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "rescheduleAppointment.reasonTitle".tr(context),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildRadioButton("rescheduleAppointment.reasons.scheduleClash".tr(context), 0),
            _buildRadioButton("rescheduleAppointment.reasons.notAvailable".tr(context), 1),
            _buildRadioButton("rescheduleAppointment.reasons.importantActivity".tr(context), 2),
            _buildRadioButton("rescheduleAppointment.reasons.noReason".tr(context), 3),
            _buildRadioButton("rescheduleAppointment.reasons.other".tr(context), 4),
            SizedBox(height: 20),
            Text(
              "rescheduleAppointment.description".tr(context),
              style: TextStyle(fontSize: 14),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle next button press
                },
                child: Text("rescheduleAppointment.nextButton".tr(context)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(String text, int value) {
    return RadioListTile(
      title: Text(text),
      value: value,
      groupValue: _selectedValue,
      onChanged: (int? newValue) {
        setState(() {
          _selectedValue = newValue!;
        });
      },
    );
  }
}