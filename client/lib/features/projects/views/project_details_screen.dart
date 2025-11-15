import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/project.dart';
import '../../../state/data_providers.dart';
import '../../../widgets/dialogs/task_form_dialog.dart';
import '../../../widgets/page_header.dart';
import '../widgets/task_board.dart';
import '../widgets/task_list_view.dart';
import '../widgets/task_table_view.dart';
import '../widgets/task_timeline_view.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  static const _tabs = ['Board', 'List', 'Timeline', 'Table'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectId = int.tryParse(widget.projectId) ?? 0;
    final projectsAsync = ref.watch(projectsProvider);
    final projects = projectsAsync.valueOrNull;
    Project? project;
    if (projects != null) {
      for (final item in projects) {
        if (item.id == projectId) {
          project = item;
          break;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: project?.name ?? 'Project $projectId',
            subtitle: project?.description ?? 'Project overview and planning',
            action: FilledButton.icon(
              onPressed: () =>
                  showTaskFormDialog(context, projectId: projectId),
              icon: const Icon(Icons.add),
              label: const Text('New task'),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: TabBarView(
              controller: _tabController,
              children: [
                TaskBoardView(projectId: projectId),
                TaskListView(projectId: projectId),
                TaskTimelineView(projectId: projectId),
                TaskTableView(projectId: projectId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
