import 'package:cupertino_ui/cupertino_ui.dart';
import '../model/toast_model.dart';
import '../theme/toast_theme.dart';
import '../widget/toast_widget.dart';

/// Overlay manager and backward-compatible bridge for global toasts.
final class AppToast {
  AppToast._();

  static OverlayEntry? _activeEntry;
  static GlobalKey<ToastWidgetState>? _activeWidgetKey;

  /// Main entry point for rendering the toast overlay.
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
    IconData? customIcon,
    bool isTop = true,
    ToastThemeData theme = const ToastThemeData(),
    VoidCallback? onDismiss,
  }) {
    if (!context.mounted) return;

    // Gracefully dismiss active toast before presenting a new one
    dismiss();

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final GlobalKey<ToastWidgetState> key = GlobalKey<ToastWidgetState>();
    _activeWidgetKey = key;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

        return SafeArea(
          child: Align(
            alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: isTop ? 16 : 0,
                bottom: isTop ? 0 : (24 + viewInsets.bottom),
              ),
              child: ToastWidget(
                key: key,
                payload: ToastPayload(
                  message: message,
                  type: type,
                  duration: duration,
                  customIcon: customIcon,
                  onDismiss: onDismiss,
                ),
                isTopPositioned: isTop,
                theme: theme,
                onFinished: () => _cleanEntry(entry),
              ),
            ),
          ),
        );
      },
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  /// Programmatically triggers smooth exit on current toast.
  static void dismiss() {
    if (_activeWidgetKey?.currentState != null) {
      _activeWidgetKey!.currentState!.dismiss();
    } else {
      _activeEntry?.remove();
      _activeEntry = null;
    }
  }

  static void _cleanEntry(OverlayEntry entry) {
    if (_activeEntry == entry) {
      _activeEntry?.remove();
      _activeEntry = null;
      _activeWidgetKey = null;
    }
  }
}

/// Ergonomic BuildContext extension for displaying toasts anywhere in the widget tree.
extension ToastContextExtension on BuildContext {
  /// General toast invocation.
  void appToast(
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
    IconData? customIcon,
    bool isTop = true,
    ToastThemeData theme = const ToastThemeData(),
    VoidCallback? onDismiss,
  }) {
    AppToast.show(
      this,
      message,
      type: type,
      duration: duration,
      customIcon: customIcon,
      isTop: isTop,
      theme: theme,
      onDismiss: onDismiss,
    );
  }

  void dismissAppToast() => AppToast.dismiss();
}
