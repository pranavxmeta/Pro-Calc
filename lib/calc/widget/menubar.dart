import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Unified configuration class for toolbar buttons.
class ToolbarButtonConfig {
  const ToolbarButtonConfig({
    required this.icon,
    this.iconSize,
    this.color,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final double? iconSize;
  final Color? color;
  final VoidCallback onTap;
  final String? tooltip;
}

/// High-performance Material 3 toolbar widget for quick calculator actions.
/// Self-contained with zero parent rebuilds; retains Toolbox in a ready state.
class CalcMenubar extends StatelessWidget {
  const CalcMenubar({
    super.key,
    this.onCopy,
    this.onPaste,
    this.onToolbox,
    this.customButtons,
  });

  final Future<bool> Function()? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onToolbox;
  final List<ToolbarButtonConfig>? customButtons;

  @override
  Widget build(BuildContext context) {
    if (customButtons != null && customButtons!.isNotEmpty) {
      return _buildCustomButtons(context, customButtons!);
    }

    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onCopy != null)
              _CopyButton(onCopy: onCopy!, defaultColor: iconColor),
            const SizedBox(width: 8.0),
            IconButton(
              icon: Icon(
                FluentIcons.clipboard_paste_24_regular,
                size: 22.0,
                color: iconColor,
              ),
              tooltip: 'Paste',
              onPressed: onPaste,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: Icon(
                FluentIcons.toolbox_24_regular,
                size: 22.0,
                color: iconColor,
              ),
              tooltip: 'Toolbox',
              onPressed: onToolbox,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButtons(
    BuildContext context,
    List<ToolbarButtonConfig> buttons,
  ) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: 8.0),
              IconButton(
                icon: Icon(
                  buttons[i].icon,
                  size: buttons[i].iconSize ?? 22.0,
                  color: buttons[i].color ?? iconColor,
                ),
                tooltip: buttons[i].tooltip,
                onPressed: buttons[i].onTap,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Self-contained animated button that morphs into a checkmark upon successful copy.
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.onCopy, required this.defaultColor});

  final Future<bool> Function() onCopy;
  final Color defaultColor;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _isCopied = false;
  Timer? _revertTimer;

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final success = await widget.onCopy();
    if (success && mounted) {
      HapticFeedback.lightImpact();
      setState(() => _isCopied = true);
      _revertTimer?.cancel();
      _revertTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _isCopied = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final successColor = Theme.of(context).colorScheme.primary;

    return IconButton(
      tooltip: _isCopied ? 'Copied!' : 'Copy',
      onPressed: _handleTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _isCopied
            ? Icon(
                FluentIcons.checkmark_24_regular,
                key: const ValueKey('copied_checkmark'),
                size: 22.0,
                color: successColor,
              )
            : Icon(
                FluentIcons.copy_24_regular,
                key: const ValueKey('normal_copy'),
                size: 22.0,
                color: widget.defaultColor,
              ),
      ),
    );
  }
}

/// Backwards-compatible helper bridging existing call-sites to [CalcMenubar].
Widget menubar(
  BuildContext context, {
  Future<bool> Function()? onCopy,
  VoidCallback? onPaste,
  VoidCallback? onToolbox,
  List<ToolbarButtonConfig>? customButtons,
}) => CalcMenubar(
  onCopy: onCopy,
  onPaste: onPaste,
  onToolbox: onToolbox,
  customButtons: customButtons,
);
