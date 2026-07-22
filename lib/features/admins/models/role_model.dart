class Permission {
  final String id;
  final String action;
  final String resource;
  final String? description;

  Permission({
    required this.id,
    required this.action,
    required this.resource,
    this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      resource: json['resource'] ?? '',
      description: json['description'],
    );
  }
}

class Role {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final bool isSystem;
  final List<Permission> permissions;

  Role({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.isSystem,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    List<Permission> parsedPermissions = [];
    if (json['role_permissions'] != null && json['role_permissions'] is List) {
      for (var item in json['role_permissions']) {
        if (item['permissions'] != null) {
          parsedPermissions.add(Permission.fromJson(item['permissions']));
        }
      }
    }

    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? json['name'] ?? '',
      description: json['description'],
      isSystem: json['is_system'] ?? false,
      permissions: parsedPermissions,
    );
  }
}
