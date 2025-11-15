class AppUser {
  const AppUser({
    required this.userId,
    required this.username,
    this.email,
    this.profilePictureUrl,
    this.teamId,
  });

  final int userId;
  final String username;
  final String? email;
  final String? profilePictureUrl;
  final int? teamId;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: (json['userId'] ?? json['id']) as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      teamId: json['teamId'] as int?,
    );
  }
}
