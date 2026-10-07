import '../models/assistant_state.dart';

final class IntentRouter {
  const IntentRouter._();

  static final RegExp _mathPattern = RegExp(r'^[\d\s+\-*/%^().,E=]+$');
  static final RegExp _mathWords = RegExp(
    r'\b(sin|cos|tan|log|ln|sqrt)\b',
    caseSensitive: false,
  );
  static final RegExp _noteTrigger = RegExp(
    r'^(note|remind|save):\s*(.*)',
    caseSensitive: false,
  );

  /// Resolves intent deterministically with zero latency.
  static AssistantIntent resolve(String input) {
    final query = input.trim();

    final noteMatch = _noteTrigger.firstMatch(query);
    if (noteMatch != null) {
      final content = noteMatch.group(2)?.trim() ?? '';
      return CreateNoteIntent('Quick Note', content);
    }

    if (_mathPattern.hasMatch(query) || _mathWords.hasMatch(query)) {
      return MathIntent(query);
    }

    final lower = query.toLowerCase();
    if (lower.contains('note') ||
        lower.contains('total') ||
        lower.contains('spent') ||
        lower.contains('expense') ||
        lower.contains('budget') ||
        lower.contains('trip')) {
      return QueryRagIntent(query);
    }

    return GeneralChatIntent(query);
  }
}
