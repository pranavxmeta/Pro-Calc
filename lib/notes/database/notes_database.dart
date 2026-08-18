import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../model/note_item.dart';

part 'notes_database.g.dart';

class NoteDocumentEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lineIndex => integer()();
  TextColumn get rawText => text().withDefault(const Constant(''))();
  BoolColumn get isSubtotal => boolean().withDefault(const Constant(false))();
}

class NoteMetaInfo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Untitled Note'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [NoteDocumentEntries, NoteMetaInfo])
class NotesDatabase extends _$NotesDatabase {
  // driftDatabase(name: ...) automatically chooses:
  // - IndexedDB / Wasm on Web (Chrome)
  // - Background isolate SQLite on Mobile & Desktop
  NotesDatabase()
    : super(
        driftDatabase(
          name: 'notes_calc_db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
            onResult: (result) {
              // Fallback debugging message if browser lacks OPFS or shared workers
              if (result.missingFeatures.isNotEmpty) {
                // ignore: avoid_print
                print('Drift Web using: ${result.chosenImplementation}');
              }
            },
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  Future<(String title, List<NoteItem> items)>
  loadOrCreateDefaultSheet() async {
    final meta = await (select(noteMetaInfo)..limit(1)).getSingleOrNull();
    final String title = meta?.title ?? 'Notes Calculator';

    final rows =
        await (select(noteDocumentEntries)
              ..orderBy([(t) => OrderingTerm.asc(t.lineIndex)])
              ..limit(20))
            .get();

    if (rows.isEmpty) {
      final List<NoteItem> initial = List.generate(
        100,
        (i) => NoteItem(index: i, text: '', type: LineType.standard),
      );
      return (title, initial);
    }

    final items = List.generate(20, (i) {
      final match = rows.where((r) => r.lineIndex == i).firstOrNull;
      return NoteItem(
        index: i,
        text: match?.rawText ?? '',
        type: (match?.isSubtotal ?? false)
            ? LineType.subtotal
            : LineType.standard,
      );
    });

    return (title, items);
  }

  Future<void> saveSheet({
    required String title,
    required List<NoteItem> items,
  }) async {
    await transaction(() async {
      await delete(noteMetaInfo).go();
      await into(noteMetaInfo).insert(
        NoteMetaInfoCompanion(
          title: Value(title),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await delete(noteDocumentEntries).go();
      for (final item in items) {
        await into(noteDocumentEntries).insert(
          NoteDocumentEntriesCompanion.insert(
            lineIndex: item.index,
            rawText: Value(item.text),
            isSubtotal: Value(item.type.isSubtotal),
          ),
        );
      }
    });
  }
}
