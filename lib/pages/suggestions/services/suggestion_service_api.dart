// lib/pages/suggestions/services/suggestion_service_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/suggestion_model.dart';
import '../../../pages/vehicle/providers/vehicle_provider.dart';

class SuggestionService {
  // 1) Generate manufacturer-style maintenance intervals:
  List<Suggestion> generateDefaults(Vehicle v) {
    final current = v.currentMileage;
    final nextOil = ((current ~/ 5000) + 1) * 5000;
    final nextRotate = ((current ~/ 6000) + 1) * 6000;
    return [
      Suggestion(
        vehicleId: v.id,
        title: 'Oil Change',
        description: 'Replace engine oil & filter',
        recommendedMileage: nextOil,
      ),
      Suggestion(
        vehicleId: v.id,
        title: 'Tire Rotation',
        description: 'Rotate tires to even out wear',
        recommendedMileage: nextRotate,
      ),
      Suggestion(
        vehicleId: v.id,
        title: 'Washer Fluid Check',
        description: 'Top off windshield washer fluid',
        recommendedDate: DateTime.now().add(Duration(days:30)),
      ),
    ];
  }

  // 2) Fetch recalls/issues from NHTSA
  Future<List<Map<String, dynamic>>> fetchRecalls(String make, String model, String year) async {
    final uri = Uri.parse(
        'https://api.nhtsa.gov/Recalls/recallsByVehicle?make=$make&model=$model&year=$year'
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to load recalls');
    final data = json.decode(res.body)['results'] as List;
    return data.cast<Map<String, dynamic>>();
  }
}
