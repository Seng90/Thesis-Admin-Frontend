class Investment {
  final String id;
  final String companyId;
  final String? investorId;
  final String? customInvestorName;
  final String roundId;
  final double amount;
  final String currency;
  final String status;
  final String? referenceUrl;
  final DateTime investDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final String? companyName;
  final String? investorName;
  final String? roundName;

  Investment({
    required this.id,
    required this.companyId,
    this.investorId,
    this.customInvestorName,
    required this.roundId,
    required this.amount,
    required this.currency,
    this.status = 'Pending',
    this.referenceUrl,
    required this.investDate,
    required this.createdAt,
    required this.updatedAt,
    this.companyName,
    this.investorName,
    this.roundName,
  });

  /// Display name for the investor: uses the registered investor name,
  /// falls back to the custom name, then to "Others".
  String get investorDisplayName {
    if (investorName != null && investorName!.isNotEmpty) return investorName!;
    if (customInvestorName != null && customInvestorName!.isNotEmpty) return customInvestorName!;
    return 'Others';
  }

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      companyId: json['company_id'] ?? json['companyId'] ?? '',
      investorId: json['investor_id'] ?? json['investorId'],
      customInvestorName: json['custom_investor_name'] ?? json['customInvestorName'],
      roundId: json['round_id'] ?? json['roundId'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'Pending',
      referenceUrl: json['reference_url'] ?? json['referenceUrl'],
      investDate: DateTime.parse(json['invest_date'] ?? json['investDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
      companyName: json['companies']?['name'],
      investorName: json['investors']?['name'],
      roundName: json['funding_rounds']?['round_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'investor_id': investorId,
      'custom_investor_name': customInvestorName,
      'round_id': roundId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'reference_url': referenceUrl,
      'invest_date': investDate.toIso8601String(),
    };
  }
}
