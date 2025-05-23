import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/forget_password/view/forget_password.dart';
import '../../features/authentication/presentation/forget_password/view/otp_verify_password.dart';
import '../../features/authentication/presentation/login/view/login_screen.dart';
import '../../features/authentication/presentation/otp/otp_verification_screen.dart';
import '../../features/authentication/presentation/otp/verified.dart';
import '../../features/authentication/presentation/reset_password/view/reset_password_screen.dart';
import '../../features/home_page/pages/home_page.dart';
import '../../features/start_app/on_boarding/view/on_boarding_screen.dart';
import '../../features/start_app/splash_screen/view/splash_screen.dart';

enum AppRouter {
  login,
  signUp,
  forgetPassword,
  otp,
  onBoarding,
  splashScreen,
  settings,
  changePassword,
  changeTheme,
  changeLang,
  homePage,
  profile,
  editProfile,
  notificationSettings,
  helpCenter,
  articles,
  myBookMark,
  clinics,
  doctors,
  clinic,
  complaint,
  otpVerification,
  verified,
  verifyPasswordOtp,
  resetPassword,
  profileDetails,
  clinicDetails,
  healthServiceDetails,
  doctorDetails,
  appointmentDetails,
  addressListPage,
  clinicService,
  addressDetails,
  telecomDetails,
  healthCareServicesPage,
  allAllergiesPage
}

GoRouter goRouter() {
  return GoRouter(
    initialLocation: "/splashScreen",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
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
            path: "/onboarding",
            name: AppRouter.onBoarding.name,
            builder: (BuildContext context, GoRouterState state) {
              return OnBoardingScreen();
            },
          ),
          GoRoute(
            path: "/homePage",
            name: AppRouter.homePage.name,
            builder: (BuildContext context, GoRouterState state) {
              return HomePage();
            },
          ),
          // GoRoute(
          //   path: "/profile",
          //   name: AppRouter.profile.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ProfilePage();
          //   },
          // ),
          GoRoute(
            path: "/forgetPassword",
            name: AppRouter.forgetPassword.name,
            builder: (BuildContext context, GoRouterState state) {
              return ForgotPasswordScreen();
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
          //   path: "/helpCenter",
          //   name: AppRouter.helpCenter.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return HelpCenterPage();
          //   },
          // ),
          // GoRoute(
          //   path: "/articles",
          //   name: AppRouter.articles.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return Articles();
          //   },
          // ),
          // GoRoute(
          //   path: "/clinics",
          //   name: AppRouter.clinics.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ClinicsPage();
          //   },
          // ),
          // GoRoute(
          //   path: "/doctors",
          //   name: AppRouter.doctors.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return DoctorsPage();
          //   },
          // ),
          // GoRoute(
          //   path: "/myBookMark",
          //   name: AppRouter.myBookMark.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return MyBookmarkPage();
          //   },
          // ),
          // GoRoute(
          //   path: "/myClinics",
          //   name: AppRouter.clinic.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ClinicsPage();
          //   },
          // ),
          // GoRoute(
          //   path: "/complaint",
          //   name: AppRouter.complaint.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return ComplaintListScreen();
          //   },
          // ),
          GoRoute(
            path: "/verified",
            name: AppRouter.verified.name,
            builder: (BuildContext context, GoRouterState state) {
              return Verified();
            },
          ),
          GoRoute(
            path: '/otp-verification',
            name: AppRouter.otpVerification.name,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final email = extra?['email'] as String? ?? '';
              return OtpVerificationScreen(email: email);
            },
          ),
          GoRoute(
            path: '/otp-verification-password',
            name: AppRouter.verifyPasswordOtp.name,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final email = extra?['email'] as String? ?? '';
              return OtpVerifyPassword(email: email);
            },
          ),
          GoRoute(
            path: '/reset-password',
            name: AppRouter.resetPassword.name,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final email = extra?['email'] as String? ?? '';
              return ResetPasswordScreen(email: email);
            },
          ),
          // GoRoute(
          //   path: '/profile-details',
          //   name: AppRouter.profileDetails.name,
          //   builder: (context, state) {
          //     return BlocProvider(
          //       create:
          //           (context) =>
          //       serviceLocator<ProfileCubit>()..fetchMyProfile(),
          //       child: ProfileDetailsPage(),
          //     );
          //   },
          // ),
          // GoRoute(
          //   path: '/edit-profile',
          //   name: AppRouter.editProfile.name,
          //   builder: (context, state) {
          //     final extra = state.extra as Map<String, dynamic>?;
          //     UpdateProfileRequestModel patientModel = extra?['patientModel'];
          //     return EditProfileScreen(patientModel: patientModel);
          //   },
          // ),
          // GoRoute(
          //   path: '/clinic_details',
          //   name: AppRouter.clinicDetails.name,
          //   builder: (context, state) {
          //     final extra = state.extra as Map<String, dynamic>?;
          //
          //     String clinicId = extra?['clinicId'] ?? "1";
          //     return ClinicDetailsPage(clinicId: clinicId);
          //   },
          // ),
          // GoRoute(
          //   path: '/health_service_details',
          //   name: AppRouter.healthServiceDetails.name,
          //   builder: (context, state) {
          //     final extra = state.extra as Map<String, dynamic>?;
          //     String serviceId = extra?['serviceId'] ?? "4";
          //     return HealthCareServiceDetailsPage(serviceId: serviceId);
          //   },
          // ),
          // GoRoute(
          //   path: '/doctor_details',
          //   name: AppRouter.doctorDetails.name,
          //   builder: (context, state) {
          //     final extra = state.extra as Map<String, dynamic>?;
          //     DoctorModel doctorModel = extra?['doctorModel'];
          //     return DoctorDetailsPage(doctorModel: doctorModel);
          //   },
          // ),
          // GoRoute(
          //   path: '/appointment_details',
          //   name: AppRouter.appointmentDetails.name,
          //   builder: (context, state) {
          //     final extra = state.extra as Map<String, dynamic>?;
          //     String appointmentId = extra?['appointmentId']??"1";
          //     return AppointmentDetailsPage(appointmentId: appointmentId,);
          //   },
          // ),
          // GoRoute(
          //   path: '/address_list_page',
          //   name: AppRouter.addressListPage.name,
          //   builder: (context, state) {
          //
          //     return AddressListPage();
          //   },
          // ),
          // GoRoute(
          //   path: "/telecomDetails",
          //   name: AppRouter.telecomDetails.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return TelecomPage();
          //   },
          // ),
          //
          // GoRoute(
          //   path: "/HealthCareServicesPage",
          //   name: AppRouter.healthCareServicesPage.name,
          //   builder: (BuildContext context, GoRouterState state) {
          //     return HealthCareServicesPage();
          //   },
          // ),
        ],
      ),
    ],
  );
}
