import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:quantify/quantify.dart';
import '../../unit/model/units_info.dart';
import '../base_converter_page.dart';

class TemperatureConverterPage extends StatelessWidget {
  const TemperatureConverterPage({super.key});

  static const List<UnitInfo<TemperatureUnit>> _units = [
    UnitInfo(
      unit: TemperatureUnit.celsius,
      displayName: 'Celsius',
      symbol: '°C',
      rank: 1,
    ),
    UnitInfo(
      unit: TemperatureUnit.fahrenheit,
      displayName: 'Fahrenheit',
      symbol: '°F',
      rank: 2,
    ),
    UnitInfo(
      unit: TemperatureUnit.kelvin,
      displayName: 'Kelvin',
      symbol: 'K',
      rank: 3,
    ),
    UnitInfo(
      unit: TemperatureUnit.rankine,
      displayName: 'Rankine',
      symbol: '°R',
      rank: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseConverterPage<TemperatureUnit, Temperature>(
      title: 'Temperature Converter',
      units: _units,
      createQuantity: (val, unit) => Temperature(val, unit),
      evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
    );
  }
}
