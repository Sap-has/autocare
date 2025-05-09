class ServiceRecord {
  final String id;
  final String serviceName;
  final DateTime completedAt;
  final double price;
  final String? location;

  ServiceRecord({
    required this.id,
    required this.serviceName,
    required this.completedAt,
    required this.price,
    this.location,
  });

  factory ServiceRecord.fromJson(String id, Map<String, dynamic> json) {
    return ServiceRecord(
      id: id,
      serviceName: json['serviceName'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'serviceName': serviceName,
    'completedAt': completedAt.toIso8601String(),
    'price': price,
    'location': location,
  };
}