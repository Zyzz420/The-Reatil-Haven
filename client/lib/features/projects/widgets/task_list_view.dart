import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/data_providers.dart';
import '../../../widgets/task_card.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(projectId));

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => TaskCard(task: tasks[index]),
        );
      },
      error: (error, __) => Center(child: Text('Error loading tasks: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
