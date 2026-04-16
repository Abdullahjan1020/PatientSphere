import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:patientsphere/screens/dashboard_screen.dart';
import 'package:patientsphere/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Using your mobile hotspot IP address
    final url = Uri.parse('http://192.168.43.180:5000/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim().toLowerCase(),
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extracting required fields from backend response
        final String firstName = responseData['user']['first_name'];
        final String email = responseData['user']['email'];
        final String id = responseData['user']['id']; // Grab the unique ObjectID string

        if (!mounted) return;

        // FIXED: Passing all 3 required parameters to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userName: firstName,
              userEmail: email,
              userId: id, // Linking data integrity here
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? "Login Failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server connection error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
              const Text("Sign in",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F))
              ),
              const SizedBox(height: 50),

              _buildField("Email/Phone number", _emailController),
              _buildField("Password", _passwordController, isPass: true),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF90E094),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _rememberMe = v!)
                    ),
                    const Text("Remember me", style: TextStyle(fontSize: 12, color: Colors.grey))
                  ]),
                  const Text("Forgot password?", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF2E4D2F))
                          : const Text("Sign in", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                  )
              ),
              const SizedBox(height: 40),
              GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text("Are you new? Register", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E4D2F)))
              ),
              const SizedBox(height: 20),
              const Text("Sign in with", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              _buildSocials(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87))
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)
                  )
                ]
            ),
            child: TextFormField(
                controller: controller,
                obscureText: isPass,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF90E094), width: 1.5),
                  ),
                )
            )
        ),
      ],
    );
  }

  Widget _buildSocials() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icons.g_mobiledata, Icons.facebook, Icons.apple].map((i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(i, size: 28, color: Colors.grey))).toList()
  );
}