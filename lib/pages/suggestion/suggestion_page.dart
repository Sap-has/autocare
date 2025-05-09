// lib/pages/suggestion/suggestion_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../database/firestore_helper.dart';
import '../services/models/service_record.dart';
import '../vehicle/providers/vehicle_provider.dart';
import 'providers/suggestion_provider.dart';

class SuggestionPage extends StatelessWidget {
  const SuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuggestionProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Maintenance Suggestions')),
        body: Consumer<SuggestionProvider>(
          builder: (ctx, prov, child) {
            return Column(
              children: [
                // Vehicle selector
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

                // Suggestions & Problems list
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // — Due services —
                      if (prov.suggestions.isEmpty)
                        const ListTile(
                          title: Center(child: Text('No services due.')),
                        )
                      else
                        ...prov.suggestions.map((s) => ListTile(
                          title: Text(s.serviceName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Due at ${s.dueMileage} mi${s.dueDate != null
                                      ? ' or on ${DateFormat('MMM d, yyyy').format(s.dueDate!)}'
                                      : ''}'),
                              if (s.description != null)
                                Text(s.description!),
                            ],
                          ),
                          onTap: () => _showCompleteDialog(context, s as ServiceRecord),
                        )),

                      // — Common problems from RepairPal —
                      if (prov.isLoadingIssues)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                      else ...[
                        // RepairPal section
                        if (prov.rpIssues.isNotEmpty) ...[
                          const Divider(thickness: 1),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text(
                              'Common Problems (RepairPal)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...prov.rpIssues.map((issue) => ExpansionTile(
                            leading: const Icon(Icons.build),
                            title: Text(issue.title),
                            subtitle: Text('Avg. mileage: ${issue.averageMileage}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(issue.description),
                              ),
                              ...issue.solutions.map((s) => ListTile(
                                dense: true,
                                title: Text(s.name),
                                trailing: Text(s.costRange),
                              )),
                            ],
                          )),
                        ],
                        // CarComplaints section
                        if (prov.ccIssues.isNotEmpty) ...[
                          const Divider(thickness: 1),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text(
                              'Complaints (CarComplaints.com)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...prov.ccIssues.map((c) => ListTile(
                            leading: const Icon(Icons.report),
                            title: Text(c.title),
                            subtitle: Text(c.description),
                            onTap: () => launchUrlString(c.detailUrl),
                          )),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext ctx, ServiceRecord s) {
    showDialog(
      context: ctx,
      builder: (dCtx) {
        double? price;
        final mapsUrl =
            'https://www.google.com/maps/search/${Uri.encodeComponent("${s.serviceName} near me")}';
        return AlertDialog(
          title: Text('Complete ${s.serviceName}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Find on Maps'),
                onPressed: () => launchUrlString(mapsUrl),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
                onChanged: (v) => price = double.tryParse(v),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dCtx).pop(),
            ),
            ElevatedButton(
              child: const Text('Complete'),
              onPressed: () {
                if (price != null) {
                  final rec = ServiceRecord(
                    id: '', // Firestore will assign
                    serviceName: s.serviceName,
                    completedAt: DateTime.now(),
                    price: price!,
                    location: mapsUrl,
                  );
                  FirestoreHelper()
                      .insertServiceRecord(
                      Provider.of<SuggestionProvider>(ctx, listen: false)
                          .selected!
                          .id,
                      rec)
                      .then((_) {
                    Navigator.of(dCtx).pop();
                    Provider.of<SuggestionProvider>(ctx, listen: false)
                        .selectVehicle(
                        Provider.of<SuggestionProvider>(ctx, listen: false)
                            .selected);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                            '${s.serviceName} logged (\$${price!.toStringAsFixed(2)})')));
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
