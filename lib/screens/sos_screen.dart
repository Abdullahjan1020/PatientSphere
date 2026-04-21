import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class SOSTriggerScreen extends StatefulWidget {
  final String sosContact; // Dashboard se aya hua user ka emergency number

  const SOSTriggerScreen({super.key, required this.sosContact});

  @override
  State<SOSTriggerScreen> createState() => _SOSTriggerScreenState();
}

class _SOSTriggerScreenState extends State<SOSTriggerScreen> {
  int _secondsRemaining = 3;
  Timer? _timer;
  bool _isTriggered = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        if (!_isTriggered) {
          _executeEmergencyProtocol();
        }
      }
    });
  }

  Future<void> _executeEmergencyProtocol() async {
    setState(() => _isTriggered = true);

    try {
      // 1. Get Current Location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String locationMsg =
          "EMERGENCY! I need help. My location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // 2. ACTION A: Call 1122 (Rescue Services)
      final Uri callUri = Uri.parse('tel:1122');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      }

      // Small delay taake dialer load hone ke baad WhatsApp load ho
      await Future.delayed(const Duration(milliseconds: 1000));

      // 3. ACTION B: WhatsApp message to Bio-data Contact
      // Number format fix (Pakistan 92)
      String cleanContact = widget.sosContact.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanContact.startsWith('0')) {
        cleanContact = "92${cleanContact.substring(1)}";
      }else if (cleanContact.startsWith('3') && cleanContact.length == 10) {
        cleanContact = "92$cleanContact";
      }

      final Uri whatsappUri = Uri.parse(
          "https://wa.me/$cleanContact?text=${Uri.encodeComponent(locationMsg)}");

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }

    } catch (e) {
      debugPrint("SOS Error: $e");
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
              _isTriggered ? "Contacting Help..." : "Sending help in:",
              style: TextStyle(fontSize: 18, color: Colors.red.shade900),
            ),
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150, width: 150,
                  child: CircularProgressIndicator(
                    value: _secondsRemaining / 3,
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
            else
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 10),
                  Text("Calling 1122 & Messaging Contact...",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}