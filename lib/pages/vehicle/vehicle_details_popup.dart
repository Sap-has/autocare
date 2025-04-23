import 'package:flutter/material.dart';
import '../vehicle/providers/vehicle_provider.dart';

class VehicleDetailsPopup extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsPopup({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with vehicle name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${vehicle.year} ${vehicle.make} ${vehicle.model} ${vehicle.trim}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader(context, 'Basic Information'),
                      _buildDetailRow('Year', vehicle.year),
                      _buildDetailRow('Make', vehicle.make),
                      _buildDetailRow('Model', vehicle.model),
                      _buildDetailRow('Trim', vehicle.trim),
                      _buildDetailRow('Description', vehicle.specs['description']?.toString() ?? 'N/A'),
                      const SizedBox(height: 16),

                      // Engine Information Section
                      _buildSectionHeader(context, 'Engine Details'),
                      ..._extractEngineDetails(),
                      const SizedBox(height: 16),

                      // Fuel and Performance Section
                      _buildSectionHeader(context, 'Fuel & Performance'),
                      ..._extractFuelPerformanceDetails(),
                      const SizedBox(height: 16),

                      // Transmission Information Section
                      _buildSectionHeader(context, 'Transmission Details'),
                      ..._extractTransmissionDetails(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Widget> _extractEngineDetails() {
    final widgets = <Widget>[];
    final specs = vehicle.specs;
    final engineSizeAdded = <bool>[false];
    final cylindersAdded = <bool>[false];

    // Add engine type if available
    if (specs.containsKey('engine_type') && specs['engine_type'] != null) {
      widgets.add(_buildDetailRow('Engine Type', specs['engine_type'].toString()));
    }

    // Add horsepower if available
    if (specs.containsKey('horsepower_hp') && specs['horsepower_hp'] != null) {
      widgets.add(_buildDetailRow('Horsepower', '${specs['horsepower_hp']} hp'));
    }

    // Get engine details from description as fallback
    final description = vehicle.specs['description'] as String?;
    if (description != null) {
      final engineRegex = RegExp(r'\((.*?)\)');
      final match = engineRegex.firstMatch(description);

      if (match != null) {
        final engineInfo = match.group(1) ?? '';

        // Try to parse engine size
        final sizeRegex = RegExp(r'(\d+\.\d+)L');
        final sizeMatch = sizeRegex.firstMatch(engineInfo);
        if (sizeMatch != null && !engineSizeAdded[0]) {
          widgets.add(_buildDetailRow('Engine Size', '${sizeMatch.group(1)}L'));
          engineSizeAdded[0] = true;
        }

        // Try to parse cylinders
        final cylinderRegex = RegExp(r'(\d+)cyl');
        final cylinderMatch = cylinderRegex.firstMatch(engineInfo);
        if (cylinderMatch != null && !cylindersAdded[0]) {
          widgets.add(_buildDetailRow('Cylinders', cylinderMatch.group(1) ?? 'N/A'));
          cylindersAdded[0] = true;
        }

        // Add raw engine info if no other engine details
        if (widgets.isEmpty || (!specs.containsKey('engine_type') && !specs.containsKey('horsepower_hp'))) {
          widgets.add(_buildDetailRow('Engine Info', engineInfo));
        }
      }
    }

    // If no engine details found, add placeholder
    if (widgets.isEmpty) {
      widgets.add(_buildDetailRow('Engine Info', 'Not available in vehicle data'));
    }

    return widgets;
  }

  List<Widget> _extractFuelPerformanceDetails() {
    final widgets = <Widget>[];
    final specs = vehicle.specs;

    // Add fuel type if available
    if (specs.containsKey('fuel_type') && specs['fuel_type'] != null) {
      widgets.add(_buildDetailRow('Fuel Type', specs['fuel_type'].toString()));
    }

    // Add fuel tank capacity if available
    if (specs.containsKey('fuel_tank_capacity') && specs['fuel_tank_capacity'] != null) {
      widgets.add(_buildDetailRow('Fuel Tank', '${specs['fuel_tank_capacity']} gallons'));
    }

    // Add MPG information
    if (specs.containsKey('combined_mpg') && specs['combined_mpg'] != null) {
      widgets.add(_buildDetailRow('Combined MPG', specs['combined_mpg'].toString()));
    }

    if (specs.containsKey('epa_city_mpg') && specs['epa_city_mpg'] != null) {
      widgets.add(_buildDetailRow('City MPG', specs['epa_city_mpg'].toString()));
    }

    if (specs.containsKey('epa_highway_mpg') && specs['epa_highway_mpg'] != null) {
      widgets.add(_buildDetailRow('Highway MPG', specs['epa_highway_mpg'].toString()));
    }

    // If no fuel/performance details found, add placeholder
    if (widgets.isEmpty) {
      widgets.add(_buildDetailRow('Fuel Info', 'Not available in vehicle data'));
    }

    return widgets;
  }

  List<Widget> _extractTransmissionDetails() {
    final widgets = <Widget>[];

    // Get transmission details from description
    final description = vehicle.specs['description'] as String?;
    if (description != null) {
      // Look for transmission info like "9A" for 9-speed automatic
      final transmissionRegex = RegExp(r'(\d+)A');
      final match = transmissionRegex.firstMatch(description);

      if (match != null) {
        widgets.add(_buildDetailRow('Type', 'Automatic'));
        widgets.add(_buildDetailRow('Speeds', '${match.group(1)}'));
      }
    }

    // If no transmission details found, add placeholder
    if (widgets.isEmpty) {
      widgets.add(_buildDetailRow('Transmission Info', 'Not available in vehicle data'));
    }

    return widgets;
  }
}