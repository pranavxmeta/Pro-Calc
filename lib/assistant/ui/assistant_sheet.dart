import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/assistant_state.dart';
import '../providers/assistant_provider.dart';
import '../services/edge_ai_service.dart';

class AssistantSheet extends ConsumerStatefulWidget {
  final String? modelUrl;

  const AssistantSheet({super.key, this.modelUrl});

  @override
  ConsumerState<AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends ConsumerState<AssistantSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend([String? textToSend]) {
    final text = (textToSend ?? _controller.text).trim();
    if (text.isEmpty) return;

    ref.read(assistantProvider.notifier).processInput(text);
    if (textToSend == null) {
      _controller.clear();
    }
  }

  Future<void> _pickOfflineModel() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.any);

      if (file != null && file.path != null) {
        final selectedFile = File(file.path!);
        await ref
            .read(assistantProvider.notifier)
            .loadPickedModel(selectedFile);
      }
    } catch (e) {
      // User cancelled picker
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reversedMessages = state.messages.reversed.toList();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? const Color(0xFF121418)
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Tools',
        middle: const Text('AI Assistant'),
        trailing: _TrailingStatusWidget(
          status: state.modelStatus,
          onLoadFile: _pickOfflineModel,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: .only(bottom: bottomInset),
          child: Column(
            children: [
              if (state.errorMessage != null)
                Container(
                  margin: const .symmetric(horizontal: 16, vertical: 8),
                  padding: const .all(10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withValues(alpha: 0.15),
                    borderRadius: .circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        FluentIcons.error_circle_20_regular,
                        size: 18,
                        color: CupertinoColors.systemRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const .symmetric(horizontal: 16, vertical: 12),
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) => _CupertinoChatBubble(
                    message: reversedMessages[index],
                    isDark: isDark,
                  ),
                ),
              ),
              if (state.isGenerating)
                const Padding(
                  padding: .symmetric(vertical: 4),
                  child: CupertinoActivityIndicator(radius: 8),
                ),
              _CupertinoQuickActions(onSelected: _handleSend, isDark: isDark),
              _CupertinoInputDock(
                controller: _controller,
                focusNode: _focusNode,
                onSend: () => _handleSend(),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailingStatusWidget extends StatelessWidget {
  final ModelStatus status;
  final VoidCallback onLoadFile;

  const _TrailingStatusWidget({required this.status, required this.onLoadFile});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ModelStatus.ready => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FluentIcons.checkmark_circle_20_filled,
            size: 16,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'Active (${EdgeAiService.instance.activeBackend})',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ModelStatus.downloading => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoActivityIndicator(radius: 7),
          SizedBox(width: 6),
          Text(
            'Validating...',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
      ModelStatus.notDownloaded || ModelStatus.error => CupertinoButton(
        padding: .zero,
        onPressed: onLoadFile,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.folder_open_20_regular, size: 16),
            SizedBox(width: 4),
            Text(
              'Select Model',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    };
  }
}

class _CupertinoChatBubble extends StatelessWidget {
  final AssistantMessage message;
  final bool isDark;

  const _CupertinoChatBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const .symmetric(vertical: 4),
        padding: const .symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? primaryColor
              : (isDark
                    ? const Color(0xFF1E2228)
                    : CupertinoColors.systemBackground),
          borderRadius: .circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser
                ? CupertinoColors.white
                : (isDark ? CupertinoColors.white : CupertinoColors.black),
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _CupertinoQuickActions extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final bool isDark;

  const _CupertinoQuickActions({
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      (label: '🌍 10 * Earth Gravity', query: 'what is 10 * earth gravity'),
      (
        label: '🔄 Earth Rotation Speed',
        query: 'how much is earth rotation speed',
      ),
      (label: '🎲 Permutation 5 pick 3', query: 'permutations of 5 pick 3'),
      (
        label: '🍎 10 baskets with 5 apples',
        query: 'how many apples with 10 baskets. each basket has 5 apples',
      ),
    ];

    return Container(
      height: 38,
      margin: const .only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const .symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = suggestions[i];
          return CupertinoButton(
            padding: const .symmetric(horizontal: 12),
            color: isDark
                ? const Color(0xFF1E2228)
                : CupertinoColors.systemBackground,
            borderRadius: .circular(16),
            minSize: 32,
            onPressed: () => onSelected(item.query),
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CupertinoInputDock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool isDark;

  const _CupertinoInputDock({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .fromLTRB(12, 8, 12, 24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF181B20)
            : CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF2A2E36)
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              padding: const .symmetric(horizontal: 14, vertical: 10),
              placeholder:
                  'Ask physics, math, permutations, or word problem...',
              placeholderStyle: const TextStyle(
                color: CupertinoColors.placeholderText,
                fontSize: 14,
              ),
              style: TextStyle(
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
                fontSize: 15,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF242830)
                    : CupertinoColors.systemGrey6,
                borderRadius: .circular(20),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: .zero,
            minSize: 38,
            color: CupertinoTheme.of(context).primaryColor,
            borderRadius: .circular(19),
            onPressed: onSend,
            child: const Icon(
              FluentIcons.arrow_up_20_filled,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
