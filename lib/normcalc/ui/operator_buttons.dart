// lib/normcalc/ui/operator_buttons.dart

// ignore_for_file: deprecated_member_use

import 'package:material_ui/material_ui.dart';

import '../models/operation.dart';

class OperatorButtons extends StatelessWidget {
  const OperatorButtons({
    required this.onOperatorSelected,
    required this.onClear,
    required this.onBackspace,
    super.key,
  });

  final ValueChanged<Operation> onOperatorSelected;
  final VoidCallback onClear;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            label: 'C',
            color: Theme.of(context).colorScheme.error,
            onPressed: onClear,
          ),
          ...Operation.values.map(
            (op) => _ActionButton(
              label: op.symbol,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => onOperatorSelected(op),
            ),
          ),
          _ActionButton(
            label: '⌫',
            color: Colors.grey.shade700,
            onPressed: onBackspace,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
