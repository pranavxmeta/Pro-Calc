import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';

class const CalcDisplay({
  super.key,
  final bool isCompact = false,
  final bool isVerticalMode = false,
  final bool isReducedKeypad = false,
  required final TextEditingController inputController,
  required final ScrollController scrollController,
  required final AnimationController animationController,
  required final Animation<double> inputTextAnimation,
  required final Animation<double> answerTextAnimation,
  required final List<CalculationHistoryEntry> history,
  required final ValueListenable<String> answerListenable,
  required final ValueChanged<String> onHistoryTap,
}) extends StatefulWidget {
  @override
  State<CalcDisplay> createState() => _CalcDisplayState();
}

class _CalcDisplayState extends State<CalcDisplay> {
  @override
  void initState() {
    super.initState();
    widget.inputController.addListener(_scrollTrailing);
  }

  @override
  void didUpdateWidget(CalcDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inputController != widget.inputController) {
      oldWidget.inputController.removeListener(_scrollTrailing);
      widget.inputController.addListener(_scrollTrailing);
    }
  }

  @override
  void dispose() {
    widget.inputController.removeListener(_scrollTrailing);
    super.dispose();
  }

  void _scrollTrailing() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted &&
        widget.scrollController.hasClients &&
        widget.scrollController.position.maxScrollExtent > 0) {
      widget.scrollController.jumpTo(
        widget.scrollController.position.maxScrollExtent,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = widget.isCompact;
    final isVertical = widget.isVerticalMode;
    final isReduced = widget.isReducedKeypad;
    final anim = widget.animationController;

    // Kinetic float & elevate drives
    final inputSlide = anim.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, -0.08),
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    final slideAnim = anim.drive(
      Tween<Offset>(
        begin: const Offset(0, 0.20),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    final fadeAnim = anim.drive(
      Tween<double>(
        begin: 0.50,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    final inputFade = anim.drive(
      Tween<double>(
        begin: 1.0,
        end: 0.65,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    // Declarative 3-tuple matrix resolving dimensions & history line quotas
    final (baseInputSize, baseAnswerSize, maxVisible) = switch ((
      isVertical,
      isReduced,
      isCompact,
    )) {
      // Tape Mode: mini-history hidden (0) to dedicate height to multi-line ledger
      (true, _, true) => (22.0, 24.0, 0),
      (true, _, false) => (30.0, 38.0, 0),

      // Normal Mode with Reduced 4x5 Keypad:
      // 5-row matrix leaves enough vertical height to show 2 history items even on compact screens!
      (false, true, true) => (28.0, 24.0, 2),
      (false, true, false) => (40.0, 38.0, 4),

      // Normal Mode with Full 5x7 Scientific Keypad:
      (false, false, true) => (28.0, 24.0, 0),
      (false, false, false) => (44.0, 38.0, 4),
    };

    final historyItems = widget.history.take(10).toList();
    final lineHeight = isCompact ? 25.0 : 30.0;
    final historyHeight =
        math.min(historyItems.length, maxVisible) * lineHeight;
    final showHistory = maxVisible > 0 && historyItems.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: .only(top: 8.0),
        child: Column(
          spacing: isCompact ? 2.0 : 4.0,
          crossAxisAlignment: .end,
          children: [
            if (showHistory)
              SizedBox(
                height: historyHeight,
                child: ListView.builder(
                  padding: .zero,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: historyItems.length,
                  itemExtent: lineHeight,
                  itemBuilder: (context, index) {
                    final entry = historyItems[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onHistoryTap(entry.result),
                      child: Align(
                        alignment: .centerRight,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            '${entry.expression} = ${entry.result}',
                            style: TextStyle(
                              fontFamily: 'RedditSans',
                              fontSize: isCompact ? 12.0 : 15.0,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (!isVertical) const Spacer(),

            _CalcInputField(
              controller: widget.inputController,
              scrollController: widget.scrollController,
              fadeAnimation: inputFade,
              slideAnimation: inputSlide,
              fontSize: baseInputSize,
              isVertical: isVertical,
            ).expandedIf(isVertical),

            ValueListenableBuilder<String>(
              valueListenable: widget.answerListenable,
              builder: (context, answer, _) => SlideTransition(
                position: slideAnim,
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: ScaleTransition(
                    scale: widget.answerTextAnimation,
                    alignment: .centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        answer,
                        textAlign: .right,
                        style: TextStyle(
                          fontFamily: 'RedditSans',
                          fontSize: baseAnswerSize,
                          color:
                              (answer == 'Error' || answer.contains('Infinity'))
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const _CalcInputField({
  required final TextEditingController controller,
  required final ScrollController scrollController,
  required final Animation<double> fadeAnimation,
  required final Animation<Offset> slideAnimation,
  required final double fontSize,
  required final bool isVertical,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: double.infinity,
            child: TextField(
              controller: controller,
              scrollController: scrollController,
              readOnly: true,
              showCursor: true,
              cursorColor: Theme.of(context).colorScheme.primary,
              cursorWidth: 2.0,
              cursorRadius: const Radius.circular(1.0),
              textAlign: TextAlign.right,
              maxLines: isVertical ? null : 1,
              style: TextStyle(
                fontFamily: 'RedditSans',
                fontSize: fontSize,
                height: 1.35,
                fontFeatures: [
                  if (isVertical) const FontFeature.tabularFigures(),
                ],
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

extension on Widget {
  Widget expandedIf(bool condition, {int flex = 1}) =>
      condition ? Expanded(flex: flex, child: this) : this;
}
