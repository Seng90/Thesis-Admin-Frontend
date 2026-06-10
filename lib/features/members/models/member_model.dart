class Member {
  final String id;
  final String username;
  final String email;
  final String status;
  final String? packageId;
  final String? avatarUrl;
  final String role;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Member({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    this.packageId,
    this.avatarUrl,
    required this.role,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'Active',
      packageId: json['package_id'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'status': status,
      'package_id': packageId,
      'avatar_url': avatarUrl,
      'role': role,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}
