import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';

import '../../blocs/localization_bloc/localization_bloc.dart';
import '../logger/logging.dart';
import '../network/network_info.dart';
import '../route/navigator_service.dart';
import 'injection_container_cache.dart';
import 'network_client_injection_container.dart';

final serviceLocator = GetIt.I;

Future<void> initDI() async {
  // serviceLocator.allowReassignment = true;
  await _initService();
  await _initDataSource();
  await _initRepository();
  await _initUseCase();
  await _initBloc();
}

Future<void> _initService() async {
  serviceLocator.registerSingleton<LogService>(LogService(log: Logger()));
  await CacheDependencyInjection.initDi();
  serviceLocator.registerSingleton<NetworkInfo>(NetworkInfoImplementation(InternetConnection()));
  serviceLocator.registerSingleton<NavigatorService>(NavigatorService());
  serviceLocator.registerSingleton<LocalizationBloc>(LocalizationBloc());
  await NetworkClientDependencyInjection.initDi();
}

Future<void> _initDataSource() async {
  // serviceLocator.registerLazySingleton<BaseRemoteDataSourceImpl>(
  //     () => BaseRemoteDataSourceImpl(networkInfo: serviceLocator(), networkClient: serviceLocator(), baseApiLinkContainer: serviceLocator()));
}

Future<void> _initRepository() async {
  // serviceLocator
  // .registerLazySingleton<BaseRepositoryImpl>(() => BaseRepositoryImpl(baseRemoteDataSource: serviceLocator.get(instanceName: 'CityInstanceName')));
}

Future<void> _initUseCase() async {
  // serviceLocator.registerFactory<BaseUseCases>(() => BaseUseCases(serviceLocator()));
}

Future<void> _initBloc() async {
  // serviceLocator.registerLazySingleton<BaseBloc>(() => BaseBloc(baseUseCase: serviceLocator(), stateFactory: serviceLocator()));
}
