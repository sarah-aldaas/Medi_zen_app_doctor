import 'dart:ui';

import 'package:bloc/bloc.dart';

import '../../services/di/injection_container_common.dart';
import '../../services/logger/logging.dart';
import '../../services/storage/storage_service.dart';

class ThemePreferenceService {
  static const String _themeKey = 'selected_theme';

  Future<void> setThemeMode(bool isDark) async {
    serviceLocator<StorageService>().saveToDisk(_themeKey, isDark);
    logger.d('Theme saved: $isDark');
  }

  Future<bool> getThemeMode() async {
    try {
      final storedValue = await serviceLocator<StorageService>().getFromDisk(
        _themeKey,
      );

      if (storedValue == null) {
        logger.d('No theme preference found, using system default');
        return PlatformDispatcher.instance.platformBrightness ==
            Brightness.dark;
      }

      if (storedValue is bool) return storedValue;
      if (storedValue is String) return storedValue.toLowerCase() == 'true';

      logger.w('Unexpected theme value type: ${storedValue.runtimeType}');
      return false;
    } catch (e) {
      return false;
    }
  }
}

class ThemeCubit extends Cubit<bool> {
  final ThemePreferenceService _preferenceService;

  ThemeCubit(this._preferenceService) : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _preferenceService.getThemeMode();
    emit(isDark);
  }

  Future<void> toggleTheme(bool isDark) async {
    await _preferenceService.setThemeMode(isDark);
    emit(isDark);
  }
}
