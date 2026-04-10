import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl' to pubspec.yaml for date formatting

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedDepartment = 'Cardiology';
  String selectedDoctor = 'Dr. Sarah Smith';

  final List<String> departments = ['Cardiology', 'Neurology', 'Orthopedics', 'General Physician'];
  final List<String> doctors = ['Dr. Sarah Smith', 'Dr. Ahmed Khan', 'Dr. John Weiss', 'Dr. Maria Ali'];

  // Date Picker Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  // Time Picker Logic
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Department", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedDepartment,
              items: departments.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => selectedDepartment = newValue!),
            ),
            const SizedBox(height: 20),

            const Text("Select Doctor", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedDoctor,
              items: doctors.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => selectedDoctor = newValue!),
            ),
            const SizedBox(height: 30),

            // Date Selection Tile
            ListTile(
              tileColor: Colors.blue.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(selectedDate == null
                  ? "Select Date"
                  : DateFormat('EEE, MMM d, yyyy').format(selectedDate!)),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 10),

            // Time Selection Tile
            ListTile(
              tileColor: Colors.blue.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: Text(selectedTime == null
                  ? "Select Time"
                  : selectedTime!.format(context)),
              onTap: () => _selectTime(context),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: (selectedDate != null && selectedTime != null)
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Appointment Requested Successfully!")),
                  );
                  Navigator.pop(context);
                }
                    : null,
                child: const Text("CONFIRM APPOINTMENT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}