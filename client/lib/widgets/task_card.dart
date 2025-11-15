import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/enums.dart';
import '../data/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMd();
    final startLabel = task.startDate != null
        ? formatter.format(task.startDate!)
        : 'Not set';
    final endLabel = task.dueDate != null
        ? formatter.format(task.dueDate!)
        : 'Not set';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (task.priority != null)
                  Chip(
                    label: Text(task.priority!.label),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                if (task.status != null)
                  Chip(
                    label: Text(task.status!.label),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                  ),
                if ((task.tags ?? '').isNotEmpty)
                  ...task.tags!
                      .split(',')
                      .map(
                        (tag) => Chip(
                          label: Text(tag.trim()),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if ((task.description ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TaskMeta(label: 'Start', value: startLabel),
                ),
                Expanded(
                  child: _TaskMeta(label: 'Due', value: endLabel),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TaskMeta(
                  label: 'Author',
                  value: task.author?.username ?? 'Unknown',
                ),
                _TaskMeta(
                  label: 'Assignee',
                  value: task.assignee?.username ?? 'Unassigned',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskMeta extends StatelessWidget {
  const _TaskMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
