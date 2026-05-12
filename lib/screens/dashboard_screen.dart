import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:patientsphere/screens/profile_screen.dart';
import 'package:patientsphere/screens/sos_screen.dart';
import 'package:patientsphere/screens/book_appointment_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'high_priority_channel',
      'Urgent Notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ));
  }

  static Future<void> showInstantPopUp() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_priority_channel',
      'Urgent Notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );
    await _notificationsPlugin.show(0, 'PatientSphere', 'System Working Properly!',
        const NotificationDetails(android: androidDetails)
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;

  const DashboardScreen({super.key, required this.userName, required this.userEmail, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final String baseUrl = "http://192.168.43.180:5000";
  String displayBlood = "--", displayAge = "--", displayGender = "--", currentSosContact = "1122";
  Map<String, dynamic>? latestAppointment;
  bool isApptLoading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_fetchUserProfile(), _fetchLatestAppointment()]);
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_profile/${widget.userId}"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          displayBlood = data['blood_group'] ?? "--";
          displayAge = data['age']?.toString() ?? "--";
          displayGender = data['gender'] ?? "--";
          currentSosContact = data['sos_contact'] ?? "1122";
        });
      }
    } catch (e) {
      debugPrint(e.toString());
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
      setState(() => isApptLoading = false);
    }
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.info_outline, color: Color(0xFF90E094)),
          const SizedBox(width: 10),
          Expanded(child: Text("$featureName Coming Soon")),
        ]),
        content: const Text("Thank you for your patience!"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK",
                  style: TextStyle(color: Color(0xFF2E4D2F))
              )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: const Color(0xFF90E094),
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
                _buildSectionHeader("System Check"),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => NotificationService.showInstantPopUp(),
                    icon: const Icon(Icons.notifications_active, color: Colors.white),
                    label: const Text("Test Push Notification", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90E094),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
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
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFF1F8F1),
              child: Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF90E094),
                  size: 20)
          ),
          const Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: Color(0xFF90E094),
                    size: 18
                ),
                Text(" Quetta",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                )
              ]
          ),
          CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF90E094),
              child: Text(widget.userName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white)
              )
          )
        ]);
  }

  Widget _buildSearchBar() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFEEEEEE))
        ),
        child: const TextField(
            decoration: InputDecoration(
                hintText: "Find the doctor",
                icon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none)
        )
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userId: widget.userId))
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20)
        ),
        child: Row(children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF90E094))),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                        children: [
                          _profileLabel("Blood: ", displayBlood),
                          const SizedBox(width: 10),
                          _profileLabel("Age: ", displayAge),
                          const SizedBox(width: 10),
                          _profileLabel("Gender: ", displayGender)
                        ]
                    )
                  ]
              )
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _profileLabel(String l, String v) => Text("$l$v", style: const TextStyle(fontSize: 11));

  Widget _buildAppointmentWidget() {
    if (isApptLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF90E094)));
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20)
      ),
      child: latestAppointment == null
          ? const Text("No active appointments", style: TextStyle(color: Colors.grey))
          : Row(
          children: [
            const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.medical_services, color: Color(0xFF90E094)
                )
            ),
            const SizedBox(width: 15),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          latestAppointment!['doctor_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Text(
                          "${latestAppointment!['date']} at ${latestAppointment!['time']}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)
                      )
                    ]
                )
            ),
            const Icon(Icons.check_circle, color: Color(0xFF90E094))
          ]),
    );
  }

  Widget _buildTrackerSection() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      _tracker("BP", "120/80", "mmHg"),
      _tracker("Temp", "34", "°C"),
      _tracker("Pulse", "80", "bpm"),
    ]));
  }

  Widget _tracker(String l, String v, String u) => Container(
    width: 110, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF1F8F1), borderRadius: BorderRadius.circular(15)),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(u, style: const TextStyle(fontSize: 8))
        ]
    ),
  );

  Widget _buildCategorySection() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      _cat(Icons.health_and_safety, "Dental"),
      _cat(Icons.favorite, "Heart"),
      _cat(Icons.face, "Skin"),
    ]));
  }

  Widget _cat(IconData i, String l) => Container(
    width: 90, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFF5F5F5)
        )
    ),
    child: Column(
        children: [
          Icon(i, color: const Color(0xFF90E094), size: 28),
          Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
          )
        ]
    ),
  );

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20), height: 70,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20
            )
          ]
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == 4) {
            Navigator.push(
                context, MaterialPageRoute(
                builder: (c) => SOSTriggerScreen(
                    sosContact: currentSosContact))
            );
          } else if (i == 3) {
            Navigator.push(
                context, MaterialPageRoute(
                builder: (c) => BookAppointmentScreen(
                    userId: widget.userId))
            ).then((_) => _loadAllData());
          } else if (i == 1 || i == 2) {
            _showComingSoonDialog(i == 1 ? "Tracker" : "Meds");
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E4D2F),
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Tracker"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "Medication"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointment"),
          BottomNavigationBarItem(icon: Icon(Icons.sos, color: Colors.red), label: "SOS"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String t) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("See all", style: TextStyle(color: Colors.grey, fontSize: 12))
      ]
  );
}