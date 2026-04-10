import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:patientsphere/models/patient_model.dart';
import 'package:patientsphere/widgets/vital_card.dart';
import 'package:patientsphere/screens/book_appointment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Mock data matching your Patient Model
  final Patient patient = Patient(
    id: "PAT-2026-088",
    name: "John Doe",
    gender: "Male",
    age: 28,
    bloodGroup: "O+",
    vitals: {
      "BP": "118/75",
      "Sugar": "92 mg/dL",
      "Weight": "72 kg",
      "Height": "178 cm",
      "BMI": "22.7",
    },
    history: ["Appendectomy (2022)", "Seasonal Dust Allergy"],
    appointments: [
      {"date": "2026-04-15", "doctor": "Dr. Sarah Smith", "time": "10:30 AM"}
    ],
    prescribedDiet: "Low Sodium, High Protein, avoid caffeine after 6 PM.",
    emergencyContact: "+92 300 1234567",
  );

  // --- Logic: Profile Picture ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500, // Optimize image size for mobile
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic: SOS Dialer ---
  Future<void> _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showSOSMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("EMERGENCY CALL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.red),
              title: const Text("Edhi Ambulance (115)"),
              onTap: () => _makeCall("115"),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety, color: Colors.orange),
              title: const Text("Chippa (1020)"),
              onTap: () => _makeCall("1020"),
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone, color: Colors.blue),
              title: const Text("Emergency Contact"),
              onTap: () => _makeCall(patient.emergencyContact),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildVitalsGrid(),
            _buildAppointmentCard(),
            _buildDietSection(),
            _buildHistorySection(),
            const SizedBox(height: 30),
            _buildSOSButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blueAccent,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 15, color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Age: ${patient.age} | ${patient.gender}", style: const TextStyle(color: Colors.blueGrey)),
                const SizedBox(height: 5),
                Text("Blood Group: ${patient.bloodGroup}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookAppointmentScreen())),
          icon: const Icon(Icons.calendar_month),
          label: const Text("Book New Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Current Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              VitalCard(title: "BP", value: patient.vitals["BP"]!, icon: Icons.favorite),
              VitalCard(title: "Sugar", value: patient.vitals["Sugar"]!, icon: Icons.bloodtype),
              VitalCard(title: "BMI", value: patient.vitals["BMI"]!, icon: Icons.monitor_weight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    final lastAppt = patient.appointments.last;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.event, color: Colors.blueAccent),
          title: const Text("Next Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${lastAppt["doctor"]} on ${lastAppt["date"]}"),
        ),
      ),
    );
  }

  Widget _buildDietSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.green.withValues(alpha: 0.05),
        child: ListTile(
          leading: const Icon(Icons.restaurant, color: Colors.green),
          title: const Text("Diet Plan", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(patient.prescribedDiet),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Medical History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...patient.history.map((h) => ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.blueAccent),
            title: Text(h),
            dense: true,
          )),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onLongPress: _showSOSMenu,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: const Center(
            child: Text("HOLD FOR SOS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}