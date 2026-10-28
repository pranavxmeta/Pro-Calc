import 'package:apptoast/apptoast.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable state holding active theme settings.
/// Uses Dart 3.13 primary constructor declaring parameters.
@immutable
class const ThemeState({
  final ThemeMode themeMode = ThemeMode.light,
  final bool followSystemTheme = true,
});

/// Riverpod v3 Notifier managing theme state and persistence.
class ThemeNotifier extends Notifier<ThemeState> {
  static const String _modeKey = 'themeMode';
  static const String _followKey = 'followSystemTheme';

  @override
  ThemeState build() {
    _loadPreferences();
    return ThemeState();
  }

  Future<void> _loadPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString(_modeKey);
      final bool follow = prefs.getBool(_followKey) ?? true;

      final ThemeMode mode = switch (saved) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

      state = ThemeState(themeMode: mode, followSystemTheme: follow);
    } catch (e) {
      debugPrint('Theme load error: $e');
    }
  }

  void setThemeMode(ThemeMode mode, {bool followSystem = false}) {
    state = ThemeState(themeMode: mode, followSystemTheme: followSystem);
    _savePreferences();
  }

  void setFollowSystemTheme(bool follow) {
    state = ThemeState(themeMode: state.themeMode, followSystemTheme: follow);
    _savePreferences();
  }

  Future<void> _savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, state.themeMode.name);
    await prefs.setBool(_followKey, state.followSystemTheme);
  }
}

/// Global Riverpod provider for application theme state.
final NotifierProvider<ThemeNotifier, ThemeState> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

const _toastTheme = ToastThemeData(
  typeWidgets: {
    AppToast.info: Icon(FluentIcons.info_24_filled),
    AppToast.success: Icon(FluentIcons.checkmark_circle_24_filled),
    AppToast.warning: Icon(FluentIcons.warning_24_filled),
    AppToast.error: Icon(FluentIcons.dismiss_circle_24_filled),
  },
);

/// Material 3 design themes configured for iOS-style Liquid Glass contrast.
final class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // iOS slate grouped background ensuring white liquid glass borders & blurs pop
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    colorScheme: const ColorScheme.light(
      surface: Colors.white,
      onSurface: Color(0xFF09090B), // Zinc-950
      outline: Color(0xFFE4E4E7), // Zinc-200
    ),
    extensions: const [_toastTheme],
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // Deep obsidian background for dark liquid glass depth
    scaffoldBackgroundColor: const Color(0xFF0F0F12),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF18181B), // Zinc-900
      onSurface: Color(0xFFFAFAFA), // Zinc-50
      outline: Color(0xFF27272A), // Zinc-800
    ),
    extensions: const [_toastTheme],
  );
}
