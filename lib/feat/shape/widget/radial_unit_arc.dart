import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnitSelectorBar extends StatelessWidget {
  final String activeUnit;
  final List<String> units;
  final ValueChanged<String> onUnitSelected;

  const UnitSelectorBar({
    super.key,
    required this.activeUnit,
    required this.units,
    required this.onUnitSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 28.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: units.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6.0),
        itemBuilder: (context, index) {
          final unit = units[index];
          final isSelected = unit == activeUnit;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                HapticFeedback.selectionClick();
                onUnitSelected(unit);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? const Color(0x35FFFFFF)
                          : const Color(0x22000000))
                    : (isDark
                          ? const Color(0x18767680)
                          : const Color(0x10767680)),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isSelected
                      ? (isDark
                            ? const Color(0x45FFFFFF)
                            : const Color(0x25000000))
                      : Colors.transparent,
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'RedditSans',
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
