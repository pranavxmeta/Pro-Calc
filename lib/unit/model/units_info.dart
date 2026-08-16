/// Represents metadata for a unit: its native Enum, display title, symbol, and display rank.
class UnitInfo<U extends Enum> {
  final U unit;
  final String displayName;
  final String symbol;
  final int rank;

  const UnitInfo({
    required this.unit,
    required this.displayName,
    required this.symbol,
    this.rank = 999,
  });
}
