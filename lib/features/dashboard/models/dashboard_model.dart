class DashboardSummary {
  final int newCompaniesThisMonth;
  final int companiesAwaitingReview;
  final int revisionsAwaitingReview;
  final double totalFundingYTD;
  final double fundingChangePct;
  final int totalInvestors;

  DashboardSummary({
    required this.newCompaniesThisMonth,
    required this.companiesAwaitingReview,
    required this.revisionsAwaitingReview,
    required this.totalFundingYTD,
    required this.fundingChangePct,
    required this.totalInvestors,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      newCompaniesThisMonth: json['newCompaniesThisMonth'] ?? 0,
      companiesAwaitingReview: json['pendingCompanyApprovals'] ?? 0,
      revisionsAwaitingReview: json['pendingRevisionApprovals'] ?? 0,
      totalFundingYTD: (json['totalInvestmentsVolume'] ?? 0).toDouble(),
      fundingChangePct: 0.0, // Needs API support in the future
      totalInvestors: json['totalInvestors'] ?? 0,
    );
  }
}

class SectorStat {
  final String industry;
  final int count;

  SectorStat({required this.industry, required this.count});

  factory SectorStat.fromJson(Map<String, dynamic> json) {
    return SectorStat(
      industry: json['industry'] ?? 'Other',
      count: json['count'] ?? 0,
    );
  }
}

class FundingHistoryItem {
  final String date;
  final double totalAmount;

  FundingHistoryItem({required this.date, required this.totalAmount});

  factory FundingHistoryItem.fromJson(Map<String, dynamic> json) {
    return FundingHistoryItem(
      date: json['date'] ?? '',
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
    );
  }
}

class RecentCompany {
  final String id;
  final String name;
  final String industry;
  final String? logoUrl;
  final DateTime? updatedAt;

  RecentCompany({
    required this.id,
    required this.name,
    required this.industry,
    this.logoUrl,
    this.updatedAt,
  });

  factory RecentCompany.fromJson(Map<String, dynamic> json) {
    return RecentCompany(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      industry: json['industry'] ?? '',
      logoUrl: json['logo_url'] ?? json['logoUrl'],
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}
