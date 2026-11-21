import 'dart:math' as math;

import 'package:exath_engine/exath_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_calc/feat/calc/service/calc_input_service.dart';
import 'package:pro_calc/feat/history/state.dart';

import '../history/widget/history_sheet.dart';
import '../settings/screen.dart';
import '../settings/state.dart';
import '../tool/widget/tools_sheet.dart';
import 'utils/calc_clipboard.dart';
import 'utils/calc_evaluator.dart';
import 'utils/calc_text_controller.dart';
import 'utils/expression_formatter.dart';
import 'widget/bottom_nav.dart';
import 'widget/calc_display.dart';
import 'widget/calc_keypad.dart';
import 'widget/kmathcon.dart';
import 'widget/menubar.dart';

/// Calculator controller screen with responsive layout scaling,
/// dual-mode toggling, and persistent live subtotal calculations.
class CalcPage extends ConsumerStatefulWidget {
  const CalcPage({super.key});

  @override
  ConsumerState<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends ConsumerState<CalcPage>
    with SingleTickerProviderStateMixin {
  late final CalcTextEditingController _inputController;
  late final ScrollController _inputScrollController;
  late final AnimationController _animationController;
  late final Animation<double> _inputTextSizeAnimation;
  late final Animation<double> _answerTextSizeAnimation;

  final ValueNotifier<String> _answerNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _isDegNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isShiftNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isVerticalNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isReducedKeypadNotifier = ValueNotifier<bool>(
    false,
  );

  static const _verticalSymbols = [
    '(',
    ')',
    'del',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '00',
    '0',
    '.',
    '=',
  ];

  bool _lastActionWasEval = false;
  String _rawExpression = '';

  final Map<String, double> _variables = {'X': 0, 'Y': 0};

  @override
  void initState() {
    super.initState();
    _inputController = CalcTextEditingController();
    _inputScrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _inputTextSizeAnimation = Tween<double>(begin: 1.0, end: 0.65).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _answerTextSizeAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    ensureInitialized();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputScrollController.dispose();
    _animationController.dispose();
    _answerNotifier.dispose();
    _isDegNotifier.dispose();
    _isShiftNotifier.dispose();
    _isVerticalNotifier.dispose();
    _isReducedKeypadNotifier.dispose();
    super.dispose();
  }

  NumberFormat _getNumberFormat(String locale) =>
      NumberFormat.decimalPattern(locale)..maximumFractionDigits = 5;

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Persistent Evaluation Engine ---
  void _evaluate({bool finalEvaluation = false}) {
    final cleanExpr = _rawExpression.replaceAll('\n', ' ').trim();

    if (cleanExpr.isEmpty) {
      _answerNotifier.value = '';
      return;
    }

    // Suppress preview when typing the first standalone scalar number
    if (!finalEvaluation &&
        RegExp(r'^-?\d*\.?\d+$').hasMatch(cleanExpr.replaceAll(',', ''))) {
      _answerNotifier.value = '';
      return;
    }

    final locale = ref.read(settingsProvider.select((s) => s.numberLocale));
    final numFormat = _getNumberFormat(locale);

    // Prepare evaluable expression for live preview:
    // Strip trailing operators so the running subtotal remains visible
    var evaluableExpr = cleanExpr;
    if (!finalEvaluation) {
      evaluableExpr = evaluableExpr.replaceFirst(RegExp(r'[+\-*/×÷^ ]+$'), '');

      // Auto-balance unclosed parentheses for live preview
      int openCount = 0;
      for (int i = 0; i < evaluableExpr.length; i++) {
        if (evaluableExpr[i] == '(') openCount++;
        if (evaluableExpr[i] == ')') openCount = math.max(0, openCount - 1);
      }
      evaluableExpr = evaluableExpr + (')' * openCount);
    }

    if (evaluableExpr.isEmpty) {
      return; // Retain previous valid answer
    }

    try {
      final result = CalcEvaluator.evaluate(
        rawExpression: evaluableExpr,
        isDeg: _isDegNotifier.value,
        variables: _variables,
        numberFormat: numFormat,
      );
      _answerNotifier.value = result;
    } catch (_) {
      if (finalEvaluation) {
        _answerNotifier.value = 'Error';
      }
      // On live syntax transitions, retain the existing subtotal so it never hides
    }
  }

  void _applyFormattedText(String newRaw, int newRawCursor) {
    final cleanRaw = newRaw.replaceAll(',', '');
    final locale = ref.read(settingsProvider.select((s) => s.numberLocale));
    final numFormat = _getNumberFormat(locale);
    final isVertical = _isVerticalNotifier.value;

    _inputController.isVerticalMode = isVertical;

    final formattedText = ExpressionFormatter.format(
      cleanRaw,
      numFormat,
      isVertical: isVertical,
    );

    _rawExpression = cleanRaw;

    final formattedCursor = ExpressionFormatter.rawToFormatted(
      newRawCursor.clamp(0, newRaw.length),
      formattedText,
    );

    _inputController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: formattedCursor.clamp(0, formattedText.length),
      ),
    );
  }

  int _getRawCursorPosition() {
    final selection = _inputController.selection;
    final cursorPos = selection.baseOffset >= 0
        ? selection.baseOffset.clamp(0, _inputController.text.length)
        : _inputController.text.length;
    return ExpressionFormatter.formattedToRaw(cursorPos, _inputController.text);
  }

  void _updateExpression(String newExpr, int newRawPos) {
    _applyFormattedText(newExpr, newRawPos);
    _lastActionWasEval = false;
    _evaluate();
  }

  void _smoothResetAnimation() {
    if (_animationController.value > 0) {
      _animationController.reverse();
    }
  }

  // --- Key Dispatcher ---
  void _onKeyPressed(String key) => switch (key) {
    'hist' => _showHistoryModal,
    'Settings' => () => showSettingsModal(context),
    'unit' => () => showToolsSheet(context),
    'Copy' => () => CalcClipboard.copy(context, _answerNotifier.value),
    'Paste' => _handlePaste,
    'AC' => _handleClearAll,
    'del' => _handleDelete,
    'k' => () => kmathcon(
      context,
      onSelect: (c) => debugPrint('Selected: ${c.name} = ${c.value}'),
    ),
    'shft' => () {
      HapticFeedback.lightImpact();
      _isShiftNotifier.value = !_isShiftNotifier.value;
      _evaluate();
    },
    'deg' => () {
      HapticFeedback.lightImpact();
      _isDegNotifier.value = !_isDegNotifier.value;
      _evaluate();
    },
    '=' => _handleEquals,
    'X' || 'Y' => () => _handleVariable(key),
    '%' => _handlePercentage,
    '00' => _handleDoubleZero,
    '±' || '+/-' => _handleNegate,
    '.' => _handleDecimal,
    '|x|' ||
    '√' ||
    '∛' ||
    'cbrt' ||
    'log' ||
    '^' ||
    'sin' ||
    'cos' ||
    'tan' ||
    'π' ||
    'e' ||
    '(' ||
    ')' ||
    '!' => () => _handleSpecialFunctions(key),
    '+' => _isShiftNotifier.value ? _handleNegate : () => _handleOperator('+'),
    '-' || '×' || '÷' => () => _handleOperator(key),
    _ => () => _handleStandardInput(key),
  }();

  void _handleClearAll() {
    HapticFeedback.mediumImpact();
    _rawExpression = '';
    _answerNotifier.value = '';
    _lastActionWasEval = false;
    _applyFormattedText('', 0);
    _smoothResetAnimation();
  }

  void _handleEquals() {
    if (_rawExpression.isEmpty) return;

    _evaluate(finalEvaluation: true);
    final currentAns = _answerNotifier.value;

    if (currentAns != 'Error' &&
        currentAns.isNotEmpty &&
        !currentAns.contains('Infinity')) {
      ref
          .read(historyControllerProvider.notifier)
          .record(_rawExpression.replaceAll('\n', ' '), currentAns);
      HapticFeedback.mediumImpact();
      _animationController.forward();
      _lastActionWasEval = true;
    }
  }

  void _handleDelete() {
    if (_rawExpression.isEmpty) return;
    final rawPos = _getRawCursorPosition();

    if (rawPos > 0) {
      final updated =
          _rawExpression.substring(0, rawPos - 1) +
          _rawExpression.substring(rawPos);
      _updateExpression(updated, rawPos - 1);
    }
  }

  void _handleVariable(String varName) {
    if (_lastActionWasEval) {
      final currentAns = _answerNotifier.value;
      if (currentAns.isNotEmpty &&
          currentAns != 'Error' &&
          !currentAns.contains('Infinity')) {
        final cleanAns = currentAns.replaceAll(',', '');
        final value = double.tryParse(cleanAns);
        if (value != null) {
          final locale = ref.read(
            settingsProvider.select((s) => s.numberLocale),
          );
          _variables[varName] = value;
          _lastActionWasEval = false;
          _answerNotifier.value =
              '$varName = ${CalcEvaluator.formatNumber(value, _getNumberFormat(locale))}';
          _applyFormattedText('', 0);
          _smoothResetAnimation();
          _showFeedback('Saved to $varName = $cleanAns');
          return;
        }
      }
      _showFeedback('Evaluation not complete');
      return;
    }

    final res = CalcInputService.insertToken(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
      token: varName,
      isSuffixFunctionOrConstant: true,
    );
    _updateExpression(res.expression, res.cursor);
  }

  void _handleDoubleZero() {
    final res = CalcInputService.handleDoubleZero(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
    );
    if (res != null) {
      _updateExpression(res.expression, res.cursor);
    }
  }

  void _handlePercentage() {
    final currentAns = _answerNotifier.value;
    if (_rawExpression.isEmpty && currentAns.isEmpty) return;

    if (_lastActionWasEval &&
        currentAns.isNotEmpty &&
        currentAns != 'Error' &&
        !currentAns.contains('Infinity')) {
      final cleanAns = currentAns.replaceAll(',', '');
      final value = (double.tryParse(cleanAns) ?? 0) / 100;
      _smoothResetAnimation();
      _answerNotifier.value = '';
      _lastActionWasEval = false;
      _applyFormattedText(value.toString(), value.toString().length);
      _evaluate();
      return;
    }

    final res = CalcInputService.insertToken(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
      token: '%',
    );
    _updateExpression(res.expression, res.cursor);
  }

  void _handleNegate() {
    final currentAns = _answerNotifier.value;

    if (_lastActionWasEval &&
        currentAns.isNotEmpty &&
        currentAns != 'Error' &&
        !currentAns.contains('Infinity')) {
      final cleanAns = currentAns.replaceAll(',', '');
      final negated = cleanAns.startsWith('-')
          ? cleanAns.substring(1)
          : '-$cleanAns';
      _lastActionWasEval = false;
      _applyFormattedText(negated, negated.length);
      _smoothResetAnimation();
      _evaluate();
      return;
    }

    final res = CalcInputService.toggleNegate(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
    );
    _updateExpression(res.expression, res.cursor);
  }

  void _handleDecimal() {
    final res = CalcInputService.handleDecimal(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
    );
    if (res != null) {
      _updateExpression(res.expression, res.cursor);
    }
  }

  void _handleOperator(String op) {
    final currentAns = _answerNotifier.value;

    if (_lastActionWasEval &&
        currentAns.isNotEmpty &&
        currentAns != 'Error' &&
        !currentAns.contains('Infinity')) {
      final cleanAns = currentAns.replaceAll(',', '');
      _lastActionWasEval = false;
      _applyFormattedText(cleanAns + op, (cleanAns + op).length);
      _smoothResetAnimation();
      _evaluate();
      return;
    }

    final res = CalcInputService.handleOperator(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
      operator: op,
    );
    _updateExpression(res.expression, res.cursor);
  }

  void _handleSpecialFunctions(String key) {
    final func = CalcInputService.resolveFunctionToken(
      key,
      isShift: _isShiftNotifier.value,
    );
    final res = CalcInputService.insertToken(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
      token: func,
      // Prevents '(' from auto-injecting '×'
      isSuffixFunctionOrConstant: key != '(' && key != ')' && key != '!',
    );
    _updateExpression(res.expression, res.cursor);
  }

  void _handleStandardInput(String key) {
    if (_lastActionWasEval && CalcInputService.digitRegex.hasMatch(key)) {
      _lastActionWasEval = false;
      _applyFormattedText(key, 1);
      _smoothResetAnimation();
      _evaluate();
      return;
    }

    final res = CalcInputService.insertToken(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
      token: key,
    );
    _updateExpression(res.expression, res.cursor);
  }

  Future<void> _handlePaste() async {
    final pasted = await CalcClipboard.getValidatedClipboardText(context);
    if (pasted == null || !mounted) return;
    final res = CalcInputService.insertToken(
      expression: _rawExpression,
      cursor: _getRawCursorPosition(),
      token: pasted,
      isSuffixFunctionOrConstant: true,
    );
    _updateExpression(res.expression, res.cursor);
  }

  void _showHistoryModal() {
    showHistorySheet(
      context,
      onExpressionTap: (result) {
        final cleaned = result.replaceAll(',', '');
        if (!mounted) return;

        if (_rawExpression.isNotEmpty &&
            CalcInputService.operatorRegex.hasMatch(_rawExpression.trim())) {
          final combined = '$_rawExpression$cleaned';
          _applyFormattedText(combined, combined.length);
        } else {
          _applyFormattedText(cleaned, cleaned.length);
        }
        _answerNotifier.value = '';
        _smoothResetAnimation();
        _evaluate();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(settingsProvider.select((s) => s.numberLocale), (
      prev,
      next,
    ) {
      if (prev != null && prev != next) {
        final newFormat = _getNumberFormat(next);
        if (_rawExpression.isNotEmpty) {
          _applyFormattedText(_rawExpression, _getRawCursorPosition());
        }
        if (_lastActionWasEval && _answerNotifier.value.isNotEmpty) {
          final cleanAns = _answerNotifier.value.replaceAll(',', '');
          final value = double.tryParse(cleanAns);
          if (value != null) {
            _answerNotifier.value = CalcEvaluator.formatNumber(
              value,
              newFormat,
            );
          }
        } else {
          _evaluate();
        }
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.25,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F0F12)
            : const Color.fromRGBO(242, 242, 247, 1.0),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 520.0;
              final isCompact = MediaQuery.sizeOf(context).height < 750.0;

              return ListenableBuilder(
                listenable: Listenable.merge([
                  _isVerticalNotifier,
                  _isReducedKeypadNotifier,
                ]),
                builder: (context, _) {
                  final isVertical = _isVerticalNotifier.value;
                  final isReduced = _isReducedKeypadNotifier.value;

                  final (displayFlex, keypadFlex) = switch ((
                    isVertical || isReduced,
                    isCompact,
                  )) {
                    (true, true) => (42, 58),
                    (true, false) => (55, 45),
                    (false, true) => (25, 75),
                    (false, false) => (42, 58),
                  };

                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: isWide ? .centerRight : .center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480.0),
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: .fromLTRB(10.0, 4.0, 10.0, 10.0),
                        child: Column(
                          children: [
                            // 1. Display: Adaptive size matrix & mini-history visibility
                            Expanded(
                              flex: displayFlex,
                              child: RepaintBoundary(
                                child: CalcDisplay(
                                  isCompact: isCompact,
                                  isVerticalMode: isVertical,
                                  isReducedKeypad: isReduced,
                                  inputController: _inputController,
                                  scrollController: _inputScrollController,
                                  animationController: _animationController,
                                  inputTextAnimation: _inputTextSizeAnimation,
                                  answerTextAnimation: _answerTextSizeAnimation,
                                  history: ref
                                      .watch(historyControllerProvider)
                                      .entries,
                                  answerListenable: _answerNotifier,
                                  onHistoryTap: (res) {
                                    final cleaned = res.replaceAll(',', '');
                                    if (_rawExpression.isNotEmpty &&
                                        CalcInputService.operatorRegex.hasMatch(
                                          _rawExpression.trim(),
                                        )) {
                                      _updateExpression(
                                        _rawExpression + cleaned,
                                        (_rawExpression + cleaned).length,
                                      );
                                    } else {
                                      _applyFormattedText(
                                        cleaned,
                                        cleaned.length,
                                      );
                                      _answerNotifier.value = '';
                                      _smoothResetAnimation();
                                      _evaluate();
                                    }
                                  },
                                ),
                              ),
                            ),

                            // 2. Menubar: Discrete toggles with instant display refresh
                            RepaintBoundary(
                              child: CalcMenubar(
                                isCompact: isCompact,
                                isVerticalMode: isVertical,
                                isReducedKeypad: isReduced,
                                onToggleReducedKeypad: () {
                                  if (_isReducedKeypadNotifier.value ||
                                      _isVerticalNotifier.value) {
                                    _isReducedKeypadNotifier.value = false;
                                    _isVerticalNotifier.value = false;
                                  } else {
                                    _isReducedKeypadNotifier.value = true;
                                  }
                                  _applyFormattedText(
                                    _rawExpression,
                                    _getRawCursorPosition(),
                                  );
                                },
                                onToggleVertical: () {
                                  _isVerticalNotifier.value =
                                      !_isVerticalNotifier.value;
                                  _applyFormattedText(
                                    _rawExpression,
                                    _getRawCursorPosition(),
                                  );
                                },
                                onCopy: () => CalcClipboard.copy(
                                  context,
                                  _answerNotifier.value,
                                ),
                                onPaste: _handlePaste,
                              ),
                            ),

                            // 3. Keypad: AnimatedSwitcher morphs 5x7 and 4x5 matrices smoothly
                            Expanded(
                              flex: keypadFlex,
                              child: RepaintBoundary(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.95,
                                            end: 1.0,
                                          ).animate(anim),
                                          child: child,
                                        ),
                                      ),
                                  child: ListenableBuilder(
                                    key: ValueKey(isVertical || isReduced),
                                    listenable: Listenable.merge([
                                      _isDegNotifier,
                                      _isShiftNotifier,
                                    ]),
                                    builder: (context, _) =>
                                        (isVertical || isReduced)
                                        ? CalcKeypad(
                                            columns: 4,
                                            rows: 5,
                                            symbols: _verticalSymbols,
                                            isDeg: _isDegNotifier.value,
                                            isShift: false,
                                            onKeyPressed: _onKeyPressed,
                                          )
                                        : CalcKeypad(
                                            columns: 5,
                                            rows: 7,
                                            symbols:
                                                CalcInputService.getKeypadSymbols(
                                                  isShift:
                                                      _isShiftNotifier.value,
                                                ),
                                            isDeg: _isDegNotifier.value,
                                            isShift: _isShiftNotifier.value,
                                            onKeyPressed: _onKeyPressed,
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isCompact ? 5.0 : 8.0),

                            // 4. Flint Bottom Dock
                            RepaintBoundary(
                              child: CalcBottomNavNew(
                                isCompact: isCompact,
                                onNavAction: _onKeyPressed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
