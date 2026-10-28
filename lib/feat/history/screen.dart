import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'state.dart';

/// Presentation screen for calculation history.
///
/// Features direct reactive integration with Drift keyset pagination,
/// zero-stutter infinite scrolling with background pre-fetching,
/// theme-adaptive typography, and isolated copy feedback micro-interactions.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key, required this.onExpressionTap, this.onClear});

  final ValueChanged<String> onExpressionTap;
  final VoidCallback? onClear;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Loose pre-fetch trigger: requests the next page when scrolling past 80% extent
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0 && (currentScroll / maxScroll) >= 0.8) {
      ref.read(historyControllerProvider.notifier).loadMore();
    }
  }

  void _handleClear() {
    HapticFeedback.mediumImpact();
    if (widget.onClear != null) {
      widget.onClear!();
    } else {
      ref.read(historyControllerProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyControllerProvider);
    final entries = historyState.entries;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.72)
        : const Color.fromRGBO(0, 0, 0, 0.65);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        // =====================================================================
        // 1. Header Bar: Title + Glass Action Button (Clear All)
        // =====================================================================
        Padding(
          padding: const .only(left: 4.0, right: 4.0, bottom: 14.0),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .center,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),
              if (entries.isNotEmpty)
                _ClearActionButton(isDark: isDark, onTap: _handleClear),
            ],
          ),
        ),

        // =====================================================================
        // 2. Body: Virtualized History Cards with Keyset Pre-fetch
        // =====================================================================
        Expanded(
          child: entries.isEmpty
              ? _EmptyHistoryView(
                  isDark: isDark,
                  secondaryColor: secondaryTextColor,
                )
              : ListView.separated(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 100.0,
                  padding: const .only(bottom: 24.0, left: 2.0, right: 2.0),
                  itemCount:
                      entries.length + (historyState.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                  itemBuilder: (context, index) {
                    // Bottom pagination indicator
                    if (index == entries.length) {
                      return const Padding(
                        padding: .symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        ),
                      );
                    }

                    final item = entries[index];
                    return _HistoryCard(
                      expression: item.expression,
                      result: item.result,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onResultTap: () => widget.onExpressionTap(item.result),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// A flat, transparent calculation card bounded by a mild grey-black border.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.expression,
    required this.result,
    required this.isDark,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onResultTap,
  });

  final String expression;
  final String result;
  final bool isDark;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onResultTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.12)
        : const Color.fromRGBO(0, 0, 0, 0.14);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromRGBO(255, 255, 255, 0.03)
            : const Color.fromRGBO(0, 0, 0, 0.02),
        borderRadius: .circular(14.0),
        border: Border.all(width: 1.0, color: borderColor),
      ),
      padding: const .symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          // Row 1: Expression + Copy Button
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  expression,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: 'RedditSans',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              _CopyIconButton(textToCopy: expression, isDark: isDark),
            ],
          ),

          if (result.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Divider(
              height: 1.0,
              thickness: 0.6,
              color: isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.07)
                  : const Color.fromRGBO(0, 0, 0, 0.06),
            ),
            const SizedBox(height: 8.0),

            // Row 2: Result (Theme-Reactive + Tappable to Canvas) + Copy Button
            Row(
              crossAxisAlignment: .center,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onResultTap,
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Flexible(
                          child: Text(
                            '= $result',
                            softWrap: true,
                            style: TextStyle(
                              fontFamily: 'RedditSans',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Icon(
                          FluentIcons.arrow_up_left_16_regular,
                          size: 14.0,
                          color: isDark
                              ? const Color.fromRGBO(255, 255, 255, 0.35)
                              : const Color.fromRGBO(0, 0, 0, 0.35),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                _CopyIconButton(textToCopy: result, isDark: isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Tactile Clear Action Button mimicking the number button glass style.
class _ClearActionButton extends StatelessWidget {
  const _ClearActionButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.20)
        : const Color.fromRGBO(255, 255, 255, 0.35);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 45.0,
        width: 45.0,
        alignment: .center,
        decoration: BoxDecoration(
          shape: .circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color.fromARGB(18, 255, 255, 255),
                    Color.fromARGB(10, 255, 255, 255),
                  ]
                : const [
                    Color.fromARGB(14, 255, 255, 255),
                    Color.fromARGB(6, 255, 255, 255),
                  ],
          ),
          border: Border.all(width: 1.0, color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color.fromRGBO(0, 0, 0, 0.25)
                  : const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6.0,
              offset: const Offset(0.0, 2.0),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            FluentIcons.delete_20_regular,
            size: 22.0,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ),
      ),
    );
  }
}

/// Independent copy button with transient checkmark confirmation feedback.
class _CopyIconButton extends StatefulWidget {
  const _CopyIconButton({required this.textToCopy, required this.isDark});

  final String textToCopy;
  final bool isDark;

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  void _handleCopy() async {
    if (_copied || widget.textToCopy.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: widget.textToCopy));
    if (!mounted) return;

    HapticFeedback.lightImpact();
    setState(() => _copied = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleCopy,
      child: Padding(
        padding: const .all(4.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _copied
              ? const Icon(
                  FluentIcons.checkmark_20_filled,
                  key: ValueKey('copied'),
                  size: 16.0,
                  color: Color.fromRGBO(34, 197, 94, 0.95),
                )
              : Icon(
                  FluentIcons.copy_20_regular,
                  key: const ValueKey('copy'),
                  size: 16.0,
                  color: widget.isDark
                      ? const Color.fromRGBO(255, 255, 255, 0.45)
                      : const Color.fromRGBO(0, 0, 0, 0.45),
                ),
        ),
      ),
    );
  }
}

/// Minimalist empty state when no history is stored.
class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({required this.isDark, required this.secondaryColor});

  final bool isDark;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Icon(
            FluentIcons.history_24_regular,
            size: 34.0,
            color: secondaryColor.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 8.0),
          Text(
            'No recent calculations',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: secondaryColor.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
