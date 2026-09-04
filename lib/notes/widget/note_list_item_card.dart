import 'package:cupertino_ui/cupertino_ui.dart';
import '../database/notes_database.dart';
import '../theme/notes_theme.dart';

class NoteListItemCard extends StatelessWidget {
  final NoteSheet sheet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteListItemCard({
    super.key,
    required this.sheet,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${sheet.updatedAt.day.toString().padLeft(2, '0')}/${sheet.updatedAt.month.toString().padLeft(2, '0')}/${sheet.updatedAt.year}';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: NotesTheme.horizontalPadding,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: NotesTheme.cardBackground,
        borderRadius: BorderRadius.circular(NotesTheme.cardBorderRadius),
        border: Border.all(color: NotesTheme.borderColor),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16.0),
        onPressed: onTap,
        child: Row(
          children: [
            // Left: Title and Updated Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sheet.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Courier',
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Updated: $formattedDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: NotesTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),

            // Middle: Grand Total Preview
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('TOTAL', style: NotesTheme.totalHeaderStyle),
                const SizedBox(height: 2),
                Text(
                  sheet.grandTotal.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Courier',
                    color: NotesTheme.accentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Right: Delete Action Button
            CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: onDelete,
              child: const Icon(
                CupertinoIcons.trash,
                size: 20,
                color: CupertinoColors.destructiveRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
