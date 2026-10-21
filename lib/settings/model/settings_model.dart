import 'package:flutter/foundation.dart';

/// Immutable data model representing application preferences.
/// Uses Dart 3.13 primary constructor declaring parameters.
@immutable
class const SettingsModel({final String numberLocale = 'en_IN'}) {
  SettingsModel copyWith({String? numberLocale}) =>
      SettingsModel(numberLocale: numberLocale ?? this.numberLocale);
}
