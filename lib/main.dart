import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:exath_engine/exath_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pro_calc/feat/calc/calc_page.dart';
import 'package:pro_calc/feat/settings/state.dart';

import 'core/theme/app_theme.dart';

Future<void> initializeApp() async {
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await FlutterEdgeAi.initialize(inferenceEngines: const [LiteRtLmEngine()]);
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

    // Pre-warm version info once at startup so modal sheets never hit native IPC
    String versionString = 'Pro Calc';
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      versionString = 'Pro Calc v${packageInfo.version}';
    } catch (_) {}

    runApp(
      ProviderScope(
        overrides: [appVersionProvider.overrideWithValue(versionString)],
        child: const ProCalc(),
      ),
    );
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

    // Native Material ThemeMode resolving cleanly with zero type collisions
    final ThemeMode effectiveThemeMode = themeState.followSystemTheme
        ? ThemeMode.system
        : themeState.themeMode;

    final orientation = MediaQuery.orientationOf(context);

    // Reserved for future experiment purposes
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
      home: CalcPage(),
    );
  }
}
