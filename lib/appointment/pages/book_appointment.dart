import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class BookAppointmentPage extends StatefulWidget {
  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("bookAppointment.title".tr(context)),
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
              "bookAppointment.selectDate".tr(context),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day} ${_getMonthName(_selectedDate.month, context)}, ${_selectedDate.year}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "bookAppointment.selectHour".tr(context),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _buildTimeButtons(context),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle next button press
                },
                child: Text("bookAppointment.nextButton".tr(context)),
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

  List<Widget> _buildTimeButtons(BuildContext context) {
    final timeSlots = [
      "bookAppointment.timeSlots.0".tr(context),
      "bookAppointment.timeSlots.1".tr(context),
      "bookAppointment.timeSlots.2".tr(context),
      "bookAppointment.timeSlots.3".tr(context),
      "bookAppointment.timeSlots.4".tr(context),
      "bookAppointment.timeSlots.5".tr(context),
      "bookAppointment.timeSlots.6".tr(context),
      "bookAppointment.timeSlots.7".tr(context),
      "bookAppointment.timeSlots.8".tr(context),
      "bookAppointment.timeSlots.9".tr(context),
      "bookAppointment.timeSlots.10".tr(context),
      "bookAppointment.timeSlots.11".tr(context),
    ];

    return timeSlots.map((time) => _buildTimeButton(time, context)).toList();
  }

  Widget _buildTimeButton(String time, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTime = TimeOfDay(
            hour: int.parse(time.split(':')[0]),
            minute: int.parse(time.split(':')[1].split(' ')[0]),
          );
        });
      },
      child: Text(time),
      style: ElevatedButton.styleFrom(
        foregroundColor:
            _selectedTime != null &&
                    _selectedTime!.hour == int.parse(time.split(':')[0]) &&
                    _selectedTime!.minute ==
                        int.parse(time.split(':')[1].split(' ')[0])
                ? Colors.blue
                : Colors.grey[300],
        backgroundColor:
            _selectedTime != null &&
                    _selectedTime!.hour == int.parse(time.split(':')[0]) &&
                    _selectedTime!.minute ==
                        int.parse(time.split(':')[1].split(' ')[0])
                ? Colors.white
                : Colors.black,
      ),
    );
  }

  String _getMonthName(int month, BuildContext context) {
    switch (month) {
      case 1:
        return "bookAppointment.months.january".tr(context);
      case 2:
        return "bookAppointment.months.february".tr(context);
      case 3:
        return "bookAppointment.months.march".tr(context);
      case 4:
        return "bookAppointment.months.april".tr(context);
      case 5:
        return "bookAppointment.months.may".tr(context);
      case 6:
        return "bookAppointment.months.june".tr(context);
      case 7:
        return "bookAppointment.months.july".tr(context);
      case 8:
        return "bookAppointment.months.august".tr(context);
      case 9:
        return "bookAppointment.months.september".tr(context);
      case 10:
        return "bookAppointment.months.october".tr(context);
      case 11:
        return "bookAppointment.months.november".tr(context);
      case 12:
        return "bookAppointment.months.december".tr(context);
      default:
        return '';
    }
  }
}
