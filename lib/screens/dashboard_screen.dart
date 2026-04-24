import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:patientsphere/screens/profile_screen.dart';
import 'package:patientsphere/screens/sos_screen.dart';
import 'package:patientsphere/screens/book_appointment_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;

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

  // IP Config: Change this to your PC's IP address
  final String baseUrl = "http://192.168.43.180:5000";

  String displayBlood = "--";
  String displayAge = "--";
  String displayGender = "Male";
  String currentSosContact = "1122";

  Map<String, dynamic>? latestAppointment;
  bool isApptLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _fetchUserProfile(),
      _fetchLatestAppointment(),
    ]);
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_profile/${widget.userId}"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          displayBlood = data['blood_group'] ?? "O+";
          displayAge = data['age']?.toString() ?? "22";
          displayGender = data['gender'] ?? "Male";
          currentSosContact = data['sos_contact'] ?? "1122";
        });
      }
    } catch (e) {
      debugPrint("Profile Fetch Error: $e");
    }
  }

  Future<void> _fetchLatestAppointment() async {
    setState(() => isApptLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_latest_appointment/${widget.userId}"));
      if (response.statusCode == 200) {
        setState(() {
          latestAppointment = json.decode(response.body);
          isApptLoading = false;
        });
      } else {
        setState(() {
          latestAppointment = null;
          isApptLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Appt Fetch Error: $e");
      setState(() => isApptLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF90E094);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: primaryGreen,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildTopBar(),
                const SizedBox(height: 25),
                _buildSearchBar(),
                const SizedBox(height: 30),
                _buildProfileCard(),
                const SizedBox(height: 30),
                _buildSectionHeader("My Appointments"),
                const SizedBox(height: 15),
                _buildAppointmentWidget(),
                const SizedBox(height: 30),
                _buildSectionHeader("Trackers"),
                const SizedBox(height: 15),
                _buildTrackerSection(),
                const SizedBox(height: 30),
                _buildSectionHeader("Categories"),
                const SizedBox(height: 15),
                _buildCategorySection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return const Row(
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFEEEEEE)),
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
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userName: widget.userName,
              userEmail: widget.userEmail,
              userId: widget.userId,
            ),
          ),
        );
        _loadAllData();
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
                  Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _profileLabel("Blood: ", displayBlood),
                      const SizedBox(width: 10),
                      _profileLabel("Age: ", displayAge),
                      const SizedBox(width: 10),
                      _profileLabel("Gender: ", displayGender),
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

  Widget _profileLabel(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 10, color: Colors.black),
        children: [
          TextSpan(text: label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildAppointmentWidget() {
    if (isApptLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: Color(0xFF90E094)),
      ));
    }

    return GestureDetector(
      onTap: () => _navigateToAppointment(),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: latestAppointment == null ? _emptyAppt() : _activeAppt(),
      ),
    );
  }

  // Common Function for Appointment Navigation
  Future<void> _navigateToAppointment() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookAppointmentScreen(userId: widget.userId)),
    );
    _fetchLatestAppointment();
  }

  Widget _emptyAppt() {
    return const Row(
      children: [
        CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.add_task, color: Color(0xFF90E094))),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("No Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("Tap to book a new one", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Icon(Icons.add_circle_outline, color: Color(0xFF90E094)),
      ],
    );
  }

  Widget _activeAppt() {
    return Row(
      children: [
        const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.medical_services_outlined, color: Color(0xFF90E094))),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(latestAppointment!['doctor_name'] ?? "Doctor", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(latestAppointment!['department'] ?? "Specialist", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                  Text(" ${latestAppointment!['date']}", style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 12, color: Colors.black54),
                  Text(" ${latestAppointment!['time']}", style: const TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: Color(0xFF90E094), size: 20),
      ],
    );
  }

  Widget _buildTrackerSection() {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          _TrackerCard(label: "Blood Pressure", value: "120/80", unit: "mmHg"),
          _TrackerCard(label: "Temperature", value: "34", unit: "°C"),
          _TrackerCard(label: "Pulse", value: "80", unit: "bpm"),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          _CategoryItem(label: "Dental", icon: Icons.health_and_safety_outlined),
          _CategoryItem(label: "Cardiology", icon: Icons.favorite_border),
          _CategoryItem(label: "Dermatology", icon: Icons.face_outlined),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 4) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SOSTriggerScreen(sosContact: currentSosContact)));
            }
            // UPDATED: Appointment Icon Navigation (Index 3)
            else if (index == 3) {
              _navigateToAppointment();
            }
            else {
              setState(() => _selectedIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E4D2F),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Tracker"),
            BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: "Medication"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Appointment"),
            BottomNavigationBarItem(icon: Icon(Icons.sos, color: Colors.red, size: 28), label: "SOS"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("See all", style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline)),
      ],
    );
  }
}

class _TrackerCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _TrackerCard({required this.label, required this.value, required this.unit});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F8F1), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(" $unit", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ]),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CategoryItem({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFF5F5F5))),
      child: Column(children: [
        Icon(icon, color: const Color(0xFF90E094), size: 32),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}