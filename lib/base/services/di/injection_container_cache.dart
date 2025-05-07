import 'package:shared_preferences/shared_preferences.dart';

import '../storage/storage_service.dart';
import 'injection_container_common.dart';

class CacheDependencyInjection {
  static Future<void> initDi() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    serviceLocator.registerSingleton<StorageService>(
      StorageService(preferences: preferences, logger: serviceLocator()),
    );
  }
}
