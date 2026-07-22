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
    // Helper function to safely parse numeric values from strings
    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      final str = value.toString();
      final parsed = num.tryParse(str);
      return parsed ?? 0;
    }

    return DashboardSummary(
      newCompaniesThisMonth: parseNum(json['newCompaniesThisMonth']).toInt(),
      companiesAwaitingReview: parseNum(json['pendingCompanyApprovals']).toInt(),
      revisionsAwaitingReview: parseNum(json['pendingRevisionApprovals']).toInt(),
      totalFundingYTD: parseNum(json['totalInvestmentsVolume']).toDouble(),
      fundingChangePct: 0.0, // Needs API support in the future
      totalInvestors: parseNum(json['totalInvestors']).toInt(),
      totalCompanies: parseNum(json['totalCompanies']).toInt(),
      totalMembers: parseNum(json['totalMembers']).toInt(),
      newMembersThisMonth: parseNum(json['newMembersThisMonth']).toInt(),
      monthlySubscriptionRevenue:
          parseNum(json['monthlySubscriptionRevenue']).toDouble(),
    );
  }
}

class SectorStat {
  final String industry;
  final int count;

  SectorStat({required this.industry, required this.count});

  factory SectorStat.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int from potential string
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      final str = value.toString();
      final parsed = int.tryParse(str);
      return parsed ?? 0;
    }

    return SectorStat(
      industry: json['industry'] ?? 'Other',
      count: parseInt(json['count']),
    );
  }
}

class FundingHistoryItem {
  final String date;
  final double totalAmount;

  FundingHistoryItem({required this.date, required this.totalAmount});

  factory FundingHistoryItem.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse double from potential string
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      final str = value.toString();
      final parsed = double.tryParse(str);
      return parsed ?? 0.0;
    }

    return FundingHistoryItem(
      date: json['date'] ?? '',
      totalAmount: parseDouble(json['totalAmount'] ?? json['total_amount']),
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
  final String? logoUrl;

  TopStartup({
    required this.id,
    required this.name,
    required this.industry,
    required this.viewCount,
    this.logoUrl,
  });

  factory TopStartup.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int from potential string
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      final str = value.toString();
      final parsed = int.tryParse(str);
      return parsed ?? 0;
    }

    return TopStartup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      industry: json['industry'] ?? '',
      viewCount: parseInt(json['view_count'] ?? json['viewCount']),
      logoUrl: json['logo_url'] ?? json['logoUrl'],
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
    // Helper to safely parse num from potential string (Decimal fields from PostgreSQL)
    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      final str = value.toString();
      final parsed = num.tryParse(str);
      return parsed ?? 0;
    }

    // Helper to safely parse int from potential string
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      final str = value.toString();
      final parsed = int.tryParse(str);
      return parsed ?? 0;
    }

    return PopularPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: parseNum(json['price']), // ← CRITICAL FIX for Decimal → num conversion
      purchaseCount: parseInt(json['purchase_count'] ?? json['purchaseCount']),
    );
  }
}
