import 'dart:async';
import 'dart:io';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:path_provider/path_provider.dart';

import '../../calc/utils/calc_evaluator.dart';
import '../../notes/database/notes_database.dart';
import '../../notes/model/note_item.dart';

final class EdgeAiService {
  EdgeAiService._();
  static final EdgeAiService instance = EdgeAiService._();

  bool _isModelReady = false;
  bool get isModelReady => _isModelReady;

  String? _loadedModelPath;
  String? get loadedModelPath => _loadedModelPath;

  String _activeBackend = 'CPU';
  String get activeBackend => _activeBackend;

  /// Imports an offline model file selected by the user into the safe app sandbox.
  Future<void> importOfflineModelFile(File pickedFile) async {
    if (!await pickedFile.exists()) {
      throw FileSystemException(
        'Selected file does not exist',
        pickedFile.path,
      );
    }

    final fileSize = await pickedFile.length();
    // Guard against empty or truncated files.
    if (fileSize < 150 * 1024 * 1024) {
      throw FormatException(
        'Selected file is too small (${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB). Expected a valid .litertlm model.',
      );
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final destinationFile = File('${docsDir.path}/offline_model.litertlm');

    // Copy user-selected file into the app's internal sandbox.
    // Guarantees unrestricted POSIX read access for native liblitert_lm.so.
    if (pickedFile.path != destinationFile.path) {
      await pickedFile.copy(destinationFile.path);
    }

    // Resolve model architecture: Gemma 4, FunctionGemma, or Gemma IT
    final fileName = pickedFile.uri.pathSegments.last.toLowerCase();
    final ModelType modelType;
    if (fileName.contains('gemma-4') || fileName.contains('gemma4')) {
      modelType = ModelType.gemma4;
    } else if (fileName.contains('functiongemma')) {
      modelType = ModelType.functionGemma;
    } else {
      modelType = ModelType.gemmaIt;
    }

    // Register with LiteRT-LM runtime
    await FlutterEdgeAi.installModel(
      modelType: modelType,
      fileType: ModelFileType.litertlm,
    ).fromFile(destinationFile.path).install();

    // HARDWARE ACCELERATION WARM-UP: Attempt GPU first for 3x-5x token rate, fallback to CPU
    try {
      final gpuModel = await FlutterEdgeAi.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );
      final testChat = await gpuModel.createChat();
      await testChat.addQueryChunk(Message.text(text: '1', isUser: true));
      await testChat.generateChatResponseAsync().first;
      _activeBackend = 'GPU';
    } catch (_) {
      final cpuModel = await FlutterEdgeAi.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );
      final testChat = await cpuModel.createChat();
      await testChat.addQueryChunk(Message.text(text: '1', isUser: true));
      await testChat.generateChatResponseAsync().first;
      _activeBackend = 'CPU';
    }

    _loadedModelPath = destinationFile.path;
    _isModelReady = true;
  }

  /// Translates user word problem or scientific question into explanation and math formulas.
  Stream<String> processAgentPrompt(String userInput) async* {
    if (!_isModelReady) {
      yield 'Model is not loaded. Please tap "Select Model" to choose your local .litertlm file.';
      return;
    }

    final query = userInput.trim();

    // Direct note handling: bypass inference for explicit note commands
    final noteMatch = RegExp(
      r'^(?:note|save):\s*(.*)',
      caseSensitive: false,
    ).firstMatch(query);
    if (noteMatch != null) {
      final content = noteMatch.group(1)?.trim() ?? '';
      yield* _saveQuickNote('Quick Note', content);
      return;
    }

    try {
      final preferred = (_activeBackend == 'GPU')
          ? PreferredBackend.gpu
          : PreferredBackend.cpu;
      final model = await FlutterEdgeAi.getActiveModel(
        maxTokens: 1024,
        preferredBackend: preferred,
      );
      final chat = await model.createChat();

      final systemPrompt =
          '''
You are an expert scientific calculator and AI assistant powered by exath_engine.
Capabilities:
- You know all physical constants (g = 9.80665 m/s², G = 6.674e-11, speed of light = 299792458 m/s, Earth rotation speed = 1674 km/h or 465 m/s, Earth radius = 6371 km).
- You know mathematical constants (pi = 3.14159, e = 2.71828, phi = 1.61803) and combinatorics/permutations (P(n, r) = n! / (n-r)!).
- Answer scientific, physics, and factual questions clearly and conversationally.
- Formatting Rule: Never output LaTeX, dollar signs (\$ or \$\$), or \\text{} formatting. Write units and numbers in plain clean text (e.g. write "m/s²" instead of "\\text{m/s}^2", write "10 * 5" instead of "\$10 \\times 5\$").
- Whenever you need to perform ANY calculation, evaluate a formula, or compute permutations, write the exact formula inside [CALC: expression]. exath_engine will compute it with exact precision.
  Example 1: "What is 10 * earth gravity?" -> "Earth's surface gravity g is approximately 9.80665 m/s². 10 times this is [CALC: 10 * 9.80665] m/s²."
  Example 2: "Permutation of 5 pick 3" -> "P(5, 3) = 5! / (5-3)! = [CALC: 5! / (5 - 3)!] possible arrangements."
  Example 3: "How many apples with 10 baskets, each having 5 apples?" -> "10 baskets with 5 apples each gives [CALC: 10 * 5] apples in total."

User: $query
Answer:
''';

      await chat.addQueryChunk(Message.text(text: systemPrompt, isUser: true));

      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } catch (e) {
      yield 'AI reasoning error: $e';
    }
  }

  Stream<String> _saveQuickNote(String title, String content) async* {
    try {
      final db = NotesDatabase.instance;
      final sheetId = await db.createNewSheet(title: title);
      final (id, sheetTitle, items) = await db.loadOrCreateSheet(sheetId);
      final updatedItems = [
        NoteItem(index: 0, text: content, type: LineType.standard),
        ...items.sublist(1),
      ];
      await db.saveSheet(
        sheetId: id,
        title: sheetTitle,
        grandTotal: 0.0,
        items: updatedItems,
      );
      yield 'Saved to notes:\n• $title: "$content"';
    } catch (e) {
      yield 'Failed to save note: $e';
    }
  }

  Stream<String> answerQueryWithRag({
    required String query,
    required NotesDatabase database,
  }) async* {
    final notes = await database.getAllSheetsWithContent();
    final queryTokens = query
        .toLowerCase()
        .split(' ')
        .where((w) => w.length > 2)
        .toList();

    final matched = notes
        .where((sheet) {
          final text = '${sheet.title} ${sheet.content}'.toLowerCase();
          return queryTokens.any(text.contains);
        })
        .take(2)
        .toList();

    if (matched.isEmpty) {
      yield 'No notes found matching "$query".';
      return;
    }

    final summary = StringBuffer();
    summary.writeln('Matching Notes:');
    for (final m in matched) {
      summary.writeln('• ${m.title}:');
      if (m.content.isNotEmpty) {
        summary.writeln('  ${m.content}');
      }
    }

    yield summary.toString();
  }
}
