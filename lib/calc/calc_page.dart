import 'package:exath_engine/exath_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_calc/feat/calc/service/calc_input_service.dart';
import 'package:pro_calc/feat/history/state.dart';

// import '../Pages/utils_settings_provider.dart';

import '../feat/history/model/calculation_history.dart';
import '../feat/history/widget/history_sheet.dart';
import '../feat/settings/screen.dart';
import '../feat/settings/state.dart';

import '../feat/tool/widget/tools_sheet.dart';
import 'utils/calc_clipboard.dart';
import 'utils/calc_evaluator.dart';
import 'utils/expression_formatter.dart';
import 'widget/bottom_nav.dart';
import 'widget/calc_display.dart';
import 'widget/calc_keypad.dart';
import 'widget/kmathcon.dart';
import 'widget/menubar.dart';

/// Streamlined calculator controller screen with snappy 200ms transitions,
/// decoupled input parsing, and strict variable assignment workflows.
class CalcPage extends ConsumerStatefulWidget {
  const CalcPage({super.key});

  @override
  ConsumerState<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends ConsumerState<CalcPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _inputController;
  late final ScrollController _inputScrollController;
  late final AnimationController _animationController;
  late final Animation<double> _inputTextSizeAnimation;
  late final Animation<double> _answerTextSizeAnimation;

  final ValueNotifier<String> _answerNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _isDegNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isShiftNotifier = ValueNotifier<bool>(false);

  bool _lastActionWasEval = false;
  String _rawExpression = '';

  final Map<String, double> _variables = {'X': 0, 'Y': 0};

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _inputScrollController = ScrollController();

    // Responsive 200ms spring-eased motion for fast numeric interactions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _inputTextSizeAnimation = Tween<double>(begin: 1.0, end: 0.74).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _answerTextSizeAnimation = Tween<double>(begin: 0.84, end: 1.26).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
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

  // --- Evaluation Engine ---
  void _evaluate({bool finalEvaluation = false}) {
    if (_rawExpression.trim().isEmpty) {
      _answerNotifier.value = '';
      return;
    }

    if (!finalEvaluation &&
        CalcEvaluator.shouldSkipLiveEvaluation(_rawExpression)) {
      _answerNotifier.value = '';
      return;
    }

    try {
      final locale = ref.read(settingsProvider.select((s) => s.numberLocale));
      final result = CalcEvaluator.evaluate(
        rawExpression: _rawExpression,
        isDeg: _isDegNotifier.value,
        variables: _variables,
        numberFormat: _getNumberFormat(locale),
      );
      _answerNotifier.value = result;
    } catch (_) {
      _answerNotifier.value = finalEvaluation ? 'Error' : '';
    }
  }

  void _applyFormattedText(String newRaw, int newRawCursor) {
    final cleanRaw = newRaw.replaceAll(',', '');
    final locale = ref.read(settingsProvider.select((s) => s.numberLocale));
    final formattedText = ExpressionFormatter.format(
      cleanRaw,
      _getNumberFormat(locale),
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
          .record(_rawExpression, currentAns);
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
    // 1. Post-evaluation: Storing active result directly into variable
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

          _lastActionWasEval = false; // Reset to typing mode
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

    // 2. Typing mode: Insert variable token into current formula
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
      isSuffixFunctionOrConstant: key != ')' && key != '!',
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

        // 1. Re-format the active input formula
        if (_rawExpression.isNotEmpty) {
          _applyFormattedText(_rawExpression, _getRawCursorPosition());
        }

        // 2. Re-format evaluated answer in-place without wiping it
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 35,
                  child: RepaintBoundary(
                    child: CalcDisplay(
                      inputController: _inputController,
                      scrollController: _inputScrollController,
                      animationController: _animationController,
                      inputTextAnimation: _inputTextSizeAnimation,
                      answerTextAnimation: _answerTextSizeAnimation,
                      history: ref
                          .watch(historyControllerProvider)
                          .toDomainList,
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
                          _applyFormattedText(cleaned, cleaned.length);
                          _answerNotifier.value = '';
                          _smoothResetAnimation();
                          _evaluate();
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: RepaintBoundary(
                    child: CalcMenubar(
                      onCopy: () =>
                          CalcClipboard.copy(context, _answerNotifier.value),
                      onPaste: _handlePaste,
                    ),
                  ),
                ),
                Expanded(
                  flex: 53,
                  child: RepaintBoundary(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _isDegNotifier,
                        _isShiftNotifier,
                      ]),
                      builder: (context, _) => CalcKeypad(
                        symbols: CalcInputService.getKeypadSymbols(
                          isShift: _isShiftNotifier.value,
                        ),
                        isDeg: _isDegNotifier.value,
                        isShift: _isShiftNotifier.value,
                        onKeyPressed: _onKeyPressed,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: RepaintBoundary(
                    child: CalcBottomNavNew(onNavAction: _onKeyPressed),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
