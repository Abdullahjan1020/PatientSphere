import 'package:flutter/material.dart';
import 'package:patientsphere/screens/dashboard_screen.dart';
import 'package:patientsphere/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text("Sign in", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              _buildField("Email/Phone number"),
              _buildField("Password", isPass: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Checkbox(value: _rememberMe,
                        activeColor: const Color(0xFF90E094),
                        onChanged: (v) => setState(() => _rememberMe = v!)
                    ),
                    const Text("Remember me",
                        style: TextStyle(fontSize: 12, color: Colors.grey)
                    )
                  ]
                  ),
                  const Text("Forgot password?",
                      style: TextStyle(fontSize: 12, color: Colors.grey)
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90E094),
                          foregroundColor: const Color(0xFF2E4D2F),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                          )
                      ),
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder:
                                  (context) => const DashboardScreen()
                          )
                      ),
                      child: const Text("Sign in",
                          style:
                          TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 18)
                      )
                  )
              ),
              const SizedBox(height: 40),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder:
                              (context) => const RegisterScreen()
                      )
                  ),
                  child: const Text("Are you new? Register",
                      style: TextStyle(fontWeight: FontWeight.bold)
                  )
              ),
              const SizedBox(height: 20),
              const Text("Sign in",
                  style: TextStyle(color: Colors.grey)
              ),
              const SizedBox(height: 20),
              _buildSocials(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding:
            const EdgeInsets.only(left: 8, bottom: 8),
            child:
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)
            )
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 20), // FIXED: Used only()
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // FIXED: withValues
                      blurRadius: 10,
                      offset: const Offset(0, 4)
                  )
                ]
            ),
            child: TextFormField(
                obscureText: isPass,
                decoration:
                InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300)
                    )
                )
            )
        ),
      ],
    );
  }

  Widget _buildSocials() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icons.g_mobiledata,
        Icons.facebook,
        Icons.apple
      ].map((i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(i, size: 28))).toList()
  );
}