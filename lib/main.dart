import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'pages/vehicle/providers/vehicle_provider.dart';
import 'widgets/drawer_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider<VehicleProvider>(
          create: (_) => VehicleProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Navigation',
        home: const DrawerWrapper(),
        theme: ThemeData(
            primaryColor: Colors.deepOrange,
            hintColor: Colors.amber,
            textTheme: TextTheme(
              headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(fontSize: 16),
            )
        ),
      ),
    );
  }
}