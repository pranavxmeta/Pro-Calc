// lib/feat/shape/screen/base_shape_page.dart
import 'package:apptoast/apptoast.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
// import 'package:pro_calc/core/utils/app_toast.dart';

import '../widget/shape_display.dart';
import '../widget/shape_parameter_card.dart';

typedef UnitOption = ({String unit, double factor});
typedef ShapeSolverFn = Map<String, double> Function(
  Map<String, double> inputs,
);
typedef ShapePainterBuilder = CustomPainter Function(
  BuildContext context,
  Map<String, double> displayValues,
  Map<String, String> activeUnits,
  bool isDark,
);

/// Primary unit system with Length, Area, and Volume dimensions
enum BaseUnit(
  final String symbol,
  final String label,
  final double lengthFactor,
  final String areaSymbol,
  final double areaFactor,
  final String volumeSymbol,
  final double volumeFactor,
) {
  meter('m', 'Meter (m)', 1.0, 'm²', 1.0, 'm³', 1.0),
  centimeter('cm', 'Centimeter (cm)', 100.0, 'cm²', 10000.0, 'cm³', 1000000.0),
  kilometer('km', 'Kilometer (km)', 0.001, 'km²', 0.000001, 'km³', 1e-9),
  foot('ft', 'Foot (ft)', 3.28084, 'ft²', 10.7639, 'ft³', 35.3147),
  inch('in', 'Inch (in)', 39.3701, 'in²', 1550.0, 'in³', 61023.7),
  mile('mi', 'Mile (mi)', 0.000621371, 'acre', 0.000247105, 'yd³', 1.30795);

  static List<UnitOption> get lengthOptions =>
      values.map((u) => (unit: u.symbol, factor: u.lengthFactor)).toList();

  static List<UnitOption> get areaOptions =>
      values.map((u) => (unit: u.areaSymbol, factor: u.areaFactor)).toList();

  static List<UnitOption> get volumeOptions => values
      .map((u) => (unit: u.volumeSymbol, factor: u.volumeFactor))
      .toList();

  /// Routes to the correct physical dimension automatically
  static List<UnitOption> optionsFor(String param) =>
      switch (param.toLowerCase()) {
        final p when p.contains('volume') => volumeOptions,
        final p when p.contains('area') => areaOptions,
        _ => lengthOptions,
      };
}

class const BaseShapePage({
  super.key,
  required final String title,
  required final String shapeType,
  required final List<String> parameters,
  required final ShapeSolverFn solver,
  final Map<String, List<UnitOption>>? unitOptions,
  final ShapePainterBuilder? painterBuilder,
}) extends StatefulWidget {
  @override
  State<BaseShapePage> createState() => _BaseShapePageState();
}

class _BaseShapePageState extends State<BaseShapePage> {
  static final _numFormatter = NumberFormat('#,##0.######');

  final Map<String, bool> _isInput = {};
  final Map<String, String> _activeUnits = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, double> _solvedMeters = {};

  BaseUnit _baseUnit = BaseUnit.meter;

  List<UnitOption> _unitsFor(String param) =>
      widget.unitOptions?[param] ?? BaseUnit.optionsFor(param);

