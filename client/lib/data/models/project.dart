import 'package:intl/intl.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  String get timelineLabel {
    final formatter = DateFormat('MMM d, yyyy');
    final start = startDate != null ? formatter.format(startDate!) : 'TBD';
    final end = endDate != null ? formatter.format(endDate!) : 'TBD';
    return '$start - $end';
  }

  bool get isCompleted => endDate != null && endDate!.isBefore(DateTime.now());
}
