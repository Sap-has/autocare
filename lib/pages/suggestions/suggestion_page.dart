// lib/pages/suggestions/suggestion_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/suggestion_provider.dart';
import '../vehicle/providers/vehicle_provider.dart';
import '../../util/date_extension.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});
  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  late VehicleProvider _vp;
  late SuggestionProvider _sp;
  int? _selectedVehicleId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vp = Provider.of<VehicleProvider>(context);
    _sp = Provider.of<SuggestionProvider>(context, listen: false);
    if (_vp.vehicles.isNotEmpty && _selectedVehicleId == null) {
      _selectedVehicleId = _vp.vehicles.first.id;
      _load();
    }
  }

  void _load() {
    final v = _vp.getVehicleById(_selectedVehicleId!);
    if (v != null) _sp.loadForVehicle(v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Vehicle dropdown
        DropdownButton<int>(
          value: _selectedVehicleId,
          items: _vp.vehicles.map((v) =>
              DropdownMenuItem(value: v.id, child: Text('${v.year} ${v.make} ${v.model}'))
          ).toList(),
          onChanged: (id) {
            setState(() => _selectedVehicleId = id);
            _load();
          },
        ),

        // Content
        Expanded(child: Consumer<SuggestionProvider>(
          builder: (_, sp, __) {
            if (sp.loading) return Center(child: CircularProgressIndicator());
            return ListView(
              children: [
                // Maintenance suggestions
                ...sp.suggestions.map((s) => ListTile(
                  title: Text(s.title),
                  subtitle: Text(s.description +
                      (s.recommendedMileage != null
                          ? ' @ ${s.recommendedMileage} mi'
                          : s.recommendedDate != null
                          ? ' on ${s.recommendedDate!.toLocal().toShortDateString()}'
                          : ''
                      )
                  ),
                  trailing: Checkbox(
                    value: s.completed,
                    onChanged: (_) => sp.toggleComplete(s),
                  ),
                )),

                Divider(),

                // Recalls & issues
                Padding(padding: EdgeInsets.all(8), child: Text('Recalls / Known Issues')),
                ...sp.recalls.map((r) => ListTile(
                  title: Text(r['Summary'] ?? 'No title'),
                  subtitle: Text(r['Conequence'] ?? ''),
                )),
              ],
            );
          },
        )),
      ],
    );
  }
}
