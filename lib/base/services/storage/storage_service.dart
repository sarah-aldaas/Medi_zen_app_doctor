import 'dart:convert';
import 'package:medi_zen_app_doctor/features/authentication/data/models/patient_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medi_zen_app_doctor/base/services/logger/logging.dart';

class StorageService {
  final LogService logger;
  static late SharedPreferences _preferences;

  StorageService({var preferences, required this.logger}) {
    logger.i("LocalStorageService(): init fun");
    _preferences = preferences;
  }

  void saveToDisk<T>(String key, T content) async {
    logger.log.i('(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content \n ${content.runtimeType}');

    if (content is String) {
      await _preferences.setString(key, content);
    } else if (content is bool) {
      await _preferences.setBool(key, content);
    } else if (content is int) {
      await _preferences.setInt(key, content);
    } else if (content is double) {
      await _preferences.setDouble(key, content);
    } else if (content is List<String>) {
      await _preferences.setStringList(key, content);
    } else {
      logger.log.e('Unsupported type for saveToDisk: ${content.runtimeType}');
    }
  }

  Future<bool> removeFromDisk(String key) async {
    logger.log.i('(TRACE) LocalStorageService:Remove from desk. key: $key');
    return await _preferences.remove(key);
  }

  dynamic getFromDisk(String key) {
    var value = _preferences.get(key);
    logger.log.i('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }

  Future<bool> clearStorage() async {
    logger.log.i('(TRACE) LocalStorageService:clearStorage');
    return await _preferences.clear();
  }

  // New method to save Patient model
  void savePatient(String key, PatientModel patient) async {
    final jsonString = jsonEncode(patient.toJson());
     saveToDisk(key, jsonString);
    logger.log.i('(TRACE) LocalStorageService:savePatient. key: $key value: $jsonString');
  }

  // New method to retrieve Patient model
  PatientModel? getPatient(String key) {
    final jsonString = getFromDisk(key) as String?;
    if (jsonString == null) {
      logger.log.i('(TRACE) LocalStorageService:getPatient. key: $key value: null');
      return null;
    }
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PatientModel.fromJson(jsonMap);
    } catch (e) {
      logger.log.e('Error decoding Patient JSON: $e');
      return null;
    }
  }
}