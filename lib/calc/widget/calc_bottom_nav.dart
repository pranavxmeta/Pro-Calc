import 'package:flutter/cupertino.dart';

import 'calc_button.dart';

/// Navigation pill hosting secondary app modal triggers.
class CalcBottomNav extends StatelessWidget {
  const CalcBottomNav({super.key, required this.onNavAction});

  final ValueChanged<String> onNavAction;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const .only(bottom: 6.0),
      child: Container(
        width: screenWidth,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(4, 0, 255, 0.35),
              blurRadius: 40,
              offset: Offset(0, 55),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.22),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.4,
                color: const Color.fromRGBO(255, 255, 255, 0.90),
              ),
              gradient: const LinearGradient(
                begin: .topRight,
                end: .bottomRight,
                colors: [
                  Color.fromRGBO(250, 250, 250, 0.65),
                  Color.fromRGBO(254, 254, 254, 0.35),
                ],
              ),
              borderRadius: .circular(24),
            ),
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                CalcButton(
                  symbol: 'Calc',
                  width: 28,
                  height: 28,
                  onPressed: () => onNavAction('Calc'),
                ),
                CalcButton(
                  symbol: 'hist',
                  width: 28,
                  height: 28,
                  onPressed: () => onNavAction('hist'),
                ),
                CalcButton(
                  symbol: 'unit',
                  width: 28,
                  height: 28,
                  onPressed: () => onNavAction('unit'),
                ),
                CalcButton(
                  symbol: 'Settings',
                  width: 28,
                  height: 28,
                  onPressed: () => onNavAction('Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
