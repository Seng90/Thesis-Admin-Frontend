class DashboardSummary {
  final int newCompaniesThisMonth;
  final int companiesAwaitingReview;
  final int revisionsAwaitingReview;
  final double totalFundingYTD;
  final double fundingChangePct;
  final int totalInvestors;
  final int totalCompanies;
  final int totalMembers;
  final int newMembersThisMonth;
  final double monthlySubscriptionRevenue;

  DashboardSummary({
    required this.newCompaniesThisMonth,
    required this.companiesAwaitingReview,
    required this.revisionsAwaitingReview,
    required this.totalFundingYTD,
    required this.fundingChangePct,
    required this.totalInvestors,
    required this.totalCompanies,
    required this.totalMembers,
    required this.newMembersThisMonth,
    required this.monthlySubscriptionRevenue,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      newCompaniesThisMonth: json['newCompaniesThisMonth'] ?? 0,
      companiesAwaitingReview: json['pendingCompanyApprovals'] ?? 0,
      revisionsAwaitingReview: json['pendingRevisionApprovals'] ?? 0,
      totalFundingYTD: (json['totalInvestmentsVolume'] ?? 0).toDouble(),
      fundingChangePct: 0.0, // Needs API support in the future
      totalInvestors: json['totalInvestors'] ?? 0,
      totalCompanies: json['totalCompanies'] ?? 0,
      totalMembers: json['totalMembers'] ?? 0,
      newMembersThisMonth: json['newMembersThisMonth'] ?? 0,
      monthlySubscriptionRevenue: (json['monthlySubscriptionRevenue'] ?? 0)
          .toDouble(),
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
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0)
          .toDouble(),
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
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}

class TopStartup {
  final String id;
  final String name;
  final String industry;
  final int viewCount;

  TopStartup({
    required this.id,
    required this.name,
    required this.industry,
    required this.viewCount,
  });

  factory TopStartup.fromJson(Map<String, dynamic> json) {
    return TopStartup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      industry: json['industry'] ?? '',
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
    );
  }
}

class PopularPackage {
  final String id;
  final String name;
  final num price;
  final int purchaseCount;

  PopularPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.purchaseCount,
  });

  factory PopularPackage.fromJson(Map<String, dynamic> json) {
    return PopularPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      purchaseCount: json['purchase_count'] ?? json['purchaseCount'] ?? 0,
    );
  }
}
