import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:quantify/quantify.dart';
import '../../unit/model/units_info.dart';
import '../base_converter_page.dart';

class LengthConverterPage extends StatelessWidget {
  const LengthConverterPage({super.key});

  static const List<UnitInfo<LengthUnit>> _units = [
    UnitInfo(
      unit: LengthUnit.millimeter,
      displayName: 'Millimeters',
      symbol: 'mm',
      rank: 1,
    ),
    UnitInfo(
      unit: LengthUnit.centimeter,
      displayName: 'Centimeters',
      symbol: 'cm',
      rank: 2,
    ),
    UnitInfo(
      unit: LengthUnit.meter,
      displayName: 'Meters',
      symbol: 'm',
      rank: 3,
    ),
    UnitInfo(
      unit: LengthUnit.kilometer,
      displayName: 'Kilometers',
      symbol: 'km',
      rank: 4,
    ),
    UnitInfo(
      unit: LengthUnit.inch,
      displayName: 'Inches',
      symbol: 'in',
      rank: 5,
    ),
    UnitInfo(unit: LengthUnit.foot, displayName: 'Feet', symbol: 'ft', rank: 6),
    UnitInfo(
      unit: LengthUnit.yard,
      displayName: 'Yards',
      symbol: 'yd',
      rank: 7,
    ),
    UnitInfo(
      unit: LengthUnit.mile,
      displayName: 'Miles',
      symbol: 'mi',
      rank: 8,
    ),
    UnitInfo(
      unit: LengthUnit.nauticalMile,
      displayName: 'Nautical Miles',
      symbol: 'nmi',
      rank: 9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseConverterPage<LengthUnit, Length>(
      title: 'Length Converter',
      units: _units,
      createQuantity: (val, unit) => Length(val, unit),
      evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
    );
  }
}
