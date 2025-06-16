// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
// import 'package:medi_zen_app_doctor/features/appointment/presentation/pages/appointment_list_page.dart';
// import 'package:medi_zen_app_doctor/features/clinics/pages/clinics_page.dart';
// import 'package:medi_zen_app_doctor/features/home_page/pages/widgets/greeting_widget.dart';
// import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_list_screen.dart';
// import 'package:medi_zen_app_doctor/features/schedule/presentation/pages/schedule_list_page.dart';
//
// import '../../../base/blocs/localization_bloc/localization_bloc.dart';
// import '../../../base/constant/app_images.dart';
// import '../../../base/constant/storage_key.dart';
// import '../../../base/go_router/go_router.dart';
// import '../../../base/services/di/injection_container_common.dart';
// import '../../../base/services/storage/storage_service.dart';
// import '../../../base/theme/theme.dart';
// import '../../Articales/Articales_screen.dart';
// import '../../authentication/data/models/doctor_model.dart';
// import '../../authentication/presentation/logout/cubit/logout_cubit.dart';
// import '../../previous_appointment/previous_appointment_screen.dart';
//
// class HomePageBody extends StatefulWidget {
//   const HomePageBody({super.key});
//
//   @override
//   State<HomePageBody> createState() => _HomePageBodyState();
// }
//
// class _HomePageBodyState extends State<HomePageBody> {
//   final List<Map<String, dynamic>> jobCategories = [
//     {
//       'title': 'patients',
//       'icon': Icons.people_alt_outlined,
//       'color': Colors.lightBlue[100],
//       'route': PatientListPage(),
//     },
//     {
//       'title': 'Doctor Schedule',
//       'icon': Icons.date_range,
//       'color': Colors.orange[100],
//       'route': ScheduleListPage(),
//     },
//     {
//       'title': 'Appointmentes',
//       'icon': Icons.access_time_outlined,
//       'color': Colors.teal[100],
//       'route': AppointmentListPage(),
//     },
//     {
//       'title': 'previous appointments',
//       'icon': Icons.history,
//       'color': Colors.blueGrey[100],
//       'route': MyPreviousAppointmentPage(),
//     },
//     {
//       'title': 'Clinics',
//       'icon': Icons.healing,
//       'color': Colors.green[100],
//       'route': ClinicsPage(),
//     },
//
//     {
//       'title': 'Articales',
//       'icon': Icons.article_outlined,
//       'color': Colors.brown[100],
//       'route': ArticaleListScreen(),
//     },
//   ];
//   int? _selectedLogoutOption;
//
//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;
//     final darkerPrimaryColor = primaryColor.withOpacity(0.8);
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         appBar: _buildHeader(context),
//         endDrawer: Drawer(
//           elevation: 5,
//           child: Column(
//             children: <Widget>[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [primaryColor.withOpacity(0.9), darkerPrimaryColor],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomRight: Radius.circular(30),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       spreadRadius: 2,
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         image: DecorationImage(
//                           image: AssetImage(AppAssetImages.logoGreenPng),
//                           fit: BoxFit.cover,
//                         ),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.7),
//                           width: 1,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             spreadRadius: 1,
//                             blurRadius: 5,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     const Text(
//                       'MediZen Doctor',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         shadows: [
//                           Shadow(
//                             offset: Offset(1.0, 1.0),
//                             blurRadius: 3.0,
//                             color: Color.fromARGB(150, 0, 0, 0),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       'home.welcome'.tr(context),
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 17,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Gap(15),
//
//               ListTile(
//                 leading: Icon(Icons.person, color: primaryColor),
//                 title: Text('profilePage.profile'.tr(context)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   context.pushNamed(AppRouter.profileDetails.name);
//                 },
//               ),
//
//               const Gap(15),
//               ThemeSwitcher.withTheme(
//                 builder: (_, switcher, theme) {
//                   return ListTile(
//                     leading: Icon(
//                       theme.brightness == Brightness.light
//                           ? Icons.brightness_3
//                           : Icons.brightness_3,
//                       size: 25,
//                       color: primaryColor,
//                     ),
//                     title: Text(
//                       theme.brightness == Brightness.light
//                           ? 'profilePage.darkMode'.tr(context)
//                           : 'profilePage.lightMode'.tr(context),
//                     ),
//                     onTap:
//                         () => switcher.changeTheme(
//                       theme:
//                       theme.brightness == Brightness.light
//                           ? darkTheme
//                           : lightTheme,
//                     ),
//                   );
//                 },
//               ),
//               const Gap(15),
//               ListTile(
//                 leading: Icon(Icons.language, color: primaryColor),
//                 title: Text('profilePage.changeLanguage'.tr(context)),
//                 onTap: () {
//                   final bloc = context.read<LocalizationBloc>();
//                   if (bloc.isArabic()) {
//                     bloc.add(const ChangeLanguageEvent(Locale('en')));
//                   } else {
//                     bloc.add(const ChangeLanguageEvent(Locale('ar')));
//                   }
//                 },
//               ),
//               const Gap(15),
//
//               BlocConsumer<LogoutCubit, LogoutState>(
//                 listener: (context, state) {
//                   if (state is LogoutSuccess) {
//                     Navigator.pop(context);
//                     context.goNamed(AppRouter.login.name);
//                   } else if (state is LogoutError) {
//                     _selectedLogoutOption = null;
//                     serviceLocator<StorageService>().removeFromDisk(
//                       StorageKey.doctorModel,
//                     );
//                     Navigator.pop(context);
//                     context.goNamed(AppRouter.login.name);
//                   }
//                 },
//                 builder: (context, state) {
//                   return ExpansionTile(
//                     leading: const Icon(Icons.logout, color: Colors.red),
//                     title: Text(
//                       'profilePage.logout'.tr(context),
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                     children: [
//                       RadioListTile<int>(
//                         title:
//                         state is LogoutLoadingOnlyThisDevice
//                             ? Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'profilePage.logoutThisDevice'.tr(
//                                 context,
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             LoadingAnimationWidget.hexagonDots(
//                               color: primaryColor,
//                               size: 25,
//                             ),
//                           ],
//                         )
//                             : Text(
//                           'profilePage.logoutThisDevice'.tr(context),
//                         ),
//                         value: 0,
//                         groupValue: _selectedLogoutOption,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedLogoutOption = value;
//                           });
//                           context.read<LogoutCubit>().sendResetLink(0);
//                         },
//                         activeColor: primaryColor,
//                       ),
//                       RadioListTile<int>(
//                         title:
//                         state is LogoutLoadingAllDevices
//                             ? Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'profilePage.logoutAllDevices'.tr(
//                                 context,
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             LoadingAnimationWidget.hexagonDots(
//                               color: primaryColor,
//                               size: 25,
//                             ),
//                           ],
//                         )
//                             : Text(
//                           'profilePage.logoutAllDevices'.tr(context),
//                         ),
//                         value: 1,
//                         groupValue: _selectedLogoutOption,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedLogoutOption = value;
//                           });
//                           context.read<LogoutCubit>().sendResetLink(1);
//                         },
//                         activeColor: primaryColor,
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: SingleChildScrollView(
//             child: Center(
//               child: Column(
//                 children: [
//                   const Gap(80),
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 22.0,
//                         mainAxisSpacing: 30.0,
//                         childAspectRatio: 1.0,
//                       ),
//                       itemCount: jobCategories.length,
//                       itemBuilder: (context, index) {
//                         final category = jobCategories[index];
//                         return _buildJobCategoryCard(
//                           title: category['title'],
//                           icon: category['icon'],
//                           color: category['color'],
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => category['route'],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildHeader(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;
//
//     DoctorModel? doctor = serviceLocator<StorageService>().getDoctor(
//       StorageKey.doctorModel,
//     );
//
//     return AppBar(
//       title: InkWell(
//         onTap: () {
//           context.pushNamed(AppRouter.profileDetails.name);
//         },
//         child: Row(
//           children: [
//             const CircleAvatar(radius: 20, child: Icon(Icons.person)),
//             const SizedBox(width: 8.0),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const GreetingWidget(),
//                 Text(
//                   "${doctor?.fName ?? ''} ${doctor?.lName ?? ''}",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               color: primaryColor,
//               onPressed: () {
//                 Scaffold.of(context).openEndDrawer();
//               },
//               tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
//             );
//           },
//         ),
//         const SizedBox(width: 8.0),
//       ],
//     );
//   }
//
//   Widget _buildJobCategoryCard({
//     required String title,
//     required IconData icon,
//     Color? color,
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Icon(icon, size: 40.0, color: Colors.black87),
//             const SizedBox(height: 8.0),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
  final List<Map<String, dynamic>> jobCategories = [
    // {'title': 'profile', 'icon': Icons.person, 'color': Colors.pink[100], 'route':BlocProvider(
    //   create:
    //       (context) =>
    //   serviceLocator<ProfileCubit>()..fetchMyProfile(),
    //   child: ProfileDetailsPage(),
    // )},
    {
      'title': 'patients',
      'icon': Icons.people_alt_outlined,
      'color': Colors.purple[100],
      'route': PatientListPage(), // Ensure it's a const if possible
    },
    {'title': 'Doctor Schedule', 'icon': Icons.date_range, 'color': Colors.orange[100], 'route': ScheduleListPage()},
    {
      'title': 'Appointmentes',
      'icon': Icons.access_time_outlined,
      'color': Colors.cyan[100],
      'route': AppointmentListPage(), // Ensure it's a const if possible
    },
    {'title': 'previous appointments', 'icon': Icons.history, 'color': Colors.blue[100], 'route': MyPreviousAppointmentPage()},
    {'title': 'Clinics', 'icon': Icons.healing, 'color': Colors.blue[100], 'route': ClinicsPage()},
    // {'title': 'Vacation', 'icon': Icons.healing, 'color': Colors.blue[100], 'route': VacationListPage(scheduleId: '1',)},
    {'title': 'Articales', 'icon': Icons.article_outlined, 'color': Colors.green[100], 'route': ArticaleListScreen()},

  ];
  int? _selectedLogoutOption; // 0 for This Device, 1 for All Devices

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
                // SearchField(),
                // const DefinitionWidget(),
                const Gap(30),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => category['route']));
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
            onTap: (){
              context.pushNamed(AppRouter.profileDetails.name);
            },
            child: Row(
              children: [
                AvatarImage(imageUrl: "${loadingDoctorModel().avatar}", radius: 20),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [GreetingWidget(), Text("${loadingDoctorModel().fName} ${loadingDoctorModel().lName}", style: TextStyle(fontWeight: FontWeight.bold))],
                ),
              ],
            ),
          ),
          Row(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                   if (value == 'Settings') {
                    context.pushNamed(AppRouter.settings.name);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(value: 'Settings', child: ListTile(leading: Icon(Icons.settings), title: Text('Settings'))),
                      PopupMenuItem<String>(
                        value: 'Logout',
                        child: BlocConsumer<LogoutCubit, LogoutState>(
                          listener: (context, state) {
                            if (state is LogoutSuccess) {
                              context.goNamed(AppRouter.login.name);
                            } else if (state is LogoutError) {
                              _selectedLogoutOption = null;
                              serviceLocator<StorageService>().removeFromDisk(StorageKey.doctorModel);
                              context.goNamed(AppRouter.login.name);
                            }
                          },
                          builder: (context, state) {
                            return ExpansionTile(
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: Text('profilePage.logout'.tr(context), style: TextStyle(color: Colors.red)),
                              children: [
                                RadioListTile<int>(
                                  title:
                                      state is LogoutLoadingOnlyThisDevice
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('profilePage.logoutThisDevice'.tr(context)),
                                              SizedBox(width: 10),

                                              LoadingAnimationWidget.hexagonDots(color: Theme.of(context).primaryColor, size: 25),
                                            ],
                                          )
                                          : Text('profilePage.logoutThisDevice'.tr(context), style: TextStyle(color: Colors.red)),
                                  value: 0,
                                  groupValue: _selectedLogoutOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLogoutOption = value;
                                    });
                                    context.read<LogoutCubit>().sendResetLink(0);
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                                RadioListTile<int>(
                                  title:
                                      state is LogoutLoadingAllDevices
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('profilePage.logoutAllDevices'.tr(context)),
                                              SizedBox(width: 10),
                                              LoadingAnimationWidget.hexagonDots(color: Theme.of(context).primaryColor, size: 25),
                                            ],
                                          )
                                          : Text('profilePage.logoutAllDevices'.tr(context), style: TextStyle(color: Colors.red)),
                                  value: 1,
                                  groupValue: _selectedLogoutOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLogoutOption = value;
                                    });
                                    context.read<LogoutCubit>().sendResetLink(1);
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

  Widget _buildJobCategoryCard({required String title, required IconData icon, Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40.0, color: Colors.black87),
            const SizedBox(height: 8.0),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
