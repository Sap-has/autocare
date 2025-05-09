import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/suggestion.dart';

class MaintenanceService {
  /// Load your static schedule JSON (if you have other intervals)
  static Future<List<MaintenanceInterval>> loadSchedule(
      String make, String model, String year) async {
    final raw = await rootBundle.loadString('assets/data/maintenance_schedule.json');
    final doc = json.decode(raw) as Map<String,dynamic>;
    final key = '$make|$model|$year';
    final list = (doc[key] as List<dynamic>?) ?? [];
    return list
        .map((j) => MaintenanceInterval.fromJson(j))
        .toList();
  }

  /// Always‐due oil change at 3 000 mi or 3 months
  static Suggestion oilChangeSuggestion({
    required int lastOdometer,
    required DateTime lastDate,
  }) {
    final dueMileage = lastOdometer + 3000;
    final dueDate    = lastDate.add(Duration(days: 90));
    return Suggestion(
      serviceName: 'Oil Change',
      dueMileage: dueMileage,
      dueDate: dueDate,
      description: 'Recommended every 3 000 mi or 3 months',
    );
  }
}

/// Helper for non-oil intervals you still keep in JSON
class MaintenanceInterval {
  final String service;
  final int intervalMiles;
  final String? description;
  MaintenanceInterval({
    required this.service,
    required this.intervalMiles,
    this.description,
  });
  factory MaintenanceInterval.fromJson(Map<String,dynamic> j) => MaintenanceInterval(
    service: j['service'],
    intervalMiles: j['intervalMiles'],
    description: j['description'],
  );
}
