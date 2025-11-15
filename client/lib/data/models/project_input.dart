class ProjectInput {
  ProjectInput({
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
  });

  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}
