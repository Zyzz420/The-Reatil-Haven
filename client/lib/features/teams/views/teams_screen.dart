import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/data_providers.dart';
import '../../../widgets/page_header.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PageHeader(title: 'Teams'),
          Expanded(
            child: teamsAsync.when(
              data: (teams) {
                if (teams.isEmpty) {
                  return const Center(child: Text('No teams configured'));
                }
                return ListView.separated(
                  itemCount: teams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        title: Text(team.teamName),
                        subtitle: Text(
                          'PO: ${team.productOwnerUsername ?? 'TBD'} · PM: ${team.projectManagerUsername ?? 'TBD'}',
                        ),
                        leading: CircleAvatar(child: Text(team.id.toString())),
                      ),
                    );
                  },
                );
              },
              error: (error, __) =>
                  Center(child: Text('Failed to load teams: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
