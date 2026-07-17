import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils_theme_provider.dart'; // Use theme provider
import 'utils_settings_provider.dart'; // Use settings provider

class SettingsModalContent extends ConsumerWidget {
  final VoidCallback onClose;

  const SettingsModalContent({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final settingsState = ref.watch(settingsProvider);
    final currentTheme = CupertinoTheme.of(context);
    final themeNotifier = ref.read(themeProvider.notifier);
    final settingsNotifier = ref.read(settingsProvider.notifier);

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
              mainAxisAlignment:
                  MainAxisAlignment.start, // Fixed typo from .start
              children: [
                Text(
                  'Settings',
                  style: currentTheme.textTheme.navTitleTextStyle,
                ),
              ],
            ),
          ),
          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                // Horizontal Row containing the Theme Toggle and 3 Dummy Buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      // Active Theme Toggle Button
                      _buildThemeButton(
                        context: context,
                        isDarkMode: themeState.themeMode == ThemeMode.dark,
                        onPressed: () {
                          themeNotifier.setThemeMode(
                            themeState.themeMode == ThemeMode.dark
                                ? ThemeMode.light
                                : ThemeMode.dark,
                            followSystem: false,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Dummy Button 1
                      _buildDummyButton(
                        context: context,
                        icon: CupertinoIcons.bell_fill,
                        label: "Dummy 1",
                      ),
                      const SizedBox(width: 16),
                      // Dummy Button 2
                      _buildDummyButton(
                        context: context,
                        icon: CupertinoIcons.person_fill,
                        label: "Dummy 2",
                      ),
                      const SizedBox(width: 16),
                      // Dummy Button 3
                      _buildDummyButton(
                        context: context,
                        icon: CupertinoIcons.gear_solid,
                        label: "Dummy 3",
                      ),
                    ],
                  ),
                ),
                // Social Media Links
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        color: currentTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse(
                                "https://pub.dev/packages/exath_engine",
                              ),
                            ),
                            child: const Text(
                              "Powered by Exath Engine",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                          _buildSocialButton(
                            context: context,
                            icon: FontAwesomeIcons.github,
                            url: "https://github.com/pranavxmeta/Pro-Calc",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton({
    required BuildContext context,
    required bool isDarkMode,
    required VoidCallback onPressed,
  }) {
    // 1. Determine icon and label based on current mode
    final IconData icon = isDarkMode
        ? CupertinoIcons.sun_max_fill
        : CupertinoIcons.moon_fill;
    final String label = isDarkMode ? "Light" : "Dark";

    // 2. Set colors based on active mode:
    // - Dark Mode active: Sun filled yellow, background black
    // - Light Mode active: Moon black, background light grey
    final Color backgroundColor = isDarkMode
        ? CupertinoColors.black
        : CupertinoColors.systemGrey5;
    final Color iconColor = isDarkMode
        ? CupertinoColors.systemYellow
        : CupertinoColors.black;
    final Color labelColor = isDarkMode
        ? CupertinoColors.systemYellow
        : CupertinoColors.black;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: .circular(25.0),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: labelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyButton({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    // Standard light grey styling for future buttons
    final Color backgroundColor = CupertinoColors.systemGrey6;
    final Color iconColor = CupertinoColors.systemGrey3;
    final Color labelColor = CupertinoColors.systemGrey2;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Handle action later
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: .circular(25.0),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: labelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required FaIconData icon,
    required String url,
  }) {
    final currentTheme = CupertinoTheme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('Could not launch $url');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: currentTheme.barBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, color: CupertinoColors.activeBlue, size: 24),
      ),
    );
  }
}
