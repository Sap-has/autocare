// lib/pages/suggestions/models/suggestion_model.dart
class Suggestion {
  final int? id;
  final int vehicleId;
  final String title;
  final String description;
  final int? recommendedMileage;      // e.g. next oil change at X miles
  final DateTime? recommendedDate;    // e.g. fluid check in 30 days
  final bool completed;
  final DateTime? completionDate;

  Suggestion({
    this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    this.recommendedMileage,
    this.recommendedDate,
    this.completed = false,
    this.completionDate,
  });

  // Add copyWith method
  Suggestion copyWith({
    int? id,
    int? vehicleId,
    String? title,
    String? description,
    int? recommendedMileage,
    DateTime? recommendedDate,
    bool? completed,
    DateTime? completionDate,
  }) {
    return Suggestion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendedMileage: recommendedMileage ?? this.recommendedMileage,
      recommendedDate: recommendedDate ?? this.recommendedDate,
      completed: completed ?? this.completed,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'vehicleId': vehicleId,
    'title': title,
    'description': description,
    'recommendedMileage': recommendedMileage,
    'recommendedDate': recommendedDate?.toIso8601String(),
    'completed': completed ? 1 : 0,
    'completionDate': completionDate?.toIso8601String(),
  };

  factory Suggestion.fromMap(Map<String, dynamic> m) => Suggestion(
    id: m['id'] as int?,
    vehicleId: m['vehicleId'] as int,
    title: m['title'] as String,
    description: m['description'] as String,
    recommendedMileage: m['recommendedMileage'] as int?,
    recommendedDate: m['recommendedDate'] != null
        ? DateTime.parse(m['recommendedDate'])
        : null,
    completed: (m['completed'] as int) == 1,
    completionDate: m['completionDate'] != null
        ? DateTime.parse(m['completionDate'])
        : null,
  );
}