import 'package:drift/drift.dart';

/// Calculation history table schema with primary-key B-tree indexing
/// optimized for O(1) keyset cursor pagination.
@DataClassName('CalculationHistoryEntry')
class CalculationHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get expression => text()();
  TextColumn get result => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Additional chat tables (e.g., chat_threads, chat_messages) will be colocated in this directory.
}
