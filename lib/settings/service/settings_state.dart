import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/settings_model.dart';

/// Riverpod v3 Notifier managing application settings and persistence.
class SettingsNotifier extends Notifier<SettingsModel> {
  static const String _localeKey = 'numberLocale';

  @override
  SettingsModel build() {
    _loadPreferences();
    return const SettingsModel();
  }

  Future<void> _loadPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedLocale = prefs.getString(_localeKey);
      if (savedLocale != null && savedLocale.isNotEmpty) {
        state = state.copyWith(numberLocale: savedLocale);
      }
    } catch (e) {
      debugPrint('Settings load error: $e');
    }
  }

  /// Toggles between Indian ('en_IN') and US ('en_US') numerical formatting.
  void toggleNumberLocale() {
    final String nextLocale = state.numberLocale == 'en_IN' ? 'en_US' : 'en_IN';
    setNumberLocale(nextLocale);
  }

  void setNumberLocale(String locale) {
    state = state.copyWith(numberLocale: locale);
    _savePreferences(locale);
  }

  Future<void> _savePreferences(String locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }
}

/// Global provider for settings state.
final NotifierProvider<SettingsNotifier, SettingsModel> settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsModel>(SettingsNotifier.new);
