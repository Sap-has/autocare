import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/vehicle/vehicle_form_page.dart';
import '../providers/navigation_provider.dart';
import '../pages/vehicle/vehicle_profile_page.dart';
import '../pages/vehicle/providers/vehicle_form_provider.dart';
import '../pages/vehicle/providers/vehicle_provider.dart';
import '../pages/suggestion/suggestion_page.dart';
import '../pages/services/service_records_page.dart';

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
            return const VehicleProfilePage();
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
        content = SuggestionPage();
        break;
      case PageIdentifier.servicePage:
        content = const ServiceRecordsPage();
        break;
    }

    return Scaffold(
      key: ValueKey(navigation.currentPage), // Add key to rebuild Scaffold properly
      appBar: AppBar(
        title: _getTitleForPage(navigation.currentPage),
      ),
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
              selected: navigation.currentPage == PageIdentifier.vehicleProfilePage,
              onTap: () {
                navigation.setPage(PageIdentifier.vehicleProfilePage);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.safety_check),
              title: const Text('Suggestion'),
              selected: navigation.currentPage == PageIdentifier.suggestionPage,
              onTap: () {
                navigation.setPage(PageIdentifier.suggestionPage);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Service'),
              selected: navigation.currentPage == PageIdentifier.servicePage,
              onTap: () {
                navigation.setPage(PageIdentifier.servicePage);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: content,
    );
  }

  // Helper method to get the title based on current page
  Widget _getTitleForPage(PageIdentifier page) {
    switch (page) {
      case PageIdentifier.vehicleProfilePage:
        return const Text("My Vehicles");
      case PageIdentifier.vehicleFormPage:
        return const Text("Add Vehicle");
      case PageIdentifier.suggestionPage:
        return const Text("Maintenance Suggestions");
      case PageIdentifier.servicePage:
        return const Text("Service History");
    }
  }
}