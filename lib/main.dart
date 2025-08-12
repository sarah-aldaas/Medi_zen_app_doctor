import 'dart:convert';
import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/cubit/article_cubit/article_cubit.dart';
import 'package:medi_zen_app_doctor/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medi_zen_app_doctor/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/cubit/allergy_cubit/allergy_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/imaging_study/presentation/cubit/imaging_study_cubit/imaging_study_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medication/presentation/cubit/medication_cubit/medication_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medication_request/presentation/cubit/medication_request_cubit/medication_request_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/observation/presentation/cubit/observation_cubit/observation_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/reactions/presentation/cubit/reaction_cubit/reaction_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/series/presentation/cubit/series_cubit/series_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/cubit/service_request_cubit/service_request_cubit.dart';
import 'package:medi_zen_app_doctor/features/notifications/presentation/cubit/notification_cubit/notification_cubit.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/cubit/patient_cubit/patient_cubit.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/cubit/qualification_cubit/qualification_cubit.dart';
import 'package:medi_zen_app_doctor/features/schedule/presentation/cubit/schedule_cubit/schedule_cubit.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/cubit/vacation_cubit/vacation_cubit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'base/blocs/code_types_bloc/code_types_cubit.dart';
import 'base/blocs/localization_bloc/localization_bloc.dart';
import 'base/constant/storage_key.dart';
import 'base/go_router/go_router.dart';
import 'base/services/di/injection_container_common.dart';
import 'base/services/di/injection_container_gen.dart';
import 'base/services/localization/app_localization_service.dart';
import 'base/services/storage/storage_service.dart';
import 'base/theme/some classes/theme_cubit.dart';
import 'base/theme/theme.dart';
import 'features/authentication/data/models/doctor_model.dart';
import 'features/authentication/presentation/logout/cubit/logout_cubit.dart';
import 'features/medical_record/diagnostic_report/presentation/cubit/diagnostic_report_cubit/diagnostic_report_cubit.dart';
import 'features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';
import 'features/profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';
import 'features/services/pages/cubits/service_cubit/service_cubit.dart';

late ThemeCubit _themeCubit;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  await checkAndRequestPermissions();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await bootstrapApplication();
  _themeCubit = ThemeCubit(ThemePreferenceService());
  await _themeCubit.stream.firstWhere((element) => true);

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  runApp(const MyApp());
}

Future<void> checkAndRequestPermissions() async {
  if (!Platform.isAndroid) return;

  if (await Permission.storage.isDenied) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      debugPrint('Storage permission not granted');
    }
  }

  if (await Permission.manageExternalStorage.isDenied) {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      debugPrint('Manage external storage permission not granted');
    }
  }
}

String? token = serviceLocator<StorageService>().getFromDisk(StorageKey.token);
DoctorModel? loadingDoctorModel() {
  try {
    DoctorModel? myDoctorModel;
    final String jsonString = serviceLocator<StorageService>().getFromDisk(
      StorageKey.doctorModel,
    );
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    myDoctorModel = DoctorModel.fromJson(jsonMap);
    return myDoctorModel;
  } catch (e) {
    return null;
  }
}

Future<void> bootstrapApplication() async {
  await initDI();
  await DependencyInjectionGen.initDI();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (context) => _themeCubit,
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          final theme = isDark ? darkTheme : lightTheme;
          return ThemeProvider(
            initTheme: theme,
            duration: const Duration(milliseconds: 500),
            builder:
                (_, theme) => ResponsiveBreakpoints.builder(
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 960, name: TABLET),
                    const Breakpoint(
                      start: 961,
                      end: double.infinity,
                      name: DESKTOP,
                    ),
                  ],
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<LocalizationBloc>(
                        create: (context) => serviceLocator<LocalizationBloc>(),
                        lazy: false,
                      ),
                      BlocProvider<ProfileCubit>(
                        create: (context) => serviceLocator<ProfileCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<CodeTypesCubit>(
                        create: (context) => serviceLocator<CodeTypesCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<TelecomCubit>(
                        create: (context) => serviceLocator<TelecomCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<LogoutCubit>(
                        create: (context) => serviceLocator<LogoutCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<QualificationCubit>(
                        create:
                            (context) => serviceLocator<QualificationCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ClinicCubit>(
                        create: (context) => serviceLocator<ClinicCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<AppointmentCubit>(
                        create: (context) => serviceLocator<AppointmentCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<AllergyCubit>(
                        create: (context) => serviceLocator<AllergyCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<EncounterCubit>(
                        create: (context) => serviceLocator<EncounterCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<VacationCubit>(
                        create: (context) => serviceLocator<VacationCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<PatientCubit>(
                        create: (context) => serviceLocator<PatientCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<DoctorCubit>(
                        create: (context) => serviceLocator<DoctorCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ScheduleCubit>(
                        create: (context) => serviceLocator<ScheduleCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ReactionCubit>(
                        create: (context) => serviceLocator<ReactionCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ArticleCubit>(
                        create: (context) => serviceLocator<ArticleCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<MedicationCubit>(
                        create: (context) => serviceLocator<MedicationCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<MedicationRequestCubit>(
                        create:
                            (context) =>
                                serviceLocator<MedicationRequestCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ConditionsCubit>(
                        create: (context) => serviceLocator<ConditionsCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ServiceRequestCubit>(
                        create:
                            (context) => serviceLocator<ServiceRequestCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ServiceCubit>(
                        create: (context) => serviceLocator<ServiceCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ObservationCubit>(
                        create: (context) => serviceLocator<ObservationCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<ImagingStudyCubit>(
                        create:
                            (context) => serviceLocator<ImagingStudyCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<DiagnosticReportCubit>(
                        create:
                            (context) => DiagnosticReportCubit(
                              remoteDataSource: serviceLocator(),
                              networkInfo: serviceLocator(),
                            ),
                        lazy: false,
                      ),
                      BlocProvider<SeriesCubit>(
                        create: (context) => serviceLocator<SeriesCubit>(),
                        lazy: false,
                      ),
                      BlocProvider<NotificationCubit>(
                        create:
                            (context) => serviceLocator<NotificationCubit>(),
                        lazy: false,
                      ),

                      BlocProvider<ThemeCubit>(
                        create: (context) => serviceLocator<ThemeCubit>(),
                        lazy: false,
                      ),
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
        },
      ),
    );
  }
}
