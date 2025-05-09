// lib/pages/suggestion/models/suggestion.dart

class Suggestion {
  final String serviceName;
  final int    dueMileage;
  final DateTime? dueDate;
  final String?   description;

  Suggestion({
    required this.serviceName,
    required this.dueMileage,
    this.dueDate,
    this.description,
  });
}
