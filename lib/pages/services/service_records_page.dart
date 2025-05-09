// lib/pages/services/service_records_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/date_extension.dart';
import '../../database/firestore_helper.dart';
import '../services/providers/service_records_provider.dart';
import '../services/models/service_record.dart';
import '../vehicle/providers/vehicle_provider.dart';
import 'widget/mechanic.dart';

class ServiceRecordsPage extends StatelessWidget {
  const ServiceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceRecordsProvider(FirestoreHelper()),
      child: Consumer<ServiceRecordsProvider>(
        builder: (ctx, prov, _) {
          return Scaffold(
            body: Column(
              children: [
                const MechanicsMap(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Vehicle>(
                    hint: const Text('Select your car'),
                    isExpanded: true,
                    value: prov.selected,
                    items: prov.vehicles.map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text('${v.year} ${v.make} ${v.model}'),
                      );
                    }).toList(),
                    onChanged: prov.selectVehicle,
                  ),
                ),
                Expanded(
                  child: prov.records.isEmpty
                      ? const Center(child: Text('No services logged.'))
                      : ListView.builder(
                    itemCount: prov.records.length,
                    itemBuilder: (_, i) {
                      final r = prov.records[i];
                      return ListTile(
                        title: Text(r.serviceName),
                        subtitle: Text(
                            '${r.completedAt.toShortDateString()} — \$${r.price.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _showAddDialog(ctx, prov),
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext ctx, ServiceRecordsProvider prov) {
    final _nameCtrl = TextEditingController();
    final _priceCtrl = TextEditingController();
    DateTime _picked = DateTime.now();

    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Add Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Service Name'),
            ),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (\$)'),
            ),
            TextButton(
              child: Text('Date: ${_picked.toShortDateString()}'),
              onPressed: () async {
                final d = await showDatePicker(
                  context: dCtx,
                  initialDate: _picked,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null) _picked = d;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dCtx).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              final name = _nameCtrl.text.trim();
              final price = double.tryParse(_priceCtrl.text) ?? 0;
              if (name.isNotEmpty) {
                prov.addService(ServiceRecord(
                  id: '',
                  serviceName: name,
                  completedAt: _picked,
                  price: price,
                ));
                Navigator.of(dCtx).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
