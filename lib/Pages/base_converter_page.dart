import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/calculation_history.dart';
import 'history_page.dart';

class BaseConverterPage extends StatefulWidget {
  final String title;
  final List<String> units;
  final Function(String, String, String) onConvert;
  final Map<String, double> conversionRates;

  const BaseConverterPage({
    super.key,
    required this.title,
    required this.units,
    required this.onConvert,
    required this.conversionRates,
  });

  @override
  State<BaseConverterPage> createState() => _BaseConverterPageState();
}

class _BaseConverterPageState extends State<BaseConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  String _fromUnit = '';
  String _toUnit = '';
  String _result = '';
  List<CalculationHistory> history = [];
  static const _historyKey = 'calculator_history_v8';

  final Map<String, int> _unitRank = {
    'mm': 1,
    'cm': 2,
    'm': 3,
    'km': 4,
    'miles': 5,
    'mm²': 1,
    'cm²': 2,
    'm²': 3,
    'km²': 4,
    'mi²': 5,
    'ml': 1,
    'l': 2,
    'm³': 3,
    'pa': 1,
    'kpa': 2,
    'bar': 3,
    'w': 1,
    'kw': 2,
    'mw': 3,
    '°C': 1,
    '°F': 2,
    'K': 3,
    'm/s': 1,
    'km/h': 2,
    'mph': 3,
    's': 1,
    'min': 2,
    'h': 3,
    'd': 4,
    'B': 1,
    'KB': 2,
    'MB': 3,
    'GB': 4,
    '°': 1,
    'rad': 2,
    'USD': 1,
    'EUR': 2,
    'mpg': 1,
    'l/100km': 2,
    'Hz': 1,
    'kHz': 2,
    'mhz': 3,
    'N': 1,
    'kgf': 2,
    'lbf': 3,
    'dB': 1,
    'Np': 2,
    'lx': 1,
    'fc': 2,
  };

  // Helper mapping full unit name to short acronym/badge label
  String _getAcronym(String unit) {
    final Map<String, String> acronyms = {
      'Meters': 'm',
      'Kilometers': 'km',
      'Centimeters': 'cm',
      'Millimeters': 'mm',
      'Miles': 'mi',
      'Yards': 'yd',
      'Feet': 'ft',
      'Inches': 'in',
      'Nautical Miles': 'nmi',
      'Square Meters': 'm²',
      'Square Kilometers': 'km²',
      'Square Centimeters': 'cm²',
      'Liters': 'l',
      'Milliliters': 'ml',
      'Cubic Meters': 'm³',
      'Celsius': '°C',
      'Fahrenheit': '°F',
      'Kelvin': 'K',
      'Seconds': 's',
      'Minutes': 'min',
      'Hours': 'h',
      'Days': 'd',
      'Bytes': 'B',
      'Kilobytes': 'KB',
      'Megabytes': 'MB',
      'Gigabytes': 'GB',
      'Pascals': 'Pa',
      'Kilopascals': 'kPa',
      'Bar': 'bar',
      'Watts': 'W',
      'Kilowatts': 'kW',
      'Megawatts': 'mW',
    };
    return acronyms[unit] ?? (unit.length > 3 ? unit.substring(0, 3) : unit);
  }

  // Formatting Rule: up to 5 integer digits and exactly 3 decimal places.
  // Beyond that threshold, represent using superscript scientific notation.
  String _formatValue(String valueStr) {
    if (valueStr.isEmpty || valueStr == 'Error') return '';
    final double? value = double.tryParse(valueStr);
    if (value == null) return valueStr;
    if (value == 0.0) return '0.000';

    final double absValue = value.abs();
    if (absValue >= 100000.0 || (absValue > 0.0 && absValue < 0.001)) {
      String expStr = value.toStringAsExponential(3);
      final parts = expStr.split('e');
      if (parts.length == 2) {
        final base = parts[0];
        final Map<String, String> superscriptMap = {
          '-': '⁻',
          '0': '⁰',
          '1': '¹',
          '2': '²',
          '3': '³',
          '4': '⁴',
          '5': '⁵',
          '6': '⁶',
          '7': '⁷',
          '8': '⁸',
          '9': '⁹',
          '+': '⁺',
        };
        String superscriptExponent = parts[1]
            .split('')
            .map((char) => superscriptMap[char] ?? char)
            .join('');
        return '$base × 10$superscriptExponent';
      }
      return expStr;
    } else {
      return value.toStringAsFixed(3);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    showOverlayMessage('Copied to clipboard');
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      final pastedText = clipboardData.text!;
      if (RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(pastedText)) {
        setState(() {
          _inputController.text = pastedText;
          _inputController.selection = TextSelection.collapsed(
            offset: pastedText.length,
          );
          _convert();
        });
      } else {
        showOverlayMessage('Invalid number format');
      }
    }
  }

  void _showHistoryModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (modalContext) {
        final currentTheme = CupertinoTheme.of(modalContext);
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
                    history: history,
                    onExpressionTap: (String result) {
                      final cleanedResult = result.replaceAll(',', '');
                      if (RegExp(
                        r'^[0-9]*\.?[0-9]*$',
                      ).hasMatch(cleanedResult)) {
                        setState(() {
                          _inputController.text = cleanedResult;
                          _inputController.selection = TextSelection.collapsed(
                            offset: cleanedResult.length,
                          );
                          _convert();
                        });
                        Navigator.pop(modalContext);
                      } else {
                        showOverlayMessage('Invalid number format');
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

  @override
  void initState() {
    super.initState();
    _fromUnit = widget.units.first;
    _toUnit = widget.units[1];
    _loadHistory();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      setState(() => _result = '');
      return;
    }
    String result = widget.onConvert(_inputController.text, _fromUnit, _toUnit);
    setState(() => _result = result);
  }

  Map<String, String> _convertToAllUnits() {
    Map<String, String> results = {};
    if (_inputController.text.isEmpty) return results;

    try {
      for (String unit in widget.units) {
        if (unit != _fromUnit) {
          String result = widget.onConvert(
            _inputController.text,
            _fromUnit,
            unit,
          );
          results[unit] = result;
        }
      }
    } catch (e) {
      debugPrint('Error converting to all units: $e');
    }
    return results;
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final loadedHistory = jsonList
            .map((json) => CalculationHistory.fromJson(json))
            .toList()
            .reversed
            .toList();
        if (mounted) {
          setState(() {
            history = loadedHistory;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = history.reversed.map((entry) => entry.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  Future<void> _clearHistory() async {
    if (mounted) {
      setState(() {
        history.clear();
      });
      await _saveHistory();
      showOverlayMessage('History Cleared');
    }
  }

  void showOverlayMessage(String message) {
    final overlay = Navigator.of(context).overlay!;
    final overlayEntry = OverlayEntry(
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
    String unit,
    String formattedValue,
    String rawValue,
  ) {
    final currentTheme = CupertinoTheme.of(context);
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
          // Top Row: Acronym Badge & Full Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getAcronym(unit),
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
                  unit,
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
          // Bottom Row: Calculated Value Display & Copy Action
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

  // Base Unit Scrollable Row Selector
  Widget _buildBaseUnitSelector() {
    final currentTheme = CupertinoTheme.of(context);
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.units.length,
        itemBuilder: (context, index) {
          final unit = widget.units[index];
          final isSelected = unit == _fromUnit;
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
                  _fromUnit = unit;
                  _convert();
                });
              },
              child: Text(
                _getAcronym(unit),
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

  // Pinned Bottom control section containing base selector, input field, and action utilities
  Widget _buildBottomPanel() {
    final currentTheme = CupertinoTheme.of(context);
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
                    onChanged: (value) {
                      _convert();
                    },
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
    final currentTheme = CupertinoTheme.of(context);
    final allConversions = _convertToAllUnits();

    final sortedUnits = widget.units.where((unit) => unit != _fromUnit).toList()
      ..sort((a, b) {
        String aKey = a
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('(', '')
            .replaceAll(')', '')
            .replaceAll('per', '/')
            .substring(0, a.length > 3 ? 3 : a.length);
        String bKey = b
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll(')', '')
            .replaceAll('(', '')
            .replaceAll('per', '/')
            .substring(0, b.length > 3 ? 3 : b.length);
        return (_unitRank[aKey] ?? 999).compareTo(_unitRank[bKey] ?? 999);
      });

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title aligned to the left with a 15px margin
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
                itemCount: sortedUnits.length,
                itemBuilder: (context, index) {
                  final unit = sortedUnits[index];
                  final rawValue = allConversions[unit] ?? '';
                  final formattedValue = _formatValue(rawValue);
                  return _buildUnitCard(
                    context,
                    unit,
                    formattedValue,
                    rawValue,
                  );
                },
              ),
            ),
            // Pinned Bottom Panel
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }
}
