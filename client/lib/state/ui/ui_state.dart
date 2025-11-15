class UiState {
  const UiState({this.isDarkMode = false, this.isSidebarCollapsed = false});

  final bool isDarkMode;
  final bool isSidebarCollapsed;

  UiState copyWith({bool? isDarkMode, bool? isSidebarCollapsed}) {
    return UiState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
    );
  }
}
