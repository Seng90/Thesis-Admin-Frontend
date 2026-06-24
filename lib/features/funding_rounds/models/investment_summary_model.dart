import 'investment_model.dart';

class InvestmentSummary {
  final Map<String, dynamic> company;
  final Map<String, dynamic> round;
  final double totalRaised;
  final List<Investment> investments;

  InvestmentSummary({
    required this.company,
    required this.round,
    required this.totalRaised,
    required this.investments,
  });

  String get companyName => company['name'] ?? 'Unknown Company';
  String get companyId => company['id'] ?? '';
  String get roundName => round['round_name'] ?? round['name'] ?? 'Unknown Round';
  String get roundId => round['id'] ?? '';
  String get companyIndustry => company['industry'] ?? '';
  String get companyLogoUrl => company['logo_url'] ?? '';

  /// The primary currency used across investments in this group
  String get currency {
    if (investments.isEmpty) return 'USD';
    return investments.first.currency;
  }

  /// The earliest invest date in this group
  DateTime? get earliestDate {
    if (investments.isEmpty) return null;
    return investments.map((i) => i.investDate).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Number of unique investors (including "Others")
  int get investorCount => investments.length;

  factory InvestmentSummary.fromJson(Map<String, dynamic> json) {
    final investmentsData = json['investments'] as List<dynamic>? ?? [];
    return InvestmentSummary(
      company: Map<String, dynamic>.from(json['company'] ?? {}),
      round: Map<String, dynamic>.from(json['round'] ?? {}),
      totalRaised: double.tryParse(json['total_raised'].toString()) ?? 0,
      investments: investmentsData.map((e) => Investment.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
