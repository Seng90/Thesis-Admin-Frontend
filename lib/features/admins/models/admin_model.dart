class Admin {
  final String id;
  final String username;
  final String email;
  final String status;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Admin({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    String parsedRole = 'admin';
    if (json['user_roles'] != null && (json['user_roles'] as List).isNotEmpty) {
      parsedRole = json['user_roles'][0]['roles']['name'] ?? 'admin';
    } else if (json['role'] != null) {
      parsedRole = json['role'];
    }

    return Admin(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'Active',
      role: parsedRole,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'status': status,
      'role': role,
    };
  }
}
