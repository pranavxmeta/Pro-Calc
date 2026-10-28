import 'package:flutter/material.dart';

/// Data model representing a mathematical constant.
class MathConstant {
  final String name;
  final String symbol;
  final double value;
  final String description;

  const MathConstant({
    required this.name,
    required this.symbol,
    required this.value,
    required this.description,
  });
}

/// Predefined list of mathematical and physical constants.
const List<MathConstant> kPredefinedMathConstants = [
  MathConstant(
    name: 'Pi',
    symbol: 'π',
    value: 3.141592653589793,
    description: 'Ratio of a circle\'s circumference to its diameter',
  ),
  MathConstant(
    name: 'Euler\'s Number',
    symbol: 'e',
    value: 2.718281828459045,
    description: 'Base of the natural logarithm',
  ),
  MathConstant(
    name: 'Golden Ratio',
    symbol: 'φ',
    value: 1.618033988749895,
    description: 'Mathematical constant associated with proportions',
  ),
  MathConstant(
    name: 'Speed of Light',
    symbol: 'c',
    value: 299792458.0,
    description: 'Speed of light in vacuum (m/s)',
  ),
  MathConstant(
    name: 'Earth Gravity',
    symbol: 'g',
    value: 9.80665,
    description: 'Standard acceleration due to gravity (m/s²)',
  ),
];

/// Triggers an on-screen popup card via Overlay (bypasses showDialog localizations check).
void kmathcon(
  BuildContext context, {
  void Function(MathConstant constant)? onSelect,
}) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (overlayContext) {
      final theme = Theme.of(context);

      return Stack(
        children: [
          // Dismiss background on tap
          GestureDetector(
            onTap: () => overlayEntry.remove(),
            child: Container(color: Colors.black54),
          ),
          // Centered popup card
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 320,
                constraints: const BoxConstraints(maxHeight: 400),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.functions, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text(
                          'Math Constants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: kPredefinedMathConstants.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = kPredefinedMathConstants[index];
                          return InkWell(
                            onTap: () {
                              overlayEntry.remove();
                              if (onSelect != null) {
                                onSelect(item);
                              }
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: Text(
                                      item.symbol,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${item.value}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => overlayEntry.remove(),
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Overlay.of(context).insert(overlayEntry);
}
