import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;

  const ProfileScreen({super.key, required this.userName, required this.userEmail, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _sosController = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  double _bmi = 0.0;
  bool _isLoading = true; // Data load hone tak loading dikhane ke liye
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); // Screen khulte hi data fetch karein
  }

  // NAYA: Database se user ka existing data mangwana
  Future<void> _fetchProfileData() async {
    final url = Uri.parse('http://192.168.43.180:5000/get_profile/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ageController.text = data['age'] ?? "";
          _heightController.text = data['height'] ?? "";
          _weightController.text = data['weight'] ?? "";
          _sosController.text = data['sos_contact'] ?? "";
          _gender = data['gender'] ?? "Male";
          _bloodGroup = data['blood_group'] ?? "O+";
          _bmi = double.tryParse(data['bmi'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateBMI() {
    final double height = double.tryParse(_heightController.text) ?? 0;
    final double weight = double.tryParse(_weightController.text) ?? 0;
    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100;
      setState(() => _bmi = weight / (heightInMeters * heightInMeters));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final url = Uri.parse('http://192.168.43.180:5000/update_profile');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "age": _ageController.text,
          "gender": _gender,
          "blood_group": _bloodGroup,
          "height": _heightController.text,
          "weight": _weightController.text,
          "bmi": _bmi.toStringAsFixed(1),
          "sos_contact": _sosController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, {
          "blood": _bloodGroup,
          "age": _ageController.text,
          "gender": _gender,
        });
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    } finally {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Medical Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.lock_open : Icons.edit, color: const Color(0xFF90E094)),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF90E094)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Icon(Icons.person, size: 60, color: const Color(0xFF90E094).withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 15),
            Text(widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(widget.userEmail, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),

            _buildFieldCard("Age & Contact", [
              _buildInput("Age", _ageController, TextInputType.number, enabled: _isEditing),
              _buildInput("SOS Contact", _sosController, TextInputType.phone, enabled: _isEditing),
            ]),

            const SizedBox(height: 20),
            _buildFieldCard("Physical Stats", [
              Row(
                children: [
                  Expanded(child: _buildInput("Height (cm)",
                      _heightController,
                      TextInputType.number,
                      enabled: _isEditing,
                      onChanged: (v) => _calculateBMI())
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Weight (kg)",
                      _weightController,
                      TextInputType.number,
                      enabled: _isEditing,
                      onChanged: (v) => _calculateBMI())
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFFF1F8F1), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Calculated BMI", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_bmi.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E4D2F)
                        )
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 20),
            _buildFieldCard("Medical Details", [
              _buildDropdown("Gender", _gender, ['Male', 'Female', 'Other'],
                      (v) => setState(() => _gender = v!),
                  enabled: _isEditing
              ),
              const SizedBox(height: 15),
              _buildDropdown("Blood Group", _bloodGroup, ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                      (v) => setState(() => _bloodGroup = v!),
                  enabled: _isEditing
              ),
            ]),

            const SizedBox(height: 40),
            if (_isEditing)
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
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Color(0xFF2E4D2F))
                      : const Text("Save & Backup Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Reused Helper methods (_buildFieldCard, _buildInput, _buildDropdown) stay the same ---
  Widget _buildFieldCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color:
          Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100)
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInput(String label,
      TextEditingController controller,
      TextInputType type, {bool enabled = true,
        Function(String)? onChanged}
      )
  {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: type,
      onChanged: onChanged,
      style: TextStyle(color: enabled ? Colors.black : Colors.grey),
      decoration: InputDecoration(labelText: label,
          labelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade100))
      ),
    );
  }

  Widget _buildDropdown(String label,
      String currentVal,
      List<String> items,
      Function(String?) onChanged,
      {bool enabled = true})
  {
    return DropdownButtonFormField<String>(
      // 'value' ko 'initialValue' se replace kar diya gaya hai
      initialValue: currentVal,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade100)),
      ),
      items: items.map((i) => DropdownMenuItem(
        value: i,
        child: Text(i),
      )).toList(),
    );
  }}