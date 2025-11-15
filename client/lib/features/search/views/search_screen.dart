import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/data_providers.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/task_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Search workspace'),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search for tasks, projects or users',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value.trim(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: resultsAsync.when(
              data: (results) {
                if (query.length < 3) {
                  return const Center(
                    child: Text('Start typing to search the workspace'),
                  );
                }
                if (results.tasks.isEmpty &&
                    results.projects.isEmpty &&
                    results.users.isEmpty) {
                  return const Center(child: Text('No results found'));
                }
                return ListView(
                  children: [
                    if (results.tasks.isNotEmpty)
                      const Text('Tasks', style: TextStyle(fontSize: 18)),
                    ...results.tasks.map((task) => TaskCard(task: task)),
                    if (results.projects.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Projects', style: TextStyle(fontSize: 18)),
                      ...results.projects.map(
                        (project) => ListTile(
                          leading: const Icon(Icons.work_outline),
                          title: Text(project.name),
                          subtitle: Text(
                            project.description ?? 'No description',
                          ),
                        ),
                      ),
                    ],
                    if (results.users.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Users', style: TextStyle(fontSize: 18)),
                      ...results.users.map(
                        (user) => ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(user.username),
                          subtitle: Text(user.email ?? 'No email provided'),
                        ),
                      ),
                    ],
                  ],
                );
              },
              error: (error, __) =>
                  Center(child: Text('Search failed: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
