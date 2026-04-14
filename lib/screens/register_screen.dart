import 'package:flutter/material.dart';
import 'package:patientsphere/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 35),
              const Text("Registration", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),

              // Email/Phone Toggle
              Container(
                height: 45,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Expanded(child: Center(child: Text("Phone number", style: TextStyle(color: Colors.grey)))),
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: const Color(0xFF66C2B2), borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text("Email",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              _buildField("Email"),
              _buildField("First name"),
              _buildField("Last name"),
              _buildField("Password", isPass: true),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["min 8 letters", "1 capital letters", "1 number"].map((e) => _buildReq(e)).toList(),
              ),
              const SizedBox(height: 35),
              _buildButton("Next", () {}),

              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text.rich(TextSpan(text: "Do you already have account? ",
                    children: [
                      TextSpan(text: "Sign in",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)
                      )
                    ]
                )
                ),
              ),
              const SizedBox(height: 20),
              const Text("Sign in", style: TextStyle(color: Colors.grey)),
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
        Padding(padding: const EdgeInsets.only(left: 8, bottom: 5),
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)
            )
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15), // FIXED: Used only() instead of .bottom
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03), // FIXED: withValues
                    blurRadius: 8,
                    offset: const Offset(0, 4)
                )
              ]
          ),
          child: TextFormField(
              obscureText: isPass,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade200)
                  )
              )
          ),
        ),
      ],
    );
  }

  Widget _buildReq(String text) => Column(
      children: [
        Container(height: 2, width: 80, color: Colors.grey.shade300),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)
        )
      ]
  );

  Widget _buildButton(String text, VoidCallback tap) => SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
          style:
          ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90E094),
              foregroundColor: const Color(0xFF2E4D2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)
              )
          ),
          onPressed: tap,
          child: Text(text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
          )
      )
  );

  Widget _buildSocials() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
      [
        Icons.g_mobiledata,
        Icons.facebook,
        Icons.apple
      ].map((i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(i, size: 28)
      )
      ).toList()
  );
}