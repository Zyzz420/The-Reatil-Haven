import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/enums.dart';
import '../../../data/models/task.dart';
import '../../../state/data_providers.dart';

class TaskBoardView extends ConsumerWidget {
  const TaskBoardView({super.key, required this.projectId});

  final int projectId;

  static const _statuses = [
    TaskStatus.toDo,
    TaskStatus.workInProgress,
    TaskStatus.underReview,
    TaskStatus.completed,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(projectId));

    return tasksAsync.when(
      data: (tasks) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _statuses
            .map(
              (status) => Expanded(
                child: _TaskColumn(
                  status: status,
                  tasks: tasks
                      .where(
                        (task) => (task.status ?? TaskStatus.toDo) == status,
                      )
                      .toList(),
                ),
              ),
            )
            .toList(),
      ),
      error: (error, __) => Center(child: Text('Error loading tasks: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _TaskColumn extends ConsumerWidget {
  const _TaskColumn({required this.status, required this.tasks});

  final TaskStatus status;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DragTarget<Task>(
        onAcceptWithDetails: (details) async {
          final task = details.data;
          await ref
              .read(taskMutationsProvider)
              .updateTaskStatus(task.id, status, task.projectId);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.05 * 255).round())
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      child: Text(tasks.length.toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...tasks.map((task) => _BoardTaskCard(task: task)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BoardTaskCard extends StatelessWidget {
  const _BoardTaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.MMMd();
    final dateLabel = task.dueDate != null
        ? formatter.format(task.dueDate!)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LongPressDraggable<Task>(
        data: task,
        feedback: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: _TaskCardBody(
              task: task,
              dateLabel: dateLabel,
              isDragging: true,
            ),
          ),
        ),
        child: _TaskCardBody(task: task, dateLabel: dateLabel),
      ),
    );
  }
}

class _TaskCardBody extends StatelessWidget {
  const _TaskCardBody({
    required this.task,
    required this.dateLabel,
    this.isDragging = false,
  });

  final Task task;
  final String dateLabel;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDragging ? 0.7 : 1,
      child: Card(
        elevation: isDragging ? 8 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                task.description ?? 'No description provided',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (task.priority != null)
                    Chip(
                      label: Text(task.priority!.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (dateLabel.isNotEmpty)
                    Chip(
                      label: Text(dateLabel),
                      avatar: const Icon(Icons.calendar_today, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text(
                      (task.assignee?.username ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(task.assignee?.username ?? 'Unassigned'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
