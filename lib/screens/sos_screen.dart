import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSTriggerScreen extends StatefulWidget {
  final String sosContact;

  const SOSTriggerScreen({super.key, required this.sosContact});

  @override
  State<SOSTriggerScreen> createState() => _SOSTriggerScreenState();
}

class _SOSTriggerScreenState extends State<SOSTriggerScreen> {
  int _secondsRemaining = 3;
  Timer? _timer;
  bool _isTriggered = false;
  bool _sosEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkSosStatus(); // Check if already enabled forever
  }

  // Check SharedPreferences to see if user already enabled SOS
  Future<void> _checkSosStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isAlreadyEnabled = prefs.getBool('sos_permanently_enabled') ?? false;

    if (isAlreadyEnabled) {
      setState(() => _sosEnabled = true);
      _startCountdown();
    } else {
      // First time user - show disclaimer
      WidgetsBinding.instance.addPostFrameCallback((_) => _showEmergencyDisclaimer());
    }
  }

  // Save the "Enabled" status permanently
  Future<void> _saveSosStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sos_permanently_enabled', true);
  }

  void _showEmergencyDisclaimer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align icon with top of text
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            // FIX: Using Expanded to prevent the yellow overflow barrier
            Expanded(
              child: Text(
                "Emergency Disclaimer",
                style: TextStyle(color: Colors.red, fontSize: 18),
                softWrap: true,
              ),
            ),
          ],
        ),
        content: const Text(
          "By enabling SOS, the app will automatically dial 1122. This is a one-time activation. Once enabled, clicking SOS will directly start the countdown in the future.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit screen
            },
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await _saveSosStatus(); // Save status forever
              if (mounted) {
                Navigator.pop(context); // Close dialog
                setState(() => _sosEnabled = true);
                _startCountdown();
              }
            },
            child: const Text("ENABLE & PROCEED", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        if (!_isTriggered) _executeEmergencyCall();
      }
    });
  }

  Future<void> _executeEmergencyCall() async {
    setState(() => _isTriggered = true);
    try {
      final Uri callUri = Uri.parse('tel:1122');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("SOS Call Error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "S.O.S EMERGENCY",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              !_sosEnabled
                  ? "Waiting for Activation..."
                  : (_isTriggered ? "Dialing 1122..." : "Countdown Started"),
              style: TextStyle(fontSize: 18, color: Colors.red.shade900),
            ),
            const SizedBox(height: 30),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150, width: 150,
                  child: CircularProgressIndicator(
                    value: _sosEnabled ? (_secondsRemaining / 3) : 0,
                    strokeWidth: 10,
                    color: Colors.red,
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                  ),
                ),
                Text(
                  "$_secondsRemaining",
                  style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 50),

            if (!_isTriggered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                onPressed: () {
                  _timer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }
}