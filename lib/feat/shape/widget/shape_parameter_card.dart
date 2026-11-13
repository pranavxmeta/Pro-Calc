import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'radial_unit_arc.dart';

/// Dual-state parameter card with hit-test isolation:
/// 1. Tapping card body activates input mode (Azure/Cyan gradient border).
/// 2. Double-tapping card body copies value.
/// 3. Tapping unit badge blooms the radial arc overlay without triggering card toggle.
class const ShapeParameterCard({
  super.key,
  required final String parameter,
  required final bool isInput,
  required final String displayValue,
  required final String activeUnit,
  required final List<String> availableUnits,
  required final TextEditingController controller,
  required final FocusNode focusNode,
  required final VoidCallback onToggleInput,
  required final ValueChanged<String> onUnitSelected,
  required final ValueChanged<String> onCopy,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(14.0);

    final inactiveBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final inactiveBorder = isDark
        ? const Color(0x2EFFFFFF)
        : const Color(0xFFE5E5EA);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggleInput, // Tapping card toggles between active and inactive
      onDoubleTap: !isInput && displayValue.isNotEmpty && displayValue != '-'
          ? () => onCopy('$displayValue $activeUnit')
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: isInput
              ? const LinearGradient(
                  colors: [Color(0xFF007FFF), Color(0xFF00E5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isInput
              ? null
              : Border.all(color: inactiveBorder, width: 0.5),
        ),
        padding: isInput ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
        child: Container(
          height: 108.0,
          padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
          decoration: BoxDecoration(
            color: isInput
                ? (isDark ? const Color(0xFF0D1D2D) : const Color(0xFFF0F9FF))
                : inactiveBg,
            borderRadius: isInput ? BorderRadius.circular(12.5) : borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: Parameter & Value / Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      parameter,
                      style: const TextStyle(
                        fontFamily: 'RedditSans',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    if (isInput)
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true, // Instantly opens keyboard on 1st tap
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        style: TextStyle(
                          fontFamily: 'RedditSans',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF007FFF),
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontFamily: 'RedditSans',
                            fontSize: 18.0,
                            color: Color(0xFF8E8E93),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    else
                      Text(
                        displayValue.isEmpty ? '-' : displayValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'RedditSans',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6.0),

              // Bottom: Unit List (its own tap recognizer wins, won't toggle the card)
              UnitSelectorBar(
                activeUnit: activeUnit,
                units: availableUnits,
                onUnitSelected: onUnitSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
