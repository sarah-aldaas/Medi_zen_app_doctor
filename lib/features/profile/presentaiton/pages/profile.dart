import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/theme/theme.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'package:medi_zen_app_doctor/main.dart';
import '../../../../base/blocs/localization_bloc/localization_bloc.dart';
import '../../../../base/constant/app_images.dart';
import '../../../../base/constant/storage_key.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/services/storage/storage_service.dart';
import '../widgets/avatar_image_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? _selectedLogoutOption; // 0 for This Device, 1 for All Devices

  @override
  Widget build(BuildContext context) {
    // DoctorModel myDoctorModel = loadingDoctorModel();
    return BlocProvider(
      create: (context) => GetIt.I<LogoutCubit>(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            spacing: 10,
            children: [
              CircleAvatar(backgroundColor: Colors.transparent, radius: 10, child: Image.asset(AppAssetImages.logoGreenPng)),
              Text('profilePage.title'.tr(context), style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
                  title: Text('profilePage.personalDetails'.tr(context)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(AppRouter.profileDetails.name);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.language, color: Theme.of(context).primaryColor),
                  title: Text('profilePage.language'.tr(context)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('profilePage.englishUS'.tr(context)), Icon(Icons.chevron_right)]),
                  onTap: () {
                    final bloc = context.read<LocalizationBloc>();
                    if (bloc.isArabic()) {
                      bloc.add(const ChangeLanguageEvent(Locale('en')));
                    } else {
                      bloc.add(const ChangeLanguageEvent(Locale('ar')));
                    }
                  },
                ),
                ThemeSwitcher.withTheme(
                  builder: (_, switcher, theme) {
                    return ListTile(
                      leading: Icon(
                        theme.brightness == Brightness.light ? Icons.brightness_3 : Icons.brightness_5,
                        size: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(theme.brightness == Brightness.light ? 'profilePage.darkMode'.tr(context) : 'profilePage.lightMode'.tr(context)),
                      onTap: () => switcher.changeTheme(theme: theme.brightness == Brightness.light ? darkTheme : lightTheme),
                    );
                  },
                ),

                BlocConsumer<LogoutCubit, LogoutState>(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
