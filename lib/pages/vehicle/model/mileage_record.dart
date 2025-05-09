// lib/vehicle/models/mileage_record.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MileageRecord {
  final String id;
  final String vehicleId;
  final int    odometer;
  final DateTime date;
  final String? notes;

  MileageRecord({
    required this.id,
    required this.vehicleId,
    required this.odometer,
    required this.date,
    this.notes,
  });

  factory MileageRecord.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MileageRecord(
      id:         doc.id,
      vehicleId:  data['vehicleId']       as String,
      odometer:   (data['odometer']       as num).toInt(),
      date:       DateTime.parse(data['date'] as String),
      notes:      data['notes']           as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'vehicleId': vehicleId,
    'odometer':  odometer,
    'date':      date.toIso8601String(),
    'notes':     notes,
  };
}
