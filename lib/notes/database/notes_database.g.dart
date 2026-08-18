// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_database.dart';

// ignore_for_file: type=lint
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
  List<GeneratedColumn> get $columns => [id, lineIndex, rawText, isSubtotal];
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
  final int lineIndex;
  final String rawText;
  final bool isSubtotal;
  const NoteDocumentEntry({
    required this.id,
    required this.lineIndex,
    required this.rawText,
    required this.isSubtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['line_index'] = Variable<int>(lineIndex);
    map['raw_text'] = Variable<String>(rawText);
    map['is_subtotal'] = Variable<bool>(isSubtotal);
    return map;
  }

  NoteDocumentEntriesCompanion toCompanion(bool nullToAbsent) {
    return NoteDocumentEntriesCompanion(
      id: Value(id),
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
      'lineIndex': serializer.toJson<int>(lineIndex),
      'rawText': serializer.toJson<String>(rawText),
      'isSubtotal': serializer.toJson<bool>(isSubtotal),
    };
  }

  NoteDocumentEntry copyWith({
    int? id,
    int? lineIndex,
    String? rawText,
    bool? isSubtotal,
  }) => NoteDocumentEntry(
    id: id ?? this.id,
    lineIndex: lineIndex ?? this.lineIndex,
    rawText: rawText ?? this.rawText,
    isSubtotal: isSubtotal ?? this.isSubtotal,
  );
  NoteDocumentEntry copyWithCompanion(NoteDocumentEntriesCompanion data) {
    return NoteDocumentEntry(
      id: data.id.present ? data.id.value : this.id,
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
          ..write('lineIndex: $lineIndex, ')
          ..write('rawText: $rawText, ')
          ..write('isSubtotal: $isSubtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lineIndex, rawText, isSubtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteDocumentEntry &&
          other.id == this.id &&
          other.lineIndex == this.lineIndex &&
          other.rawText == this.rawText &&
          other.isSubtotal == this.isSubtotal);
}

class NoteDocumentEntriesCompanion extends UpdateCompanion<NoteDocumentEntry> {
  final Value<int> id;
  final Value<int> lineIndex;
  final Value<String> rawText;
  final Value<bool> isSubtotal;
  const NoteDocumentEntriesCompanion({
    this.id = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.rawText = const Value.absent(),
    this.isSubtotal = const Value.absent(),
  });
  NoteDocumentEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int lineIndex,
    this.rawText = const Value.absent(),
    this.isSubtotal = const Value.absent(),
  }) : lineIndex = Value(lineIndex);
  static Insertable<NoteDocumentEntry> custom({
    Expression<int>? id,
    Expression<int>? lineIndex,
    Expression<String>? rawText,
    Expression<bool>? isSubtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lineIndex != null) 'line_index': lineIndex,
      if (rawText != null) 'raw_text': rawText,
      if (isSubtotal != null) 'is_subtotal': isSubtotal,
    });
  }

  NoteDocumentEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? lineIndex,
    Value<String>? rawText,
    Value<bool>? isSubtotal,
  }) {
    return NoteDocumentEntriesCompanion(
      id: id ?? this.id,
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
          ..write('lineIndex: $lineIndex, ')
          ..write('rawText: $rawText, ')
          ..write('isSubtotal: $isSubtotal')
          ..write(')'))
        .toString();
  }
}

