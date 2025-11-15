import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/data_providers.dart';
import '../../../state/ui/ui_controller.dart';

class DashboardTopBar extends ConsumerWidget {
  const DashboardTopBar({super.key, required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiControllerProvider);
    final usersAsync = ref.watch(usersProvider);
    final selectedUserId = ref.watch(selectedUserIdProvider);

    return uiState.when(
      data: (state) {
        final colorScheme = Theme.of(context).colorScheme;
        final usersValue = usersAsync.valueOrNull;
        var currentUser = usersValue != null && usersValue.isNotEmpty
            ? usersValue.firstWhere(
                (user) => user.userId == selectedUserId,
                orElse: () => usersValue.first,
              )
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.menu),
                tooltip: 'Toggle navigation',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Search projects, tasks, teams...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(uiControllerProvider.notifier).toggleDarkMode(),
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: 'Toggle theme',
              ),
              const SizedBox(width: 8),
              usersAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const CircleAvatar(child: Icon(Icons.person));
                  }
                  final dropdownItems = users
                      .map(
                        (user) => PopupMenuItem<int>(
                          value: user.userId,
                          child: Text(user.username),
                        ),
                      )
                      .toList();
                  return PopupMenuButton<int>(
                    tooltip: 'Switch active user',
                    initialValue: currentUser?.userId,
                    onSelected: (value) =>
                        ref.read(selectedUserIdProvider.notifier).state = value,
                    itemBuilder: (context) => dropdownItems,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          child: Text(
                            (currentUser?.username ?? 'ED')
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(currentUser?.username ?? 'Select user'),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  );
                },
                error: (_, __) => const CircleAvatar(child: Icon(Icons.person)),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox(height: 64),
    );
  }
}
