import 'package:flutter/material.dart';
import 'package:vocasense/services/api_service.dart';
import 'guardian_model.dart';
import 'guardian_screen.dart';

const LinearGradient logoGradient = LinearGradient(
  colors: [
    Color(0xFF1E567B),
    Color(0xFFC0A16B),
  ],
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();

  List<Guardian> guardians = [];
  bool isLoading = true;
  List<dynamic> callHistory = [];

  @override
  void initState() {
    super.initState();
    loadGuardians();
    loadCallHistory();
  }

  Future<void> loadGuardians() async {
    try {
      final data = await api.getGuardians();

      setState(() {
        guardians = data.map((g) => Guardian(
          id: g['id'],
          name: g['name'],
          phone: g['phone'],
        )).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load guardians: $e")),
      );
    }
  }

  Future<void> _openGuardians() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuardianScreen(guardians: guardians),
      ),
    );

    if (result == true) {
      await loadGuardians();
    }
  }

  Future<void> loadCallHistory() async {
    try {
      final data = await api.getCallHistory();

      setState(() {
        callHistory = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load call history: $e")),
      );
   }
 }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("VocaSense"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E567B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.green, size: 36),
                  SizedBox(width: 12),
                  Text("Protection Active",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 15),


            //  Guardians
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Guardians",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  Text(
                    isLoading
                        ? "Loading guardians..."
                        : guardians.isEmpty
                        ? "No guardians added"
                        : "${guardians.length} guardian(s) connected",
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openGuardians,
                          child: const Text("Add"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _openGuardians,
                          child: const Text("View"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            Expanded(
              child: callHistory.isEmpty
                  ? const Center(child: Text("No call history yet"))
                  : ListView.builder(
                      itemCount: callHistory.length,
                      itemBuilder: (context, index) {
                        final call = callHistory[index];
                        final status = call["status"] ?? "unknown";
                        final phone = call["phone"] ?? "Unknown";
                        final risk = call["risk_score"];

                        IconData icon;
                        Color color;

                        if (status == "spam") {
                          icon = Icons.warning;
                          color = Colors.red;
                        } else if (status == "suspicious") {
                          icon = Icons.error_outline;
                          color = Colors.orange;
                        } else {
                          icon = Icons.check_circle;
                          color = Colors.green;
                        }

                        return Card(
                          child: ListTile(
                            leading: Icon(icon, color: color),
                            title: Text(phone),
                            subtitle: Text(
                              risk == null
                                  ? "Status: $status"
                                  : "Status: $status • Risk: $risk",
                            ),
                          ),
                        );
                      },
                   ),
             ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/history');
                    },
                    child: const Text("History"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: const Text("Settings"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}