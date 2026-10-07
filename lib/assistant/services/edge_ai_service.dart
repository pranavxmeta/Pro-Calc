import 'dart:async';
import 'dart:io';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:intl/intl.dart';
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

    // WARM-UP VALIDATION: Initialize CPU engine to verify weights immediately.
    try {
      final model = await FlutterEdgeAi.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );
      final testChat = await model.createChat();
      await testChat.addQueryChunk(Message.text(text: 'test', isUser: true));
      await testChat.generateChatResponseAsync().first;
    } catch (e) {
      _isModelReady = false;
      throw Exception('LiteRT-LM engine validation failed on this file: $e');
    }

    _loadedModelPath = destinationFile.path;
    _isModelReady = true;
  }

  /// Translates user word problem into mathematical formula using the active SLM.
  Stream<String> processAgentPrompt(String userInput) async* {
    if (!_isModelReady) {
      yield 'Model is not loaded. Please tap "Select Model" to choose your local .litertlm file.';
      return;
    }

    // Direct note handling: bypass inference for explicit note commands
    final noteMatch = RegExp(
      r'^(?:note|save):\s*(.*)',
      caseSensitive: false,
    ).firstMatch(userInput.trim());
    if (noteMatch != null) {
      final content = noteMatch.group(1)?.trim() ?? '';
      yield* _saveQuickNote('Quick Note', content);
      return;
    }

    try {
      final model = await FlutterEdgeAi.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );
      final chat = await model.createChat();

      final systemPrompt =
          '''
You are a math formula translator.
Translate the user's word problem into a single math expression.
Do not calculate the answer. Do not output words, explanations, or units.
Output ONLY the math expression on the last line after "Formula:".

Example 1:
User: I have 50 candies and ate 12
Formula: 50 - 12

Example 2:
User: 20 percent of 500 plus 40
Formula: (20% * 500) + 40

Example 3:
User: i have 100 apples, i give 38 to maria and 13 to jack, how many do i have
Formula: 100 - 38 - 13

Example 4:
User: split 1200 among 4 people and subtract 15
Formula: (1200 / 4) - 15

User: $userInput
Formula:
''';

      await chat.addQueryChunk(Message.text(text: systemPrompt, isUser: true));

      final rawBuffer = StringBuffer();
      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          rawBuffer.write(response.token);
        }
      }

      final rawOutput = rawBuffer.toString().trim();
      final formula = _extractFormula(rawOutput);

      if (formula != null && formula.isNotEmpty) {
        try {
          final evaluatedResult = CalcEvaluator.evaluate(
            rawExpression: formula,
            isDeg: true,
            variables: const {},
            numberFormat: NumberFormat.decimalPattern(),
          );
          yield 'Result: $evaluatedResult  ($formula)';
          return;
        } catch (_) {}
      }

      yield rawOutput.isNotEmpty
          ? rawOutput
          : 'Unable to determine calculation.';
    } catch (e) {
      yield 'AI reasoning error: $e';
    }
  }

  String? _extractFormula(String text) {
    if (text.isEmpty) return null;

    final formulaTagIndex = text.lastIndexOf('Formula:');
    var candidate = (formulaTagIndex != -1)
        ? text.substring(formulaTagIndex + 8).trim()
        : text.trim();

    candidate = candidate
        .replaceAll('`', '')
        .replaceAll('=', '')
        .split('\n')
        .first
        .trim();

    if (RegExp(r'[\d+\-*/%^().]').hasMatch(candidate)) {
      return candidate;
    }
    return null;
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
