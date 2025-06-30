import 'dart:convert';
import 'dart:ui';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:medi_zen_app_doctor/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medi_zen_app_doctor/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/cubit/allergy_cubit/allergy_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/reactions/presentation/cubit/reaction_cubit/reaction_cubit.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/cubit/patient_cubit/patient_cubit.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/cubit/qualification_cubit/qualification_cubit.dart';
import 'package:medi_zen_app_doctor/features/schedule/presentation/cubit/schedule_cubit/schedule_cubit.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/cubit/vacation_cubit/vacation_cubit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'base/blocs/code_types_bloc/code_types_cubit.dart';
import 'base/blocs/localization_bloc/localization_bloc.dart';
import 'base/constant/storage_key.dart';
import 'base/go_router/go_router.dart';
import 'base/services/di/injection_container_common.dart';
import 'base/services/di/injection_container_gen.dart';
import 'base/services/localization/app_localization_service.dart';
import 'base/services/storage/storage_service.dart';
import 'base/theme/theme.dart';
import 'features/authentication/data/models/doctor_model.dart';
import 'features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';
import 'features/profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  await bootstrapApplication();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  runApp(const MyApp());
}

String? token = serviceLocator<StorageService>().getFromDisk(StorageKey.token);

DoctorModel? loadingDoctorModel() {
  DoctorModel? myDoctorModel;
  final String jsonString = serviceLocator<StorageService>().getFromDisk(StorageKey.doctorModel);
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  myDoctorModel = DoctorModel.fromJson(jsonMap);
  return myDoctorModel;
}
Future<void> bootstrapApplication() async {
  await initDI();
  await DependencyInjectionGen.initDI();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? darkTheme : lightTheme;
    return ThemeProvider(
      initTheme: initTheme,
      duration: const Duration(milliseconds: 500),
      builder:
          (_, theme) => ResponsiveBreakpoints.builder(
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 960, name: TABLET),
              const Breakpoint(start: 961, end: double.infinity, name: DESKTOP),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<LocalizationBloc>(
                  create: (context) => serviceLocator<LocalizationBloc>(),
                  lazy: false,
                ),
                BlocProvider<ProfileCubit>(create: (context) => serviceLocator<ProfileCubit>(), lazy: false),
                BlocProvider<CodeTypesCubit>(create: (context) => serviceLocator<CodeTypesCubit>(), lazy: false),
                BlocProvider<TelecomCubit>(create: (context) => serviceLocator<TelecomCubit>(), lazy: false),
                BlocProvider<LogoutCubit>(create: (context) => serviceLocator<LogoutCubit>(), lazy: false),
                BlocProvider<QualificationCubit>(create: (context) => serviceLocator<QualificationCubit>(), lazy: false),
                BlocProvider<ClinicCubit>(create: (context) => serviceLocator<ClinicCubit>(), lazy: false),
                BlocProvider<AppointmentCubit>(create: (context) => serviceLocator<AppointmentCubit>(), lazy: false),
                BlocProvider<AllergyCubit>(create: (context) => serviceLocator<AllergyCubit>(), lazy: false),
                BlocProvider<EncounterCubit>(create: (context) => serviceLocator<EncounterCubit>(), lazy: false),
                BlocProvider<VacationCubit>(create: (context) => serviceLocator<VacationCubit>(), lazy: false),
                BlocProvider<PatientCubit>(create: (context) => serviceLocator<PatientCubit>(), lazy: false),
                BlocProvider<DoctorCubit>(create: (context) => serviceLocator<DoctorCubit>(), lazy: false),
                BlocProvider<ScheduleCubit>(create: (context) => serviceLocator<ScheduleCubit>(), lazy: false),
                BlocProvider<ReactionCubit>(create: (context) => serviceLocator<ReactionCubit>(), lazy: false),


              ],
              child: BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, state) {
                  return OKToast(
                    child: MaterialApp.router(
                      routerConfig: goRouter(),
                      theme: theme,
                      debugShowCheckedModeBanner: false,
                      title: 'MediZen Mobile',
                      locale: state.locale,
                      supportedLocales: AppLocalizations.supportedLocales,
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}
