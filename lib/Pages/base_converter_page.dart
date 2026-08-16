import 'dart:convert';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../history/model/calculation_history.dart';
import '../unit/model/units_info.dart';
import 'history_page.dart';
import 'package:intl/intl.dart';

class BaseConverterPage<U extends Enum, Q> extends StatefulWidget {
  final String title;
  final List<UnitInfo<U>> units;
  final Q Function(double value, U unit) createQuantity;
  final double Function(Q quantity, U targetUnit) evaluateUnit;

  const BaseConverterPage({
    super.key,
    required this.title,
    required this.units,
    required this.createQuantity,
    required this.evaluateUnit,
  });

  @override
  State<BaseConverterPage<U, Q>> createState() =>
      _BaseConverterPageState<U, Q>();
}

class _BaseConverterPageState<U extends Enum, Q>
    extends State<BaseConverterPage<U, Q>> {
  final TextEditingController _inputController = TextEditingController();
  late UnitInfo<U> _selectedUnit;
  List<CalculationHistory> _history = [];
  static const String _historyKey = 'calculator_history_v8';

  // Cached sorted list (excluding active unit)
  late List<UnitInfo<U>> _displayUnits;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.units.first;
    _updateDisplayUnits();
    _loadHistory();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _updateDisplayUnits() {
    _displayUnits =
        widget.units.where((u) => u.unit != _selectedUnit.unit).toList()
          ..sort((a, b) => a.rank.compareTo(b.rank));
  }

  String _formatNumericValue(double value) {
    final abs = value.abs();
    return (abs >= 1e5 || (abs > 0 && abs < 1e-3)
            ? NumberFormat('0.000 E0')
            : NumberFormat('0.000'))
        .format(value);
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showOverlayMessage('Copied to clipboard');
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      final String pastedText = clipboardData.text!.trim();
      if (RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(pastedText)) {
        setState(() {
          _inputController.text = pastedText;
          _inputController.selection = TextSelection.collapsed(
            offset: pastedText.length,
          );
        });
      } else {
        _showOverlayMessage('Invalid number format');
      }
    }
  }

  void _showHistoryModal() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) {
        final CupertinoThemeData currentTheme = CupertinoTheme.of(modalContext);
        return GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 200) {
              Navigator.pop(modalContext);
            }
          },
          child: Container(
            height: MediaQuery.of(modalContext).size.height * 0.65,
            decoration: BoxDecoration(
              color: currentTheme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 35,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: currentTheme.primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Expanded(
                  child: HistoryPage(
                    history: _history,
                    onExpressionTap: (String result) {
                      final String cleanedResult = result
                          .replaceAll(',', '')
                          .trim();
                      if (RegExp(
                        r'^[0-9]*\.?[0-9]*$',
                      ).hasMatch(cleanedResult)) {
                        setState(() {
                          _inputController.text = cleanedResult;
                          _inputController.selection = TextSelection.collapsed(
                            offset: cleanedResult.length,
                          );
                        });
                        Navigator.pop(modalContext);
                      } else {
                        _showOverlayMessage('Invalid number format');
                      }
                    },
                    onClear: () {
                      _clearHistory();
                      Navigator.pop(modalContext);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadHistory() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_historyKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        final List<CalculationHistory> loadedHistory = jsonList
            .map(
              (json) =>
                  CalculationHistory.fromJson(json as Map<String, dynamic>),
            )
            .toList()
            .reversed
            .toList();
        if (mounted) {
          setState(() {
            _history = loadedHistory;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _history.reversed
          .map((entry) => entry.toJson())
          .toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  Future<void> _clearHistory() async {
    if (mounted) {
      setState(() {
        _history.clear();
      });
      await _saveHistory();
      _showOverlayMessage('History Cleared');
    }
  }

  void _showOverlayMessage(String message) {
    final OverlayState overlay = Navigator.of(context).overlay!;
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 32,
        right: 32,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(20, 20, 20, 0.60),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFFFF9000), fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _handleCalcButton() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Single Card Layout
  Widget _buildUnitCard(
    BuildContext context,
    UnitInfo<U> unitInfo,
    String formattedValue,
    String rawValue,
  ) {
    final CupertinoThemeData currentTheme = CupertinoTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: currentTheme.barBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4, width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  unitInfo.symbol,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  unitInfo.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: currentTheme.textTheme.textStyle.color,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  formattedValue.isEmpty ? '0.000' : formattedValue,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: currentTheme.textTheme.textStyle.color,
                  ),
                ),
              ),
              if (rawValue.isNotEmpty)
                GestureDetector(
                  onTap: () => _copyToClipboard(rawValue),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      FluentIcons.copy_24_regular,
                      size: 16,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Base Unit Horizontal Selector
  Widget _buildBaseUnitSelector() {
    final CupertinoThemeData currentTheme = CupertinoTheme.of(context);
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.units.length,
        itemBuilder: (context, index) {
          final UnitInfo<U> item = widget.units[index];
          final bool isSelected = item.unit == _selectedUnit.unit;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              color: isSelected
                  ? currentTheme.primaryColor
                  : currentTheme.barBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              onPressed: () {
                setState(() {
                  _selectedUnit = item;
                  _updateDisplayUnits();
                });
              },
              child: Text(
                item.symbol,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? CupertinoColors.white
                      : currentTheme.textTheme.textStyle.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Pinned Bottom Panel
  Widget _buildBottomPanel() {
    final CupertinoThemeData currentTheme = CupertinoTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentTheme.scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBaseUnitSelector(),
            const SizedBox(height: 12),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showHistoryModal,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: currentTheme.barBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    child: Icon(
                      FluentIcons.history_24_regular,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoTextField(
                    controller: _inputController,
                    placeholder: 'Enter value',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Inter',
                      color: currentTheme.textTheme.textStyle.color,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (_) => setState(() {}),
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onPressed: _pasteFromClipboard,
                      child: Icon(
                        FluentIcons.clipboard_paste_24_regular,
                        size: 20,
                        color: currentTheme.primaryColor,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: currentTheme.barBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _handleCalcButton,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: currentTheme.barBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    child: Icon(
                      FluentIcons.calculator_24_filled,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData currentTheme = CupertinoTheme.of(context);

    // 1. Parse numeric input once per render pass
    final double? inputValue = double.tryParse(_inputController.text.trim());

    // 2. Instantiate Quantity object ONCE using quantify
    final Q? quantity = inputValue != null
        ? widget.createQuantity(inputValue, _selectedUnit.unit)
        : null;

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Text(
                widget.title.replaceAll(' Converter', ''),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentTheme.textTheme.textStyle.color,
                ),
              ),
            ),
            // Dynamic Grid displaying conversions
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                itemCount: _displayUnits.length,
                itemBuilder: (context, index) {
                  final UnitInfo<U> unitInfo = _displayUnits[index];

                  String formattedValue = '';
                  String rawValue = '';

                  if (quantity != null) {
                    final double calculated = widget.evaluateUnit(
                      quantity,
                      unitInfo.unit,
                    );
                    formattedValue = _formatNumericValue(calculated);
                    rawValue = calculated.toString();
                  }

                  return _buildUnitCard(
                    context,
                    unitInfo,
                    formattedValue,
                    rawValue,
                  );
                },
              ),
            ),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }
}
