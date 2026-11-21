import 'package:apptoast/apptoast.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_calc/core/theme/app_theme.dart';
import 'package:pro_calc/feat/settings/model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widget/modal_sheet/model/ios_sheet_options.dart';
import '../../core/widget/modal_sheet/utils/ios_sheet_extension.dart';
import 'state.dart';

/// Lightweight record representing an action item in the settings sheet.
typedef _SettingsAction = ({
  Widget icon,
  String label,
  VoidCallback? onTap,
  Color? bg,
  Color? fg,
});

/// Standalone launcher presenting the Settings modal in iOS Liquid Glass style.
/// Mirrors [showHistorySheet] presentation without redundant drag handle or close button.
Future<void> showSettingsModal(
  BuildContext context, {
  double heightFactor = 0.42,
}) {
  return context.showIosSheet<void>(
    options: const IosSheetOptions(),
    builder: (modalContext) => SizedBox(
      height: MediaQuery.sizeOf(modalContext).height * heightFactor,
      child: const SafeArea(
        top: false,
        child: Padding(
          padding: .symmetric(horizontal: 16.0),
          child: SettingsScreen(),
        ),
      ),
    ),
  );
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Settings sheet content presenting application controls and system info.
///
/// Fully synchronous zero-jank architecture identical in frame rate to HistorySheet.
class const SettingsScreen({super.key, final VoidCallback? onClose})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState themeState = ref.watch(themeProvider);
    final SettingsModel settings = ref.watch(settingsProvider);
    final bool isDark = themeState.themeMode == ThemeMode.dark;

    // Glass design tokens matching ToolsScreen
    final Color primaryTextColor = isDark ? Colors.white : Colors.black;
    final Color cardBorderColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.10)
        : const Color.fromRGBO(0, 0, 0, 0.08);
    final Color cardBg = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.035)
        : const Color.fromRGBO(255, 255, 255, 0.62);
    final Color subtextColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.45)
        : const Color.fromRGBO(0, 0, 0, 0.45);

    final List<_SettingsAction> actions = [
      (
        icon: Icon(
          isDark
              ? FluentIcons.weather_sunny_24_filled
              : FluentIcons.weather_moon_24_filled,
          color: isDark ? const Color(0xFFFACC15) : const Color(0xFF007AFF),
          size: 20.0,
        ),
        label: isDark ? 'Light' : 'Dark',
        bg: isDark
            ? const Color.fromRGBO(255, 255, 255, 0.08)
            : const Color.fromRGBO(0, 0, 0, 0.05),
        fg: isDark ? const Color(0xFFFACC15) : const Color(0xFF007AFF),
        onTap: () => ref
            .read(themeProvider.notifier)
            .setThemeMode(
              isDark ? ThemeMode.light : ThemeMode.dark,
              followSystem: false,
            ),
      ),
      (
        icon: Text(
          settings.numberLocale == 'en_IN' ? 'IN' : 'US',
          style: const TextStyle(
            fontFamily: 'RedditSans',
            fontSize: 15.0,
            fontWeight: .w700,
            color: Color(0xFF007AFF),
          ),
        ),
        label: '# Format',
        bg: cardBg,
        fg: const Color(0xFF007AFF),
        onTap: () {
          ref.read(settingsProvider.notifier).toggleNumberLocale();
          final String formatName = settings.numberLocale == 'en_IN'
              ? 'US (1,234,567)'
              : 'Indian (12,34,567)';

          AppToast.info(context, 'Switched to $formatName');
        },
      ),
      (
        icon: FaIcon(
          FontAwesomeIcons.github,
          color: isDark ? Colors.white : Colors.black,
          size: 20.0,
        ),
        label: 'GitHub',
        bg: cardBg,
        fg: primaryTextColor,
        onTap: () => _launchUrl('https://github.com/pranavxmeta/Pro-Calc'),
      ),
      (
        icon: Icon(
          FluentIcons.alert_24_regular,
          color: subtextColor,
          size: 20.0,
        ),
        label: 'Alerts',
        bg: cardBg,
        fg: subtextColor,
        onTap: null,
      ),
      (
        icon: Icon(
          FluentIcons.person_24_regular,
          color: subtextColor,
          size: 20.0,
        ),
        label: 'Profile',
        bg: cardBg,
        fg: subtextColor,
        onTap: null,
      ),
      (
        icon: Icon(
          FluentIcons.settings_24_regular,
          color: subtextColor,
          size: 20.0,
        ),
        label: 'General',
        bg: cardBg,
        fg: subtextColor,
        onTap: null,
      ),
    ];

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Snug Header (Zero top dead space)
        Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'RedditSans',
            fontSize: 17.0,
            fontWeight: .w700,
            color: primaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12.0),

        // 5 x N Grid isolated with RepaintBoundary
        Expanded(
          child: RepaintBoundary(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.92,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: actions.length,
              itemBuilder: (context, i) => _ActionButton(
                item: actions[i],
                defaultBg: cardBg,
                borderColor: cardBorderColor,
                defaultFg: subtextColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),

        // Engine Credit Footer
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _launchUrl('https://pub.dev/packages/exath_engine'),
            child: const Text(
              'Powered by Exath Engine',
              style: TextStyle(
                fontFamily: 'RedditSans',
                decoration: TextDecoration.underline,
                fontSize: 12.5,
                fontWeight: .w500,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0),

        // Synchronous App Version
        Center(child: _AppVersionText(color: subtextColor)),
        const SizedBox(height: 12.0),
      ],
    );
  }
}

/// Instantaneous version display directly reading in-memory startup state.
class const _AppVersionText({required final Color color})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String version = ref.watch(appVersionProvider);

    return Text(
      version,
      style: TextStyle(fontFamily: 'RedditSans', fontSize: 11.5, color: color),
    );
  }
}

/// Squircle translucent glass tile tailored for 5-column grid cells.
class const _ActionButton({
  required final _SettingsAction item,
  required final Color defaultBg,
  required final Color borderColor,
  required final Color defaultFg,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color bg = item.bg ?? defaultBg;
    final Color fg = item.fg ?? defaultFg;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: .circular(14.0),
          border: Border.all(width: 1.0, color: borderColor),
        ),
        padding: const .symmetric(vertical: 6.0, horizontal: 2.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            item.icon,
            const SizedBox(height: 4.0),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'RedditSans',
                fontSize: 11.0,
                fontWeight: .w500,
                color: fg,
                letterSpacing: 0.2,
              ),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
