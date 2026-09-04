enum LineType {
  standard,
  subtotal;

  bool get isSubtotal => this == LineType.subtotal;
}

final class NoteItem {
  final int index;
  final String text;
  final LineType type;
  final double? computedValue;

  const NoteItem({
    required this.index,
    required this.text,
    this.type = LineType.standard,
    this.computedValue,
  });

  NoteItem copyWith({
    int? index,
    String? text,
    LineType? type,
    double? computedValue,
  }) {
    return NoteItem(
      index: index ?? this.index,
      text: text ?? this.text,
      type: type ?? this.type,
      computedValue: computedValue ?? this.computedValue,
    );
  }
}
