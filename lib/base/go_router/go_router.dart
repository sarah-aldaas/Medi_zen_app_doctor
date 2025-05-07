import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/Appointment/pages/appointments_list_screen.dart';
import '../../features/authentication/forget_password/view/forget_password.dart';
import '../../features/authentication/login/view/login_screen.dart';
import '../../features/authentication/otp/otp_page.dart';
import '../../features/authentication/signup/view/signup_screen.dart';
import '../../features/home_page/pages/home_page.dart';
import '../../features/profile/profile.dart';
import '../../features/settings/change_lang.dart';
import '../../features/settings/change_password.dart';
import '../../features/settings/change_theme.dart';
import '../../features/settings/settings.dart';
import '../../features/start_app/on_boarding/view/on_boarding_screen.dart';
import '../../features/start_app/splash_screen/view/splash_screen.dart';
import '../../features/start_app/welcome/view/welcome_screen.dart';

enum AppRouter {
  AppointmentsListScreen,
  login,
  signUp,
  forgetPassword,
  otp,
  onBoarding,
  splashScreen,
  welcomeScreen,
  settings,
  changePassword,
  changeTheme,
  changeLang,
  homePage,
  profile,
  notificationSettings,
  helpCenter,
  articles,
  myBookMark,
  clinics,
  doctors,
  clinic,
  complaint,
}

GoRouter goRouter() {
  return GoRouter(
    initialLocation: "/homePage",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
          GoRoute(
            path: "/welcome",
            name: AppRouter.welcomeScreen.name,
            builder: (BuildContext context, GoRouterState state) {
              return WelcomeScreen();
            },
          ),
          GoRoute(
            path: "/onboarding",
            name: AppRouter.onBoarding.name,
            builder: (BuildContext context, GoRouterState state) {
              return OnBoardingScreen();
            },
          ),
          GoRoute(
            path: "/register",
            name: AppRouter.signUp.name,
            builder: (BuildContext context, GoRouterState state) {
              return SignupScreen();
            },
          ),
          GoRoute(
            path: "/login",
            name: AppRouter.login.name,
            builder: (BuildContext context, GoRouterState state) {
              return LoginScreen();
            },
          ),

          GoRoute(
            path: "/splashScreen",
            name: AppRouter.splashScreen.name,
            builder: (BuildContext context, GoRouterState state) {
              return SplashScreen();
            },
          ),
          GoRoute(
            path: "/settings",
            name: AppRouter.settings.name,
            builder: (BuildContext context, GoRouterState state) {
              return Settings();
            },
          ),
          GoRoute(
            path: "/changeTheme",
            name: AppRouter.changeTheme.name,
            builder: (BuildContext context, GoRouterState state) {
              return ChangeTheme();
            },
          ),
          GoRoute(
            path: "/changeLang",
            name: AppRouter.changeLang.name,
            builder: (BuildContext context, GoRouterState state) {
              return ChangeLang();
            },
          ),
          GoRoute(
            path: "/changePassword",
            name: AppRouter.changePassword.name,
            builder: (BuildContext context, GoRouterState state) {
              return ChangePassword();
            },
          ),
          GoRoute(
            path: "/homePage",
            name: AppRouter.homePage.name,
            builder: (BuildContext context, GoRouterState state) {
              return HomePage();
            },
          ),
          GoRoute(
            path: "/profile",
            name: AppRouter.profile.name,
            builder: (BuildContext context, GoRouterState state) {
              return ProfilePage();
            },
          ),
          GoRoute(
            path: "/forgetPassword",
            name: AppRouter.forgetPassword.name,
            builder: (BuildContext context, GoRouterState state) {
              return ForgotPasswordScreen();
            },
          ),
          GoRoute(
            path: "/otpPage",
            name: AppRouter.otp.name,
            builder: (BuildContext context, GoRouterState state) {
              return OtpPage();
            },
          ),
          GoRoute(
            path: "/AppointmentsListScreen",
            name: AppRouter.AppointmentsListScreen.name,
            builder: (BuildContext context, GoRouterState state) {
              return AppointmentsListScreen();
            },
          ),

          // GoRoute(
          //   path: "/notificationSettings",
          //   name: AppRouter.notificationSettings.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return NotificationSettingsPage();
          //   },
          // ),

          // GoRoute(
          //   path: "/articles",
          //   name: AppRouter.articles.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return Articles();
          //   },
          // ),
        ],
      ),
    ],
  );
}
