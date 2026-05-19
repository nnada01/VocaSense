import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getIdToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getGuardians() async {
    final res = await http.get(
      Uri.parse("$baseUrl/guardians/"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load guardians: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> addGuardian(String name, String phone) async {
    final res = await http.post(
      Uri.parse("$baseUrl/guardians/"),
      headers: await _headers(),
      body: jsonEncode({
        "name": name,
        "phone": phone,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to add guardian: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  Future<void> deleteGuardian(String id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/guardians/$id"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to delete guardian: ${res.body}");
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    final res = await http.get(
      Uri.parse("$baseUrl/settings/"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load settings: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> saveSettings({
    required bool liveDetection,
    required bool callAlerts,
    required bool soundWarnings,
  }) async {
    final res = await http.put(
      Uri.parse("$baseUrl/settings/"),
      headers: await _headers(),
      body: jsonEncode({
        "live_detection": liveDetection,
        "call_alerts": callAlerts,
        "sound_warnings": soundWarnings,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to save settings: ${res.body}");
    }
  }
  Future<Map<String, dynamic>> checkNumber(String phone) async {
    final res = await http.post(
     Uri.parse("$baseUrl/calls/check-number"),
     headers: {
       "Content-Type": "application/json",
     },
     body: jsonEncode({
       "phone": phone,
     }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to check number: ${res.body}");
    }

    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  Future<Map<String, dynamic>> reportSpam({
    required String phone,
    String? reason,
    double? riskScore,
    String source = "manual",
  }) async {
    final res = await http.post(
     Uri.parse("$baseUrl/calls/report-spam"),
     headers: await _headers(),
     body: jsonEncode({
       "phone": phone,
       "reason": reason,
       "risk_score": riskScore,
       "source": source,
     }),
   );

   if (res.statusCode != 200) {
     throw Exception("Failed to report spam: ${res.body}");
   }

   return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  Future<List<dynamic>> syncSpamNumbers() async {
    final res = await http.get(
     Uri.parse("$baseUrl/calls/sync"),
     headers: {
       "Content-Type": "application/json",
     },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to sync spam numbers: ${res.body}");
    }

    return List<dynamic>.from(jsonDecode(res.body));
  }

  Future<void> logCall({
    required String phone,
    required String status,
    double? riskScore,
    String source = "manual",
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/calls/log"),
      headers: await _headers(),
      body: jsonEncode({
        "phone": phone,
        "status": status,
        "risk_score": riskScore,
        "source": source,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to log call: ${res.body}");
    }
 }

  Future<List<dynamic>> getCallHistory() async {
    final res = await http.get(
      Uri.parse("$baseUrl/calls/history"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load call history: ${res.body}");
    }

    return List<dynamic>.from(jsonDecode(res.body));
  }

  Future<void> createGuardianAlert({
    required String phone,
    required String status,
    double? riskScore,
    String? message,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/alerts/guardian"),
      headers: await _headers(),
      body: jsonEncode({
        "phone": phone,
        "status": status,
        "risk_score": riskScore,
        "message": message,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to create guardian alert: ${res.body}");
    }
  }


}