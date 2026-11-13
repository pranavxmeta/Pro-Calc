import 'package:material_ui/material_ui.dart';
import 'package:quantify/quantify.dart';

import '../screen/base_converter_page.dart';

class AreaConverterPage extends StatelessWidget {
  static const _metric = [
    (
      unit: AreaUnit.squareMillimeter,
      name: 'Square Millimeters',
      symbol: 'mm²',
    ),
    (
      unit: AreaUnit.squareCentimeter,
      name: 'Square Centimeters',
      symbol: 'cm²',
    ),
    (unit: AreaUnit.squareMeter, name: 'Square Meters', symbol: 'm²'),
    (unit: AreaUnit.hectare, name: 'Hectares', symbol: 'ha'),
    (unit: AreaUnit.squareKilometer, name: 'Square Kilometers', symbol: 'km²'),
  ];

  static const _imperial = [
    (unit: AreaUnit.squareInch, name: 'Square Inches', symbol: 'in²'),
    (unit: AreaUnit.squareFoot, name: 'Square Feet', symbol: 'ft²'),
    (unit: AreaUnit.squareYard, name: 'Square Yards', symbol: 'yd²'),
    (unit: AreaUnit.acre, name: 'Acres', symbol: 'ac'),
    (unit: AreaUnit.squareMile, name: 'Square Miles', symbol: 'mi²'),
  ];

  const AreaConverterPage({super.key});

  @override
  Widget build(BuildContext context) => BaseConverterPage<AreaUnit, Area>(
    title: 'Area Converter',
    metricUnits: _metric,
    imperialUnits: _imperial,
    createQuantity: (val, unit) => Area(val, unit),
    evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
  );
}
