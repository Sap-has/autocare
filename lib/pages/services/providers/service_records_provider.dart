// lib/pages/services/providers/service_records_provider.dart
import 'package:flutter/material.dart';
import '../../../database/firestore_helper.dart';
import '../models/service_record.dart';
import '../../vehicle/providers/vehicle_provider.dart';

class ServiceRecordsProvider extends ChangeNotifier {
  final FirestoreHelper _db;
  List<Vehicle> vehicles = [];
  Vehicle? selected;
  List<ServiceRecord> records = [];

  ServiceRecordsProvider(this._db) {
    _db.watchVehicles().listen((v) {
      vehicles = v;
      notifyListeners();
    });
  }

  void selectVehicle(Vehicle? v) {
    if (v == null) return;
    selected = v;
    records = [];
    notifyListeners();
    _db.watchServiceRecords(v.id).listen((recs) {
      records = recs;
      notifyListeners();
    });
  }

  Future<void> addService(ServiceRecord record) async {
    if (selected == null) return;
    await _db.insertServiceRecord(selected!.id, record);
  }
}