class $NoteMetaInfoTable extends NoteMetaInfo
    with TableInfo<$NoteMetaInfoTable, NoteMetaInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteMetaInfoTable(this.attachedDatabase, [this._alias]);
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
  List<GeneratedColumn> get $columns => [id, title, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_meta_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteMetaInfoData> instance, {
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
  NoteMetaInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteMetaInfoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteMetaInfoTable createAlias(String alias) {
    return $NoteMetaInfoTable(attachedDatabase, alias);
  }
}

class NoteMetaInfoData extends DataClass
    implements Insertable<NoteMetaInfoData> {
  final int id;
  final String title;
  final DateTime updatedAt;
  const NoteMetaInfoData({
    required this.id,
    required this.title,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NoteMetaInfoCompanion toCompanion(bool nullToAbsent) {
    return NoteMetaInfoCompanion(
      id: Value(id),
      title: Value(title),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteMetaInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteMetaInfoData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteMetaInfoData copyWith({int? id, String? title, DateTime? updatedAt}) =>
      NoteMetaInfoData(
        id: id ?? this.id,
        title: title ?? this.title,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  NoteMetaInfoData copyWithCompanion(NoteMetaInfoCompanion data) {
    return NoteMetaInfoData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteMetaInfoData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteMetaInfoData &&
          other.id == this.id &&
          other.title == this.title &&
          other.updatedAt == this.updatedAt);
}

class NoteMetaInfoCompanion extends UpdateCompanion<NoteMetaInfoData> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> updatedAt;
  const NoteMetaInfoCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NoteMetaInfoCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<NoteMetaInfoData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NoteMetaInfoCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? updatedAt,
  }) {
    return NoteMetaInfoCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteMetaInfoCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$NotesDatabase extends GeneratedDatabase {
  _$NotesDatabase(QueryExecutor e) : super(e);
  $NotesDatabaseManager get managers => $NotesDatabaseManager(this);
  late final $NoteDocumentEntriesTable noteDocumentEntries =
      $NoteDocumentEntriesTable(this);
  late final $NoteMetaInfoTable noteMetaInfo = $NoteMetaInfoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    noteDocumentEntries,
    noteMetaInfo,
  ];
}

typedef $$NoteDocumentEntriesTableCreateCompanionBuilder =
    NoteDocumentEntriesCompanion Function({
      Value<int> id,
      required int lineIndex,
      Value<String> rawText,
      Value<bool> isSubtotal,
    });
typedef $$NoteDocumentEntriesTableUpdateCompanionBuilder =
    NoteDocumentEntriesCompanion Function({
      Value<int> id,
      Value<int> lineIndex,
      Value<String> rawText,
      Value<bool> isSubtotal,
    });

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
          (
            NoteDocumentEntry,
            BaseReferences<
              _$NotesDatabase,
              $NoteDocumentEntriesTable,
              NoteDocumentEntry
            >,
          ),
          NoteDocumentEntry,
          PrefetchHooks Function()
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
                Value<int> lineIndex = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<bool> isSubtotal = const Value.absent(),
              }) => NoteDocumentEntriesCompanion(
                id: id,
                lineIndex: lineIndex,
                rawText: rawText,
                isSubtotal: isSubtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lineIndex,
                Value<String> rawText = const Value.absent(),
                Value<bool> isSubtotal = const Value.absent(),
              }) => NoteDocumentEntriesCompanion.insert(
                id: id,
                lineIndex: lineIndex,
                rawText: rawText,
                isSubtotal: isSubtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        NoteDocumentEntry,
        BaseReferences<
          _$NotesDatabase,
          $NoteDocumentEntriesTable,
          NoteDocumentEntry
        >,
      ),
      NoteDocumentEntry,
      PrefetchHooks Function()
    >;
typedef $$NoteMetaInfoTableCreateCompanionBuilder =
    NoteMetaInfoCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> updatedAt,
    });
typedef $$NoteMetaInfoTableUpdateCompanionBuilder =
    NoteMetaInfoCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> updatedAt,
    });

class $$NoteMetaInfoTableFilterComposer
    extends Composer<_$NotesDatabase, $NoteMetaInfoTable> {
  $$NoteMetaInfoTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteMetaInfoTableOrderingComposer
    extends Composer<_$NotesDatabase, $NoteMetaInfoTable> {
  $$NoteMetaInfoTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteMetaInfoTableAnnotationComposer
    extends Composer<_$NotesDatabase, $NoteMetaInfoTable> {
  $$NoteMetaInfoTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NoteMetaInfoTableTableManager
    extends
        RootTableManager<
          _$NotesDatabase,
          $NoteMetaInfoTable,
          NoteMetaInfoData,
          $$NoteMetaInfoTableFilterComposer,
          $$NoteMetaInfoTableOrderingComposer,
          $$NoteMetaInfoTableAnnotationComposer,
          $$NoteMetaInfoTableCreateCompanionBuilder,
          $$NoteMetaInfoTableUpdateCompanionBuilder,
          (
            NoteMetaInfoData,
            BaseReferences<
              _$NotesDatabase,
              $NoteMetaInfoTable,
              NoteMetaInfoData
            >,
          ),
          NoteMetaInfoData,
          PrefetchHooks Function()
        > {
  $$NoteMetaInfoTableTableManager(_$NotesDatabase db, $NoteMetaInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteMetaInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteMetaInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteMetaInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NoteMetaInfoCompanion(
                id: id,
                title: title,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NoteMetaInfoCompanion.insert(
                id: id,
                title: title,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteMetaInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$NotesDatabase,
      $NoteMetaInfoTable,
      NoteMetaInfoData,
      $$NoteMetaInfoTableFilterComposer,
      $$NoteMetaInfoTableOrderingComposer,
      $$NoteMetaInfoTableAnnotationComposer,
      $$NoteMetaInfoTableCreateCompanionBuilder,
      $$NoteMetaInfoTableUpdateCompanionBuilder,
      (
        NoteMetaInfoData,
        BaseReferences<_$NotesDatabase, $NoteMetaInfoTable, NoteMetaInfoData>,
      ),
      NoteMetaInfoData,
      PrefetchHooks Function()
    >;

class $NotesDatabaseManager {
  final _$NotesDatabase _db;
  $NotesDatabaseManager(this._db);
  $$NoteDocumentEntriesTableTableManager get noteDocumentEntries =>
      $$NoteDocumentEntriesTableTableManager(_db, _db.noteDocumentEntries);
  $$NoteMetaInfoTableTableManager get noteMetaInfo =>
      $$NoteMetaInfoTableTableManager(_db, _db.noteMetaInfo);
}
