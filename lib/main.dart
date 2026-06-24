import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:pro_calc/Pages/calc_page.dart';
import 'package:pro_calc/Pages/utils_theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exath_engine/exath_engine.dart';

Future<void> initializeApp() async {
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (Platform.isAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeApp();
    await ensureInitialized();

    runApp(const ProviderScope(child: ProCalc()));
  } catch (e) {
    debugPrint('Fatal error during app startup: $e');
    rethrow;
  }
}

class ProCalc extends ConsumerWidget {
  const ProCalc({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    ThemeMode effectiveThemeMode = themeState.themeMode;

    if (themeState.followSystemTheme) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      effectiveThemeMode =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }

    final theme =
        effectiveThemeMode == ThemeMode.light ? lightTheme : darkTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.barBackgroundColor,
      systemNavigationBarColor: theme.barBackgroundColor,
      systemNavigationBarIconBrightness: effectiveThemeMode == ThemeMode.light
          ? Brightness.dark
          : Brightness.light,
    ));

    final orientation = MediaQuery.of(context).orientation;

    Widget homeContent;

    if (kIsWeb && orientation == Orientation.landscape) {
      homeContent = const CupertinoPageScaffold(
        child: Center(
          child: Text(
            'The app is best viewed in portrait mode',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    } else {
      homeContent = const CalcPage();
    }

    return CupertinoApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      title: 'Pro Calc',
      home: homeContent,
    );
  }
}
