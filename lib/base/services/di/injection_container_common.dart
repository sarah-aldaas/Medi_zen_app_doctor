import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import '../../../features/authentication/data/datasource/auth_remote_data_source.dart';
import '../../../features/authentication/presentation/forget_password/cubit/forgot_password_cubit.dart';
import '../../../features/authentication/presentation/forget_password/cubit/otp_verify_password_cubit.dart';
import '../../../features/authentication/presentation/login/cubit/login_cubit.dart';
import '../../../features/authentication/presentation/logout/cubit/logout_cubit.dart';
import '../../../features/authentication/presentation/otp/cubit/otp_cubit.dart';
import '../../../features/authentication/presentation/reset_password/cubit/reset_password_cubit.dart';
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
}

Future<void> _initBloc() async {
  serviceLocator.registerFactory<OtpCubit>(() => OtpCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<OtpVerifyPasswordCubit>(() => OtpVerifyPasswordCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<LoginCubit>(() => LoginCubit(authRemoteDataSource: serviceLocator()));

  serviceLocator.registerFactory<LogoutCubit>(() => LogoutCubit(authRemoteDataSource: serviceLocator()));
  serviceLocator.registerFactory<CodeTypesCubit>(() => CodeTypesCubit(remoteDataSource: serviceLocator()));
}
