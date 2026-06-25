class MemberLog {
  final String id;
  final String? adminId;
  final String? memberId;
  final String action;
  final DateTime createdAt;
  final LogAdmin? admin;
  final LogMember? member;

  MemberLog({
    required this.id,
    this.adminId,
    this.memberId,
    required this.action,
    required this.createdAt,
    this.admin,
    this.member,
  });

  factory MemberLog.fromJson(Map<String, dynamic> json) {
    return MemberLog(
      id: json['id'] ?? '',
      adminId: json['admin_id'],
      memberId: json['member_id'],
      action: json['action'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      admin: json['admins'] != null ? LogAdmin.fromJson(json['admins']) : null,
      member: json['members'] != null
          ? LogMember.fromJson(json['members'])
          : null,
    );
  }
}

class LogAdmin {
  final String id;
  final String username;
  final String role;

  LogAdmin({required this.id, required this.username, required this.role});

  factory LogAdmin.fromJson(Map<String, dynamic> json) {
    return LogAdmin(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class LogMember {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? avatarUrl;

  LogMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory LogMember.fromJson(Map<String, dynamic> json) {
    return LogMember(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }
}
