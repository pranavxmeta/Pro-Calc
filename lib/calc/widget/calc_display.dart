import 'package:flutter/cupertino.dart';

import '../../history/model/calculation_history.dart';

/// Expression input, animated answer, and mini-history scroll strip.
class const CalcDisplay({
  super.key,
  required final TextEditingController inputController,
  required final ScrollController scrollController,
  required final AnimationController animationController,
  required final Animation<double> inputTextAnimation,
  required final Animation<double> answerTextAnimation,
  required final List<CalculationHistory> history,
  required final String answer,
  required final ValueChanged<String> onHistoryTap,
  required final ValueChanged<int> onCursorPositionChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isError = answer == 'Error' || answer.contains('Infinity');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.01,
      ),
      alignment: .bottomRight,
      child: Column(
        mainAxisAlignment: .end,
        crossAxisAlignment: .end,
        children: [
          // Mini-history preview items
          ...history
              .take(3)
              .map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.008),
                  child: GestureDetector(
                    onTap: () => onHistoryTap(entry.result),
                    child: SingleChildScrollView(
                      scrollDirection: .horizontal,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: Text(
                        '${entry.expression} = ${entry.result}',
                        style: TextStyle(
                          fontFamily: 'RedditSans',
                          fontWeight: FontWeight.w400,
                          fontSize: (size.height * 0.020).clamp(12.0, 18.0),
                          color: theme.textTheme.textStyle.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                    ),
                  ),
                ),
              )
              .toList()
              .reversed,

          const Spacer(),

          // Input field
          AnimatedBuilder(
            animation: animationController,
            builder: (context, _) => SingleChildScrollView(
              controller: scrollController,
              scrollDirection: .horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: IntrinsicWidth(
                child: CupertinoTextField(
                  controller: inputController,
                  readOnly: true,
                  showCursor: true,
                  cursorColor: theme.primaryColor,
                  textAlign: .right,
                  style: TextStyle(
                    fontFamily: 'RedditSans',
                    fontWeight: FontWeight.w400,
                    fontSize: inputTextAnimation.value,
                  ),
                  decoration: null,
                  maxLines: 1,
                  onTap: () {
                    final selection = inputController.selection;
                    if (selection.baseOffset < 0 ||
                        selection.extentOffset < 0) {
                      inputController.selection = TextSelection.collapsed(
                        offset: inputController.text.length,
                      );
                      onCursorPositionChanged(inputController.text.length);
                    } else {
                      onCursorPositionChanged(selection.baseOffset);
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),

          // Answer result view
          AnimatedBuilder(
            animation: animationController,
            builder: (context, _) => Opacity(
              opacity: 0.7 + (animationController.value * 0.3),
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - animationController.value)),
                child: SingleChildScrollView(
                  scrollDirection: .horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: IntrinsicWidth(
                    child: Text(
                      answer,
                      textAlign: .right,
                      style: TextStyle(
                        fontFamily: 'RedditSans',
                        fontWeight: FontWeight.w400,
                        fontSize: answerTextAnimation.value,
                        color: isError
                            ? CupertinoColors.systemRed
                            : theme.textTheme.textStyle.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
        ],
      ),
    );
  }
}
