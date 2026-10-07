import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/database/notes_database.dart';
import '../models/assistant_state.dart';
import '../services/edge_ai_service.dart';

final assistantProvider = NotifierProvider<AssistantNotifier, AssistantState>(
  AssistantNotifier.new,
);

class AssistantNotifier extends Notifier<AssistantState> {
  @override
  AssistantState build() {
    return AssistantState(
      [
        AssistantMessage(
          'welcome',
          'AI Assistant Ready (100% Offline Mode).\n• Tap "Select Model" to choose your local .litertlm file.\n• Ask word problems: "100 apples, give 38 to maria and 13 to jack"\n• Calculations are solved with exath_engine.',
          false,
          DateTime.now(),
          null,
        ),
      ],
      false,
      ModelStatus.notDownloaded,
      0.0,
      null,
    );
  }

  /// Imports an offline model file picked via system file selector.
  Future<void> loadPickedModel(File file) async {
    state = state.copyWith(
      modelStatus: ModelStatus.downloading,
      errorMessage: null,
    );

    try {
      await EdgeAiService.instance.importOfflineModelFile(file);
      state = state.copyWith(
        modelStatus: ModelStatus.ready,
        downloadProgress: 1.0,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        modelStatus: ModelStatus.error,
        errorMessage: '$e',
      );
    }
  }

  Future<void> processInput(String rawInput) async {
    final query = rawInput.trim();
    if (query.isEmpty) return;

    final userMsg = AssistantMessage(
      DateTime.now().microsecondsSinceEpoch.toString(),
      query,
      true,
      DateTime.now(),
      null,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isGenerating: true,
      errorMessage: null,
    );

    final botId = DateTime.now().microsecondsSinceEpoch.toString();
    var currentResponse = '';

    try {
      final isSearchNotes =
          query.toLowerCase().startsWith('search:') ||
          query.toLowerCase().contains('my notes');

      final stream = isSearchNotes
          ? EdgeAiService.instance.answerQueryWithRag(
              query: query,
              database: NotesDatabase.instance,
            )
          : EdgeAiService.instance.processAgentPrompt(query);

      await for (final chunk in stream) {
        currentResponse += chunk;
        _upsertMessage(botId, currentResponse);
      }
    } catch (e) {
      _appendMessage('Error: $e');
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  void _appendMessage(String text) {
    final msg = AssistantMessage(
      DateTime.now().microsecondsSinceEpoch.toString(),
      text,
      false,
      DateTime.now(),
      null,
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void _upsertMessage(String id, String fullText) {
    final list = [...state.messages];
    final idx = list.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      list[idx] = AssistantMessage(
        id,
        fullText,
        false,
        list[idx].timestamp,
        null,
      );
    } else {
      list.add(AssistantMessage(id, fullText, false, DateTime.now(), null));
    }
    state = state.copyWith(messages: list);
  }
}
