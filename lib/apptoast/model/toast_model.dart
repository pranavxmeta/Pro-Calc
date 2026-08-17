import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

/// Enhanced enum binding visual identity directly to each toast variant.
enum ToastType {
  info(Color(0xFFFF9000), FluentIcons.info_24_filled),
  success(Color(0xFF34C759), FluentIcons.checkmark_circle_24_filled),
  warning(Color(0xFFFFCC00), FluentIcons.warning_24_filled),
  error(Color(0xFFFF3B30), FluentIcons.dismiss_circle_24_filled);

  const ToastType(this.accentColor, this.icon);

  final Color accentColor;
  final IconData icon;
}

/// Immutable data payload passed to the toast presenter.
@immutable
class ToastPayload {
  const ToastPayload({
    required this.message,
    this.type = ToastType.info,
    this.duration = const Duration(milliseconds: 2400),
    this.customIcon,
    this.onDismiss,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final IconData? customIcon;
  final VoidCallback? onDismiss;
}
