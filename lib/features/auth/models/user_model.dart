class UserModel {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final List<String> permissions;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    required this.permissions,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'roles': roles,
      'permissions': permissions,
      'avatar_url': avatarUrl,
    };
  }
}
