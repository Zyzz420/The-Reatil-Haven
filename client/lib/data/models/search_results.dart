import 'project.dart';
import 'task.dart';
import 'user.dart';

class SearchResults {
  const SearchResults({
    this.tasks = const [],
    this.projects = const [],
    this.users = const [],
  });

  final List<Task> tasks;
  final List<Project> projects;
  final List<AppUser> users;

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final tasks =
        (json['tasks'] as List<dynamic>?)
            ?.map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList() ??
        const <Task>[];
    final projects =
        (json['projects'] as List<dynamic>?)
            ?.map((item) => Project.fromJson(item as Map<String, dynamic>))
            .toList() ??
        const <Project>[];
    final users =
        (json['users'] as List<dynamic>?)
            ?.map((item) => AppUser.fromJson(item as Map<String, dynamic>))
            .toList() ??
        const <AppUser>[];

    return SearchResults(tasks: tasks, projects: projects, users: users);
  }
}
