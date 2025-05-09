// lib/pages/suggestion/providers/suggestion_provider.dart

import 'package:flutter/material.dart';
import '../../../database/firestore_helper.dart';
import '../../vehicle/providers/vehicle_provider.dart';
import '../models/suggestion.dart';
import '../services/maintenance_service.dart';
import '../services/repairpal_service.dart';
import '../services/carcomplaints_service.dart';

class SuggestionProvider extends ChangeNotifier {
  final _db = FirestoreHelper();
  List<Vehicle> vehicles = [];
  List<MileageRecord> records = [];
  List<Suggestion> suggestions = [];
  Vehicle? selected;

  bool isLoadingIssues = false;
  List<RepairIssue> rpIssues = [];
  List<CarComplaintsIssue> ccIssues = [];

  SuggestionProvider() {
    _db.watchVehicles().listen((v) {
      vehicles = v;
      notifyListeners();
    });
  }

  void selectVehicle(Vehicle? v) {
    if (v == null) return;
    selected = v;

    _compute();
    _db.watchMileageRecords(v.id).listen((recs) {
      records = recs;
      _compute();
    });
    notifyListeners();
  }

  Future<void> _compute() async {
    if (selected == null) return;

    rpIssues = [];
    ccIssues = [];
    isLoadingIssues = true;
    notifyListeners();

    final v = selected!;

    final schedule = await MaintenanceService.loadSchedule(
      v.make, v.model, v.year.toString(),
    );
    final oilRecs = records.where((r) =>
    r.notes?.toLowerCase().contains('oil') == true);
    suggestions = oilRecs.isNotEmpty
        ? [ MaintenanceService.oilChangeSuggestion(
      lastOdometer: oilRecs.first.odometer,
      lastDate:     oilRecs.first.date,
    ) ]
        : [];
    suggestions.addAll(schedule.map((interval) => Suggestion(
      serviceName: interval.service,
      dueMileage:  interval.intervalMiles,
      dueDate:     null,
      description: interval.description,
    )));

    try {
      rpIssues = await RepairPalService.fetchCarIssuesDetailed(
        make:  v.make,
        model: v.model,
        year:  v.year.toString(),
      );
      ccIssues = await CarComplaintsService.fetchIssues(
        make:  v.make,
        model: v.model,
        year:  v.year.toString(),
      );
    } catch (e) {
      print('issue-scrape error: $e');
    } finally {
      isLoadingIssues = false;
      notifyListeners();
    }
  }
}
