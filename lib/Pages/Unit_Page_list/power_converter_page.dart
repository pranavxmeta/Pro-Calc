import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:quantify/quantify.dart';
import '../../unit/model/units_info.dart';
import '../base_converter_page.dart';

class PowerConverterPage extends StatelessWidget {
  const PowerConverterPage({super.key});

  static const List<UnitInfo<PowerUnit>> _units = [
    UnitInfo(unit: PowerUnit.watt, displayName: 'Watts', symbol: 'W', rank: 1),
    UnitInfo(
      unit: PowerUnit.kilowatt,
      displayName: 'Kilowatts',
      symbol: 'kW',
      rank: 2,
    ),
    UnitInfo(
      unit: PowerUnit.megawatt,
      displayName: 'Megawatts',
      symbol: 'MW',
      rank: 3,
    ),
    UnitInfo(
      unit: PowerUnit.gigawatt,
      displayName: 'Gigawatts',
      symbol: 'GW',
      rank: 4,
    ),
    UnitInfo(
      unit: PowerUnit.milliwatt,
      displayName: 'Milliwatts',
      symbol: 'mW',
      rank: 5,
    ),
    UnitInfo(
      unit: PowerUnit.metricHorsepower,
      displayName: 'Horsepower (Metric)',
      symbol: 'hp (M)',
      rank: 6,
    ),
    UnitInfo(
      unit: PowerUnit.horsepower,
      displayName: 'Horsepower (Imperial)',
      symbol: 'hp',
      rank: 7,
    ),
    UnitInfo(
      unit: PowerUnit.btuPerHour,
      displayName: 'BTU per Hour',
      symbol: 'BTU/h',
      rank: 8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseConverterPage<PowerUnit, Power>(
      title: 'Power Converter',
      units: _units,
      createQuantity: (val, unit) => Power(val, unit),
      evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
    );
  }
}
