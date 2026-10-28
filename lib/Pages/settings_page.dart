// import 'package:cupertino_ui/cupertino_ui.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:pro_calc/core/theme/app_theme.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'utils_settings_provider.dart';

// /// Lightweight record representing a settings action button.
// typedef _Action = ({
//   Widget icon,
//   String label,
//   VoidCallback? onTap,
//   Color? bg,
//   Color? fg,
// });

// /// Modal sheet presenting application preferences and external links.
// /// Uses Dart 3.13 primary constructor declaring parameters.
// class const SettingsModalContent({
//   super.key,
//   required final VoidCallback onClose,
// }) extends ConsumerWidget {
//   Future<void> _launchUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final ThemeState themeState = ref.watch(themeProvider);
//     final SettingsState settingsState = ref.watch(settingsProvider);
//     final CupertinoThemeData theme = CupertinoTheme.of(context);
//     final bool isDark = themeState.themeMode == ThemeMode.dark;

//     final List<_Action> actions = [
//       (
//         icon: Icon(
//           isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
//           color: isDark ? CupertinoColors.systemYellow : CupertinoColors.black,
//           size: 22,
//         ),
//         label: isDark ? 'Light' : 'Dark',
//         bg: isDark ? CupertinoColors.black : CupertinoColors.systemGrey5,
//         fg: isDark ? CupertinoColors.systemYellow : CupertinoColors.black,
//         onTap: () => ref
//             .read(themeProvider.notifier)
//             .setThemeMode(
//               isDark ? ThemeMode.light : ThemeMode.dark,
//               followSystem: false,
//             ),
//       ),
//       (
//         icon: Text(
//           settingsState.numberLocale == 'en_IN' ? 'IN' : 'US',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: CupertinoColors.activeBlue,
//           ),
//         ),
//         label: '# Format',
//         bg: CupertinoColors.systemGrey5,
//         fg: CupertinoColors.activeBlue,
//         onTap: () => ref.read(settingsProvider.notifier).toggleNumberLocale(),
//       ),
//       (
//         icon: const FaIcon(
//           FontAwesomeIcons.github,
//           color: CupertinoColors.activeBlue,
//           size: 22,
//         ),
//         label: 'GitHub',
//         bg: theme.barBackgroundColor,
//         fg: CupertinoColors.activeBlue,
//         onTap: () => _launchUrl('https://github.com/pranavxmeta/Pro-Calc'),
//       ),
//       (
//         icon: const Icon(
//           CupertinoIcons.bell_fill,
//           color: CupertinoColors.systemGrey3,
//           size: 22,
//         ),
//         label: 'Alerts',
//         bg: null,
//         fg: null,
//         onTap: null,
//       ),
//       (
//         icon: const Icon(
//           CupertinoIcons.person_fill,
//           color: CupertinoColors.systemGrey3,
//           size: 22,
//         ),
//         label: 'Profile',
//         bg: null,
//         fg: null,
//         onTap: null,
//       ),
//       (
//         icon: const Icon(
//           CupertinoIcons.gear_solid,
//           color: CupertinoColors.systemGrey3,
//           size: 22,
//         ),
//         label: 'General',
//         bg: null,
//         fg: null,
//         onTap: null,
//       ),
//     ];

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.32,
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 5,
//             width: 35,
//             margin: const EdgeInsets.symmetric(vertical: 10),
//             decoration: BoxDecoration(
//               color: theme.primaryColor.withValues(alpha: 0.3),
//               borderRadius: BorderRadius.circular(2.5),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//             child: Align(
//               alignment: .centerLeft,
//               child: Text('Settings', style: theme.textTheme.navTitleTextStyle),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               children: [
//                 SizedBox(
//                   height: 76,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     itemCount: actions.length,
//                     separatorBuilder: (_, _) => const SizedBox(width: 14),
//                     itemBuilder: (_, i) =>
//                         _SettingsActionButton(item: actions[i]),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 18, bottom: 8),
//                   child: Center(
//                     child: GestureDetector(
//                       onTap: () =>
//                           _launchUrl('https://pub.dev/packages/exath_engine'),
//                       child: const Text(
//                         'Powered by Exath Engine',
//                         style: TextStyle(
//                           decoration: TextDecoration.underline,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: CupertinoColors.activeBlue,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 FutureBuilder<PackageInfo>(
//                   future: PackageInfo.fromPlatform(),
//                   builder: (context, snapshot) => Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Text(
//                         snapshot.hasData
//                             ? 'Pro Calc v${snapshot.data!.version}'
//                             : 'Pro Calc',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color:
//                               theme.textTheme.textStyle.color?.withValues(
//                                 alpha: 0.45,
//                               ) ??
//                               CupertinoColors.systemGrey,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Unified action button matching Cupertino circular design.
// class const _SettingsActionButton({required final _Action item})
//     extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoButton(
//       padding: .zero,
//       onPressed: item.onTap,
//       child: SizedBox(
//         width: 56,
//         child: Column(
//           mainAxisSize: .min,
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               alignment: .center,
//               decoration: BoxDecoration(
//                 color: item.bg ?? CupertinoColors.systemGrey6,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: item.icon,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               item.label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: item.fg ?? CupertinoColors.systemGrey2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
