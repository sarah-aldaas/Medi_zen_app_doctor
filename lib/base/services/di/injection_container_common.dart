import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:medi_zen_app_doctor/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medi_zen_app_doctor/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medi_zen_app_doctor/features/profile/data/data_sources/qualification_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/cubit/qualification_cubit/qualification_cubit.dart';
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

}
