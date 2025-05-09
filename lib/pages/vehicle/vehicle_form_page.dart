import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vehicle/providers/vehicle_form_provider.dart';
import '../vehicle/providers/vehicle_provider.dart';
import '../../providers/navigation_provider.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({Key? key}) : super(key: key);

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  bool _isLoadingMakes = false;
  bool _isLoadingModels = false;
  bool _isLoadingTrims = false;

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
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (year) {
                if (year != null) _onYearSelected(year);
              },
              disabledHint: _isLoadingMakes
                  ? const Center(child: CircularProgressIndicator())
                  : null,
            ),

            // Make dropdown
            if (formProv.selectedYear != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: formProv.selectedMake,
                decoration: const InputDecoration(labelText: 'Make'),
                items: formProv.makes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: _isLoadingMakes
                    ? null
                    : (make) {
                  if (make != null) _onMakeSelected(make);
                },
              ),
            ],

            // Model dropdown
            if (formProv.selectedMake != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: formProv.selectedModel,
                decoration: const InputDecoration(labelText: 'Model'),
                items: formProv.models
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: _isLoadingModels
                    ? null
                    : (model) {
                  if (model != null) _onModelSelected(model);
                },
              ),
            ],

            // Trim dropdown
            if (formProv.selectedModel != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: formProv.selectedTrim,
                decoration: const InputDecoration(labelText: 'Trim'),
                items: formProv.trims
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: _isLoadingTrims
                    ? null
                    : (trim) {
                  if (trim != null) _onTrimSelected(trim);
                },
              ),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed: (formProv.selectedTrim != null && !_isLoadingTrims)
                  ? () => _showTrimPicker(context, formProv)
                  : null,
              child: const Text('Select Exact Trim'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onYearSelected(int year) async {
    setState(() {
      _isLoadingMakes = true;
      _isLoadingModels = false;
      _isLoadingTrims = false;
    });
    await context.read<VehicleFormProvider>().selectYear(year);
    setState(() {
      _isLoadingMakes = false;
    });
  }

  Future<void> _onMakeSelected(String make) async {
    setState(() {
      _isLoadingModels = true;
      _isLoadingTrims = false;
    });
    await context.read<VehicleFormProvider>().selectMake(make);
    setState(() {
      _isLoadingModels = false;
    });
  }

  Future<void> _onModelSelected(String model) async {
    setState(() {
      _isLoadingTrims = true;
    });
    await context.read<VehicleFormProvider>().selectModel(model);
    setState(() {
      _isLoadingTrims = false;
    });
  }

  Future<void> _onTrimSelected(String trim) async {
    setState(() {
      _isLoadingTrims = true;
    });
    context.read<VehicleFormProvider>().selectTrim(trim);
    setState(() {
      _isLoadingTrims = false;
    });
  }

  void _showTrimPicker(BuildContext context, VehicleFormProvider formProv) {
    final filteredTrims = formProv.selectedTrim != null
        ? formProv.trimsRaw
        .where((t) => t['name'] == formProv.selectedTrim)
        .toList()
        : formProv.trimsRaw;

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Available ${formProv.selectedTrim} Trims',
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
                  title: Text(trim['name'].toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trim['description'] != null)
                        Text(trim['description'].toString()),
                      if (trim['engine'] != null)
                        Text('Engine: ${trim['engine']}'),
                      if (trim['transmission'] != null)
                        Text('Transmission: ${trim['transmission']}'),
                    ],
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final vehicleProv = context.read<VehicleProvider>();
                    final navigationProv = context.read<NavigationProvider>();
                    await formProv.loadSpecsFor(trim['id'] as int);
                    if (formProv.fullSpecs != null) {
                      vehicleProv.addVehicle(
                        Vehicle(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .remainder(1 << 31),
                          trimId: trim['id'] as int,
                          year: formProv.selectedYear.toString(),
                          make: formProv.selectedMake ?? '',
                          model: formProv.selectedModel ?? '',
                          trim: trim['name'].toString(),
                          specs: formProv.fullSpecs!,
                        ),
                      );
                      navigationProv
                          .setPage(PageIdentifier.vehicleProfilePage);
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
