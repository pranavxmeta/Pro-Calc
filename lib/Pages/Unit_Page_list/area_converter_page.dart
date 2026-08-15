import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:quantify/quantify.dart';
import '../../models/units_info.dart';
import '../base_converter_page.dart';

class AreaConverterPage extends StatelessWidget {
  const AreaConverterPage({super.key});

  static const List<UnitInfo<AreaUnit>> _units = [
    UnitInfo(
      unit: AreaUnit.squareMillimeter,
      displayName: 'Square Millimeters',
      symbol: 'mm²',
      rank: 1,
    ),
    UnitInfo(
      unit: AreaUnit.squareCentimeter,
      displayName: 'Square Centimeters',
      symbol: 'cm²',
      rank: 2,
    ),
    UnitInfo(
      unit: AreaUnit.squareMeter,
      displayName: 'Square Meters',
      symbol: 'm²',
      rank: 3,
    ),
    UnitInfo(
      unit: AreaUnit.hectare,
      displayName: 'Hectares',
      symbol: 'ha',
      rank: 4,
    ),
    UnitInfo(
      unit: AreaUnit.squareKilometer,
      displayName: 'Square Kilometers',
      symbol: 'km²',
      rank: 5,
    ),
    UnitInfo(
      unit: AreaUnit.squareInch,
      displayName: 'Square Inches',
      symbol: 'in²',
      rank: 6,
    ),
    UnitInfo(
      unit: AreaUnit.squareFoot,
      displayName: 'Square Feet',
      symbol: 'ft²',
      rank: 7,
    ),
    UnitInfo(
      unit: AreaUnit.squareYard,
      displayName: 'Square Yards',
      symbol: 'yd²',
      rank: 8,
    ),
    UnitInfo(unit: AreaUnit.acre, displayName: 'Acres', symbol: 'ac', rank: 9),
    UnitInfo(
      unit: AreaUnit.squareMile,
      displayName: 'Square Miles',
      symbol: 'mi²',
      rank: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseConverterPage<AreaUnit, Area>(
      title: 'Area Converter',
      units: _units,
      createQuantity: (val, unit) => Area(val, unit),
      evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
    );
  }
}
