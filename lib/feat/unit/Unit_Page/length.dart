import 'package:material_ui/material_ui.dart';
import 'package:quantify/quantify.dart';

import '../screen/base_converter_page.dart';

class LengthConverterPage extends StatelessWidget {
  static const _metric = [
    (unit: LengthUnit.millimeter, name: 'Millimeters', symbol: 'mm'),
    (unit: LengthUnit.centimeter, name: 'Centimeters', symbol: 'cm'),
    (unit: LengthUnit.meter, name: 'Meters', symbol: 'm'),
    (unit: LengthUnit.kilometer, name: 'Kilometers', symbol: 'km'),
  ];

  static const _imperial = [
    (unit: LengthUnit.inch, name: 'Inches', symbol: 'in'),
    (unit: LengthUnit.foot, name: 'Feet', symbol: 'ft'),
    (unit: LengthUnit.yard, name: 'Yards', symbol: 'yd'),
    (unit: LengthUnit.mile, name: 'Miles', symbol: 'mi'),
    (unit: LengthUnit.nauticalMile, name: 'Nautical Miles', symbol: 'nmi'),
  ];

  const LengthConverterPage({super.key});

  @override
  Widget build(BuildContext context) => BaseConverterPage<LengthUnit, Length>(
    title: 'Length Converter',
    metricUnits: _metric,
    imperialUnits: _imperial,
    createQuantity: (val, unit) => Length(val, unit),
    evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
  );
}
