// lib/pages/suggestions/providers/suggestion_provider.dart
import 'package:flutter/material.dart';
import '../models/suggestion_model.dart';
import '../services/suggestion_service_api.dart';
import '../../../database/database_helper.dart';
import '../../../pages/vehicle/providers/vehicle_provider.dart';

class SuggestionProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  final _svc = SuggestionService();

  List<Suggestion> _suggestions = [];
  List<Map<String,dynamic>> _recalls = [];
  bool loading = false;

  List<Suggestion> get suggestions => _suggestions;
  List<Map<String,dynamic>> get recalls => _recalls;

  Future<void> loadForVehicle(Vehicle v) async {
    loading = true;
    notifyListeners();

    // 1) Load existing from DB
    _suggestions = await _db.getSuggestionsForVehicle(v.id);

    // 2) If none, generate defaults & insert
    if (_suggestions.isEmpty) {
      final defaults = _svc.generateDefaults(v);
      for (var s in defaults) {
        final id = await _db.insertSuggestion(s);
        _suggestions.add(s.copyWith(id: id));
      }
    }

    // 3) Fetch recalls/issues
    _recalls = await _svc.fetchRecalls(v.make, v.model, v.year);
    loading = false;
    notifyListeners();
  }

  Future<void> toggleComplete(Suggestion s) async {
    final updated = s.copyWith(
      completed: !s.completed,
      completionDate: s.completed ? null : DateTime.now(),
    );
    await _db.updateSuggestion(updated);
    final idx = _suggestions.indexWhere((e) => e.id == s.id);
    _suggestions[idx] = updated;
    notifyListeners();
  }
}
