import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class PendingCallLogService {
  static const String key = "pending_call_logs";
  final ApiService api = ApiService();

  Future<void> uploadPendingLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);

    if (raw == null || raw.isEmpty) return;

    final List<dynamic> logs = jsonDecode(raw);

    for (final log in logs) {
      await api.logCall(
        phone: log["phone"],
        status: log["status"],
        riskScore: (log["risk_score"] as num?)?.toDouble(),
        source: log["source"] ?? "android_screening",
      );

      if (log["status"] == "spam" || log["status"] == "suspicious") {
        await api.createGuardianAlert(
          phone: log["phone"],
          status: log["status"],
          riskScore: (log["risk_score"] as num?)?.toDouble(),
          message: "VocaSense detected a risky call from ${log["phone"]}",
        );
      }
    }

    await prefs.remove(key);
  }
}