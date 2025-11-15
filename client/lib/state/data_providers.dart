import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../data/models/project.dart';
import '../data/models/project_input.dart';
import '../data/models/search_results.dart';
import '../data/models/task.dart';
import '../data/models/task_input.dart';
import '../data/models/team.dart';
import '../data/models/user.dart';
import '../data/models/enums.dart';
import '../data/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final projectsProvider = FutureProvider<List<Project>>(
  (ref) => ref.watch(apiServiceProvider).fetchProjects(),
);

final usersProvider = FutureProvider<List<AppUser>>(
  (ref) => ref.watch(apiServiceProvider).fetchUsers(),
);

final teamsProvider = FutureProvider<List<Team>>(
  (ref) => ref.watch(apiServiceProvider).fetchTeams(),
);

final selectedUserIdProvider = StateProvider<int>(
  (ref) => AppConfig.defaultUserId,
);

final projectTasksProvider = FutureProvider.family.autoDispose<List<Task>, int>(
  (ref, projectId) {
    return ref.watch(apiServiceProvider).fetchTasks(projectId);
  },
);

final tasksByUserProvider = FutureProvider.family.autoDispose<List<Task>, int>((
  ref,
  userId,
) {
  return ref.watch(apiServiceProvider).fetchTasksByUser(userId);
});

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 3) {
    return Future.value(const SearchResults());
  }
  return ref.watch(apiServiceProvider).search(query);
});

final projectMutationsProvider = Provider<ProjectMutations>((ref) {
  return ProjectMutations(ref);
});

final taskMutationsProvider = Provider<TaskMutations>((ref) {
  return TaskMutations(ref);
});

class ProjectMutations {
  ProjectMutations(this._ref);

  final Ref _ref;

  Future<Project> createProject(ProjectInput input) async {
    final project = await _ref.read(apiServiceProvider).createProject(input);
    _ref.invalidate(projectsProvider);
    return project;
  }
}

class TaskMutations {
  TaskMutations(this._ref);

  final Ref _ref;

  Future<Task> createTask(TaskInput input) async {
    final task = await _ref.read(apiServiceProvider).createTask(input);
    _ref.invalidate(projectTasksProvider(input.projectId));
    _ref.invalidate(tasksByUserProvider(input.authorUserId));
    if (input.assignedUserId != null) {
      _ref.invalidate(tasksByUserProvider(input.assignedUserId!));
    }
    return task;
  }

  Future<Task> updateTaskStatus(
    int taskId,
    TaskStatus status,
    int projectId,
  ) async {
    final task = await _ref
        .read(apiServiceProvider)
        .updateTaskStatus(taskId: taskId, status: status);
    _ref.invalidate(projectTasksProvider(projectId));
    return task;
  }
}
