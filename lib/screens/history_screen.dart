import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService api = ApiService();

  List<dynamic> callHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final data = await api.getCallHistory();

      setState(() {
        callHistory = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load history: $e")),
      );
    }
  }

  Color getRiskColor(String status) {
    if (status == "spam") return Colors.red;
    if (status == "suspicious") return Colors.orange;
    return Colors.green;
  }

  IconData getRiskIcon(String status) {
    if (status == "spam") return Icons.warning;
    if (status == "suspicious") return Icons.error_outline;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Call History"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E567B),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : callHistory.isEmpty
              ? const Center(child: Text("No call history yet"))
              : RefreshIndicator(
                  onRefresh: loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: callHistory.length,
                    itemBuilder: (context, index) {
                      final call = callHistory[index];
                      final phone = call["phone"] ?? "Unknown";
                      final status = call["status"] ?? "unknown";
                      final risk = call["risk_score"];
                      final source = call["source"] ?? "unknown";

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            getRiskIcon(status),
                            color: getRiskColor(status),
                          ),
                          title: Text(phone),
                          subtitle: Text(
                            risk == null
                                ? "Status: $status • Source: $source"
                                : "Status: $status • Risk: $risk • Source: $source",
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}