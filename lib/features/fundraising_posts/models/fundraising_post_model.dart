class FundraisingPost {
  final String id;
  final String companyId;
  final String title;
  final String excerpt;
  final String content;
  final String roundType;
  final double targetAmountUsd;
  final double minTicketUsd;
  final String contactEmail;
  final String? pitchDeckUrl;
  final String? websiteUrl;
  final String? coverUrl;
  final DateTime deadline;
  final String slug;
  final String status;
  final String? adminFeedback;

  FundraisingPost({
    required this.id,
    required this.companyId,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.roundType,
    required this.targetAmountUsd,
    required this.minTicketUsd,
    required this.contactEmail,
    this.pitchDeckUrl,
    this.websiteUrl,
    this.coverUrl,
    required this.deadline,
    required this.slug,
    required this.status,
    this.adminFeedback,
  });

  factory FundraisingPost.fromJson(Map<String, dynamic> json) {
    return FundraisingPost(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? json['companyId'] ?? '',
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      content: json['content'] ?? '',
      roundType: json['round_type'] ?? json['roundType'] ?? '',
      targetAmountUsd: double.tryParse((json['target_amount_usd'] ?? json['targetAmountUsd'] ?? 0).toString()) ?? 0.0,
      minTicketUsd: double.tryParse((json['min_ticket_usd'] ?? json['minTicketUsd'] ?? 0).toString()) ?? 0.0,
      contactEmail: json['contact_email'] ?? json['contactEmail'] ?? '',
      pitchDeckUrl: json['pitch_deck_url'] ?? json['pitchDeckUrl'],
      websiteUrl: json['website_url'] ?? json['websiteUrl'],
      coverUrl: json['cover_url'] ?? json['coverUrl'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now(),
      slug: json['slug'] ?? '',
      status: json['status'] ?? 'Active',
      adminFeedback: json['admin_feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'roundType': roundType,
      'targetAmountUsd': targetAmountUsd,
      'minTicketUsd': minTicketUsd,
      'contactEmail': contactEmail,
      'pitchDeckUrl': pitchDeckUrl,
      'websiteUrl': websiteUrl,
      'coverUrl': coverUrl,
      'deadline': deadline.toIso8601String(),
      'slug': slug,
      'status': status,
      'admin_feedback': adminFeedback,
    };
  }
}
