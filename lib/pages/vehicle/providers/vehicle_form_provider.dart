import 'package:flutter/material.dart';
import '../services/car_service_api.dart';

class VehicleFormProvider extends ChangeNotifier {
  final CarApiService api = CarApiService();

  // Dropdown data
  List<int> years = [];
  List<String> makes = [];
  List<String> models = [];
  List<String> trims = [];
  List<Map<String, dynamic>> trimsRaw = [];

  // User selections
  int? selectedYear;
  String? selectedMake;
  String? selectedModel;
  String? selectedTrim;
  int? selectedTrimId;

  // Loaded verbose specs
  Map<String, dynamic>? fullSpecs;

  // Loading flag
  bool loading = false;

  VehicleFormProvider() {
    loadYears();
  }

  void loadYears() {
    years = api.fetchYears();
    notifyListeners();
  }

  Future<void> selectYear(int year) async {
    selectedYear = year;
    selectedMake = null;
    selectedModel = null;
    selectedTrim = null;
    fullSpecs = null;
    List<String> rawMakes = await api.fetchMakes(year);
    makes = rawMakes.toSet().toList()..sort();

    models = [];
    trims = [];
    trimsRaw = [];
    notifyListeners();
  }

  Future<void> selectMake(String make) async {
    if (selectedYear == null) return;
    selectedMake = make;
    selectedModel = null;
    selectedTrim = null;
    fullSpecs = null;

    List<String> rawModels = await api.fetchModels(selectedYear!, make);
    models = rawModels.toSet().toList()..sort();

    trims = [];
    trimsRaw = [];
    notifyListeners();
  }

  Future<void> selectModel(String model) async {
    if (selectedYear == null || selectedMake == null) return;
    selectedModel = model;
    selectedTrim = null;
    fullSpecs = null;
    trimsRaw = await api.fetchTrimsRaw(selectedYear!, selectedMake!, model);

    Set<String> trimSet = {};
    trims = [];
    for (var trim in trimsRaw) {
      String name = trim['name'] as String;
      if (!trimSet.contains(name)) {
        trimSet.add(name);
        trims.add(name);
      }
    }
    trims.sort();

    notifyListeners();
  }

  void selectTrim(String trim) {
    selectedTrim = trim;
    // Store trimId for later fetch
    selectedTrimId = trimsRaw.firstWhere((e) => e['name'] == trim)['id'] as int;
    fullSpecs = null;
    notifyListeners();
  }

  /// Fetch verbose specs for a given trim ID and store in `fullSpecs`.
  Future<void> loadSpecsFor(int trimId) async {
    loading = true;
    notifyListeners();
    fullSpecs = await api.fetchTrimVerbose(trimId);
    loading = false;
    notifyListeners();
  }

}