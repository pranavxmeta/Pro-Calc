import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../history/widget/history_sheet.dart';
import '../widget/converter_input_bar.dart';
import '../widget/unit_card.dart';

/// Dart 3 Record Typedef: Replaces standalone model class completely.
typedef UnitInfo<U extends Enum> = ({U unit, String name, String symbol});

/// Modernized base unit converter screen.
/// Adopts a minimalist iOS grouped theme, locked 2-column cards, and native title layout.
class const BaseConverterPage<U extends Enum, Q>({
  super.key,
  required final String title,
  required final List<UnitInfo<U>> metricUnits,
  final List<UnitInfo<U>> imperialUnits = const [],
  required final Q Function(double value, U unit) createQuantity,
  required final double Function(Q quantity, U targetUnit) evaluateUnit,
}) extends StatefulWidget {
  @override
  State<BaseConverterPage<U, Q>> createState() =>
      _BaseConverterPageState<U, Q>();
}

class _BaseConverterPageState<U extends Enum, Q>
    extends State<BaseConverterPage<U, Q>> {
  late final TextEditingController _inputController;
  late UnitInfo<U> _selectedUnit;

  bool _isMetricExpanded = true;
  bool _isImperialExpanded = true;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController()
      ..addListener(() => setState(() {}));
    _selectedUnit = widget.metricUnits.isNotEmpty
        ? widget.metricUnits.first
        : widget.imperialUnits.first;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// Clean number formatting: zero trailing zeroes, dynamic decimal precision,
  /// and stripped exponential notation for extreme numbers.
  String _formatNumericValue(double value) {
    if (value == 0) return '0';
    final abs = value.abs();
    if (abs >= 1e7 || (abs > 0 && abs < 1e-4)) {
      final exp = value.toStringAsExponential(4);
      final parts = exp.split('e');
      final mantissa = double.parse(parts[0]).toString();
      return '${mantissa}e${parts[1].replaceAll('+', '')}';
    }
    return NumberFormat('#,##0.######').format(value);
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text'),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text != null && RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      _inputController.text = text;
      _inputController.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  void _showHistoryModal() {
    showHistorySheet(
      context,
      onExpressionTap: (result) {
        final cleaned = result.replaceAll(',', '').trim();
        if (RegExp(r'^\d*\.?\d*$').hasMatch(cleaned)) {
          _inputController.text = cleaned;
          _inputController.selection = TextSelection.collapsed(
            offset: cleaned.length,
          );
        }
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    const headerColor = Color(0xFF8E8E93);

    return InkWell(
      onTap: onToggle,
      borderRadius: .circular(8.0),
      child: Padding(
        padding: const .fromLTRB(16.0, 10.0, 16.0, 6.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: headerColor,
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.0 : -0.25,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: const Icon(
                FluentIcons.chevron_down_16_regular,
                size: 14.0,
                color: headerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverGrid({
    required List<UnitInfo<U>> units,
    required Q? quantity,
  }) => SliverPadding(
    padding: const .symmetric(horizontal: 14.0),
    sliver: SliverGrid.builder(
      // Locked 2-column layout with fixed ergonomic height
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 68.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unitInfo = units[index];
        final isActive = unitInfo.unit == _selectedUnit.unit;

        var formattedValue = '';
        var rawValue = '';

        if (quantity != null) {
          final calculated = widget.evaluateUnit(quantity, unitInfo.unit);
          formattedValue = _formatNumericValue(calculated);
          rawValue = calculated.toString();
        }

        return UnitCard<U>(
          unitInfo: unitInfo,
          formattedValue: formattedValue,
          rawValue: rawValue,
          isActive: isActive,
          onSelect: () => setState(() => _selectedUnit = unitInfo),
          onCopy: _copyToClipboard,
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputValue = double.tryParse(_inputController.text.trim());
    final quantity = inputValue != null
        ? widget.createQuantity(inputValue, _selectedUnit.unit)
        : null;

    final hasMetric = widget.metricUnits.isNotEmpty;
    final hasImperial = widget.imperialUnits.isNotEmpty;

    return Scaffold(
      // iOS System Grouped Background palette matching CalcPage
      backgroundColor: isDark
          ? const Color(0xFF0F0F12)
          : const Color.fromRGBO(242, 242, 247, 1.0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Native iOS-style large title header (no AppBar back button)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const .fromLTRB(16.0, 16.0, 16.0, 4.0),
                      child: Text(
                        widget.title.replaceAll(' Converter', ''),
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ),

                  if (hasMetric) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        title: 'METRIC',
                        isExpanded: _isMetricExpanded,
                        onToggle: () => setState(
                          () => _isMetricExpanded = !_isMetricExpanded,
                        ),
                      ),
                    ),
                    if (_isMetricExpanded)
                      _buildSliverGrid(
                        units: widget.metricUnits,
                        quantity: quantity,
                      ),
                  ],

                  if (hasImperial) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        title: 'IMPERIAL',
                        isExpanded: _isImperialExpanded,
                        onToggle: () => setState(
                          () => _isImperialExpanded = !_isImperialExpanded,
                        ),
                      ),
                    ),
                    if (_isImperialExpanded)
                      _buildSliverGrid(
                        units: widget.imperialUnits,
                        quantity: quantity,
                      ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                ],
              ),
            ),

            ConverterInputBar(
              controller: _inputController,
              onHistoryTap: _showHistoryModal,
              onPaste: _pasteFromClipboard,
              onClear: () => _inputController.clear(),
            ),
          ],
        ),
      ),
    );
  }
}
