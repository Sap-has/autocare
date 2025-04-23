import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vehicle/providers/vehicle_provider.dart';
import 'package:intl/intl.dart';

import 'mileage_entry_form.dart';

class MileageHistoryPage extends StatelessWidget {
  final int vehicleId;

  const MileageHistoryPage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicle = vehicleProvider.getVehicleById(vehicleId);

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mileage History')),
        body: const Center(child: Text('Vehicle not found')),
      );
    }

    // Sort records by date (newest first)
    final records = List<MileageRecord>.from(vehicle.mileageRecords)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.year} ${vehicle.make} ${vehicle.model} Mileage'),
      ),
      body: Column(
        children: [
          // Current mileage card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Mileage',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Record'),
                          onPressed: () {
                            _showAddMileageBottomSheet(context, vehicle.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${vehicle.currentMileage}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'miles',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // History section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Mileage History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${records.length} records)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // List of mileage records
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('No mileage records yet'))
                : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final dateStr = DateFormat('MMM d, yyyy').format(record.date);

                // Calculate distance if not the first record
                String? distanceText;
                if (index < records.length - 1) {
                  final prevRecord = records[index + 1]; // Note: list is newest first
                  final distance = record.odometer - prevRecord.odometer;
                  distanceText = '+$distance miles';
                }

                return ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('$dateStr: ${record.odometer} miles'),
                  subtitle: record.notes != null ? Text(record.notes!) : null,
                  trailing: distanceText != null
                      ? Text(
                    distanceText,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMileageBottomSheet(BuildContext context, int vehicleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => MileageEntryForm(vehicleId: vehicleId),
    );
  }
}