import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vehicle/providers/vehicle_form_provider.dart';
import '../vehicle/providers/vehicle_provider.dart';
import '../../providers/navigation_provider.dart';
import 'dart:math';

class VehicleFormPage extends StatelessWidget {
  const VehicleFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formProv = context.watch<VehicleFormProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Year dropdown
            DropdownButtonFormField<int>(
              value: formProv.selectedYear,
              decoration: const InputDecoration(labelText: 'Year'),
              items: formProv.years
                  .map((y) => DropdownMenuItem(
                value: y,
                child: Text(y.toString()),
              ))
                  .toList(),
              onChanged: (year) {
                if (year != null) formProv.selectYear(year);
              },
            ),

            // Make dropdown (after year)
            if (formProv.selectedYear != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: formProv.selectedMake,
                decoration: const InputDecoration(labelText: 'Make'),
                items: formProv.makes
                    .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m),
                ))
                    .toList(),
                onChanged: (make) {
                  if (make != null) formProv.selectMake(make);
                },
              ),
            ],

            // Model dropdown (after make)
            if (formProv.selectedMake != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: formProv.selectedModel,
                decoration: const InputDecoration(labelText: 'Model'),
                items: formProv.models
                    .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m),
                ))
                    .toList(),
                onChanged: (model) {
                  if (model != null) formProv.selectModel(model);
                },
              ),
            ],

            // Trim dropdown (after model)
            if (formProv.selectedModel != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: formProv.selectedTrim,
                decoration: const InputDecoration(labelText: 'Trim'),
                items: formProv.trims
                    .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t),
                ))
                    .toList(),
                onChanged: (trim) {
                  if (trim != null) formProv.selectTrim(trim);
                },
              ),
            ],

            const Spacer(),

            // Button to pick the exact trim from trimsRaw list
            ElevatedButton(
              onPressed: (formProv.selectedTrim != null && formProv.trimsRaw.isNotEmpty)
                  ? () => _showTrimPicker(context, formProv)
                  : null,
              child: const Text('Select Exact Trim'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrimPicker(BuildContext context, VehicleFormProvider formProv) {
    // Filter trims to only show those that match the selected trim name
    final filteredTrims = formProv.selectedTrim != null
        ? formProv.trimsRaw.where((trim) => trim['name'] == formProv.selectedTrim).toList()
        : formProv.trimsRaw;

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available ${formProv.selectedTrim ?? ""} Trims',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTrims.length,
              itemBuilder: (ctx, i) {
                final trim = filteredTrims[i];
                return ListTile(
                  title: Text(trim['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show some distinguishing characteristics
                      if (trim['description'] != null)
                        Text(trim['description']),
                      // You can show additional info if available
                      if (trim['engine'] != null)
                        Text('Engine: ${trim['engine']}'),
                      if (trim['transmission'] != null)
                        Text('Transmission: ${trim['transmission']}'),
                    ],
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await formProv.loadSpecsFor(trim['id'] as int);
                    if (formProv.fullSpecs != null && context.mounted) {
                      // Get providers
                      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
                      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

                      // Add the vehicle to the provider
                      vehicleProvider.addVehicle(
                        Vehicle(
                          id: DateTime.now().millisecondsSinceEpoch % 2147483647, // Simple ID generation
                          trimId: trim['id'] as int,
                          year: formProv.selectedYear.toString(),
                          make: formProv.selectedMake ?? '',
                          model: formProv.selectedModel ?? '',
                          trim: trim['name'] as String,
                          specs: formProv.fullSpecs!,
                        ),
                      );

                      // Navigate back to vehicle profile page
                      navigationProvider.setPage(PageIdentifier.vehicleProfilePage);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}