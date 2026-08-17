import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart' hide ThemeMode;
import 'package:url_launcher/url_launcher.dart';
import 'utils_theme_provider.dart';
import 'utils_settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Declarative data model for settings action buttons.
class SettingsActionItem {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? labelColor;

  const SettingsActionItem({
    required this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.labelColor,
  });
}

class SettingsModalContent extends ConsumerWidget {
  final VoidCallback onClose;

  const SettingsModalContent({super.key, required this.onClose});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final settingsState = ref.watch(settingsProvider);
    final currentTheme = CupertinoTheme.of(context);
    final isDarkMode = themeState.themeMode == ThemeMode.dark;

    // Data-driven list of 6 action buttons in the row
    final List<SettingsActionItem> actionItems = [
      // 1. Theme Toggle Button
      SettingsActionItem(
        icon: Icon(
          isDarkMode ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
          color: isDarkMode
              ? CupertinoColors.systemYellow
              : CupertinoColors.black,
          size: 22,
        ),
        label: isDarkMode ? 'Light' : 'Dark',
        backgroundColor: isDarkMode
            ? CupertinoColors.black
            : CupertinoColors.systemGrey5,
        labelColor: isDarkMode
            ? CupertinoColors.systemYellow
            : CupertinoColors.black,
        onPressed: () {
          ref
              .read(themeProvider.notifier)
              .setThemeMode(
                isDarkMode ? ThemeMode.light : ThemeMode.dark,
                followSystem: false,
              );
        },
      ),

      // 2. Number Format Button (IN / US)
      SettingsActionItem(
        icon: Text(
          settingsState.numberLocale == 'en_IN' ? 'IN' : 'US',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
        label: '# Format',
        backgroundColor: CupertinoColors.systemGrey5,
        labelColor: CupertinoColors.activeBlue,
        onPressed: () =>
            ref.read(settingsProvider.notifier).toggleNumberLocale(),
      ),

      // 3. Social Media (GitHub) - Replaced Dummy 3
      SettingsActionItem(
        icon: const FaIcon(
          FontAwesomeIcons.github,
          color: CupertinoColors.activeBlue,
          size: 22,
        ),
        label: 'GitHub',
        backgroundColor: currentTheme.barBackgroundColor,
        labelColor: CupertinoColors.activeBlue,
        onPressed: () => _launchUrl('https://github.com/pranavxmeta/Pro-Calc'),
      ),

      // 4. Dummy 1 (Alerts/Notifications)
      const SettingsActionItem(
        icon: Icon(
          CupertinoIcons.bell_fill,
          color: CupertinoColors.systemGrey3,
          size: 22,
        ),
        label: 'Alerts',
      ),

      // 5. Dummy 2 (Profile)
      const SettingsActionItem(
        icon: Icon(
          CupertinoIcons.person_fill,
          color: CupertinoColors.systemGrey3,
          size: 22,
        ),
        label: 'Profile',
      ),

      // 6. Dummy 3 (General Settings)
      const SettingsActionItem(
        icon: Icon(
          CupertinoIcons.gear_solid,
          color: CupertinoColors.systemGrey3,
          size: 22,
        ),
        label: 'General',
      ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: currentTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Handle
          Container(
            height: 5,
            width: 35,
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: currentTheme.primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: currentTheme.textTheme.navTitleTextStyle,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                // 6 Action Buttons in a horizontal single-scroll row
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (int i = 0; i < actionItems.length; i++) ...[
                          _SettingsActionButton(item: actionItems[i]),
                          if (i < actionItems.length - 1)
                            const SizedBox(width: 14),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () =>
                          _launchUrl('https://pub.dev/packages/exath_engine'),
                      child: const Text(
                        'Powered by Exath Engine',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final packageInfo = snapshot.data!;

                      final version = packageInfo.version;

                      return Center(
                        child: Padding(
                          padding: .all(8),
                          child: Row(
                            mainAxisAlignment: .center,
                            children: [
                              Text('Pro Calc'),
                              const SizedBox(width: 10),
                              Text('v$version'),
                            ],
                          ),
                        ),
                      );
                    }

                    // Loading placeholder
                    return Material(
                      child: const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('App Version'),
                        subtitle: Text('Loading...'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Unified button component for all settings action buttons.
class _SettingsActionButton extends StatelessWidget {
  final SettingsActionItem item;

  const _SettingsActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final bgColor = item.backgroundColor ?? CupertinoColors.systemGrey6;
    final fgColor = item.labelColor ?? CupertinoColors.systemGrey2;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: item.onPressed,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: item.icon,
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
