import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:patientsphere/models/patient_model.dart';
import 'package:patientsphere/widgets/vital_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Synchronized Mock Data
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
    appointments: [{"date": "2026-04-15", "doctor": "Dr. Sarah Smith"}],
    prescribedDiet: "Low Sodium, High Protein, avoid caffeine after 6 PM.",
    emergencyContact: "+92 300 1234567",
  );

  // --- Logic Functions ---

  Future<void> _makeEmergencyCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
    } else {
    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Could not launch the dialer")),
    );
    }
    }
  }

  void _showSOSOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            const Text("EMERGENCY SERVICES",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSOSOption(Icons.local_shipping, "Call Edhi Ambulance (115)", "115", Colors.red),
            _buildSOSOption(Icons.health_and_safety, "Call Chippa (1020)", "1020", Colors.orange),
            _buildSOSOption(Icons.contact_phone, "Call Emergency Contact", patient.emergencyContact, Colors.blue),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSOption(IconData icon, String label, String number, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      subtitle: Text(number),
      onTap: () {
        Navigator.pop(context);
        _makeEmergencyCall(number);
      },
    );
  }

  // --- UI Building Blocks ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildVitalsGrid(),
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
          const Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Age: ${patient.age} | ${patient.gender}",
                    style: const TextStyle(color: Colors.blueGrey)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Blood Group: ${patient.bloodGroup}",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Current Vitals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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

  Widget _buildDietSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.green.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.green, width: 0.5)),
        child: ListTile(
          leading: const Icon(Icons.restaurant, color: Colors.green),
          title: const Text("Prescribed Diet", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(patient.prescribedDiet),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Medical History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          ...patient.history.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 10),
                Text(item, style: const TextStyle(fontSize: 15)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onLongPress: _showSOSOptions,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sos, color: Colors.white, size: 35),
              SizedBox(width: 15),
              Text("HOLD FOR SOS",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}