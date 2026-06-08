class Investment {
  final String id;
  final String companyId;
  final String investorId;
  final String roundId;
  final double amount;
  final String currency;
  final DateTime investDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    required this.id,
    required this.companyId,
    required this.investorId,
    required this.roundId,
    required this.amount,
    required this.currency,
    required this.investDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      companyId: json['company_id'] ?? json['companyId'],
      investorId: json['investor_id'] ?? json['investorId'],
      roundId: json['round_id'] ?? json['roundId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      currency: json['currency'] ?? 'USD',
      investDate: DateTime.parse(json['invest_date'] ?? json['investDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'investor_id': investorId,
      'round_id': roundId,
      'amount': amount,
      'currency': currency,
      'invest_date': investDate.toIso8601String(),
    };
  }
}
