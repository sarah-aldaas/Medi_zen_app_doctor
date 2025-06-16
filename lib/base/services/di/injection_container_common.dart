import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:medi_zen_app_doctor/features/appointment/data/data_source/appointments_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:medi_zen_app_doctor/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medi_zen_app_doctor/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medi_zen_app_doctor/features/doctor/data/datasource/doctor_remote_datasource.dart';
import 'package:medi_zen_app_doctor/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/data/data_source/allergies_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/cubit/allergy_cubit/allergy_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/data/data_source/encounters_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import 'package:medi_zen_app_doctor/features/medical_record/reactions/data/data_source/reactions_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/medical_record/reactions/presentation/cubit/reaction_cubit/reaction_cubit.dart';
import 'package:medi_zen_app_doctor/features/patients/data/data_source/patients_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/cubit/patient_cubit/patient_cubit.dart';
import 'package:medi_zen_app_doctor/features/profile/data/data_sources/qualification_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/cubit/qualification_cubit/qualification_cubit.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/data_source/schedule_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/schedule/presentation/cubit/schedule_cubit/schedule_cubit.dart';
import 'package:medi_zen_app_doctor/features/services/data/datasources/services_remote_datasoources.dart';
import 'package:medi_zen_app_doctor/features/services/pages/cubits/service_cubit/service_cubit.dart';
import 'package:medi_zen_app_doctor/features/vacations/data/data_source/vacations_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/cubit/vacation_cubit/vacation_cubit.dart';
import '../../../features/authentication/data/datasource/auth_remote_data_source.dart';
import '../../../features/authentication/presentation/forget_password/cubit/forgot_password_cubit.dart';
import '../../../features/authentication/presentation/forget_password/cubit/otp_verify_password_cubit.dart';
import '../../../features/authentication/presentation/login/cubit/login_cubit.dart';
import '../../../features/authentication/presentation/logout/cubit/logout_cubit.dart';
import '../../../features/authentication/presentation/otp/cubit/otp_cubit.dart';
import '../../../features/authentication/presentation/reset_password/cubit/reset_password_cubit.dart';
import '../../../features/profile/data/data_sources/profile_remote_data_sources.dart';
import '../../../features/profile/data/data_sources/telecom_remote_data_sources.dart';
import '../../../features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';
import '../../../features/profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';
import '../../blocs/code_types_bloc/code_types_cubit.dart';
import '../../blocs/localization_bloc/localization_bloc.dart';
import '../../data/data_sources/remote_data_sources.dart';
import '../logger/logging.dart';
import '../network/network_info.dart';
import 'injection_container_cache.dart';
import 'network_client_injection_container.dart';

final serviceLocator = GetIt.I;

Future<void> initDI() async {
  await _initService();
  await _initDataSource();
  await _initBloc();
}

Future<void> _initService() async {
  serviceLocator.registerSingleton<LogService>(LogService(log: Logger()));
  await CacheDependencyInjection.initDi();
  serviceLocator.registerSingleton<NetworkInfo>(NetworkInfoImplementation(InternetConnection()));
  serviceLocator.registerSingleton<LocalizationBloc>(LocalizationBloc());
  await NetworkClientDependencyInjection.initDi();
}

Future<void> _initDataSource() async {
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(networkClient: serviceLocator()));

  serviceLocator.registerLazySingleton<RemoteDataSourcePublic>(() => RemoteDataSourcePublicImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<TelecomRemoteDataSource>(() => TelecomRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<QualificationRemoteDataSource>(() => QualificationRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ClinicRemoteDataSource>(() => ClinicRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<AppointmentRemoteDataSource>(() => AppointmentRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<AllergyRemoteDataSource>(() => AllergyRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ReactionRemoteDataSource>(() => ReactionRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<PatientRemoteDataSource>(() => PatientRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<EncounterRemoteDataSource>(() => EncounterRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<VacationRemoteDataSource>(() => VacationRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ScheduleRemoteDataSource>(() => ScheduleRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<DoctorRemoteDataSource>(() => DoctorRemoteDataSourceImpl(networkClient: serviceLocator()));
  serviceLocator.registerLazySingleton<ServicesRemoteDataSource>(() => ServicesRemoteDataSourceImpl(networkClient: serviceLocator()));

}

Future<void> _initBloc() async {
  serviceLocator.registerFactory<OtpCubit>(() => OtpCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<OtpVerifyPasswordCubit>(() => OtpVerifyPasswordCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<LoginCubit>(() => LoginCubit(authRemoteDataSource: serviceLocator()));

  serviceLocator.registerFactory<LogoutCubit>(() => LogoutCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<CodeTypesCubit>(() => CodeTypesCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ProfileCubit>(() => ProfileCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<TelecomCubit>(() => TelecomCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<QualificationCubit>(() => QualificationCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ClinicCubit>(() => ClinicCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<AppointmentCubit>(() => AppointmentCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<DoctorCubit>(() => DoctorCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<PatientCubit>(() => PatientCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ScheduleCubit>(() => ScheduleCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<VacationCubit>(() => VacationCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<EncounterCubit>(() => EncounterCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ReactionCubit>(() => ReactionCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<AllergyCubit>(() => AllergyCubit(remoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ServiceCubit>(() => ServiceCubit(remoteDataSource: serviceLocator()));

}
