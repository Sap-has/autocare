import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../vehicle/providers/vehicle_provider.dart';

class MileageEntryForm extends StatefulWidget {
  final int vehicleId;

  const MileageEntryForm({super.key, required this.vehicleId});

  @override
  State<MileageEntryForm> createState() => _MileageEntryFormState();
}

class _MileageEntryFormState extends State<MileageEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = Provider.of<VehicleProvider>(context).getVehicleById(widget.vehicleId);

    // If vehicle not found, show error
    if (vehicle == null) {
      return const Center(child: Text('Vehicle not found'));
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Mileage Record',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Current mileage display
            if (vehicle.mileageRecords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Current odometer reading: ${vehicle.currentMileage} miles',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            // Date picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Odometer reading field
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(
                labelText: 'Odometer Reading (miles)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the odometer reading';
                }

                final reading = int.tryParse(value);
                if (reading == null) {
                  return 'Please enter a valid number';
                }

                // Optional: validate that new reading is higher than previous
                if (vehicle.mileageRecords.isNotEmpty && reading < vehicle.currentMileage) {
                  return 'New reading must be higher than current (${vehicle.currentMileage})';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes field (optional)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., Regular maintenance, trip, etc.',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create and save the mileage record
                      final provider = Provider.of<VehicleProvider>(context, listen: false);

                      provider.addMileageRecord(
                        widget.vehicleId,
                        MileageRecord(
                          date: _selectedDate,
                          odometer: int.parse(_odometerController.text),
                          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                        ),
                      );

                      Navigator.pop(context);

                      // Show confirmation snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mileage record added successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}