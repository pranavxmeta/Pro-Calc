// lib/normcalc/ui/normcalc_screen.dart

import 'package:material_ui/material_ui.dart';
import '../business_logic/calc_view_model.dart';
import '../models/operation.dart';
import '../utils/formatters.dart';
import 'operator_buttons.dart';

class NormCalcScreen extends StatefulWidget {
  const NormCalcScreen({super.key});

  @override
  State<NormCalcScreen> createState() => _NormCalcScreenState();
}

class _NormCalcScreenState extends State<NormCalcScreen> {
  late final CalcViewModel _vm;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _vm = CalcViewModel()..addListener(_scrollToBottom);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _vm.focusNode.requestFocus(),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_scrollToBottom);
    _vm.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // Realtime Solution Container (Sticky Top)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'REALTIME SOLUTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _vm.realtimeResult,
                          style: theme.textTheme.displayMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Note-Cards Stream (Grows upward, active card at bottom)
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      // Locked Previous Steps
                      for (var i = 0; i < _vm.history.length; i++)
                        _EquationCard(step: _vm.history[i], index: i + 1),

                      // Active Typing Bottom Card with Native Numpad
                      _ActiveInputCard(
                        controller: _vm.inputController,
                        focusNode: _vm.focusNode,
                        onChanged: _vm.onInputChanged,
                      ),
                    ],
                  ),
                ),

                // 4 Operators & Quick Actions
                OperatorButtons(
                  onOperatorSelected: _vm.applyOperator,
                  onClear: _vm.clearAll,
                  onBackspace: _vm.deleteLast,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private Helper Note Card Widgets
// ---------------------------------------------------------------------------

class _EquationCard extends StatelessWidget {
  const _EquationCard({required this.step, required this.index});

  final EquationStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Step Index Badge (#1, #2...)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#$index',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Formatted Value
          Text(
            CalcFormatter.formatResult(step.value),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          // Operator Badge Pill
          if (step.op case final op?) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                op.symbol,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveInputCard extends StatelessWidget {
  const _ActiveInputCard({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'INPUT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge,
              cursorColor: theme.colorScheme.secondary,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
