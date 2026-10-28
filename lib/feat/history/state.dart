import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import 'model/calculation_history.dart';
import 'data.dart';

class HistoryState {
  const HistoryState({
    this.entries = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<CalculationHistoryEntry> entries;
  final bool isLoadingMore;
  final bool hasMore;

  /// Domain model adapter for zero-break compatibility with legacy widgets.
  List<CalculationHistory> get toDomainList => entries
      .map(
        (e) => CalculationHistory(
          expression: e.expression,
          result: e.result,
          timestamp: e.createdAt,
        ),
      )
      .toList();

  HistoryState copyWith({
    List<CalculationHistoryEntry>? entries,
    bool? isLoadingMore,
    bool? hasMore,
  }) => HistoryState(
    entries: entries ?? this.entries,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
  );
}

/// Riverpod v3 Notifier managing in-memory cached history and debounced lazy loading.
class HistoryController extends Notifier<HistoryState> {
  late final HistoryRepository _repository = ref.read(
    historyRepositoryProvider,
  );
  static const int _pageSize = 30;
  bool _isFetching = false;

  @override
  HistoryState build() {
    _loadInitial();
    return const HistoryState();
  }

  Future<void> _loadInitial() async {
    _isFetching = true;
    try {
      final initialItems = await _repository.fetchBatch(limit: _pageSize);
      state = state.copyWith(
        entries: initialItems,
        hasMore: initialItems.length == _pageSize,
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Loose background pre-fetch: called when scrolling nears the bottom.
  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore || state.entries.isEmpty) return;
    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final lastId = state.entries.last.id;
      final nextItems = await _repository.fetchBatch(
        cursorId: lastId,
        limit: _pageSize,
      );

      state = state.copyWith(
        entries: [...state.entries, ...nextItems],
        hasMore: nextItems.length == _pageSize,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    } finally {
      _isFetching = false;
    }
  }

  /// Optimistic in-memory insertion: immediately prepends to RAM and writes
  /// to disk in background. Never triggers a disk read on active calculations.
  Future<void> record(String expression, String result) async {
    if (expression.isEmpty ||
        result.isEmpty ||
        result == 'Error' ||
        expression == result) {
      return;
    }

    if (state.entries.isNotEmpty &&
        state.entries.first.expression == expression &&
        state.entries.first.result == result) {
      return;
    }

    final id = await _repository.insert(expression: expression, result: result);

    final optimisticEntry = CalculationHistoryEntry(
      id: id,
      expression: expression,
      result: result,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(entries: [optimisticEntry, ...state.entries]);
  }

  Future<void> clear() async {
    await _repository.clearAll();
    state = const HistoryState(entries: [], hasMore: false);
  }
}

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);
