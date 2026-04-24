import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookAppointmentScreen extends StatefulWidget {
  final String userId;

  const BookAppointmentScreen({super.key, required this.userId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // IP Address Check: Mobile testing ke liye PC ka IP use karein
  final String baseUrl = "http://192.168.43.180:5000";

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedDepartment;
  Map<String, dynamic>? selectedDoctor;

  List<dynamic> allDoctors = [];
  List<String> departments = [];
  List<dynamic> filteredDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  // API CALL: Fetching Doctors from Python Backend
  Future<void> _fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_doctors"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          allDoctors = data;
          departments = data.map((e) => e['dept'].toString()).toSet().toList();
          if (departments.isNotEmpty) {
            selectedDepartment = departments[0];
            _filterDoctors(selectedDepartment!);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  void _filterDoctors(String dept) {
    setState(() {
      filteredDoctors = allDoctors.where((doc) => doc['dept'] == dept).toList();
      selectedDoctor = filteredDoctors.isNotEmpty ? filteredDoctors[0] : null;
    });
  }

  // API CALL: Posting Appointment to Python Backend
  Future<void> _confirmBooking() async {
    if (selectedDate == null || selectedTime == null || selectedDoctor == null) return;

    showDialog(context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF90E094)
            )
        )
    );

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/book_appointment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "doctor_id": selectedDoctor!['_id'],
          "doctor_name": selectedDoctor!['name'],
          "department": selectedDepartment,
          "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
          "time": selectedTime!.format(context),
        }),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.statusCode == 201) {
        _showSuccessSheet();
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF90E094), size: 80),
            const SizedBox(height: 20),
            const Text("Appointment Booked!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Your visit to ${selectedDoctor!['name']} is confirmed."),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4D2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)
                    )
                ),
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Back to Dashboard
                },
                child: const Text("BACK TO HOME", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF90E094);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Book Appointment",
          style: TextStyle(
              fontWeight: FontWeight.bold)
      ), backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Department", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdownContainer(
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                value: selectedDepartment,
                items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) {
                  setState(() => selectedDepartment = v!);
                  _filterDoctors(v!);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Doctor", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdownContainer(
              child: DropdownButton<dynamic>(
                isExpanded: true,
                underline: const SizedBox(),
                value: selectedDoctor,
                items: filteredDoctors.map((doc) => DropdownMenuItem(value: doc, child: Text(doc['name']))).toList(),
                onChanged: (v) => setState(() => selectedDoctor = v),
              ),
            ),
            const SizedBox(height: 30),
            _buildPickerTile(
              icon: Icons.calendar_month,
              label: selectedDate == null ? "Select Date" : DateFormat('EEE, MMM d, yyyy').format(selectedDate!),
              onTap: () async {
                final p = await showDatePicker(context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)
                    )
                );
                if (p != null) setState(() => selectedDate = p);
              },
            ),
            const SizedBox(height: 15),
            _buildPickerTile(
              icon: Icons.access_time,
              label: selectedTime == null ? "Select Time" : selectedTime!.format(context),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (t != null) setState(() => selectedTime = t);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4D2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)
                    )
                ),
                onPressed: _confirmBooking,
                child: const Text("CONFIRM APPOINTMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFF90E094).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }

  Widget _buildPickerTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      tileColor: const Color(0xFF90E094).withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: Icon(icon, color: const Color(0xFF90E094)),
      title: Text(label),
      onTap: onTap,
    );
  }
}