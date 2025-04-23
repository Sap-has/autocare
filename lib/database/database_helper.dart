import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../pages/vehicle/providers/vehicle_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'autocare_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create vehicles table
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY,
        trimId INTEGER NOT NULL,
        year TEXT NOT NULL,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        trim TEXT NOT NULL,
        specs TEXT NOT NULL
      )
    ''');

    // Create mileage records table with foreign key to vehicles
    await db.execute('''
      CREATE TABLE mileage_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        date TEXT NOT NULL,
        odometer INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');
  }

  // Vehicle operations
  Future<int> insertVehicle(Vehicle vehicle, Map<String, dynamic> specs) async {
    final db = await database;

    // Convert specs map to JSON string
    final specsJson = vehicleSpecsToJson(specs);

    return await db.insert(
      'vehicles',
      {
        'id': vehicle.id,
        'trimId': vehicle.trimId,
        'year': vehicle.year,
        'make': vehicle.make,
        'model': vehicle.model,
        'trim': vehicle.trim,
        'specs': specsJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> vehicleMaps = await db.query('vehicles');

    List<Vehicle> vehicles = [];

    for (var vehicleMap in vehicleMaps) {
      // Get related mileage records for this vehicle
      final mileageRecords = await getMileageRecords(vehicleMap['id']);

      // Parse specs from JSON string
      final specs = jsonSpecsToMap(vehicleMap['specs']);

      vehicles.add(Vehicle(
        id: vehicleMap['id'],
        trimId: vehicleMap['trimId'],
        year: vehicleMap['year'],
        make: vehicleMap['make'],
        model: vehicleMap['model'],
        trim: vehicleMap['trim'],
        specs: specs,
        mileageRecords: mileageRecords,
      ));
    }

    return vehicles;
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    // The mileage records will be deleted automatically due to the CASCADE constraint
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // Mileage operations
  Future<int> insertMileageRecord(int vehicleId, MileageRecord record) async {
    final db = await database;
    return await db.insert(
      'mileage_records',
      {
        'vehicleId': vehicleId,
        'date': record.date.toIso8601String(),
        'odometer': record.odometer,
        'notes': record.notes,
      },
    );
  }

  Future<List<MileageRecord>> getMileageRecords(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> recordMaps = await db.query(
      'mileage_records',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
    );

    return recordMaps.map((recordMap) => MileageRecord(
      date: DateTime.parse(recordMap['date']),
      odometer: recordMap['odometer'],
      notes: recordMap['notes'],
    )).toList();
  }

  // Helper methods for converting between JSON and Map
  String vehicleSpecsToJson(Map<String, dynamic> specs) {
    // Convert specs map to JSON string
    return jsonEncode(specs);
  }

  Map<String, dynamic> jsonSpecsToMap(String jsonString) {
    // Convert JSON string back to specs map
    return jsonDecode(jsonString);
  }
}