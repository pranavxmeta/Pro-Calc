import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Class to hold calculator layout settings
class SettingsState {
  final bool enablePhoneKeypad;
  final bool changeOperatorOrder;
  final String numberLocale;

  SettingsState({
    required this.enablePhoneKeypad,
    required this.changeOperatorOrder,
    required this.numberLocale,
  });

  SettingsState copyWith({
    bool? enablePhoneKeypad,
    bool? changeOperatorOrder,
    String? numberLocale,
  }) {
    return SettingsState(
      enablePhoneKeypad: enablePhoneKeypad ?? this.enablePhoneKeypad,
      changeOperatorOrder: changeOperatorOrder ?? this.changeOperatorOrder,
      numberLocale: numberLocale ?? this.numberLocale,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        SettingsState(
          enablePhoneKeypad: false,
          changeOperatorOrder: false,
          numberLocale: 'en_IN',
        ),
      ) {
    _loadSettings();
  }

  static const _phoneKeypadKey = 'enablePhoneKeypad';
  static const _operatorOrderKey = 'changeOperatorOrder';
  static const _numberLocaleKey = 'numberLocale';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = SettingsState(
        enablePhoneKeypad: prefs.getBool(_phoneKeypadKey) ?? false,
        changeOperatorOrder: prefs.getBool(_operatorOrderKey) ?? false,
        numberLocale: prefs.getString(_numberLocaleKey) ?? 'en_IN',
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setEnablePhoneKeypad(bool value) async {
    state = state.copyWith(enablePhoneKeypad: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_phoneKeypadKey, value);
  }

  Future<void> setChangeOperatorOrder(bool value) async {
    state = state.copyWith(changeOperatorOrder: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_operatorOrderKey, value);
  }

  Future<void> toggleNumberLocale() async {
    // <-- Make async to save
    final newLocale = state.numberLocale == 'en_IN' ? 'en_US' : 'en_IN';
    state = state.copyWith(numberLocale: newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_numberLocaleKey, newLocale); // <-- Persist value
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
