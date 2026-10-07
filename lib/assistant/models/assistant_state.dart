import 'package:flutter/foundation.dart';

sealed class AssistantIntent {
  const AssistantIntent();
}

final class MathIntent(final String expression) extends AssistantIntent;
final class CreateNoteIntent(final String title, final String content)
    extends AssistantIntent;
final class QueryRagIntent(final String query) extends AssistantIntent;
final class GeneralChatIntent(final String prompt) extends AssistantIntent;

enum ModelStatus { notDownloaded, downloading, ready, error }

@immutable
final class const AssistantMessage(
  final String id,
  final String text,
  final bool isUser,
  final DateTime timestamp,
  final String? referencedNote,
);

@immutable
final class const AssistantState(
  final List<AssistantMessage> messages,
  final bool isGenerating,
  final ModelStatus modelStatus,
  final double downloadProgress,
  final String? errorMessage,
) {
  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isGenerating,
    ModelStatus? modelStatus,
    double? downloadProgress,
    String? errorMessage,
  }) => AssistantState(
    messages ?? this.messages,
    isGenerating ?? this.isGenerating,
    modelStatus ?? this.modelStatus,
    downloadProgress ?? this.downloadProgress,
    errorMessage ?? this.errorMessage,
  );

  factory AssistantState.initial() =>
      AssistantState([], false, ModelStatus.notDownloaded, 0.0, null);
}
