class Package {
  final String id;
  final String name;
  final double price;
  final String features;
  final int? durationDays;
  final int purchaseCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Package({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    this.durationDays,
    required this.purchaseCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      features: json['features'] ?? '',
      durationDays: json['duration_days'],
      purchaseCount: json['purchase_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'features': features,
      'duration_days': durationDays,
      'purchase_count': purchaseCount,
    };
  }
}