  @override
  void initState() {
    super.initState();
    for (final param in widget.parameters) {
      _isInput[param] = false;
      _activeUnits[param] = _defaultUnitFor(param, _baseUnit.symbol);

      final ctrl = TextEditingController()..addListener(_recalculate);
      final node = FocusNode();

      _controllers[param] = ctrl;
      _focusNodes[param] = node;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  String _defaultUnitFor(String param, String base) =>
      _unitsFor(param)
          .firstWhere(
            (u) => u.unit == base || u.unit.startsWith(base),
            orElse: () => _unitsFor(param).first,
          )
          .unit;

  double _factorFor(String param, String unit) => _unitsFor(param)
      .firstWhere(
        (u) => u.unit == unit,
        orElse: () => (unit: unit, factor: 1.0),
      )
      .factor;

  String _formatNumeric(double value) {
    if (value == 0) return '0';
    final abs = value.abs();
    if (abs >= 1e7 || (abs > 0 && abs < 1e-4)) {
      final exp = value.toStringAsExponential(4);
      final parts = exp.split('e');
      final mantissa = double.parse(parts[0]).toString();
      return '${mantissa}e${parts[1].replaceAll('+', '')}';
    }
    return _numFormatter.format(value);
  }

  void _recalculate() {
    final inputsInMeters = <String, double>{};

    for (final p in widget.parameters) {
      if ((_isInput[p] ?? false) && _controllers[p]!.text.isNotEmpty) {
        final val = double.tryParse(_controllers[p]!.text.trim());
        if (val case double validVal when validVal > 0) {
          final activeUnit = _activeUnits[p] ?? _baseUnit.symbol;
          final factor = _factorFor(p, activeUnit);
          inputsInMeters[p] = validVal / factor;
        }
      }
    }

    final solved = widget.solver(inputsInMeters);

    setState(() {
      _solvedMeters
        ..clear()
        ..addAll(solved);
    });
  }

  void _clearAll() {
    for (final p in widget.parameters) {
      _controllers[p]!.clear();
      _isInput[p] = false;
      _focusNodes[p]!.unfocus();
    }
    setState(() => _solvedMeters.clear());
    AppToast.info(context, 'Inputs cleared');
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppToast.success(context, 'Copied $text');
  }

  void _showBaseUnitModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const .symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final opt in BaseUnit.values)
                ListTile(
                  title: Text(
                    opt.label,
                    style: TextStyle(
                      fontFamily: 'RedditSans',
                      fontWeight: opt == _baseUnit
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: opt == _baseUnit
                          ? const Color(0xFF007FFF)
                          : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                    ),
                  ),
                  trailing: opt == _baseUnit
                      ? const Icon(
                          FluentIcons.checkmark_24_regular,
                          color: Color(0xFF007FFF),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _baseUnit = opt;
                      for (final p in widget.parameters) {
                        _activeUnits[p] = _defaultUnitFor(p, _baseUnit.symbol);
                      }
                      _recalculate();
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _buildDisplayValues() {
    final display = <String, double>{};
    for (final p in widget.parameters) {
      final activeUnit = _activeUnits[p] ?? _baseUnit.symbol;
      final factor = _factorFor(p, activeUnit);

      if (_isInput[p] ?? false) {
        final val = double.tryParse(_controllers[p]!.text.trim());
        if (val != null && val > 0) display[p] = val;
      } else if (_solvedMeters.containsKey(p)) {
        display[p] = _solvedMeters[p]! * factor;
      }
    }
    return display;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final displayValues = _buildDisplayValues();

    return Scaffold(
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const .fromLTRB(16.0, 16.0, 16.0, 12.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'RedditSans',
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ),
                  if (widget.painterBuilder != null)
                    SliverToBoxAdapter(
                      child: ShapeDisplay(
                        painter: widget.painterBuilder!(
                          context,
                          displayValues,
                          _activeUnits,
                          isDark,
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = widget.parameters[index];
                      final isInput = _isInput[p] ?? false;
                      final isEvaluated =
                          !isInput &&
                          _solvedMeters.containsKey(p) &&
                          _solvedMeters[p]! > 0;
                      final activeUnit = _activeUnits[p] ?? _baseUnit.symbol;

                      var displayValue = '';
                      if (!isInput && _solvedMeters.containsKey(p)) {
                        final inMeters = _solvedMeters[p]!;
                        final factor = _factorFor(p, activeUnit);
                        displayValue = _formatNumeric(inMeters * factor);
                      }

                      final availUnits = _unitsFor(p)
                          .map((u) => u.unit)
                          .toList();

                      return ShapeParameterCard(
                        parameter: p,
                        isInput: isInput,
                        displayValue: displayValue,
                        activeUnit: activeUnit,
                        availableUnits: availUnits.isNotEmpty
                            ? availUnits
                            : [_baseUnit.symbol],
                        controller: _controllers[p]!,
                        focusNode: _focusNodes[p]!,
                        onToggleInput: () {
                          if (isEvaluated) {
                            AppToast.info(
                              context,
                              '$p is auto-calculated. Clear inputs to edit.',
                            );
                            return;
                          }

                          setState(() {
                            final curr = _isInput[p] ?? false;
                            _isInput[p] = !curr;
                            _controllers[p]!.clear();

                            if (!curr) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _focusNodes[p]?.requestFocus();
                              });
                            } else {
                              _focusNodes[p]?.unfocus();
                            }
                            _recalculate();
                          });
                        },
                        onUnitSelected: (u) {
                          setState(() {
                            _activeUnits[p] = u;
                            _recalculate();
                          });
                        },
                        onCopy: _copy,
                      );
                    }, childCount: widget.parameters.length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                ],
              ),
            ),
            Container(
              padding: const .fromLTRB(14.0, 8.0, 14.0, 10.0),
              color: Colors.transparent,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _showBaseUnitModal,
                      child: Container(
                        height: 44.0,
                        padding: const .symmetric(horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: .circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Base: ${_baseUnit.symbol}',
                              style: const TextStyle(
                                fontFamily: 'RedditSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007FFF),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(
                              FluentIcons.chevron_down_16_regular,
                              size: 14.0,
                              color: Color(0xFF007FFF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        FluentIcons.dismiss_24_regular,
                        color: Color(0xFF007FFF),
                      ),
                      tooltip: 'Clear All',
                      onPressed: _clearAll,
                      style: IconButton.styleFrom(
                        backgroundColor: pillBg,
                        minimumSize: const Size(44.0, 44.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
