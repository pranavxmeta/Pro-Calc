import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../feat/history/model/calculation_history.dart';

/// Expression input, animated answer, and mini-history scroll strip.
/// Isolates answer updates to prevent TextField rebuild jitter,
/// synchronizes trailing scroll post-frame, and renders multi-axis GPU result transitions.
class CalcDisplay extends StatefulWidget {
  const CalcDisplay({
    super.key,
    required this.inputController,
    required this.scrollController,
    required this.animationController,
    required this.inputTextAnimation,
    required this.answerTextAnimation,
    required this.history,
    required this.answerListenable,
    required this.onHistoryTap,
  });

  final TextEditingController inputController;
  final ScrollController scrollController;
  final AnimationController animationController;
  final Animation<double> inputTextAnimation;
  final Animation<double> answerTextAnimation;
  final List<CalculationHistory> history;
  final ValueListenable<String> answerListenable;
  final ValueChanged<String> onHistoryTap;

  @override
  State<CalcDisplay> createState() => _CalcDisplayState();
}

class _CalcDisplayState extends State<CalcDisplay> {
  late final Animation<Offset> _answerSlideAnimation;
  late final Animation<double> _answerFadeAnimation;
  late final Animation<double> _inputFadeAnimation;

  @override
  void initState() {
    super.initState();

    _answerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Curves.fastOutSlowIn,
          ),
        );

    _answerFadeAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _inputFadeAnimation = Tween<double>(begin: 1.0, end: 0.65).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    widget.inputController.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(CalcDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inputController != widget.inputController) {
      oldWidget.inputController.removeListener(_handleTextChange);
      widget.inputController.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    widget.inputController.removeListener(_handleTextChange);
    super.dispose();
  }

  /// Trailing lock: guarantees zero horizontal wobbling as numbers are typed.
  void _handleTextChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.scrollController.hasClients &&
          widget.scrollController.position.maxScrollExtent > 0) {
        widget.scrollController.jumpTo(
          widget.scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    final baseInputSize = (size.height * 0.045).clamp(28.0, 52.0);
    final baseAnswerSize = (size.height * 0.042).clamp(24.0, 48.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.01,
        ),
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Mini-history preview items (overflow-safe horizontal scroll strip)
            for (final entry in widget.history.take(3).toList().reversed)
              Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.008),
                child: GestureDetector(
                  onTap: () => widget.onHistoryTap(entry.result),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Text(
                      '${entry.expression} = ${entry.result}',
                      style: TextStyle(
                        fontFamily: 'RedditSans',
                        fontWeight: FontWeight.w400,
                        fontSize: (size.height * 0.020).clamp(12.0, 18.0),
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),

            // Isolated Input Field: Never rebuilds when live evaluation answers update
            FadeTransition(
              opacity: _inputFadeAnimation,
              child: ScaleTransition(
                scale: widget.inputTextAnimation,
                alignment: Alignment.centerRight,
                child: TextField(
                  controller: widget.inputController,
                  scrollController: widget.scrollController,
                  readOnly: true,
                  showCursor: true,
                  cursorColor: theme.colorScheme.primary,
                  cursorWidth: 2.0,
                  cursorRadius: const Radius.circular(1.0),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'RedditSans',
                    fontWeight: FontWeight.w400,
                    fontSize: baseInputSize,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 1,
                ),
              ),
            ),

            SizedBox(height: size.height * 0.01),

            // Isolated Answer View: ONLY this sub-tree rebuilds during live keystroke evaluation
            ValueListenableBuilder<String>(
              valueListenable: widget.answerListenable,
              builder: (context, answer, _) {
                final isError =
                    answer == 'Error' || answer.contains('Infinity');

                return SlideTransition(
                  position: _answerSlideAnimation,
                  child: FadeTransition(
                    opacity: _answerFadeAnimation,
                    child: ScaleTransition(
                      scale: widget.answerTextAnimation,
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          answer,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'RedditSans',
                            fontWeight: FontWeight.w400,
                            fontSize: baseAnswerSize,
                            color: isError
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }
}
