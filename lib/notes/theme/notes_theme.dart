import 'package:cupertino_ui/cupertino_ui.dart';

abstract final class NotesTheme {
  // Dimensions
  static const double titleCardHeight = 100.0;
  static const double cardBorderRadius = 14.0;
  static const double lineHeight = 52.0;
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 8.0;

  // Colors
  static const Color cardBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const Color borderColor = CupertinoColors.systemGrey4;
  static const Color accentGreen = CupertinoColors.systemGreen;
  static const Color accentBlue = CupertinoColors.activeBlue;
  static const Color mutedText = CupertinoColors.systemGrey;
  static const Color subtotalSymbolColor = CupertinoColors.systemPurple;

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFamily: 'Courier',
    color: CupertinoColors.label,
  );

  static const TextStyle noteInputStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Courier',
    height: 1.3,
    color: CupertinoColors.label,
  );

  static const TextStyle evalTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Courier',
    fontWeight: FontWeight.w600,
    color: accentGreen,
  );

  static const TextStyle subtotalTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Courier',
    fontWeight: FontWeight.w700,
    color: accentBlue,
  );

  static const TextStyle totalHeaderStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: mutedText,
  );

  static const TextStyle totalAmountStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    fontFamily: 'Courier',
    color: CupertinoColors.label,
  );
}
