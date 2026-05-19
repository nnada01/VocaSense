import 'package:flutter/material.dart';
import '../services/api_service.dart';

const LinearGradient logoGradient = LinearGradient(
  colors: [
    Color(0xFF1E567B),
    Color(0xFFC0A16B),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService api = ApiService();

  bool liveDetection = true;
  bool callAlerts = true;
  bool soundWarnings = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final data = await api.getSettings();

      setState(() {
        liveDetection = data["live_detection"] ?? true;
        callAlerts = data["call_alerts"] ?? true;
        soundWarnings = data["sound_warnings"] ?? true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load settings: $e")),
      );
    }
  }

  Future<void> saveSettings() async {
    try {
      await api.saveSettings(
        liveDetection: liveDetection,
        callAlerts: callAlerts,
        soundWarnings: soundWarnings,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save settings: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E567B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Protection Settings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: SwitchListTile(
                title: const Text("Live Call Detection"),
                subtitle: const Text("Automatically detect spam calls"),
                value: liveDetection,
                onChanged: (val) {
                  setState(() => liveDetection = val);
                  saveSettings();
                },
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: SwitchListTile(
                title: const Text("Call Alerts"),
                subtitle: const Text("Notify for risky calls"),
                value: callAlerts,
                onChanged: (val) {
                  setState(() => callAlerts = val);
                  saveSettings();
                },
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: SwitchListTile(
                title: const Text("Sound Warnings"),
                subtitle: const Text("Play warning sound"),
                value: soundWarnings,
                onChanged: (val) {
                  setState(() => soundWarnings = val);
                  saveSettings();
                },
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: const ListTile(
                leading: Icon(Icons.phone),
                title: Text("Phone Number"),
                subtitle: Text("+96181873258"),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // logout later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text("Logout"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}