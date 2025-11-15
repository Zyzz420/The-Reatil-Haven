class Team {
  const Team({
    required this.id,
    required this.teamName,
    this.productOwnerUsername,
    this.projectManagerUsername,
  });

  final int id;
  final String teamName;
  final String? productOwnerUsername;
  final String? projectManagerUsername;

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      teamName: json['teamName'] as String,
      productOwnerUsername: json['productOwnerUsername'] as String?,
      projectManagerUsername: json['projectManagerUsername'] as String?,
    );
  }
}
