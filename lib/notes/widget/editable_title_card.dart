import 'package:cupertino_ui/cupertino_ui.dart';
import '../theme/notes_theme.dart';

class EditableTitleCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const EditableTitleCard({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: NotesTheme.titleCardHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: NotesTheme.horizontalPadding,
        vertical: NotesTheme.verticalPadding,
      ),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: NotesTheme.cardBackground,
        borderRadius: BorderRadius.circular(NotesTheme.cardBorderRadius),
        border: Border.all(color: NotesTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TITLE', style: NotesTheme.totalHeaderStyle),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: controller,
            placeholder: 'Tap to name this sheet...',
            style: NotesTheme.titleStyle,
            decoration: const BoxDecoration(),
            padding: EdgeInsets.zero,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
