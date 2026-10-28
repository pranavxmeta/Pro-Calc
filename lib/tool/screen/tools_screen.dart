import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../Pages/Unit_Page/unit_page.dart';
import '../../Pages/shapes_page.dart';
import '../../Pages/tools_tab_page.dart';

/// Presentation screen hosting conversion units, shapes, and utility tools.
///
/// Features independent floating glass tab pills (no enclosing outer box),
/// compact squircle tiles in an ergonomic 4-column grid, and bold crisp typography.
class ToolsScreen({super.key, final bool isModal = false})
    extends StatefulWidget {
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int _selectedIndex = 0;

  static const _titles = ['Units', 'Shapes', 'Tools'];
  static const _icons = [
    FluentIcons.ruler_24_regular,
    FluentIcons.square_24_regular,
    FluentIcons.toolbox_24_regular,
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _ToolsGridContent(),
      const ShapesPage(),
      const ToolsTabPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // =====================================================================
        // 1. Independent Floating Glass Tab Pills (Zero outer box-in-box)
        // =====================================================================
        Padding(
          padding: const .fromLTRB(4.0, 0.0, 4.0, 10.0),
          child: Row(
            children: List.generate(_titles.length, (index) {
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: Padding(
                  padding: const .symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? const Color.fromRGBO(255, 255, 255, 0.16)
                                  : const Color.fromRGBO(255, 255, 255, 0.42))
                            : Colors.transparent,
                        borderRadius: .circular(15.0),
                        border: Border.all(
                          width: 1.0,
                          color: isSelected
                              ? (isDark
                                    ? const Color.fromRGBO(255, 255, 255, 0.22)
                                    : const Color.fromRGBO(255, 255, 255, 0.35))
                              : (isDark
                                    ? const Color.fromRGBO(255, 255, 255, 0.06)
                                    : const Color.fromRGBO(0, 0, 0, 0.06)),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: isDark
                                      ? const Color.fromRGBO(0, 0, 0, 0.25)
                                      : const Color.fromRGBO(0, 0, 0, 0.04),
                                  blurRadius: 6.0,
                                  offset: const Offset(0.0, 2.0),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Icon(
                            _icons[index],
                            size: 15.0,
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark
                                      ? const Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.45,
                                        )
                                      : const Color.fromRGBO(0, 0, 0, 0.45)),
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            _titles[index],
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark
                                        ? const Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.45,
                                          )
                                        : const Color.fromRGBO(0, 0, 0, 0.45)),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // =====================================================================
        // 2. Active Tab Content
        // =====================================================================
        Expanded(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
      ],
    );
  }
}

/// Compact 4-Column Grid for Unit Conversion tools.
class _ToolsGridContent extends StatelessWidget {
  const _ToolsGridContent();

  static const _tools = [
    ('Length', FluentIcons.ruler_24_regular, Color(0xFF007AFF)),
    ('Area', FluentIcons.square_24_regular, Color(0xFF34C759)),
    ('Volume', FluentIcons.beaker_24_regular, Color(0xFFFF9500)),
    ('Temperature', FluentIcons.temperature_24_regular, Color(0xFFFF3B30)),
    ('Speed', FluentIcons.cellular_data_1_24_regular, Color(0xFF5856D6)),
    ('Time', FluentIcons.clock_24_regular, Color(0xFFAF52DE)),
    ('Pressure', FluentIcons.gauge_24_regular, Color(0xFF00C7BE)),
    ('Power', FluentIcons.flash_24_regular, Color(0xFFFFCC00)),
    ('Data', FluentIcons.data_trending_24_regular, Color(0xFF32ADE6)),
    ('Angle', FluentIcons.triangle_24_regular, Color(0xFFFF2D55)),
    ('Currency', FluentIcons.money_24_regular, Color(0xFF34C759)),
    ('Fuel', FluentIcons.gas_pump_24_regular, Color(0xFFFF9500)),
    ('Frequency', FluentIcons.cellular_data_3_24_regular, Color(0xFF007AFF)),
    ('Storage', FluentIcons.hard_drive_24_regular, Color(0xFF5856D6)),
    ('Force', FluentIcons.arrow_forward_24_regular, Color(0xFFFF3B30)),
    ('Sound', FluentIcons.speaker_2_24_regular, Color(0xFFAF52DE)),
    ('Illuminance', FluentIcons.lightbulb_24_regular, Color(0xFFFFCC00)),
    ('BMI', FluentIcons.person_24_regular, Color(0xFF00C7BE)),
  ];

  void _navigateToConverter(BuildContext context, String name) {
    final Widget? page = switch (name) {
      'Length' => const LengthConverterPage(),
      'Area' => const AreaConverterPage(),
      'Volume' => const VolumeConverterPage(),
      'Temperature' => const TemperatureConverterPage(),
      _ => null,
    };

    if (page == null) return;

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
        // Proportioned for compact height (shrunk container height)
        childAspectRatio: 1.10,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _tools.length,
      itemBuilder: (context, index) {
        final (name, icon, accentColor) = _tools[index];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _navigateToConverter(context, name),
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
                    // Upgraded font weight and high-contrast color for bold legibility
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
