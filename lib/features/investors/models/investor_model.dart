class Investor {
  final String id;
  final String name;
  final String type;
  final String? logoUrl;
  final String? websiteUrl;
  final String? contactInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? investmentFocus;
  final List<String>? preferredStages;
  final List<String>? preferredIndustries;

  Investor({
    required this.id,
    required this.name,
    required this.type,
    this.logoUrl,
    this.websiteUrl,
    this.contactInfo,
    this.createdAt,
    this.updatedAt,
    this.investmentFocus,
    this.preferredStages,
    this.preferredIndustries,
  });

  factory Investor.fromJson(Map<String, dynamic> json) {
    return Investor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      logoUrl: json['logo_url'],
      websiteUrl: json['website_url'],
      contactInfo: json['contact_info'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      investmentFocus: json['investment_focus'],
      preferredStages: json['preferred_stages'] != null
          ? List<String>.from(json['preferred_stages'])
          : null,
      preferredIndustries: json['preferred_industries'] != null
          ? List<String>.from(json['preferred_industries'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'contact_info': contactInfo,
      'investment_focus': investmentFocus,
      'preferred_stages': preferredStages,
      'preferred_industries': preferredIndustries,
    };
  }
}
