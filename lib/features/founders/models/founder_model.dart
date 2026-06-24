class Founder {
  final String id;
  final String nameEn;
  final String nameLa;
  final String? role;
  final String? bio;
  final String? linkedinUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? skills;
  final String? pastExperience;
  final String? twitterUrl;
  final String? githubUrl;

  Founder({
    required this.id,
    required this.nameEn,
    required this.nameLa,
    this.role,
    this.bio,
    this.linkedinUrl,
    required this.createdAt,
    required this.updatedAt,
    this.skills,
    this.pastExperience,
    this.twitterUrl,
    this.githubUrl,
  });

  factory Founder.fromJson(Map<String, dynamic> json) {
    return Founder(
      id: json['id'],
      nameEn: json['name_en'] ?? json['nameEn'] ?? '',
      nameLa: json['name_la'] ?? json['nameLa'] ?? '',
      role: json['role'],
      bio: json['bio'],
      linkedinUrl: json['linkedin_url'] ?? json['linkedinUrl'],
      createdAt: DateTime.parse(
        json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ??
            json['updatedAt'] ??
            DateTime.now().toIso8601String(),
      ),
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      pastExperience: json['past_experience'] ?? json['pastExperience'],
      twitterUrl: json['twitter_url'] ?? json['twitterUrl'],
      githubUrl: json['github_url'] ?? json['githubUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_la': nameLa,
      'role': role,
      'bio': bio,
      'linkedin_url': linkedinUrl,
      'skills': skills,
      'past_experience': pastExperience,
      'twitter_url': twitterUrl,
      'github_url': githubUrl,
    };
  }
}
