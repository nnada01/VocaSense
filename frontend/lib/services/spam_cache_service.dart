import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SpamCacheService {
  static const String spamNumbersKey = "spam_numbers_cache";
  final ApiService api = ApiService();

  Future<void> syncSpamNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final spamList = await api.syncSpamNumbers();

    final numbers = spamList
        .map((item) => item["phone"]?.toString() ?? "")
        .where((phone) => phone.isNotEmpty)
        .toList();

    await prefs.setString(spamNumbersKey, jsonEncode(numbers));
  }

  Future<List<String>> getSpamNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(spamNumbersKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = List<dynamic>.from(jsonDecode(raw));
    return decoded.map((e) => e.toString()).toList();
  }

  Future<bool> isSpamNumber(String phone) async {
    final numbers = await getSpamNumbers();
    return numbers.contains(phone);
  }
}