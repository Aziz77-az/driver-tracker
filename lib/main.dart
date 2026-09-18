import 'package:flutter/material.dart';

import 'screens/driver_list_screen.dart';

void main() {
  runApp(const DispatcherApp());
}

class DispatcherApp extends StatelessWidget {
  const DispatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Трекер водителей',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DriverListScreen(),
    );
  }
}
