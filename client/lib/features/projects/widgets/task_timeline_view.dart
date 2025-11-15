import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task.dart';
import '../../../state/data_providers.dart';

class TaskTimelineView extends ConsumerWidget {
  const TaskTimelineView({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(projectId));

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks scheduled'));
        }
        final datedTasks = tasks
            .where((task) => task.startDate != null && task.dueDate != null)
            .toList();
        if (datedTasks.isEmpty) {
          return const Center(child: Text('Tasks do not have schedule dates'));
        }
        datedTasks.sort((a, b) => a.startDate!.compareTo(b.startDate!));
        final start = datedTasks.first.startDate!;
        final end = datedTasks
            .map((task) => task.dueDate!)
            .reduce((a, b) => a.isAfter(b) ? a : b);

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: datedTasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _TimelineRow(
            task: datedTasks[index],
            minDate: start,
            maxDate: end,
          ),
        );
      },
      error: (error, __) =>
          Center(child: Text('Error loading timeline: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.task,
    required this.minDate,
    required this.maxDate,
  });

  final Task task;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  Widget build(BuildContext context) {
    final totalDuration = maxDate
        .difference(minDate)
        .inHours
        .toDouble()
        .clamp(1, double.infinity);
    final startOffset =
        task.startDate!.difference(minDate).inHours.toDouble() / totalDuration;
    final taskDuration =
        task.dueDate!.difference(task.startDate!).inHours.toDouble() /
        totalDuration;
    final formatter = DateFormat.MMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${formatter.format(task.startDate!)} - ${formatter.format(task.dueDate!)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final barLeft = width * startOffset;
            final barWidth = width * taskDuration;
            final segmentWidth = barWidth.clamp(6.0, width).toDouble();

            return Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Positioned(
                  left: barLeft,
                  child: Container(
                    height: 16,
                    width: segmentWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
