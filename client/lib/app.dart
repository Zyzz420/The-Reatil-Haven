import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router.dart';
import 'config/theme.dart';
import 'state/ui/ui_controller.dart';

class ProjectManagementApp extends ConsumerWidget {
  const ProjectManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final uiState = ref.watch(uiControllerProvider);

    final themeMode = uiState.maybeWhen(
      data: (state) => state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      orElse: () => ThemeMode.light,
    );

    return MaterialApp.router(
      title: 'Project Management Dashboard',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
