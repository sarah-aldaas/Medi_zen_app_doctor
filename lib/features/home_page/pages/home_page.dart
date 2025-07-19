import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/pages/appointment_list_page.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/pages/articles_page.dart';

import '../../appointment/presentation/pages/previous_appointment_screen.dart';
import '../../profile/presentaiton/pages/profile.dart';
import 'home_page_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomePageBody(),
      // MedicalRecordPage(patientName: ''),
      ProfilePage(),
      AppointmentListPage(),
      ArticlesPage(),
      MyPreviousAppointmentPage(),
    ];

    return ThemeSwitchingArea(
      child: SafeArea(
        child: Scaffold(
          body: _widgetOptions.elementAt(
            _selectedIndex,
          ), // Remove the Center widget
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: context.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
