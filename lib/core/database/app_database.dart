import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/calculation_history_table.dart';

part 'app_database.g.dart';

/// Unified Drift database for the app.
/// Web-ready with single worker & OPFS, designed for zero-migration feature scalability.
@DriftDatabase(tables: [CalculationHistoryEntries])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal()
    : super(
        driftDatabase(
          name: 'app_database',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});
