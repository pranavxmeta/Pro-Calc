import 'package:apptoast/apptoast.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Supported application theme modes.
enum ThemeMode { light, dark }

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
    return const ThemeState();
  }

  Future<void> _loadPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString(_modeKey);
      final bool follow = prefs.getBool(_followKey) ?? true;

      state = ThemeState(
        themeMode: saved == 'dark' ? ThemeMode.dark : ThemeMode.light,
        followSystemTheme: follow,
      );
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

/// Global riverpod provider for application theme state.
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

/// Cupertino design themes consumed by CupertinoApp.
const CupertinoThemeData lightTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: CupertinoColors.activeBlue,
  barBackgroundColor: Color.fromRGBO(242, 242, 242, 0),
  scaffoldBackgroundColor: Color.fromRGBO(249, 249, 249, 1),
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(
      fontFamily: 'RedditSans',
      color: Color.fromRGBO(20, 20, 20, 0.65),
    ),
    navTitleTextStyle: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.label,
    ),
    navLargeTitleTextStyle: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: CupertinoColors.label,
    ),
  ),
);

const CupertinoThemeData darkTheme = CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: CupertinoColors.systemIndigo,
  barBackgroundColor: Color.fromRGBO(10, 10, 10, 0),
  scaffoldBackgroundColor: Color.fromRGBO(10, 10, 10, 1),
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(fontFamily: 'Inter', color: CupertinoColors.white),
    navTitleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.white,
    ),
    navLargeTitleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: CupertinoColors.white,
    ),
  ),
);

/// Material design themes injected via builder for AppToast ThemeExtension lookup.
final class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
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
    scaffoldBackgroundColor: const Color(0xFF09090B), // Zinc-950
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF09090B),
      onSurface: Color(0xFFFAFAFA), // Zinc-50
      outline: Color(0xFF27272A), // Zinc-800
    ),
    extensions: const [_toastTheme],
  );
}
