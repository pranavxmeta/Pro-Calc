import 'package:flutter/cupertino.dart';

class LineData {
  final String rawText;
  final double? value;
  final double? subtotal;
  final bool isSubtotalLine;

  LineData({
    required this.rawText,
    this.value,
    this.subtotal,
    this.isSubtotalLine = false,
  });
}

class NotesCalcPage extends StatefulWidget {
  const NotesCalcPage({super.key});

  @override
  State<NotesCalcPage> createState() => _NotesCalcPageState();
}

class _NotesCalcPageState extends State<NotesCalcPage> {
  final TextEditingController _controller = TextEditingController();
  List<LineData> _parsedLines = [];
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_recalculate);
    _recalculate();
  }

  @override
  void dispose() {
    _controller.removeListener(_recalculate);
    _controller.dispose();
    super.dispose();
  }

  void _recalculate() {
    final text = _controller.text;
    final rawLines = text.split('\n');

    // Enforce a hard maximum of 50 lines
    List<String> lines = rawLines;
    if (rawLines.length > 50) {
      lines = rawLines.sublist(0, 50);
      final truncatedText = lines.join('\n');

      // Update text field and maintain cursor position
      _controller.value = TextEditingValue(
        text: truncatedText,
        selection: TextSelection.collapsed(offset: truncatedText.length),
      );
    }

    final List<LineData> parsed = [];
    final List<double> currentBlock = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('++')) {
        // Compute subtotal from the previous line up to the first empty line or previous subtotal
        final double sub = currentBlock.fold(0.0, (sum, val) => sum + val);
        parsed.add(
          LineData(rawText: line, subtotal: sub, isSubtotalLine: true),
        );
        currentBlock.clear(); // Clear current block after calculation boundary
      } else if (trimmed.isEmpty) {
        currentBlock.clear(); // Empty lines break/reset the block accumulator
        parsed.add(LineData(rawText: line));
      } else {
        // Parse left-hand side value (before first '=')
        final parts = trimmed.split('=');
        double? parsedVal;
        if (parts.length > 1) {
          final String numberPart = parts[0].trim();
          parsedVal = double.tryParse(numberPart);
        }

        if (parsedVal != null) {
          currentBlock.add(parsedVal);
          parsed.add(LineData(rawText: line, value: parsedVal));
        } else {
          parsed.add(LineData(rawText: line));
        }
      }
    }

    // Pad the list up to 50 lines for UI consistency
    while (parsed.length < 50) {
      parsed.add(LineData(rawText: ''));
    }

    // Calculate overall total from raw entry values (excluding subtotal duplicates)
    final double totalSum = parsed
        .where((l) => l.value != null)
        .map((l) => l.value!)
        .fold(0.0, (sum, val) => sum + val);

    setState(() {
      _parsedLines = parsed;
      _total = totalSum;
    });
  }

  Widget _buildLineNumbersColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(50, (index) {
        return SizedBox(
          height: 24, // Coordinates with font-size and line-height spacing
          // alignment: Alignment.centerRight,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 16,
              height: 1.5,
              color: CupertinoColors.systemGrey3,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEvalColumn(CupertinoThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(50, (index) {
        final lineData = _parsedLines[index];
        String displayVal = '';
        Color textColor = currentTheme.textTheme.textStyle.color!;

        if (lineData.isSubtotalLine) {
          displayVal = '(= ${lineData.subtotal?.toStringAsFixed(0)})';
          textColor = CupertinoColors.activeBlue;
        } else if (lineData.value != null) {
          displayVal = lineData.value!.toStringAsFixed(0);
          textColor = CupertinoColors.systemGreen;
        }

        return SizedBox(
          height: 24,
          // alignment: Alignment.centerLeft,
          child: Text(
            displayVal,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 16,
              height: 1.5,
              color: textColor,
              fontWeight: lineData.isSubtotalLine
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Notes Calculator'),
        backgroundColor: currentTheme.barBackgroundColor,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Total Status Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: currentTheme.barBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _total.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Note Editor Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: currentTheme.barBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fixed Line Numbers on the Left
                      _buildLineNumbersColumn(),
                      const SizedBox(width: 12),
                      // Expandable Input Area
                      Expanded(
                        child: CupertinoTextField(
                          controller: _controller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          placeholder:
                              'Type expressions here...\n(e.g., 100 = fuel)',
                          scrollPhysics: const NeverScrollableScrollPhysics(),
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            height: 1.5,
                            color: currentTheme.textTheme.textStyle.color,
                          ),
                          decoration: const BoxDecoration(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Output Calculations on the Right
                      _buildEvalColumn(currentTheme),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
