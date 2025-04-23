import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/suggestions/suggestion_page.dart';
import '../pages/vehicle/vehicle_form_page.dart';
import '../providers/navigation_provider.dart';
import '../pages/vehicle/vehicle_profile_page.dart';
import '../pages/vehicle/providers/vehicle_form_provider.dart';
import '../pages/vehicle/providers/vehicle_provider.dart';

class DrawerWrapper extends StatelessWidget {
  const DrawerWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = Provider.of<NavigationProvider>(context);
    Widget content;

    switch (navigation.currentPage) {
      case PageIdentifier.vehicleProfilePage:
        content = Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, _) {
            return VehicleProfilePage();
          },
        );
        break;
      case PageIdentifier.vehicleFormPage:
        content = ChangeNotifierProvider(
          create: (_) => VehicleFormProvider(),
          child: const VehicleFormPage(),
        );
        break;
      case PageIdentifier.suggestionPage:
        content = const SuggestionPage();
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("AutoCare Pro")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('AutoCare Pro',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.car_rental),
              title: const Text('Vehicle Profile'),
              onTap: () {
                navigation.setPage(PageIdentifier.vehicleProfilePage);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.recommend),
              title: const Text('Suggestions'),
              onTap: () {
                navigation.setPage(PageIdentifier.suggestionPage);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: content,
    );
  }
}