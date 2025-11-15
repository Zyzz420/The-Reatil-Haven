import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/enums.dart';
import '../../../state/data_providers.dart';

class TaskTableView extends ConsumerWidget {
  const TaskTableView({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(projectId));
    final formatter = DateFormat.yMMMd();

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Priority')),
              DataColumn(label: Text('Start')),
              DataColumn(label: Text('Due')),
              DataColumn(label: Text('Author')),
              DataColumn(label: Text('Assignee')),
            ],
            rows: tasks
                .map(
                  (task) => DataRow(
                    cells: [
                      DataCell(Text(task.title)),
                      DataCell(Text(task.status?.label ?? 'N/A')),
                      DataCell(Text(task.priority?.label ?? 'N/A')),
                      DataCell(
                        Text(
                          task.startDate != null
                              ? formatter.format(task.startDate!)
                              : 'Not set',
                        ),
                      ),
                      DataCell(
                        Text(
                          task.dueDate != null
                              ? formatter.format(task.dueDate!)
                              : 'Not set',
                        ),
                      ),
                      DataCell(Text(task.author?.username ?? 'Unknown')),
                      DataCell(Text(task.assignee?.username ?? 'Unassigned')),
                    ],
                  ),
                )
                .toList(),
          ),
        );
      },
      error: (error, __) => Center(child: Text('Error loading tasks: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
