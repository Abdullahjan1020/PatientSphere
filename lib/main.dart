import 'package:flutter/material.dart';
import 'package:patientsphere/screens/login_screen.dart';

void main() {
  runApp(const PatientSphereApp());
}

class PatientSphereApp extends StatelessWidget {
  const PatientSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PatientSphere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}