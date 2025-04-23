import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

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
  final List<Vehicle> _vehicles = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoaded = false;

  List<Vehicle> get vehicles => _vehicles;

  // Constructor loads data from database
  VehicleProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

  // Load vehicles from the database
  Future<void> _loadVehicles() async {
    if (_isLoaded) return;

    final vehicles = await _dbHelper.getVehicles();
    _vehicles.clear();
    _vehicles.addAll(vehicles);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    // Add to database first
    await _dbHelper.insertVehicle(vehicle, vehicle.specs);

    // Then add to in-memory list
    _vehicles.add(vehicle);
    notifyListeners();
  }

  Future<void> removeVehicle(int id) async {
    // Remove from database
    await _dbHelper.deleteVehicle(id);

    // Remove from in-memory list
    _vehicles.removeWhere((vehicle) => vehicle.id == id);
    notifyListeners();
  }

  // New method to add a mileage record to a vehicle
  Future<void> addMileageRecord(int vehicleId, MileageRecord record) async {
    // Add to database
    await _dbHelper.insertMileageRecord(vehicleId, record);

    // Update in-memory list
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index >= 0) {
      final vehicle = _vehicles[index];
      final updatedRecords = List<MileageRecord>.from(vehicle.mileageRecords)..add(record);

      // Replace the vehicle with an updated copy
      _vehicles[index] = vehicle.copyWith(mileageRecords: updatedRecords);
      notifyListeners();
    }
  }

  Vehicle? getVehicleById(int id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}