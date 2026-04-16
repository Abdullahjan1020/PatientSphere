import 'package:flutter/material.dart';
import 'package:patientsphere/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId; // Integrity link: Received from Login

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // LOGIC 2: State variables to show real data on the card
  String displayBlood = "N/A";
  String displayAge = "N/A";
  String displayGender = "N/A";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. Top Bar
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFF1F8F1),
                    child: Icon(Icons.camera_alt_outlined, color: Color(0xFF90E094), size: 20),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Color(0xFF90E094), size: 18),
                      Text(" Quetta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF90E094),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 2. Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Find the doctor",
                    hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                    icon: Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: Icon(Icons.tune, color: Colors.grey, size: 20),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. Profile Card (Now dynamic)
              _buildProfileCard(),

              const SizedBox(height: 30),

              _buildSectionHeader("My Appointments"),
              const SizedBox(height: 15),
              _buildAppointmentCard(),

              const SizedBox(height: 30),

              _buildSectionHeader("Trackers"),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTrackerCard("Blood Pressure", "120/80", "mmHg"),
                    _buildTrackerCard("Temperature", "34", "°C"),
                    _buildTrackerCard("Pulse", "80", "bpm"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _buildSectionHeader("Categories"),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryItem("Dental", Icons.health_and_safety_outlined),
                    _buildCategoryItem("Cardiology", Icons.favorite_border),
                    _buildCategoryItem("Dermatology", Icons.face_outlined),
                    _buildCategoryItem("Ophthalmology", Icons.visibility_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              if (index == 4) debugPrint("SOS Triggered!");
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2E4D2F),
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Tracker"),
              BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: "Medication"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Appointment"),
              BottomNavigationBarItem(
                icon: Icon(Icons.sos, color: Colors.red, size: 28),
                label: "SOS",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () async {
        // Wait for updated bio-data from ProfileScreen
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
              userId: widget.userId,
            ),
          ),
        );

        // If user saved data, update the UI locally
        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            displayBlood = result['blood'] ?? "N/A";
            displayAge = result['age'] ?? "N/A";
            displayGender = result['gender'] ?? "N/A";
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF90E094), size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Blood: ", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(displayBlood, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 10),
                      const Text("Age: ", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(displayAge, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 10),
                      const Text("Gender: ", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(displayGender, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F))),
        const Text("See all", style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline)),
      ],
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.medical_services_outlined, color: Color(0xFF90E094)),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. Pakatess Buldakova", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Dermatology", style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                    Text(" 03/15/2026", style: TextStyle(fontSize: 11)),
                    SizedBox(width: 12),
                    Icon(Icons.access_time, size: 12, color: Colors.black54),
                    Text(" 10:00", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF90E094), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCard(String label, String value, String unit) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F1F1F))),
              Text(" $unit", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2)
            )
          ]
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF90E094), size: 32),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}