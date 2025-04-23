import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'pages/vehicle/providers/vehicle_provider.dart';
import 'widgets/drawer_wrapper.dart';
import 'database/database_helper.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  final darwinSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission:  true,
    requestSoundPermission:  true,
  );

  final initSettings = InitializationSettings(
    android: androidSettings,
    iOS:    darwinSettings,
    macOS:  darwinSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // handle notification tapped logic here
    },
  );
  // Initialize the database
  final dbHelper = DatabaseHelper();
  await dbHelper.database; // This ensures the database is created

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