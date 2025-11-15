import 'enums.dart';

class TaskInput {
  TaskInput({
    required this.title,
    required this.projectId,
    required this.authorUserId,
    this.description,
    this.status = TaskStatus.toDo,
    this.priority = TaskPriority.backlog,
    this.tags,
    this.startDate,
    this.dueDate,
    this.points,
    this.assignedUserId,
  });

  final String title;
  final int projectId;
  final int authorUserId;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? tags;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int? points;
  final int? assignedUserId;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.label,
      'priority': priority.label,
      'tags': tags,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'points': points,
      'projectId': projectId,
      'authorUserId': authorUserId,
      'assignedUserId': assignedUserId,
    };
  }
}
