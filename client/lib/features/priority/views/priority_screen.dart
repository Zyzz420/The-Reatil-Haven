import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/enums.dart';
import '../../../state/data_providers.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/task_card.dart';

class PriorityScreen extends ConsumerStatefulWidget {
  const PriorityScreen({super.key, required this.priority});

  final String priority;

  @override
  ConsumerState<PriorityScreen> createState() => _PriorityScreenState();
}

class _PriorityScreenState extends ConsumerState<PriorityScreen> {
  String _view = 'list';

  @override
  Widget build(BuildContext context) {
    final priority = TaskPriorityParser.fromRaw(widget.priority);
    final selectedUserId = ref.watch(selectedUserIdProvider);
    final tasksAsync = ref.watch(tasksByUserProvider(selectedUserId));
    final formatter = DateFormat.yMMMd();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: '${priority.label} tasks',
            subtitle: 'Tasks assigned to you grouped by priority',
            action: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'list', label: Text('List')),
                ButtonSegment(value: 'table', label: Text('Table')),
              ],
              selected: {_view},
              onSelectionChanged: (selection) {
                setState(() {
                  _view = selection.first;
                });
              },
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final filtered = tasks
                    .where((task) => task.priority == priority)
                    .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No ${priority.label} tasks assigned'),
                  );
                }
                if (_view == 'list') {
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        TaskCard(task: filtered[index]),
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Start')),
                      DataColumn(label: Text('Due')),
                    ],
                    rows: filtered
                        .map(
                          (task) => DataRow(
                            cells: [
                              DataCell(Text(task.title)),
                              DataCell(Text(task.status?.label ?? 'N/A')),
                              DataCell(
                                Text(
                                  task.startDate != null
                                      ? formatter.format(task.startDate!)
                                      : '',
                                ),
                              ),
                              DataCell(
                                Text(
                                  task.dueDate != null
                                      ? formatter.format(task.dueDate!)
                                      : '',
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                );
              },
              error: (error, __) =>
                  Center(child: Text('Unable to load tasks: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
