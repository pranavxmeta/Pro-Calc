import 'dart:convert';

import '../core/widget/modal_sheet/model/ios_sheet_options.dart';
import '../core/widget/modal_sheet/utils/ios_sheet_extension.dart';

import 'package:exath_engine/exath_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../history/model/calculation_history.dart';
import '../Pages/history_page.dart';
import '../Pages/settings_page.dart';
import '../Pages/tools_page.dart';
import '../Pages/utils_settings_provider.dart';

import 'utils/calc_clipboard.dart';
import 'utils/calc_evaluator.dart';
import 'utils/expression_formatter.dart';
import 'widget/calc_bottom_nav.dart';
import 'widget/calc_display.dart';
import 'widget/calc_keypad.dart';

/// Main screen controller orchestrating input, evaluation pipeline, and modal routing.
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
  late Animation<double> _inputTextSizeAnimation;
  late Animation<double> _answerTextSizeAnimation;

  int _rawCursorPosition = 0;
  Map<int, int> _formattedToRawPositionMap = {};
  Map<int, int> _rawToFormattedPositionMap = {};

  String answer = '';
  bool isDeg = true;
  bool isShift = false;
  bool _lastActionWasEval = false;
  String _rawExpression = '';

  final Map<String, double> variables = {'X': 0, 'Y': 0};
  final List<CalculationHistory> history = [];
  static const int _maxHistoryEntries = 100;
  static const String _historyKey = 'calculator_history_v8';

  final RegExp _digitRegex = RegExp(r'[0-9]$');
  final RegExp _operatorRegex = RegExp(r'[+\-*/×÷]$');
  final RegExp _numberOrParenRegex = RegExp(r'([\d.)eπXY])$');

  NumberFormat get _numberFormat {
    final locale = ref.watch(settingsProvider).numberLocale;
    return NumberFormat.decimalPattern(locale)..maximumFractionDigits = 5;
  }

  List<String> get _keypadSymbols {
    final settings = ref.watch(settingsProvider);
    final numberRows = settings.enablePhoneKeypad
        ? [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ]
        : [
            ['7', '8', '9'],
            ['4', '5', '6'],
            ['1', '2', '3'],
          ];

    final operators = settings.changeOperatorOrder
        ? ['+', '-', '×', '÷']
        : ['÷', '×', '-', '+'];

    return [
      'Copy',
      'Paste',
      'empty',
      'empty',
      'empty',
      'shft',
      'X',
      'Y',
      'DEG',
      'AC',
      'sin',
      'cos',
      'tan',
      'π',
      'del',
      'e',
      '(',
      ')',
      '%',
      operators[0],
      '!',
      numberRows[0][0],
      numberRows[0][1],
      numberRows[0][2],
      operators[1],
      '^',
      numberRows[1][0],
      numberRows[1][1],
      numberRows[1][2],
      operators[2],
      '√',
      numberRows[2][0],
      numberRows[2][1],
      numberRows[2][2],
      operators[3],
      'log',
      '00',
      '0',
      '.',
      '=',
    ];
  }

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _inputScrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _inputTextSizeAnimation = const AlwaysStoppedAnimation(36.0);
    _answerTextSizeAnimation = const AlwaysStoppedAnimation(32.0);

    _loadHistory();
    ensureInitialized();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAnimations();
  }

  void _initAnimations() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final baseInput = (screenHeight * 0.042).clamp(24.0, 55.0);
    final baseAnswer = (screenHeight * 0.045).clamp(24.0, 55.0);

    _inputTextSizeAnimation =
        Tween<double>(begin: baseInput * 1.2, end: baseInput * 0.8).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _answerTextSizeAnimation =
        Tween<double>(begin: baseAnswer * 0.8, end: baseAnswer * 1.2).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- Persistence ---
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);
      if (jsonString != null && mounted) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        setState(() {
          history
            ..clear()
            ..addAll(
              jsonList
                  .map((e) => CalculationHistory.fromJson(e))
                  .toList()
                  .reversed,
            );
        });
      }
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = history.reversed.map((e) => e.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  void _recordHistory(String expr, String res) {
    if (expr.isEmpty || res.isEmpty || res == 'Error' || expr == res) return;
    if (history.isNotEmpty &&
        history.first.expression == expr &&
        history.first.result == res) {
      return;
    }

    setState(() {
      history.insert(0, CalculationHistory(expression: expr, result: res));
      if (history.length > _maxHistoryEntries) {
        history.removeLast();
      }
    });
    _saveHistory();
  }

  // --- Live & Final Evaluation ---
  void _evaluate({bool finalEvaluation = false}) {
    if (_rawExpression.trim().isEmpty) {
      if (mounted) setState(() => answer = '');
      return;
    }

    if (!finalEvaluation &&
        CalcEvaluator.shouldSkipLiveEvaluation(_rawExpression)) {
      if (mounted) setState(() => answer = '');
      return;
    }

    try {
      final result = CalcEvaluator.evaluate(
        rawExpression: _rawExpression,
        isDeg: isDeg,
        variables: variables,
        numberFormat: _numberFormat,
      );
      if (mounted) setState(() => answer = result);
    } catch (_) {
      if (mounted) setState(() => answer = finalEvaluation ? 'Error' : '');
    }
  }

  void _applyFormattedText(String newRaw, int newRawCursor) {
    final formatResult = ExpressionFormatter.format(newRaw, _numberFormat);
    _rawExpression = newRaw;
    _rawCursorPosition = newRawCursor.clamp(0, newRaw.length);
    _rawToFormattedPositionMap = formatResult.rawToFormatted;
    _formattedToRawPositionMap = formatResult.formattedToRaw;

    final formattedCursor =
        _rawToFormattedPositionMap[_rawCursorPosition] ??
        formatResult.formattedText.length;
    _inputController.value = TextEditingValue(
      text: formatResult.formattedText,
      selection: TextSelection.collapsed(
        offset: formattedCursor.clamp(0, formatResult.formattedText.length),
      ),
    );
  }

  // --- Key Action Dispatcher ---
  void _onKeyPressed(String key) => switch (key) {
    'hist' => _showHistoryModal,
    'Settings' => _showSettingsModal,
    'unit' => _showToolsModal,
    'Copy' => () => CalcClipboard.copy(context, answer),
    'Paste' => _handlePaste,
    'AC' => () => setState(() {
      _rawExpression = '';
      answer = '';
      _applyFormattedText('', 0);
      _animationController.reset();
    }),
    'del' => _handleDelete,
    'shft' => () => setState(() {
      isShift = !isShift;
      _evaluate();
    }),
    'DEG' => () => setState(() {
      isDeg = !isDeg;
      _evaluate();
    }),
    '=' => _handleEquals,
    'X' || 'Y' => () => _handleVariable(key),
    '%' => _handlePercentage,
    '.' ||
    '√' ||
    'log' ||
    '^' ||
    'sin' ||
    'cos' ||
    'tan' ||
    'π' ||
    'e' ||
    '(' => () => _handleSpecialFunctions(key),
    '+' || '-' || '×' || '÷' => () => _handleOperator(key),
    _ => () => _handleStandardInput(key),
  }();

  void _handleEquals() {
    if (_rawExpression.isNotEmpty) {
      _evaluate(finalEvaluation: true);
      if (answer != 'Error' &&
          answer.isNotEmpty &&
          !answer.contains('Infinity')) {
        _recordHistory(_rawExpression, answer);
        _animationController.forward();
        _lastActionWasEval = true;
      }
    }
  }

  void _handleDelete() {
    if (_rawExpression.isEmpty) return;
    final selection = _inputController.selection;
    final cursorPos = selection.baseOffset >= 0
        ? selection.baseOffset.clamp(0, _inputController.text.length)
        : _inputController.text.length;
    final rawPos =
        _formattedToRawPositionMap[cursorPos] ?? _rawExpression.length;

    if (rawPos > 0) {
      final updated =
          _rawExpression.substring(0, rawPos - 1) +
          _rawExpression.substring(rawPos);
      setState(() {
        _applyFormattedText(updated, rawPos - 1);
        _lastActionWasEval = false;
        _evaluate();
      });
    }
  }

  void _handleVariable(String varName) {
    if (answer.isNotEmpty &&
        answer != 'Error' &&
        !answer.contains('Infinity')) {
      final value = double.tryParse(answer.replaceAll(',', ''));
      if (value != null) {
        setState(() {
          variables[varName] = value;
          answer =
              '$varName = ${CalcEvaluator.formatNumber(value, _numberFormat)}';
          _applyFormattedText('', 0);
          _animationController.reset();
        });
        return;
      }
    }
    _insertToken(varName, isSuffixFunctionOrConstant: true);
  }

  void _handlePercentage() {
    if (_rawExpression.isEmpty && answer.isEmpty) return;

    if (_lastActionWasEval &&
        answer.isNotEmpty &&
        answer != 'Error' &&
        !answer.contains('Infinity')) {
      final cleanAns = answer.replaceAll(',', '');
      final value = (double.tryParse(cleanAns) ?? 0) / 100;
      setState(() {
        _animationController.reset();
        answer = '';
        _lastActionWasEval = false;
        _applyFormattedText(value.toString(), value.toString().length);
        _evaluate();
      });
      return;
    }

    _insertToken('%');
  }

  void _handleOperator(String op) {
    if (_lastActionWasEval &&
        answer.isNotEmpty &&
        answer != 'Error' &&
        !answer.contains('Infinity')) {
      final cleanAns = answer.replaceAll(',', '');
      setState(() {
        _animationController.reset();
        answer = '';
        _lastActionWasEval = false;
        _applyFormattedText(cleanAns + op, (cleanAns + op).length);
        _evaluate();
      });
      return;
    }

    final rawPos = _getRawCursorPosition();
    final textBefore = _rawExpression.substring(0, rawPos);
    final textAfter = _rawExpression.substring(rawPos);
    final trimmedBefore = textBefore.trim();

    // Check if directly following an existing operator
    if (_operatorRegex.hasMatch(trimmedBefore)) {
      if (op == '-' && !trimmedBefore.endsWith('-')) {
        // Allow unary minus for negative numbers or discount factors: e.g. "100 * -" or "100 + -"
        final newExpr = textBefore + op + textAfter;
        _updateExpression(newExpr, rawPos + 1);
      } else {
        // Backtrack and replace single or compound operators (e.g. "100 * -" + "+" -> "100 +")
        var cutPos = textBefore.length - 1;
        if (trimmedBefore.length >= 2 &&
            _operatorRegex.hasMatch(trimmedBefore[trimmedBefore.length - 2])) {
          cutPos = textBefore.length - 2;
        }
        final newExpr = textBefore.substring(0, cutPos) + op + textAfter;
        _updateExpression(newExpr, cutPos + op.length);
      }
    } else {
      final newExpr = textBefore + op + textAfter;
      _updateExpression(newExpr, rawPos + op.length);
    }
  }

  void _handleSpecialFunctions(String key) {
    if (key == '.') {
      final parts = _rawExpression.split(RegExp(r'[+\-*/×÷]'));
      if (parts.isEmpty || !parts.last.contains('.')) {
        final rawPos = _getRawCursorPosition();
        final textBefore = _rawExpression.substring(0, rawPos);
        final toInsert =
            (textBefore.isEmpty || _operatorRegex.hasMatch(textBefore))
            ? '0.'
            : '.';
        _insertToken(toInsert);
      }
      return;
    }

    final func = switch (key) {
      '√' => '√(',
      'log' => isShift ? 'ln(' : 'log(',
      '^' => isShift ? 'E' : '^',
      'sin' || 'cos' || 'tan' => isShift ? '$key⁻¹(' : '$key(',
      _ => key,
    };

    _insertToken(func, isSuffixFunctionOrConstant: true);
  }

  void _handleStandardInput(String key) {
    if (_lastActionWasEval && _digitRegex.hasMatch(key)) {
      setState(() {
        _animationController.reset();
        answer = '';
        _lastActionWasEval = false;
        _applyFormattedText(key, 1);
        _evaluate();
      });
      return;
    }

    _insertToken(key);
  }

  int _getRawCursorPosition() {
    final selection = _inputController.selection;
    final cursorPos = selection.baseOffset >= 0
        ? selection.baseOffset.clamp(0, _inputController.text.length)
        : _inputController.text.length;
    return _formattedToRawPositionMap[cursorPos] ?? _rawExpression.length;
  }

  void _insertToken(String text, {bool isSuffixFunctionOrConstant = false}) {
    final rawPos = _getRawCursorPosition();
    var insert = text;
    final textBefore = _rawExpression.substring(0, rawPos);
    final textAfter = _rawExpression.substring(rawPos);

    // Auto-insert multiplication if constant/function follows a digit or paren
    if (isSuffixFunctionOrConstant &&
        _numberOrParenRegex.hasMatch(textBefore)) {
      insert = '*$insert';
    }

    final newExpr = textBefore + insert + textAfter;
    _updateExpression(newExpr, rawPos + insert.length);
  }

  void _updateExpression(String newExpr, int newRawPos) {
    setState(() {
      _applyFormattedText(newExpr, newRawPos);
      _lastActionWasEval = false;
      _evaluate();
    });
  }

  Future<void> _handlePaste() async {
    final pasted = await CalcClipboard.getValidatedClipboardText(context);
    if (pasted == null || !mounted) return;
    _insertToken(pasted, isSuffixFunctionOrConstant: true);
  }

  // void _showHistoryModal() {
  //   final theme = CupertinoTheme.of(context);

  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true, // Required for custom height
  //     enableDrag: true, // Built-in swipe to dismiss with spring physics
  //     showDragHandle: true, // Built-in drag handle pill
  //     backgroundColor: Color.fromRGBO(240, 240, 240, 1),
  //     constraints: BoxConstraints(maxWidth: 460),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
  //     ),
  //     builder: (modalContext) => Padding(
  //       padding: const EdgeInsets.all(24.0),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: const Color.fromRGBO(240, 240, 240, 1),
  //           borderRadius: BorderRadius.circular(22), // Rounded on all corners
  //         ),
  //         height:
  //             MediaQuery.sizeOf(modalContext).height * 0.65, // Exact 65% height
  //         child: SafeArea(
  //           top: false, // Prevents clipping at the bottom home indicator
  //           child: HistoryPage(
  //             history: history,
  //             onExpressionTap: (result) {
  //               final cleaned = result.replaceAll(',', '');
  //               if (!mounted) return;

  //               setState(() {
  //                 if (_rawExpression.isNotEmpty &&
  //                     _operatorRegex.hasMatch(_rawExpression.trim())) {
  //                   _applyFormattedText(
  //                     _rawExpression + cleaned,
  //                     (_rawExpression + cleaned).length,
  //                   );
  //                 } else {
  //                   _applyFormattedText(cleaned, cleaned.length);
  //                 }
  //                 answer = '';
  //                 _animationController.reset();
  //                 _evaluate();
  //               });

  //               Navigator.pop(modalContext);
  //             },
  //             onClear: () {
  //               if (!mounted) return;
  //               setState(history.clear);
  //               _saveHistory();
  //               Navigator.pop(modalContext);
  //             },
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showHistoryModal() {
    context.showIosSheet<void>(
      options: const IosSheetOptions(
        maxWidth: 460.0,
        cornerRadius: 22.0,
        showGrabber: true,
        enableDrag: true,
        // iOS 26 Light Frosted Glass Surface
        surfaceColor: Color(0xD9F2F2F7),
        barrierColor: Color(0x40000000),
      ),
      builder: (modalContext) => SizedBox(
        height: MediaQuery.sizeOf(modalContext).height * 0.65,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HistoryPage(
              history: history,
              onExpressionTap: (result) {
                final cleaned = result.replaceAll(',', '');
                if (!mounted) return;

                setState(() {
                  if (_rawExpression.isNotEmpty &&
                      _operatorRegex.hasMatch(_rawExpression.trim())) {
                    final combined = '$_rawExpression$cleaned';
                    _applyFormattedText(combined, combined.length);
                  } else {
                    _applyFormattedText(cleaned, cleaned.length);
                  }
                  answer = '';
                  _animationController.reset();
                  _evaluate();
                });

                Navigator.of(modalContext).pop();
              },
              onClear: () {
                if (!mounted) return;
                setState(history.clear);
                _saveHistory();
                Navigator.of(modalContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showToolsModal() {
    context.showIosSheet<void>(
      options: const IosSheetOptions(
        maxWidth: 460.0,
        cornerRadius: 24.0,
        showGrabber: true,
        enableDrag: true,
        surfaceColor: Color(0xD9F2F2F7),
        barrierColor: Color(0x40000000),
      ),
      builder: (modalContext) => SizedBox(
        height: MediaQuery.sizeOf(modalContext).height * 0.65,
        child: const SafeArea(top: false, child: ToolsPage(isModal: true)),
      ),
    );
  }

  void _showSettingsModal() {
    context.showIosSheet<void>(
      options: const IosSheetOptions(
        maxWidth: 460.0,
        cornerRadius: 24.0,
        showGrabber: true,
        enableDrag: true,
        surfaceColor: Color(0xD9F2F2F7),
        barrierColor: Color(0x40000000),
      ),
      builder: (modalContext) =>
          SettingsModalContent(onClose: () => Navigator.of(modalContext).pop()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_inputTextSizeAnimation is AlwaysStoppedAnimation) {
      _initAnimations();
    }
    final theme = CupertinoTheme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        bottomSheetTheme: const BottomSheetThemeData(
          dragHandleColor:
              Colors.red, // 👈 Only affects this screen's bottom sheets
        ),
      ),
      child: CupertinoPageScaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const .all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 35,
                  child: CalcDisplay(
                    inputController: _inputController,
                    scrollController: _inputScrollController,
                    animationController: _animationController,
                    inputTextAnimation: _inputTextSizeAnimation,
                    answerTextAnimation: _answerTextSizeAnimation,
                    history: history,
                    answer: answer,
                    onHistoryTap: (res) {
                      final cleaned = res.replaceAll(',', '');
                      if (_rawExpression.isNotEmpty &&
                          _operatorRegex.hasMatch(_rawExpression.trim())) {
                        _updateExpression(
                          _rawExpression + cleaned,
                          (_rawExpression + cleaned).length,
                        );
                      } else {
                        setState(() {
                          _applyFormattedText(cleaned, cleaned.length);
                          answer = '';
                          _animationController.reset();
                          _evaluate();
                        });
                      }
                    },
                    onCursorPositionChanged: (pos) => _rawCursorPosition =
                        _formattedToRawPositionMap[pos] ??
                        _rawExpression.length,
                  ),
                ),
                Expanded(
                  flex: 59,
                  child: CalcKeypad(
                    symbols: _keypadSymbols,
                    isDeg: isDeg,
                    isShift: isShift,
                    onKeyPressed: _onKeyPressed,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: CalcBottomNav(onNavAction: _onKeyPressed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
