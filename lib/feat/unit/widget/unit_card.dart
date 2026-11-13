import 'package:material_ui/material_ui.dart';

import '../screen/base_converter_page.dart';

/// Compact vertical-stack conversion card with left-aligned digits.
/// Uses iOS grouped surfaces and an Azure-to-Cyan gradient border when active.
class const UnitCard<U extends Enum>({
  super.key,
  required final UnitInfo<U> unitInfo,
  required final String formattedValue,
  required final String rawValue,
  required final bool isActive,
  required final VoidCallback onSelect,
  required final ValueChanged<String> onCopy,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final borderRadius = BorderRadius.circular(12.0);

    final displayValue = formattedValue.isEmpty ? '0' : formattedValue;

    // iOS surface palette matching CalcPage
    final inactiveBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final inactiveBorder = isDark
        ? const Color(0x2EFFFFFF)
        : const Color(0xFFE5E5EA);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      onDoubleTap: () => onCopy(rawValue.isEmpty ? displayValue : rawValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    Color(0xFF007FFF), // Azure
                    Color(0xFF00E5FF), // Cyan
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isActive
              ? null
              : Border.all(color: inactiveBorder, width: 0.5),
        ),
        padding: isActive ? const .all(1.5) : .zero,
        child: Container(
          padding: const .fromLTRB(10.0, 7.0, 10.0, 7.0),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF0D1D2D) : const Color(0xFFF0F9FF))
                : inactiveBg,
            borderRadius: isActive ? .circular(10.5) : borderRadius,
          ),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const .symmetric(horizontal: 5.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF007FFF).withValues(alpha: 0.18)
                          : (isDark
                                ? const Color(0x1FFFFFFF)
                                : const Color(0xFFE5E5EA)),
                      borderRadius: .circular(4.0),
                    ),
                    child: Text(
                      unitInfo.symbol,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? (isDark
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF007FFF))
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF1C1C1E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      unitInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ],
              ),
              // Left-aligned digits for clean optical margins
              Text(
                displayValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'RedditSans',
                  color: isActive
                      ? (isDark
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF007FFF))
                      : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
