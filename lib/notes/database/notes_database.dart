import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../model/note_item.dart';
import '../utils/math_evaluator.dart';

part 'notes_database.g.dart';

@DataClassName('NoteSheet')
class NoteSheets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Untitled Note'))();
  RealColumn get grandTotal => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('NoteDocumentEntry')
class NoteDocumentEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sheetId =>
      integer().references(NoteSheets, #id, onDelete: KeyAction.cascade)();
  IntColumn get lineIndex => integer()();
  TextColumn get rawText => text().withDefault(const Constant(''))();
  BoolColumn get isSubtotal => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [NoteSheets, NoteDocumentEntries])
class NotesDatabase extends _$NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._internal();

  NotesDatabase._internal()
    : super(
        driftDatabase(
          name: 'notes_calc_db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedInitialSampleData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Step 1: Read existing v1 data before altering any tables
        String oldTitle = 'Imported Note (v1)';
        try {
          final metaResult = await customSelect(
            'SELECT title FROM note_meta_info LIMIT 1;',
          ).getSingleOrNull();

          if (metaResult != null && metaResult.data['title'] != null) {
            final fetchedTitle = (metaResult.data['title'] as String).trim();
            if (fetchedTitle.isNotEmpty) {
              oldTitle = fetchedTitle;
            }
          }
        } catch (_) {
          // note_meta_info might be absent if v1 was never initialized
        }

        List<QueryRow> oldLines = [];
        try {
          oldLines = await customSelect(
            'SELECT line_index, raw_text, is_subtotal FROM note_document_entries ORDER BY line_index ASC;',
          ).get();
        } catch (_) {
          // note_document_entries might be absent
        }

        // Step 2: Drop obsolete legacy tables safely
        await customStatement('DROP TABLE IF EXISTS note_meta_info;');
        await customStatement('DROP TABLE IF EXISTS note_document_entries;');

        // Step 3: Create the new v2 schema
        await m.createAll();

        // Step 4: Non-destructively convert old lines into the first v2 NoteSheet
        final hasUserData = oldLines.any((row) {
          final raw = row.data['raw_text'] as String?;
          return raw != null && raw.trim().isNotEmpty;
        });

        if (hasUserData) {
          final sheetId = await into(noteSheets).insert(
            NoteSheetsCompanion.insert(
              title: Value(oldTitle),
              grandTotal: const Value(0.0),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

          final List<NoteItem> migratedItems = [];

          for (int i = 0; i < 20; i++) {
            final matchedRow = oldLines
                .where((r) => r.data['line_index'] == i)
                .firstOrNull;
            final rawText = matchedRow != null
                ? (matchedRow.data['raw_text'] as String? ?? '')
                : '';
            final isSub =
                matchedRow != null &&
                ((matchedRow.data['is_subtotal'] as int? ?? 0) == 1);

            migratedItems.add(
              NoteItem(
                index: i,
                text: rawText,
                type: isSub ? LineType.subtotal : LineType.standard,
              ),
            );

            await into(noteDocumentEntries).insert(
              NoteDocumentEntriesCompanion.insert(
                sheetId: sheetId,
                lineIndex: i,
                rawText: Value(rawText),
                isSubtotal: Value(isSub),
              ),
            );
          }

          // Compute and save the accurate grand total for the migrated note
          final (_, grandTotal) = MathEvaluator.computeDocument(migratedItems);
          await (update(noteSheets)..where((t) => t.id.equals(sheetId))).write(
            NoteSheetsCompanion(grandTotal: Value(grandTotal)),
          );
        } else {
          // If v1 had no real content, populate with sample note
          await _seedInitialSampleData();
        }
      }
    },
    beforeOpen: (details) async {
      // Self-heal: Seed initial note if the database has zero sheets
      final count = await (select(noteSheets)..limit(1)).get();
      if (count.isEmpty) {
        await _seedInitialSampleData();
      }
    },
  );

  /// Seeds a starter note so the app is never empty on first launch
  Future<void> _seedInitialSampleData() async {
    final sampleLines = [
      (text: '120 = Fuel', isSub: false),
      (text: '45.50 = Lunch', isSub: false),
      (text: 'Subtotal', isSub: true),
      (text: '80 = Hotel', isSub: false),
      (text: '15 = Coffee', isSub: false),
      (text: 'Subtotal', isSub: true),
    ];

    final initialItems = List.generate(20, (i) {
      if (i < sampleLines.length) {
        return NoteItem(
          index: i,
          text: sampleLines[i].text,
          type: sampleLines[i].isSub ? LineType.subtotal : LineType.standard,
        );
      }
      return NoteItem(index: i, text: '', type: LineType.standard);
    });

    final (_, grandTotal) = MathEvaluator.computeDocument(initialItems);

    final sheetId = await into(noteSheets).insert(
      NoteSheetsCompanion.insert(
        title: const Value('Trip Expenses (Sample)'),
        grandTotal: Value(grandTotal),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    for (final item in initialItems) {
      await into(noteDocumentEntries).insert(
        NoteDocumentEntriesCompanion.insert(
          sheetId: sheetId,
          lineIndex: item.index,
          rawText: Value(item.text),
          isSubtotal: Value(item.type.isSubtotal),
        ),
      );
    }
  }

  /// Reactive stream for real-time list page updates
  Stream<List<NoteSheet>> watchAllSheets() {
    return (select(
      noteSheets,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  /// Creates a new empty note sheet and returns its ID
  Future<int> createNewSheet({String title = 'Untitled Note'}) async {
    return transaction(() async {
      final sheetId = await into(noteSheets).insert(
        NoteSheetsCompanion.insert(
          title: Value(title),
          grandTotal: const Value(0.0),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      for (int i = 0; i < 20; i++) {
        await into(noteDocumentEntries).insert(
          NoteDocumentEntriesCompanion.insert(
            sheetId: sheetId,
            lineIndex: i,
            rawText: const Value(''),
            isSubtotal: const Value(false),
          ),
        );
      }
      return sheetId;
    });
  }

  /// Loads a sheet by ID, or lazily initializes the first available sheet
  Future<(int sheetId, String title, List<NoteItem> items)> loadOrCreateSheet([
    int? targetSheetId,
  ]) async {
    if (targetSheetId != null) {
      final sheet = await (select(
        noteSheets,
      )..where((t) => t.id.equals(targetSheetId))).getSingleOrNull();
      if (sheet != null) {
        final rows =
            await (select(noteDocumentEntries)
                  ..where((t) => t.sheetId.equals(targetSheetId))
                  ..orderBy([(t) => OrderingTerm.asc(t.lineIndex)])
                  ..limit(20))
                .get();

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

        return (sheet.id, sheet.title, items);
      }
    }

    final existingSheets = await (select(noteSheets)..limit(1)).get();
    if (existingSheets.isNotEmpty) {
      return loadOrCreateSheet(existingSheets.first.id);
    }

    final newId = await createNewSheet();
    return loadOrCreateSheet(newId);
  }

  /// Atomically saves title, grand total, and the 20 lines
  Future<void> saveSheet({
    required int sheetId,
    required String title,
    required double grandTotal,
    required List<NoteItem> items,
  }) async {
    await transaction(() async {
      await (update(noteSheets)..where((t) => t.id.equals(sheetId))).write(
        NoteSheetsCompanion(
          title: Value(title.trim().isEmpty ? 'Untitled Note' : title.trim()),
          grandTotal: Value(grandTotal),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (delete(
        noteDocumentEntries,
      )..where((t) => t.sheetId.equals(sheetId))).go();

      for (final item in items) {
        await into(noteDocumentEntries).insert(
          NoteDocumentEntriesCompanion.insert(
            sheetId: sheetId,
            lineIndex: item.index,
            rawText: Value(item.text),
            isSubtotal: Value(item.type.isSubtotal),
          ),
        );
      }
    });
  }

  /// Deletes a sheet and its cascade lines
  Future<void> deleteSheet(int sheetId) async {
    await transaction(() async {
      await (delete(
        noteDocumentEntries,
      )..where((t) => t.sheetId.equals(sheetId))).go();
      await (delete(noteSheets)..where((t) => t.id.equals(sheetId))).go();
    });
  }
}
