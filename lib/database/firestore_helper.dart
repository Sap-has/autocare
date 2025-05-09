import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/services/models/service_record.dart';
import '../pages/vehicle/providers/vehicle_provider.dart';

class FirestoreHelper {
  final _db = FirebaseFirestore.instance;

  Future<void> insertVehicle(Vehicle vehicle) {
    return _db
        .collection('vehicles')
        .doc(vehicle.id.toString())
        .set({
      'trimId': vehicle.trimId,
      'year': vehicle.year,
      'make': vehicle.make,
      'model': vehicle.model,
      'trim': vehicle.trim,
      'specs': vehicle.specs,
    });
  }

  Stream<List<Vehicle>> watchVehicles() {
    return _db.collection('vehicles').snapshots().map((snap) =>
        snap.docs.map((doc) {
          final data = doc.data();
          return Vehicle(
            id: int.parse(doc.id),
            trimId: data['trimId'],
            year: data['year'],
            make: data['make'],
            model: data['model'],
            trim: data['trim'],
            specs: Map<String, dynamic>.from(data['specs']),
            mileageRecords: [], // loaded separately below
          );
        }).toList(),
    );
  }

  Future<void> insertMileageRecord(int vehicleId, MileageRecord record) {
    return _db
        .collection('vehicles')
        .doc(vehicleId.toString())
        .collection('mileage_records')
        .add({
      'date': record.date.toIso8601String(),
      'odometer': record.odometer,
      'notes': record.notes,
    });
  }

  Stream<List<MileageRecord>> watchMileageRecords(int vehicleId) {
    return _db
        .collection('vehicles')
        .doc(vehicleId.toString())
        .collection('mileage_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final d = doc.data();
      return MileageRecord(
        date: DateTime.parse(d['date']),
        odometer: d['odometer'],
        notes: d['notes'],
      );
    }).toList());
  }

  Future<void> deleteVehicle(int vehicleId) {
    return _db
        .collection('vehicles')
        .doc(vehicleId.toString())
        .delete();
  }

  Future<void> insertServiceRecord(int vehicleId, ServiceRecord record) {
    return _db
        .collection('vehicles')
        .doc(vehicleId.toString())
        .collection('service_records')
        .add(record.toJson());
  }

  Stream<List<ServiceRecord>> watchServiceRecords(int vehicleId) {
    return _db
        .collection('vehicles')
        .doc(vehicleId.toString())
        .collection('service_records')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ServiceRecord.fromJson(d.id, d.data()))
        .toList()
    );
  }

// Similarly add methods for suggestions...
}
