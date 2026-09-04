// lib/normcalc/ui/normcalc_app.dart

import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';
import 'normcalc_screen.dart';

class NormCalcApp extends StatelessWidget {
  const NormCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NormCalc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const NormCalcScreen(),
    );
  }
}
