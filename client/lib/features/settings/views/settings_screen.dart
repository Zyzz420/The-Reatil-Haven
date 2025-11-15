import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/data_providers.dart';
import '../../../widgets/page_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final selectedUserId = ref.watch(selectedUserIdProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users available'));
          }
          final currentUser = users.firstWhere(
            (user) => user.userId == selectedUserId,
            orElse: () => users.first,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Settings'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: currentUser.userId,
                decoration: const InputDecoration(labelText: 'Active user'),
                items: users
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.userId,
                        child: Text(user.username),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedUserIdProvider.notifier).state = value;
                  }
                },
              ),
              const SizedBox(height: 24),
              _SettingTile(label: 'Username', value: currentUser.username),
              _SettingTile(
                label: 'Email',
                value: currentUser.email ?? 'Not provided',
              ),
              _SettingTile(
                label: 'Team ID',
                value: currentUser.teamId?.toString() ?? 'Unassigned',
              ),
            ],
          );
        },
        error: (error, __) =>
            Center(child: Text('Unable to load settings: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
