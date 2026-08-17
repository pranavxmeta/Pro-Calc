import 'package:cupertino_ui/cupertino_ui.dart';

/// Design tokens for global overlay toast rendering.
@immutable
class ToastThemeData {
  const ToastThemeData({
    this.backgroundColor = const Color.fromRGBO(20, 20, 20, 0.90),
    this.borderColor = const Color.fromRGBO(255, 255, 255, 0.12),
    this.textStyle = const TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      fontFamily: 'Reddit Sans',
      color: CupertinoColors.white,
      decoration: TextDecoration.none,
      letterSpacing: -0.2,
    ),
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.blurSigma = 14.0,
  });

  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blurSigma;
}
