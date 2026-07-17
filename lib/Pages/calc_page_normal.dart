import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalcPageNormal extends ConsumerWidget {
  const CalcPageNormal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We will use the same logic from CalcPage but with a different stringList.
    // To keep it DRY, we'll define the layout here.
    final List<String> normalStringList = [
      'AC', 'DEL', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '0', '.', '', '', // 5x4 grid, last two are empty
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ... (Display area similar to CalcPage) ...
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: normalStringList.length,
                itemBuilder: (context, index) {
                  final String label = normalStringList[index];
                  if (label == '') {
                    return const SizedBox.shrink();
                  }
                  return CupertinoButton(
                    child: Text(label),
                    onPressed: () {
                      // This will be linked to the same buttonPressed logic
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
