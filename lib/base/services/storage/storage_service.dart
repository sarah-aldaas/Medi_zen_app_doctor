import 'package:shared_preferences/shared_preferences.dart';

import '../logger/logging.dart';

class StorageService {
  final LogService logger;

  static late SharedPreferences _preferences;

  StorageService({var preferences, required this.logger}) {
    logger.i("LocalStorageService(): init fun");
    _preferences = preferences;
  }

  // updated _saveToDisk function that handles all types
  void saveToDisk<T>(String key, T content) async {
    logger.log.i('(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content \n ${content.runtimeType}');

    if (content is String) {
      await _preferences.setString(key, content);
    }
    if (content is bool) {
      _preferences.setBool(key, content);
    }
    if (content is int) {
      _preferences.setInt(key, content);
    }
    if (content is double) {
      _preferences.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences.setStringList(key, content);
    }
  }

  // updated _saveToDisk function that handles all types
  Future<bool> removeFromDisk<T>(String key) {
    logger.log.i('(TRACE) LocalStorageService:Remove from desk. key: $key');

    return _preferences.remove(key);
  }

  dynamic getFromDisk(String key) {
    var value = _preferences.get(key);
    logger.log.i('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }

  Future<bool> clearStorage() {
    logger.log.i('(TRACE) LocalStorageService:clearStorage');
    return _preferences.clear();
  }
}
