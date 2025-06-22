import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/pages/appointment_list_page.dart';
import 'package:medi_zen_app_doctor/features/clinics/pages/clinics_page.dart';
import 'package:medi_zen_app_doctor/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_list_screen.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/widgets/avatar_image_widget.dart';
import 'package:medi_zen_app_doctor/features/schedule/presentation/pages/schedule_list_page.dart';

import '../../../base/constant/storage_key.dart';
import '../../../base/go_router/go_router.dart';
import '../../../base/services/di/injection_container_common.dart';
import '../../../base/services/storage/storage_service.dart';
import '../../../base/theme/app_color.dart';
import '../../../main.dart';
import '../../Articales/Articales_screen.dart';
import '../../authentication/presentation/logout/cubit/logout_cubit.dart';
import '../../previous_appointment/previous_appointment_screen.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  int? _selectedLogoutOption;

  List<Map<String, dynamic>> _getJobCategories(BuildContext context) {
    return [
      {
        'title': 'homePage.patientsCategory'.tr(context),
        'icon': Icons.people_alt_outlined,
        'color': Colors.lightBlue[100],
        'route': PatientListPage(),
      },
      {
        'title': 'homePage.doctorScheduleCategory'.tr(context),
        'icon': Icons.date_range,
        'color': Colors.orange[100],
        'route': ScheduleListPage(),
      },
      {
        'title': 'homePage.appointmentsCategory'.tr(context),
        'icon': Icons.access_time_outlined,
        'color': Colors.teal[100],
        'route': AppointmentListPage(),
      },
      {
        'title': 'homePage.previousAppointmentsCategory'.tr(context),
        'icon': Icons.history,
        'color': Colors.blueGrey[100],
        'route': MyPreviousAppointmentPage(),
      },
      {
        'title': 'homePage.clinicsCategory'.tr(context),
        'icon': Icons.healing,
        'color': Colors.green[100],
        'route': ClinicsPage(),
      },
      {
        'title': 'homePage.articlesCategory'.tr(
          context,
        ),
        'icon': Icons.article_outlined,
        'color': Colors.brown[100],
        'route': ArticaleListScreen(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> localizedJobCategories = _getJobCategories(
      context,
    );

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const Gap(30),
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
                    itemCount: localizedJobCategories.length,
                    itemBuilder: (context, index) {
                      final category = localizedJobCategories[index];
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
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRouter.profileDetails.name);
            },
            child: Row(
              children: [
                AvatarImage(
                  imageUrl: "${loadingDoctorModel().avatar}",
                  radius: 20,
                ),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingWidget(),
                    Text(
                      "${loadingDoctorModel().fName} ${loadingDoctorModel().lName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              PopupMenuButton<String>(
                color: Theme.of(context).scaffoldBackgroundColor,
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  if (value == 'Settings') {
                    context.pushNamed(AppRouter.settings.name);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'Settings',
                        child: ListTile(
                          leading: const Icon(
                            Icons.settings,
                            color: AppColors.primaryColor,
                          ),
                          title: Text(
                            'profilePage.settings'.tr(context),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Logout',
                        child: BlocConsumer<LogoutCubit, LogoutState>(
                          listener: (context, state) {
                            if (state is LogoutSuccess) {
                              context.goNamed(AppRouter.login.name);
                            } else if (state is LogoutError) {
                              _selectedLogoutOption = null;
                              serviceLocator<StorageService>().removeFromDisk(
                                StorageKey.doctorModel,
                              );
                              context.goNamed(AppRouter.login.name);
                            }
                          },
                          builder: (context, state) {
                            return ExpansionTile(
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: Text(
                                'profilePage.logout'.tr(context),
                                style: TextStyle(color: Colors.red),
                              ),
                              children: [
                                RadioListTile<int>(
                                  title:
                                      state is LogoutLoadingOnlyThisDevice
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'profilePage.logoutThisDevice'
                                                    .tr(context),
                                              ),
                                              SizedBox(width: 10),
                                              LoadingAnimationWidget.hexagonDots(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                size: 25,
                                              ),
                                            ],
                                          )
                                          : Text(
                                            'profilePage.logoutThisDevice'.tr(
                                              context,
                                            ),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  value: 0,
                                  groupValue: _selectedLogoutOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLogoutOption = value;
                                    });
                                    context.read<LogoutCubit>().sendResetLink(
                                      0,
                                    );
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                                RadioListTile<int>(
                                  title:
                                      state is LogoutLoadingAllDevices
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'profilePage.logoutAllDevices'
                                                    .tr(context),
                                              ),
                                              SizedBox(width: 10),
                                              LoadingAnimationWidget.hexagonDots(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                size: 25,
                                              ),
                                            ],
                                          )
                                          : Text(
                                            'profilePage.logoutAllDevices'.tr(
                                              context,
                                            ),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  value: 1,
                                  groupValue: _selectedLogoutOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLogoutOption = value;
                                    });
                                    context.read<LogoutCubit>().sendResetLink(
                                      1,
                                    );
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
              ),
            ],
          ),
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
