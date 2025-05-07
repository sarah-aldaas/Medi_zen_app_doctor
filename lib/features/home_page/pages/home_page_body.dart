import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medi_zen_app_doctor/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medi_zen_app_doctor/features/home_page/pages/widgets/search_field.dart';
import 'package:medi_zen_app_doctor/features/profile/profile.dart';

import '../../Appointment/pages/appointments_list_screen.dart';
import '../../Articales/Articales_screen.dart';
import '../../Doctor_schedule/DoctorScheduleScreen.dart';
import '../../Patients/patient_list_screen.dart';
import '../../previous_appointment/previous_appointment_screen.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final List<Map<String, dynamic>> jobCategories = [
    {
      'title': 'Patients',
      'icon': Icons.people_alt_outlined,
      'color': Colors.purple[100],
      'route': PatientListScreen(), // Ensure it's a const if possible
    },
    {
      'title': 'Doctor Schedule',
      'icon': Icons.date_range,
      'color': Colors.orange[100],
      'route': DoctorScheduleScreen(),
    },
    {
      'title': 'Articales',
      'icon': Icons.article_outlined,
      'color': Colors.green[100],
      'route': ArticaleListScreen(),
    },
    {
      'title': 'Appointmentes',
      'icon': Icons.access_time_outlined,
      'color': Colors.cyan[100],
      'route': AppointmentsListScreen(), // Ensure it's a const if possible
    },
    {
      'title': 'previous appointments',
      'icon': Icons.history,
      'color': Colors.blue[100],
      'route': MyPreviousAppointmentPage(),
    },
    {
      'title': 'profile',
      'icon': Icons.person,
      'color': Colors.pink[100],
      'route': ProfilePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                SearchField(),
                const DefinitionWidget(),
                const Gap(30),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find Jobs'.tr(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18.0,
                          mainAxisSpacing: 18.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: jobCategories.length,
                    itemBuilder: (context, index) {
                      final category = jobCategories[index];
                      return _buildJobCategoryCard(
                        title: category['title'],
                        icon: category['icon'],
                        color: category['color'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => category['route'],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, child: Icon(Icons.person)),
              SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingWidget(),
                  Text(
                    'Andrew Ainsley',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(children: [Icon(Icons.notifications_outlined)]),
        ],
      ),
    );
  }

  Widget _buildJobCategoryCard({
    required String title,
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40.0, color: Colors.black87),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
