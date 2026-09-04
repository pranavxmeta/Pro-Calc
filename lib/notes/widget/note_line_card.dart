import 'package:cupertino_ui/cupertino_ui.dart';
import '../model/note_item.dart';
import '../theme/notes_theme.dart';

class NoteLineCard extends StatelessWidget {
  final NoteItem item;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSubtotalToggled;
  final VoidCallback onSubmitted;

  const NoteLineCard({
    super.key,
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.onTextChanged,
    required this.onSubtotalToggled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isSubtotal = item.type.isSubtotal;

    return Container(
      height: NotesTheme.lineHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: NotesTheme.horizontalPadding,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: isSubtotal
            ? NotesTheme.subtotalSymbolColor.withValues(alpha: 0.08)
            : NotesTheme.cardBackground,
        borderRadius: BorderRadius.circular(NotesTheme.cardBorderRadius),
        border: Border.all(
          color: isSubtotal ? NotesTheme.accentBlue : NotesTheme.borderColor,
          width: isSubtotal ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Index Badge
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${item.index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Courier',
                color: NotesTheme.mutedText,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Left Column: Editable Note (or Subtotal Label)
          Expanded(
            flex: 6,
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isSubtotal,
              placeholder: 'e.g. 100 = lunch',
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => onSubmitted(),
              onChanged: onTextChanged,
              style: isSubtotal
                  ? NotesTheme.subtotalTextStyle
                  : NotesTheme.noteInputStyle,
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          // Divider
          Container(width: 1, height: 28, color: NotesTheme.borderColor),

          // Right Column: Evaluation Chip / Subtotal Toggle Target
          Expanded(
            flex: 4,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: onSubtotalToggled,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Maths Sigma Symbol
                  Text(
                    '∑',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isSubtotal
                          ? NotesTheme.accentBlue
                          : NotesTheme.mutedText.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _formattedValue(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isSubtotal
                          ? NotesTheme.subtotalTextStyle
                          : NotesTheme.evalTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedValue() {
    final val = item.computedValue;
    if (val == null) return '';
    return val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(2);
  }
}
