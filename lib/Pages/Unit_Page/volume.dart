import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:quantify/quantify.dart';
import '../../unit/model/units_info.dart';
import '../base_converter_page.dart';

class VolumeConverterPage extends StatelessWidget {
  const VolumeConverterPage({super.key});

  static const List<UnitInfo<VolumeUnit>> _units = [
    UnitInfo(
      unit: VolumeUnit.milliliter,
      displayName: 'Milliliters',
      symbol: 'ml',
      rank: 1,
    ),
    UnitInfo(
      unit: VolumeUnit.cubicCentimeter,
      displayName: 'Cubic Centimeters',
      symbol: 'cm³',
      rank: 2,
    ),
    UnitInfo(
      unit: VolumeUnit.litre,
      displayName: 'Liters',
      symbol: 'l',
      rank: 3,
    ),
    UnitInfo(
      unit: VolumeUnit.cubicMeter,
      displayName: 'Cubic Meters',
      symbol: 'm³',
      rank: 4,
    ),
    UnitInfo(
      unit: VolumeUnit.cubicInch,
      displayName: 'Cubic Inches',
      symbol: 'in³',
      rank: 5,
    ),
    UnitInfo(
      unit: VolumeUnit.cubicFoot,
      displayName: 'Cubic Feet',
      symbol: 'ft³',
      rank: 6,
    ),
    // UnitInfo(
    //   unit: VolumeUnit.usLiquidPint,
    //   displayName: 'Pints (US)',
    //   symbol: 'pt',
    //   rank: 7,
    // ),
    // UnitInfo(
    //   unit: VolumeUnit.usLiquidQuart,
    //   displayName: 'Quarts (US)',
    //   symbol: 'qt',
    //   rank: 8,
    // ),
    UnitInfo(
      unit: VolumeUnit.gallon,
      displayName: 'Gallons (US)',
      symbol: 'gal',
      rank: 9,
    ),
    UnitInfo(
      unit: VolumeUnit.imperialGallon,
      displayName: 'Gallons (UK)',
      symbol: 'imp gal',
      rank: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseConverterPage<VolumeUnit, Volume>(
      title: 'Volume Converter',
      units: _units,
      createQuantity: (val, unit) => Volume(val, unit),
      evaluateUnit: (qty, targetUnit) => qty.getValue(targetUnit),
    );
  }
}
