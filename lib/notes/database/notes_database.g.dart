// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_database.dart';

// ignore_for_file: type=lint
class $NoteSheetsTable extends NoteSheets
    with TableInfo<$NoteSheetsTable, NoteSheet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteSheetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Untitled Note'),
  );
  static const VerificationMeta _grandTotalMeta = const VerificationMeta(
    'grandTotal',
  );
  @override
  late final GeneratedColumn<double> grandTotal = GeneratedColumn<double>(
    'grand_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    grandTotal,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_sheets';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteSheet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('grand_total')) {
      context.handle(
        _grandTotalMeta,
        grandTotal.isAcceptableOrUnknown(data['grand_total']!, _grandTotalMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteSheet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteSheet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      grandTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grand_total'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteSheetsTable createAlias(String alias) {
    return $NoteSheetsTable(attachedDatabase, alias);
  }
}

class NoteSheet extends DataClass implements Insertable<NoteSheet> {
  final int id;
  final String title;
  final double grandTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteSheet({
    required this.id,
    required this.title,
    required this.grandTotal,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['grand_total'] = Variable<double>(grandTotal);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NoteSheetsCompanion toCompanion(bool nullToAbsent) {
    return NoteSheetsCompanion(
      id: Value(id),
      title: Value(title),
      grandTotal: Value(grandTotal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteSheet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteSheet(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      grandTotal: serializer.fromJson<double>(json['grandTotal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'grandTotal': serializer.toJson<double>(grandTotal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteSheet copyWith({
    int? id,
    String? title,
    double? grandTotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteSheet(
    id: id ?? this.id,
    title: title ?? this.title,
    grandTotal: grandTotal ?? this.grandTotal,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteSheet copyWithCompanion(NoteSheetsCompanion data) {
    return NoteSheet(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      grandTotal: data.grandTotal.present
          ? data.grandTotal.value
          : this.grandTotal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteSheet(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, grandTotal, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteSheet &&
          other.id == this.id &&
          other.title == this.title &&
          other.grandTotal == this.grandTotal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NoteSheetsCompanion extends UpdateCompanion<NoteSheet> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> grandTotal;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NoteSheetsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NoteSheetsCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<NoteSheet> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? grandTotal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NoteSheetsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<double>? grandTotal,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NoteSheetsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      grandTotal: grandTotal ?? this.grandTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<double>(grandTotal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteSheetsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NoteDocumentEntriesTable extends NoteDocumentEntries
    with TableInfo<$NoteDocumentEntriesTable, NoteDocumentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteDocumentEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES note_sheets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lineIndexMeta = const VerificationMeta(
    'lineIndex',
  );
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
    'line_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSubtotalMeta = const VerificationMeta(
    'isSubtotal',
  );
  @override
  late final GeneratedColumn<bool> isSubtotal = GeneratedColumn<bool>(
    'is_subtotal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_subtotal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sheetId,
    lineIndex,
    rawText,
    isSubtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_document_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteDocumentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(
        _lineIndexMeta,
        lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('is_subtotal')) {
      context.handle(
        _isSubtotalMeta,
        isSubtotal.isAcceptableOrUnknown(data['is_subtotal']!, _isSubtotalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteDocumentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteDocumentEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      lineIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_index'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      isSubtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_subtotal'],
      )!,
    );
  }

  @override
  $NoteDocumentEntriesTable createAlias(String alias) {
    return $NoteDocumentEntriesTable(attachedDatabase, alias);
  }
}

class NoteDocumentEntry extends DataClass
    implements Insertable<NoteDocumentEntry> {
  final int id;
  final int sheetId;
  final int lineIndex;
  final String rawText;
  final bool isSubtotal;
  const NoteDocumentEntry({
    required this.id,
    required this.sheetId,
    required this.lineIndex,
    required this.rawText,
    required this.isSubtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sheet_id'] = Variable<int>(sheetId);
    map['line_index'] = Variable<int>(lineIndex);
    map['raw_text'] = Variable<String>(rawText);
    map['is_subtotal'] = Variable<bool>(isSubtotal);
    return map;
  }

  NoteDocumentEntriesCompanion toCompanion(bool nullToAbsent) {
    return NoteDocumentEntriesCompanion(
      id: Value(id),
      sheetId: Value(sheetId),
      lineIndex: Value(lineIndex),
      rawText: Value(rawText),
      isSubtotal: Value(isSubtotal),
    );
  }

  factory NoteDocumentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteDocumentEntry(
      id: serializer.fromJson<int>(json['id']),
      sheetId: serializer.fromJson<int>(json['sheetId']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
      rawText: serializer.fromJson<String>(json['rawText']),
      isSubtotal: serializer.fromJson<bool>(json['isSubtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sheetId': serializer.toJson<int>(sheetId),
      'lineIndex': serializer.toJson<int>(lineIndex),
      'rawText': serializer.toJson<String>(rawText),
      'isSubtotal': serializer.toJson<bool>(isSubtotal),
    };
  }

  NoteDocumentEntry copyWith({
    int? id,
    int? sheetId,
    int? lineIndex,
    String? rawText,
    bool? isSubtotal,
  }) => NoteDocumentEntry(
    id: id ?? this.id,
    sheetId: sheetId ?? this.sheetId,
    lineIndex: lineIndex ?? this.lineIndex,
    rawText: rawText ?? this.rawText,
    isSubtotal: isSubtotal ?? this.isSubtotal,
  );
  NoteDocumentEntry copyWithCompanion(NoteDocumentEntriesCompanion data) {
    return NoteDocumentEntry(
      id: data.id.present ? data.id.value : this.id,
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      isSubtotal: data.isSubtotal.present
          ? data.isSubtotal.value
          : this.isSubtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteDocumentEntry(')
          ..write('id: $id, ')
          ..write('sheetId: $sheetId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('rawText: $rawText, ')
          ..write('isSubtotal: $isSubtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sheetId, lineIndex, rawText, isSubtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteDocumentEntry &&
          other.id == this.id &&
          other.sheetId == this.sheetId &&
          other.lineIndex == this.lineIndex &&
          other.rawText == this.rawText &&
          other.isSubtotal == this.isSubtotal);
}

class NoteDocumentEntriesCompanion extends UpdateCompanion<NoteDocumentEntry> {
  final Value<int> id;
  final Value<int> sheetId;
  final Value<int> lineIndex;
  final Value<String> rawText;
  final Value<bool> isSubtotal;
  const NoteDocumentEntriesCompanion({
    this.id = const Value.absent(),
    this.sheetId = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.rawText = const Value.absent(),
    this.isSubtotal = const Value.absent(),
  });
  NoteDocumentEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sheetId,
    required int lineIndex,
    this.rawText = const Value.absent(),
    this.isSubtotal = const Value.absent(),
  }) : sheetId = Value(sheetId),
       lineIndex = Value(lineIndex);
  static Insertable<NoteDocumentEntry> custom({
    Expression<int>? id,
    Expression<int>? sheetId,
    Expression<int>? lineIndex,
    Expression<String>? rawText,
    Expression<bool>? isSubtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sheetId != null) 'sheet_id': sheetId,
      if (lineIndex != null) 'line_index': lineIndex,
      if (rawText != null) 'raw_text': rawText,
      if (isSubtotal != null) 'is_subtotal': isSubtotal,
    });
  }

  NoteDocumentEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sheetId,
    Value<int>? lineIndex,
    Value<String>? rawText,
    Value<bool>? isSubtotal,
  }) {
    return NoteDocumentEntriesCompanion(
      id: id ?? this.id,
      sheetId: sheetId ?? this.sheetId,
      lineIndex: lineIndex ?? this.lineIndex,
      rawText: rawText ?? this.rawText,
      isSubtotal: isSubtotal ?? this.isSubtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (isSubtotal.present) {
      map['is_subtotal'] = Variable<bool>(isSubtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteDocumentEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sheetId: $sheetId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('rawText: $rawText, ')
          ..write('isSubtotal: $isSubtotal')
          ..write(')'))
        .toString();
  }
}

abstract class _$NotesDatabase extends GeneratedDatabase {
  _$NotesDatabase(QueryExecutor e) : super(e);
  $NotesDatabaseManager get managers => $NotesDatabaseManager(this);
  late final $NoteSheetsTable noteSheets = $NoteSheetsTable(this);
  late final $NoteDocumentEntriesTable noteDocumentEntries =
      $NoteDocumentEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    noteSheets,
    noteDocumentEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'note_sheets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_document_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$NoteSheetsTableCreateCompanionBuilder =
    NoteSheetsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<double> grandTotal,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$NoteSheetsTableUpdateCompanionBuilder =
    NoteSheetsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<double> grandTotal,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$NoteSheetsTableReferences
    extends BaseReferences<_$NotesDatabase, $NoteSheetsTable, NoteSheet> {
  $$NoteSheetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteDocumentEntriesTable, List<NoteDocumentEntry>>
  _noteDocumentEntriesRefsTable(_$NotesDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.noteDocumentEntries,
        aliasName: 'note_sheets__id__note_document_entries__sheet_id',
      );

  $$NoteDocumentEntriesTableProcessedTableManager get noteDocumentEntriesRefs {
    final manager = $$NoteDocumentEntriesTableTableManager(
      $_db,
      $_db.noteDocumentEntries,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _noteDocumentEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NoteSheetsTableFilterComposer
    extends Composer<_$NotesDatabase, $NoteSheetsTable> {
  $$NoteSheetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteDocumentEntriesRefs(
    Expression<bool> Function($$NoteDocumentEntriesTableFilterComposer f) f,
  ) {
    final $$NoteDocumentEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteDocumentEntries,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteDocumentEntriesTableFilterComposer(
            $db: $db,
            $table: $db.noteDocumentEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NoteSheetsTableOrderingComposer
    extends Composer<_$NotesDatabase, $NoteSheetsTable> {
  $$NoteSheetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteSheetsTableAnnotationComposer
    extends Composer<_$NotesDatabase, $NoteSheetsTable> {
  $$NoteSheetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get grandTotal => $composableBuilder(
    column: $table.grandTotal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> noteDocumentEntriesRefs<T extends Object>(
    Expression<T> Function($$NoteDocumentEntriesTableAnnotationComposer a) f,
  ) {
    final $$NoteDocumentEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.noteDocumentEntries,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NoteDocumentEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.noteDocumentEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NoteSheetsTableTableManager
    extends
        RootTableManager<
          _$NotesDatabase,
          $NoteSheetsTable,
          NoteSheet,
          $$NoteSheetsTableFilterComposer,
          $$NoteSheetsTableOrderingComposer,
          $$NoteSheetsTableAnnotationComposer,
          $$NoteSheetsTableCreateCompanionBuilder,
          $$NoteSheetsTableUpdateCompanionBuilder,
          (NoteSheet, $$NoteSheetsTableReferences),
          NoteSheet,
          PrefetchHooks Function({bool noteDocumentEntriesRefs})
        > {
  $$NoteSheetsTableTableManager(_$NotesDatabase db, $NoteSheetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteSheetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteSheetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteSheetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> grandTotal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NoteSheetsCompanion(
                id: id,
                title: title,
                grandTotal: grandTotal,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> grandTotal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NoteSheetsCompanion.insert(
                id: id,
                title: title,
                grandTotal: grandTotal,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteSheetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteDocumentEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (noteDocumentEntriesRefs) db.noteDocumentEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (noteDocumentEntriesRefs)
                    await $_getPrefetchedData<
                      NoteSheet,
                      $NoteSheetsTable,
                      NoteDocumentEntry
                    >(
                      currentTable: table,
                      referencedTable: $$NoteSheetsTableReferences
                          ._noteDocumentEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NoteSheetsTableReferences(
                            db,
                            table,
                            p0,
                          ).noteDocumentEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sheetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NoteSheetsTableProcessedTableManager =
    ProcessedTableManager<
      _$NotesDatabase,
      $NoteSheetsTable,
      NoteSheet,
      $$NoteSheetsTableFilterComposer,
      $$NoteSheetsTableOrderingComposer,
      $$NoteSheetsTableAnnotationComposer,
      $$NoteSheetsTableCreateCompanionBuilder,
      $$NoteSheetsTableUpdateCompanionBuilder,
      (NoteSheet, $$NoteSheetsTableReferences),
      NoteSheet,
      PrefetchHooks Function({bool noteDocumentEntriesRefs})
    >;
typedef $$NoteDocumentEntriesTableCreateCompanionBuilder =
    NoteDocumentEntriesCompanion Function({
      Value<int> id,
      required int sheetId,
      required int lineIndex,
      Value<String> rawText,
      Value<bool> isSubtotal,
    });
typedef $$NoteDocumentEntriesTableUpdateCompanionBuilder =
    NoteDocumentEntriesCompanion Function({
      Value<int> id,
      Value<int> sheetId,
      Value<int> lineIndex,
      Value<String> rawText,
      Value<bool> isSubtotal,
    });

final class $$NoteDocumentEntriesTableReferences
    extends
        BaseReferences<
          _$NotesDatabase,
          $NoteDocumentEntriesTable,
          NoteDocumentEntry
        > {
  $$NoteDocumentEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NoteSheetsTable _sheetIdTable(_$NotesDatabase db) => db.noteSheets
      .createAlias('note_document_entries__sheet_id__note_sheets__id');

  $$NoteSheetsTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$NoteSheetsTableTableManager(
      $_db,
      $_db.noteSheets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteDocumentEntriesTableFilterComposer
    extends Composer<_$NotesDatabase, $NoteDocumentEntriesTable> {
  $$NoteDocumentEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineIndex => $composableBuilder(
    column: $table.lineIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubtotal => $composableBuilder(
    column: $table.isSubtotal,
    builder: (column) => ColumnFilters(column),
  );

  $$NoteSheetsTableFilterComposer get sheetId {
    final $$NoteSheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.noteSheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteSheetsTableFilterComposer(
            $db: $db,
            $table: $db.noteSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteDocumentEntriesTableOrderingComposer
    extends Composer<_$NotesDatabase, $NoteDocumentEntriesTable> {
  $$NoteDocumentEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineIndex => $composableBuilder(
    column: $table.lineIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubtotal => $composableBuilder(
    column: $table.isSubtotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$NoteSheetsTableOrderingComposer get sheetId {
    final $$NoteSheetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.noteSheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteSheetsTableOrderingComposer(
            $db: $db,
            $table: $db.noteSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteDocumentEntriesTableAnnotationComposer
    extends Composer<_$NotesDatabase, $NoteDocumentEntriesTable> {
  $$NoteDocumentEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<bool> get isSubtotal => $composableBuilder(
    column: $table.isSubtotal,
    builder: (column) => column,
  );

  $$NoteSheetsTableAnnotationComposer get sheetId {
    final $$NoteSheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.noteSheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteSheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteDocumentEntriesTableTableManager
    extends
        RootTableManager<
          _$NotesDatabase,
          $NoteDocumentEntriesTable,
          NoteDocumentEntry,
          $$NoteDocumentEntriesTableFilterComposer,
          $$NoteDocumentEntriesTableOrderingComposer,
          $$NoteDocumentEntriesTableAnnotationComposer,
          $$NoteDocumentEntriesTableCreateCompanionBuilder,
          $$NoteDocumentEntriesTableUpdateCompanionBuilder,
          (NoteDocumentEntry, $$NoteDocumentEntriesTableReferences),
          NoteDocumentEntry,
          PrefetchHooks Function({bool sheetId})
        > {
  $$NoteDocumentEntriesTableTableManager(
    _$NotesDatabase db,
    $NoteDocumentEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteDocumentEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteDocumentEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NoteDocumentEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sheetId = const Value.absent(),
                Value<int> lineIndex = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<bool> isSubtotal = const Value.absent(),
              }) => NoteDocumentEntriesCompanion(
                id: id,
                sheetId: sheetId,
                lineIndex: lineIndex,
                rawText: rawText,
                isSubtotal: isSubtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sheetId,
                required int lineIndex,
                Value<String> rawText = const Value.absent(),
                Value<bool> isSubtotal = const Value.absent(),
              }) => NoteDocumentEntriesCompanion.insert(
                id: id,
                sheetId: sheetId,
                lineIndex: lineIndex,
                rawText: rawText,
                isSubtotal: isSubtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteDocumentEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$NoteDocumentEntriesTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$NoteDocumentEntriesTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteDocumentEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$NotesDatabase,
      $NoteDocumentEntriesTable,
      NoteDocumentEntry,
      $$NoteDocumentEntriesTableFilterComposer,
      $$NoteDocumentEntriesTableOrderingComposer,
      $$NoteDocumentEntriesTableAnnotationComposer,
      $$NoteDocumentEntriesTableCreateCompanionBuilder,
      $$NoteDocumentEntriesTableUpdateCompanionBuilder,
      (NoteDocumentEntry, $$NoteDocumentEntriesTableReferences),
      NoteDocumentEntry,
      PrefetchHooks Function({bool sheetId})
    >;

class $NotesDatabaseManager {
  final _$NotesDatabase _db;
  $NotesDatabaseManager(this._db);
  $$NoteSheetsTableTableManager get noteSheets =>
      $$NoteSheetsTableTableManager(_db, _db.noteSheets);
  $$NoteDocumentEntriesTableTableManager get noteDocumentEntries =>
      $$NoteDocumentEntriesTableTableManager(_db, _db.noteDocumentEntries);
}
