class Founder {
  final String id;
  final String name;
  final String? bio;
  final String? linkedinUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Founder({
    required this.id,
    required this.name,
    this.bio,
    this.linkedinUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Founder.fromJson(Map<String, dynamic> json) {
    return Founder(
      id: json['id'],
      name: json['name'],
      bio: json['bio'],
      linkedinUrl: json['linkedin_url'] ?? json['linkedinUrl'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'linkedin_url': linkedinUrl,
    };
  }
}
