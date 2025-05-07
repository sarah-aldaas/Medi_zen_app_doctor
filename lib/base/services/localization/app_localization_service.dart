import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, dynamic> _localizedStrings;

  static List<Locale> get supportedLocales => [
    const Locale('en', ''),
    const Locale('ar', ''),
  ];

  Future<bool> load() async {
    // Load the JSON file from the default path
    String jsonString = await rootBundle.loadString(
      '${kIsWeb ? '' : 'assets/'}lang/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap;
    return true;
  }

  String translate(String key) {
    List<String> keyParts = key.split('.');
    Map<String, dynamic> nestedMap = _localizedStrings;

    for (int i = 0; i < keyParts.length - 1; i++) {
      nestedMap = nestedMap[keyParts[i]];
    }

    return nestedMap[keyParts.last] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
