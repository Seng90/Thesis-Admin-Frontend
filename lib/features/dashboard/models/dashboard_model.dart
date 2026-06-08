class DashboardSummary {
  final int newCompaniesThisMonth;
  final int companiesAwaitingReview;
  final int revisionsAwaitingReview;
  final double totalFundingYTD;
  final double fundingChangePct;

  DashboardSummary({
    required this.newCompaniesThisMonth,
    required this.companiesAwaitingReview,
    required this.revisionsAwaitingReview,
    required this.totalFundingYTD,
    required this.fundingChangePct,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      newCompaniesThisMonth: json['new_companies_this_month'] ?? 0,
      companiesAwaitingReview: json['companies_awaiting_review'] ?? 0,
      revisionsAwaitingReview: json['revisions_awaiting_review'] ?? 0,
      totalFundingYTD: (json['total_funding_ytd'] ?? 0).toDouble(),
      fundingChangePct: (json['funding_change_pct'] ?? 0).toDouble(),
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
