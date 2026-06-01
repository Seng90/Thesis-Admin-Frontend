class Company {
  final String id;
  final String name;
  final String description;
  final String industry;
  final String location;
  final String contactEmail;
  final DateTime? foundedDate;
  final String status;
  final int viewCount;
  final String? logoUrl;
  final String? websiteUrl;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.location,
    required this.contactEmail,
    this.foundedDate,
    required this.status,
    required this.viewCount,
    this.logoUrl,
    this.websiteUrl,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      industry: json['industry'] ?? '',
      location: json['location'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      foundedDate: json['founded_date'] != null ? DateTime.tryParse(json['founded_date'].toString()) : null,
      status: json['status'] ?? 'Pending',
      viewCount: json['view_count'] ?? 0,
      logoUrl: json['logo_url'],
      websiteUrl: json['website_url'],
      approvedBy: json['approved_by'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'industry': industry,
      'location': location,
      'contact_email': contactEmail,
      'founded_date': foundedDate?.toIso8601String(),
      'status': status,
      'view_count': viewCount,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'approved_by': approvedBy,
    };
  }
}
