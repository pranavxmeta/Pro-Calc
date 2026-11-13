import 'package:material_ui/material_ui.dart';
import 'package:quantify/quantify.dart';

import '../screen/base_converter_page.dart';

class PowerConverterPage extends StatelessWidget {
  static const _metric = [
    (unit: PowerUnit.watt, name: 'Watts', symbol: 'W'),
    (unit: PowerUnit.kilowatt, name: 'Kilowatts', symbol: 'kW'),
    (unit: PowerUnit.megawatt, name: 'Megawatts', symbol: 'MW'),
    (unit: PowerUnit.gigawatt, name: 'Gigawatts', symbol: 'GW'),
    (unit: PowerUnit.milliwatt, name: 'Milliwatts', symbol: 'mW'),
    (
      unit: PowerUnit.metricHorsepower,
      name: 'Horsepower (Metric)',
      symbol: 'hp (M)',
    ),
  ];

  static const _imperial = [
    (unit: PowerUnit.horsepower, name: 'Horsepower (Imperial)', symbol: 'hp'),
    (unit: PowerUnit.btuPerHour, name: 'BTU per Hour', symbol: 'BTU/h'),
  ];

  const PowerConverterPage({super.key});

  @override
  Widget build(BuildContext context) => BaseConverterPage<PowerUnit, Power>(
    title: 'Power Converter',
    metricUnits: _metric,
    imperialUnits: _imperial,
    createQuantity: (val, unit) => Power(val, unit),
    evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
  );
}
