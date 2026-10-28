import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';

/// Repository handling keyset cursor queries for zero-disk-scan pagination.
class HistoryRepository {
  const HistoryRepository(this._db);

  final AppDatabase _db;

  /// Fetches a window of history items strictly using `id < cursorId`.
  /// Uses SQLite B-tree index directly for instantaneous O(1) retrieval.
  Future<List<CalculationHistoryEntry>> fetchBatch({
    int? cursorId,
    int limit = 30,
  }) {
    var query = _db.select(_db.calculationHistoryEntries);

    if (cursorId != null) {
      query = query..where((t) => t.id.isSmallerThanValue(cursorId));
    }

    return (query
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(limit))
        .get();
  }

  /// Inserts a newly evaluated calculation and returns its generated ID.
  Future<int> insert({required String expression, required String result}) {
    return _db
        .into(_db.calculationHistoryEntries)
        .insert(
          CalculationHistoryEntriesCompanion.insert(
            expression: expression,
            result: result,
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  /// Clears all calculation records.
  Future<int> clearAll() => _db.delete(_db.calculationHistoryEntries).go();

  /// Deletes a single calculation record by ID.
  Future<int> deleteById(int id) => (_db.delete(
    _db.calculationHistoryEntries,
  )..where((t) => t.id.equals(id))).go();
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryRepository(db);
});
