import 'enums.dart';
import 'user.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.status,
    this.priority,
    this.tags,
    this.startDate,
    this.dueDate,
    this.points,
    required this.projectId,
    this.authorUserId,
    this.assignedUserId,
    this.author,
    this.assignee,
    this.attachments = const [],
    this.comments = const [],
  });

  final int id;
  final String title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? tags;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int? points;
  final int projectId;
  final int? authorUserId;
  final int? assignedUserId;
  final AppUser? author;
  final AppUser? assignee;
  final List<TaskAttachment> attachments;
  final List<TaskComment> comments;

  factory Task.fromJson(Map<String, dynamic> json) {
    final attachments =
        (json['attachments'] as List<dynamic>?)
            ?.map(
              (item) => TaskAttachment.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        const <TaskAttachment>[];
    final comments =
        (json['comments'] as List<dynamic>?)
            ?.map((item) => TaskComment.fromJson(item as Map<String, dynamic>))
            .toList() ??
        const <TaskComment>[];

    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatusParser.fromRaw(json['status'] as String?),
      priority: TaskPriorityParser.fromRaw(json['priority'] as String?),
      tags: json['tags'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      points: json['points'] as int?,
      projectId: json['projectId'] as int,
      authorUserId: json['authorUserId'] as int?,
      assignedUserId: json['assignedUserId'] as int?,
      author: json['author'] != null
          ? AppUser.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      assignee: json['assignee'] != null
          ? AppUser.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
      attachments: attachments,
      comments: comments,
    );
  }
}

class TaskAttachment {
  const TaskAttachment({
    required this.id,
    required this.fileUrl,
    this.fileName,
  });

  final int id;
  final String fileUrl;
  final String? fileName;

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] as int,
      fileUrl: json['fileURL'] as String,
      fileName: json['fileName'] as String?,
    );
  }
}

class TaskComment {
  const TaskComment({required this.id, required this.text, this.user});

  final int id;
  final String text;
  final AppUser? user;

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as int,
      text: json['text'] as String,
      user: json['user'] != null
          ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
