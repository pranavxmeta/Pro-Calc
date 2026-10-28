import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
// import 'package:flutter_displaymode/flutter_displaymode.dart';
// import 'package:pro_calc/Pages/calc_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exath_engine/exath_engine.dart';
import 'package:pro_calc/calc/calc_page.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';

import 'core/theme/app_theme.dart';

Future<void> initializeApp() async {
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await FlutterEdgeAi.initialize(inferenceEngines: const [LiteRtLmEngine()]);
    // if (Platform.isAndroid) {
    //   await FlutterDisplayMode.setHighRefreshRate();
    // }
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeApp();
    debugPrint('app init');
    await ensureInitialized();
    debugPrint('engine start');

    runApp(const ProviderScope(child: ProCalc()));
  } catch (e) {
    debugPrint('Fatal error during app startup: $e');
    rethrow;
  }
}

// lib/main.dart
class ProCalc extends ConsumerWidget {
  const ProCalc({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    // Native Material ThemeMode resolving cleanly with zero type collisions
    final ThemeMode effectiveThemeMode = themeState.followSystemTheme
        ? ThemeMode.system
        : themeState.themeMode;

    final orientation = MediaQuery.orientationOf(context);

    final Widget homeContent = (kIsWeb && orientation == Orientation.landscape)
        ? const Scaffold(
            body: Center(
              child: Text(
                'The app is best viewed in portrait mode',
                style: TextStyle(fontSize: 20),
              ),
            ),
          )
        : const CalcPage();

    return MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Pro Calc',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: effectiveThemeMode,
      home: homeContent,
    );
  }
}
