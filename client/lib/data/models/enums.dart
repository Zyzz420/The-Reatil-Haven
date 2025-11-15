enum TaskPriority { urgent, high, medium, low, backlog }

enum TaskStatus { toDo, workInProgress, underReview, completed }

extension TaskPriorityParser on TaskPriority {
  static TaskPriority fromRaw(String? value) {
    final normalized = value?.trim().toLowerCase();
    switch (normalized) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      case 'backlog':
      default:
        return TaskPriority.backlog;
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.backlog:
        return 'Backlog';
    }
  }
}

extension TaskStatusParser on TaskStatus {
  static TaskStatus fromRaw(String? value) {
    final normalized = value?.trim().toLowerCase();
    switch (normalized) {
      case 'to do':
        return TaskStatus.toDo;
      case 'work in progress':
        return TaskStatus.workInProgress;
      case 'under review':
        return TaskStatus.underReview;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.toDo;
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.workInProgress:
        return 'Work In Progress';
      case TaskStatus.underReview:
        return 'Under Review';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
