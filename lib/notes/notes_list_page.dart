import 'package:cupertino_ui/cupertino_ui.dart';
import 'database/notes_database.dart';
import 'notes_calc_page.dart';
import 'theme/notes_theme.dart';
import 'widget/note_list_item_card.dart';

class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});

  Future<void> _openNewNote(BuildContext context) async {
    final sheetId = await NotesDatabase.instance.createNewSheet();
    if (context.mounted) {
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => NotesCalcPage(sheetId: sheetId),
        ),
      );
    }
  }

  void _openExistingNote(BuildContext context, int sheetId) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => NotesCalcPage(sheetId: sheetId)),
    );
  }

  void _confirmDelete(BuildContext context, NoteSheet sheet) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${sheet.title}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              NotesDatabase.instance.deleteSheet(sheet.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: const Text('My Notes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openNewNote(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.add, size: 20),
              SizedBox(width: 4),
              Text('New', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<List<NoteSheet>>(
          stream: NotesDatabase.instance.watchAllSheets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final sheets = snapshot.data ?? [];

            if (sheets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.doc_plaintext,
                      size: 56,
                      color: NotesTheme.mutedText,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No saved notes yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: NotesTheme.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: () => _openNewNote(context),
                      child: const Text('Create First Note'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: sheets.length,
              itemBuilder: (context, index) {
                final sheet = sheets[index];
                return NoteListItemCard(
                  key: ValueKey('sheet_${sheet.id}'),
                  sheet: sheet,
                  onTap: () => _openExistingNote(context, sheet.id),
                  onDelete: () => _confirmDelete(context, sheet),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
