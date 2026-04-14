import 'package:flutter/material.dart';
import 'package:patientsphere/screens/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              child: Image.asset(
                'assets/male-doctor.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  "Take control of your health",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                ),
                SizedBox(height: 15),
                Text(
                  "Access clinical records, manage appointments, medications, trackers, and a whole lot more",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF90E094),
                  foregroundColor: const Color(0xFF2E4D2F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text("Get started", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 70);
    path.quadraticBezierTo(size.width / 2, size.height + 30, size.width, size.height - 70);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}