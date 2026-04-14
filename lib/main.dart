import 'package:flutter/material.dart';
import 'package:patientsphere/screens/onboarding_screen.dart';

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
        // Setting a global theme that matches the minimalist image
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF90E094),
          primary: const Color(0xFF90E094),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const OnboardingScreen(), // Updated entry point
    );
  }
}