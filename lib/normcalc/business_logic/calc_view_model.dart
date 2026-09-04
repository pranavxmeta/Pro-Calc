// lib/normcalc/business_logic/calc_view_model.dart

import 'package:material_ui/material_ui.dart';
import '../models/operation.dart';
import '../utils/formatters.dart';
import 'calc_engine.dart';

final class CalcViewModel extends ChangeNotifier {
  CalcViewModel({CalcEngine engine = const CalcEngine()}) : _engine = engine;

  final CalcEngine _engine;
  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final List<EquationStep> _history = [];
  List<EquationStep> get history => List.unmodifiable(_history);

  String _realtimeResult = '0';
  String get realtimeResult => _realtimeResult;

  void onInputChanged(String val) {
    _computeRealtime();
    notifyListeners();
  }

  void applyOperator(Operation op) {
    final text = inputController.text.trim();
    final parsed = double.tryParse(text);

    if (parsed == null && _history.isEmpty) return;

    if (parsed != null) {
      _history.add((value: parsed, op: op));
      inputController.clear();
    } else if (_history.isNotEmpty) {
      // Replace last operator if tapped repeatedly
      final last = _history.removeLast();
      _history.add((value: last.value, op: op));
    }

    _computeRealtime();
    focusNode.requestFocus();
    notifyListeners();
  }

  void clearAll() {
    _history.clear();
    inputController.clear();
    _realtimeResult = '0';
    focusNode.requestFocus();
    notifyListeners();
  }

  void deleteLast() {
    if (inputController.text.isNotEmpty) {
      final text = inputController.text;
      inputController.text = text.substring(0, text.length - 1);
      inputController.selection = TextSelection.collapsed(
        offset: inputController.text.length,
      );
      _computeRealtime();
      notifyListeners();
    } else if (_history.isNotEmpty) {
      final last = _history.removeLast();
      inputController.text = CalcFormatter.formatResult(last.value);
      inputController.selection = TextSelection.collapsed(
        offset: inputController.text.length,
      );
      _computeRealtime();
      notifyListeners();
    }
  }

  void _computeRealtime() {
    final res = _engine.evaluate(_history, inputController.text.trim());
    _realtimeResult = CalcFormatter.formatResult(res);
  }

  @override
  void dispose() {
    inputController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
