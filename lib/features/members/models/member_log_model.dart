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
      adminId: json['admin_id'] ?? json['performed_by']?['id'],
      memberId: json['member_id'] ?? json['target_user']?['id'],
      action: json['action'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      admin: json['performed_by'] != null
          ? LogAdmin.fromJson(json['performed_by'])
          : (json['admins'] != null ? LogAdmin.fromJson(json['admins']) : null),
      member: json['target_user'] != null
          ? LogMember.fromJson(json['target_user'])
          : (json['members'] != null ? LogMember.fromJson(json['members']) : null),
    );
  }
}

class LogAdmin {
  final String id;
  final String username;
  final String role;

  LogAdmin({required this.id, required this.username, required this.role});

  factory LogAdmin.fromJson(Map<String, dynamic> json) {
    String roleStr = '';
    if (json['user_roles'] != null && json['user_roles'] is List) {
      final rolesList = (json['user_roles'] as List)
          .map((ur) => ur['roles']?['name'] ?? '')
          .where((r) => r.toString().isNotEmpty)
          .toList();
      roleStr = rolesList.join(', ');
    } else if (json['role'] != null) {
      roleStr = json['role'];
    }
    
    // Fallback if role is empty but it was an admin
    if (roleStr.isEmpty) {
      roleStr = 'Admin';
    }

    return LogAdmin(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      role: roleStr,
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
    String roleStr = '';
    if (json['user_roles'] != null && json['user_roles'] is List) {
      final rolesList = (json['user_roles'] as List)
          .map((ur) => ur['roles']?['name'] ?? '')
          .where((r) => r.toString().isNotEmpty)
          .toList();
      roleStr = rolesList.join(', ');
    } else if (json['role'] != null) {
      roleStr = json['role'];
    }

    return LogMember(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: roleStr,
      avatarUrl: json['avatar_url'],
    );
  }
}
