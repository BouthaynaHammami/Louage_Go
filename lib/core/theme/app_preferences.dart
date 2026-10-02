import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hive_service.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = _readPreference('themeMode');
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _writePreference('themeMode', mode.name);
  }
}

class LocaleNotifier extends Notifier<Locale> {
  static const _supportedLanguageCodes = {'ar', 'en', 'fr'};

  @override
  Locale build() {
    final stored = _readPreference('locale') ?? _readPreference('language');
    final languageCode = stored?.toLowerCase().split(RegExp('[-_]')).first;
    return Locale(
      _supportedLanguageCodes.contains(languageCode) ? languageCode! : 'fr',
    );
  }

  Future<void> setLocale(Locale locale) async {
    final languageCode = locale.languageCode.toLowerCase();
    state = Locale(
      _supportedLanguageCodes.contains(languageCode) ? languageCode : 'fr',
    );
    await _writePreference('locale', state.languageCode);
  }
}

String? _readPreference(String key) {
  try {
    final stored = HiveService.session.get(key);
    final value = stored is Map ? stored['value'] : stored;
    return value is String ? value : null;
  } on StateError {
    return null;
  }
}

Future<void> _writePreference(String key, String value) async {
  try {
    await HiveService.session.put(key, {'value': value});
  } on StateError {
    return;
  }
}
