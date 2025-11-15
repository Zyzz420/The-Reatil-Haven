import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/project.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../state/data_providers.dart';
import '../../../widgets/dialogs/project_form_dialog.dart';
import '../../../widgets/page_header.dart';

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return _EmptyState(
            message:
                'You do not have any projects yet. Create one to get started.',
            onActionPressed: () => showProjectFormDialog(context),
          );
        }
        final selectedProject = projects.first;
        final tasksAsync = ref.watch(projectTasksProvider(selectedProject.id));

        return tasksAsync.when(
          data: (tasks) => _DashboardContent(
            projects: projects,
            selectedProject: selectedProject,
            tasks: tasks,
          ),
          error: (error, __) =>
              Center(child: Text('Unable to load tasks: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, __) =>
          Center(child: Text('Unable to load dashboard: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.projects,
    required this.selectedProject,
    required this.tasks,
  });

  final List<Project> projects;
  final Project selectedProject;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final totalProjects = projects.length;
    final completedProjects = projects
        .where((project) => project.endDate != null)
        .length;
    final activeProjects = totalProjects - completedProjects;
    final totalTasks = tasks.length;
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    final priorityDistribution = _buildPriorityDistribution(tasks);
    final formatter = DateFormat.yMMMd();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Project Management Dashboard',
            subtitle:
                'Overview of ${selectedProject.name} and your wider portfolio',
            action: FilledButton.icon(
              onPressed: () => showProjectFormDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New project'),
            ),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                title: 'Active projects',
                value: activeProjects.toString(),
                subtitle: '$completedProjects completed',
                icon: Icons.work_outline,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Tasks in this project',
                value: totalTasks.toString(),
                subtitle: '$completedTasks completed',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Timeline',
                value: formatter.format(
                  selectedProject.startDate ?? DateTime.now(),
                ),
                subtitle: selectedProject.endDate != null
                    ? formatter.format(selectedProject.endDate!)
                    : 'No end date set',
                icon: Icons.timeline,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 1000;
              return Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: 'Task priority distribution',
                      child: SizedBox(
                        height: 280,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final priority =
                                        TaskPriority.values[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(priority.label),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: priorityDistribution.entries
                                .map(
                                  (entry) => BarChartGroupData(
                                    x: entry.key.index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value.toDouble(),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 22,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16, width: 16),
                  Expanded(
                    child: _DashboardCard(
                      title: 'Project status',
                      child: SizedBox(
                        height: 280,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: activeProjects.toDouble(),
                                color: Colors.blueAccent,
                                title: 'Active',
                              ),
                              PieChartSectionData(
                                value: completedProjects.toDouble(),
                                color: Colors.greenAccent,
                                title: 'Completed',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _DashboardCard(
            title: 'Tasks',
            action: Text(
              'Project ${selectedProject.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            child: tasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No tasks in this project yet')),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Due date')),
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
                                    task.dueDate != null
                                        ? formatter.format(task.dueDate!)
                                        : 'Not set',
                                  ),
                                ),
                                DataCell(
                                  Text(task.assignee?.username ?? 'Unassigned'),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<TaskPriority, int> _buildPriorityDistribution(List<Task> tasks) {
    final counts = <TaskPriority, int>{};
    for (final priority in TaskPriority.values) {
      counts[priority] = 0;
    }
    for (final task in tasks) {
      final priority = task.priority ?? TaskPriority.backlog;
      counts[priority] = (counts[priority] ?? 0) + 1;
    }
    return counts;
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha((0.1 * 255).round()),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onActionPressed});

  final String message;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.add),
            label: const Text('Create project'),
          ),
        ],
      ),
    );
  }
}
