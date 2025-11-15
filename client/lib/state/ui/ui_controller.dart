import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui_state.dart';

final uiControllerProvider = AsyncNotifierProvider<UiController, UiState>(
  UiController.new,
);

class UiController extends AsyncNotifier<UiState> {
  static const _darkModeKey = 'isDarkMode';
  static const _sidebarKey = 'isSidebarCollapsed';

  late SharedPreferences _prefs;

  @override
  Future<UiState> build() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs.getBool(_darkModeKey) ?? false;
    final isSidebarCollapsed = _prefs.getBool(_sidebarKey) ?? false;
    return UiState(isDarkMode: isDark, isSidebarCollapsed: isSidebarCollapsed);
  }

  Future<void> toggleDarkMode() async {
    final current = state.valueOrNull ?? const UiState();
    final updated = current.copyWith(isDarkMode: !current.isDarkMode);
    state = AsyncData(updated);
    await _prefs.setBool(_darkModeKey, updated.isDarkMode);
  }

  Future<void> toggleSidebar() async {
    final current = state.valueOrNull ?? const UiState();
    final updated = current.copyWith(
      isSidebarCollapsed: !current.isSidebarCollapsed,
    );
    state = AsyncData(updated);
    await _prefs.setBool(_sidebarKey, updated.isSidebarCollapsed);
  }

  Future<void> setSidebarCollapsed(bool value) async {
    final current = state.valueOrNull ?? const UiState();
    final updated = current.copyWith(isSidebarCollapsed: value);
    state = AsyncData(updated);
    await _prefs.setBool(_sidebarKey, updated.isSidebarCollapsed);
  }
}
