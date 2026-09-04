import 'package:cupertino_ui/cupertino_ui.dart';
import '../theme/notes_theme.dart';

class TotalBottomCard extends StatelessWidget {
  final double totalAmount;

  const TotalBottomCard({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(NotesTheme.horizontalPadding),
      decoration: BoxDecoration(
        color: NotesTheme.cardBackground,
        borderRadius: BorderRadius.circular(NotesTheme.cardBorderRadius),
        border: Border.all(color: NotesTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GRAND TOTAL', style: NotesTheme.totalHeaderStyle),
              Text(
                'Sum of entries',
                style: TextStyle(fontSize: 12, color: NotesTheme.mutedText),
              ),
            ],
          ),
          Text(
            totalAmount.toStringAsFixed(2),
            style: NotesTheme.totalAmountStyle,
          ),
        ],
      ),
    );
  }
}
