import 'dart:async';
import 'dart:ui';
import 'package:cupertino_ui/cupertino_ui.dart';
import '../model/toast_model.dart';
import '../theme/toast_theme.dart';

/// Self-governed toast pill with smooth entrance, wait, and exit animations.
class ToastWidget extends StatefulWidget {
  const ToastWidget({
    super.key,
    required this.payload,
    required this.isTopPositioned,
    required this.onFinished,
    this.theme = const ToastThemeData(),
  });

  final ToastPayload payload;
  final bool isTopPositioned;
  final VoidCallback onFinished;
  final ToastThemeData theme;

  @override
  State<ToastWidget> createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    // Natural physics: slides DOWN from top or UP from bottom
    final Offset beginOffset = widget.isTopPositioned
        ? const Offset(0, -0.4)
        : const Offset(0, 0.4);

    _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeIn,
          ),
        );

    _startPresentationCycle();
  }

  void _startPresentationCycle() {
    _controller.forward().then((_) {
      if (!mounted) return;
      _dismissTimer = Timer(widget.payload.duration, dismiss);
    });
  }

  /// Reverses the animation and informs the overlay service upon completion.
  Future<void> dismiss() async {
    _dismissTimer?.cancel();
    if (!mounted || _controller.isDismissed) return;

    await _controller.reverse();
    if (mounted) {
      widget.payload.onDismiss?.call();
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ToastType type = widget.payload.type;
    final IconData icon = widget.payload.customIcon ?? type.icon;
    final ToastThemeData theme = widget.theme;

    return Padding(
      padding: theme.margin,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dismissible(
              key: const ValueKey('toast_dismissible_entry'),
              direction: widget.isTopPositioned
                  ? DismissDirection.up
                  : DismissDirection.down,
              onDismissed: (_) => dismiss(),
              child: GestureDetector(
                onTap: dismiss,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: theme.blurSigma,
                      sigmaY: theme.blurSigma,
                    ),
                    child: Container(
                      padding: theme.padding,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(theme.borderRadius),
                        border: Border.all(
                          color: theme.borderColor,
                          width: 0.75,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: type.accentColor, size: 20),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              widget.payload.message,
                              style: theme.textStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
