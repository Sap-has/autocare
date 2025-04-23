import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../vehicle/providers/vehicle_provider.dart';
import 'mileage_entry_form.dart';
import 'mileage_history_page.dart';
import 'vehicle_details_popup.dart';

class VehicleProfilePage extends StatelessWidget {
  const VehicleProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicles = vehicleProvider.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Provider.of<NavigationProvider>(context, listen: false)
                  .setPage(PageIdentifier.vehicleFormPage);
            },
          )
        ],
      ),
      body: !vehicleProvider.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No vehicles added yet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false)
                    .setPage(PageIdentifier.vehicleFormPage);
              },
              child: const Text('Add Vehicle'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return VehicleCard(vehicle: vehicle);
          },
        ),
      ),
    );
  }
}

// In vehicle_profile_page.dart, update the VehicleCard class
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image or Placeholder
          Container(
            height: 100,
            color: Colors.grey.shade300,
            child: Center(
              child: Icon(
                Icons.directions_car,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Vehicle Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (vehicle.mileageRecords.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildSpecRow(
                    Icons.speed,
                    '${vehicle.currentMileage} miles',
                    context,
                  ),
                ],

                const SizedBox(height: 4),
                Text(
                  vehicle.trim,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Extract a few key specs to show
                _buildSpecRow(
                    Icons.speed,
                    _getEngineInfo(vehicle.specs),
                    context
                ),
                _buildSpecRow(
                    Icons.compare_arrows,
                    _getTransmissionInfo(vehicle.specs),
                    context
                ),
              ],
            ),
          ),

          const Spacer(),

          // Row of buttons at the bottom
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info button
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    _showDetailsPopup(context);
                  },
                  tooltip: "Show Details",
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.speed),
                  onPressed: () {
                    _showMileageOptions(context);
                  },
                  tooltip: "Mileage",
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMileageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Mileage Record'),
              onTap: () {
                Navigator.pop(context);
                _showAddMileageForm(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View Mileage History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MileageHistoryPage(vehicleId: vehicle.id),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMileageForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => MileageEntryForm(vehicleId: vehicle.id),
    );
  }

  // Show the detailed popup
  void _showDetailsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: VehicleDetailsPopup(vehicle: vehicle),
        );
      },
    );
  }

  // Rest of your methods...
  Widget _buildSpecRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getEngineInfo(Map<String, dynamic> specs) {
    try {
      // First try to get engine_type if available
      if (specs.containsKey('engine_type') && specs['engine_type'] != null) {
        return specs['engine_type'].toString();
      }

      // Then try description
      final description = specs['description'] as String?;
      if (description != null && description.contains('(') && description.contains(')')) {
        // Extract engine info from parentheses in description
        final engineInfo = RegExp(r'\((.*?)\)').firstMatch(description)?.group(1);
        return engineInfo ?? 'Engine Info N/A';
      }
    } catch (e) {
      // Fallback
    }
    return 'Engine Info N/A';
  }

  String _getTransmissionInfo(Map<String, dynamic> specs) {
    try {
      // Extract transmission info from description if possible
      final description = specs['description'] as String?;
      if (description != null) {
        // If description contains something like "9A" for 9-speed automatic
        final match = RegExp(r'(\d+)A').firstMatch(description);
        if (match != null) {
          return '${match.group(1)}-speed Automatic';
        }
      }

      // Try other fields
      if (specs.containsKey('transmission') && specs['transmission'] != null) {
        return specs['transmission'].toString();
      }
    } catch (e) {
      // Handle any nested property access errors
    }
    return 'Auto';  // More friendly default
  }
}