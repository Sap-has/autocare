import 'package:flutter/material.dart';
import '../../../database/firestore_helper.dart';

class Vehicle {
  final int id;
  final int trimId;
  final String year;
  final String make;
  final String model;
  final String trim;
  final Map<String, dynamic> specs;

  // New fields for mileage tracking
  final List<MileageRecord> mileageRecords;

  Vehicle({
    required this.id,
    required this.trimId,
    required this.year,
    required this.make,
    required this.model,
    required this.trim,
    required this.specs,
    this.mileageRecords = const [],
  });

  // Create a copy with new mileage records
  Vehicle copyWith({List<MileageRecord>? mileageRecords}) {
    return Vehicle(
      id: id,
      trimId: trimId,
      year: year,
      make: make,
      model: model,
      trim: trim,
      specs: specs,
      mileageRecords: mileageRecords ?? this.mileageRecords,
    );
  }

  // Helper to get current mileage (most recent record)
  int get currentMileage {
    if (mileageRecords.isEmpty) return 0;

    // Sort by date and return the most recent
    final sortedRecords = List<MileageRecord>.from(mileageRecords)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedRecords.first.odometer;
  }
}

// New class to track mileage records
class MileageRecord {
  final DateTime date;
  final int odometer;
  final String? notes;

  MileageRecord({
    required this.date,
    required this.odometer,
    this.notes,
  });
}

class VehicleProvider extends ChangeNotifier {
  final FirestoreHelper _fs = FirestoreHelper();
  List<Vehicle> vehicles = [];
  final Map<int, List<MileageRecord>> _records = {};

  bool isLoaded = false;

  VehicleProvider() {
    // Listen for vehicles
    _fs.watchVehicles().listen((list) {
      vehicles = list;
      isLoaded = true;
      notifyListeners();
      // For each vehicle, start listening to its records:
      for (var v in vehicles) {
        if (!_records.containsKey(v.id)) {
          _fs.watchMileageRecords(v.id).listen((recs) {
            _records[v.id] = recs;
            notifyListeners();
          });
        }
      }
    });
  }

  Future<void> addVehicle(Vehicle v) {
    return _fs.insertVehicle(v);
  }

  Future<void> deleteVehicle(int vehicleId) {
    return _fs.deleteVehicle(vehicleId);
  }

  Future<void> addMileageRecord(int vehicleId, MileageRecord r) {
    return _fs.insertMileageRecord(vehicleId, r);
  }

  Vehicle? getVehicleById(int id) {
    final idx = vehicles.indexWhere((v) => v.id == id);
    if (idx == -1) return null;                      // no vehicle found
    final vehicle = vehicles[idx];
    final recs    = _records[id] ?? [];
    return vehicle.copyWith(mileageRecords: recs);
  }

}