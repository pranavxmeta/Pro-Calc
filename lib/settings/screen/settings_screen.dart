import 'package:apptoast/apptoast.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart' hide ThemeMode;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pro_calc/core/theme/app_theme.dart';
import 'package:pro_calc/settings/model/settings_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/settings_state.dart';

/// Lightweight record representing an action item in the settings sheet.
typedef _SettingsAction = ({
  Widget icon,
  String label,
  VoidCallback? onTap,
  Color? bg,
  Color? fg,
});

/// Standalone launcher presenting the Settings modal in Shadcn Zinc style.
Future<void> showSettingsModal(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        width: 1.0,
      ),
    ),
    builder: (sheetContext) =>
        SettingsScreen(onClose: () => Navigator.of(sheetContext).pop()),
  );
}

/// Settings sheet content presenting application controls and system info.
/// Uses Dart 3.13 primary constructor declaring parameters.
class const SettingsScreen({super.key, required final VoidCallback onClose})
    extends ConsumerWidget {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState themeState = ref.watch(themeProvider);
    final SettingsModel settings = ref.watch(settingsProvider);
    final bool isDark = themeState.themeMode == ThemeMode.dark;
    final Color sheetBg = isDark ? const Color(0xFF09090B) : Colors.white;

    // Zinc design tokens
    final Color textColor = isDark
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF09090B);
    final Color subtextColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final Color borderColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE4E4E7);
    final Color cardBg = isDark
        ? const Color(0xFF18181B)
        : const Color(0xFFF4F4F5);

    final List<_SettingsAction> actions = [
      (
        icon: Icon(
          isDark
              ? FluentIcons.weather_sunny_24_filled
              : FluentIcons.weather_moon_24_filled,
          color: isDark ? const Color(0xFFFACC15) : const Color(0xFF18181B),
          size: 20,
        ),
        label: isDark ? 'Light' : 'Dark',
        bg: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        fg: isDark ? const Color(0xFFFACC15) : const Color(0xFF18181B),
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0284C7),
          ),
        ),
        label: '# Format',
        bg: cardBg,
        fg: const Color(0xFF0284C7),
        onTap: () {
          ref.read(settingsProvider.notifier).toggleNumberLocale();
          final String formatName = settings.numberLocale == 'en_IN'
              ? 'US (1,234,567)'
              : 'Indian (12,34,567)';

          AppToast.info(context, 'Switched to $formatName');
        },
      ),
      (
        icon: const FaIcon(
          FontAwesomeIcons.github,
          color: Color(0xFF0284C7),
          size: 20,
        ),
        label: 'GitHub',
        bg: cardBg,
        fg: const Color(0xFF0284C7),
        onTap: () => _launchUrl('https://github.com/pranavxmeta/Pro-Calc'),
      ),
      (
        icon: Icon(FluentIcons.alert_24_regular, color: subtextColor, size: 20),
        label: 'Alerts',
        bg: null,
        fg: null,
        onTap: null,
      ),
      (
        icon: Icon(
          FluentIcons.person_24_regular,
          color: subtextColor,
          size: 20,
        ),
        label: 'Profile',
        bg: null,
        fg: null,
        onTap: null,
      ),
      (
        icon: Icon(
          FluentIcons.settings_24_regular,
          color: subtextColor,
          size: 20,
        ),
        label: 'General',
        bg: null,
        fg: null,
        onTap: null,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shadcn Header: Title + Outlined Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: .center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 1.0),
                      ),
                      child: Icon(
                        FluentIcons.dismiss_24_regular,
                        size: 16,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Action Items Row
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: actions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _ActionButton(
                    item: actions[i],
                    defaultBg: cardBg,
                    borderColor: borderColor,
                    defaultFg: subtextColor,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Engine Credit Footer
              Center(
                child: GestureDetector(
                  onTap: () =>
                      _launchUrl('https://pub.dev/packages/exath_engine'),
                  child: const Text(
                    'Powered by Exath Engine',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // App Version
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) => Center(
                  child: Text(
                    snapshot.hasData
                        ? 'Pro Calc v${snapshot.data!.version}'
                        : 'Pro Calc',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action item pill with crisp 1px borders matching the Shadcn design.
class const _ActionButton({
  super.key,
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
      onTap: item.onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: .center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: item.icon,
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
