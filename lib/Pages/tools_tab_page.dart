import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_calc/assistant/ui/assistant_sheet.dart';
import 'package:pro_calc/normcalc/ui/normcalc_app.dart';

import '../feat/tool/Tools_Page/tools_page.dart';

/// Screen hosting utility calculation tools, AI assistant, and productivity apps.
///
/// Shares the frosted glassmorphism visual language, 4-column squircle grid,
/// and bold crisp typography with [ToolsScreen] and [ShapesPage].
class const ToolsTabPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ToolsTabGridContent();
  }
}

/// Compact 4-Column Grid for Utility Tools and Calculators.
class const ToolsTabGridContent({super.key}) extends StatelessWidget {
  static const _tools = [
    (
      'Date Calc',
      FluentIcons.calendar_24_regular,
      Color(0xFF007AFF),
      DateCalcPage(),
    ),
    ('Notes', FluentIcons.tag_24_regular, Color(0xFFFF9500), NotesListPage()),
    (
      'AI Chat',
      FluentIcons.chat_sparkle_24_regular,
      Color(0xFFAF52DE),
      AssistantSheet(
        modelUrl: 'https://huggingface.co/litert-community/SmolLM2-360M-Instruct/resolve/main/SmolLM2_360M_instruct.litertlm',
      ),
    ),
    ('BMI', FluentIcons.person_24_regular, Color(0xFF00C7BE), NormCalcApp()),
    (
      'Fuel Cost',
      FluentIcons.gas_pump_24_regular,
      Color(0xFFFF3B30),
      FuelCostCalcPage(),
    ),
    (
      'Loan Calc',
      FluentIcons.money_hand_24_regular,
      Color(0xFF34C759),
      LoanCalcPage(),
    ),
  ];

  void _navigateToTool(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final cardBorderColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.10)
        : const Color.fromRGBO(0, 0, 0, 0.08);

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const .fromLTRB(4.0, 2.0, 4.0, 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.10,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _tools.length,
      itemBuilder: (context, index) {
        final (name, icon, accentColor, page) = _tools[index];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _navigateToTool(context, page),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.035)
                  : const Color.fromRGBO(255, 255, 255, 0.62),
              borderRadius: .circular(14.0),
              border: Border.all(width: 1.0, color: cardBorderColor),
            ),
            padding: const .symmetric(vertical: 4.0, horizontal: 4.0),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Icon(icon, size: 24.0, color: accentColor),
                const SizedBox(height: 4.0),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'RedditSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: primaryTextColor,
                    letterSpacing: 1,
                  ),
                  textAlign: .center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
