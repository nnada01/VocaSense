import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../services/ai_scam_analyzer.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final stt.SpeechToText speech = stt.SpeechToText();
  final ApiService api = ApiService();
  final AiScamAnalyzer aiAnalyzer = AiScamAnalyzer();

  bool isListening = false;
  bool alertAlreadyTriggered = false;

  String detectedText = "";
  String aiLabel = "safe";
  String aiReason = "No scam detected yet";
  double riskScore = 0.0;

  @override
  void initState() {
    super.initState();
    startListening();
  }

Future<void> startListening() async {
  final available = await speech.initialize(
    onStatus: (status) {
      print("Speech status: $status");
    },
    onError: (error) {
      print("Speech error: $error");
    },
  );

  print("Speech available: $available");

  if (!available) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Speech recognition is not available")),
    );
    return;
  }

  setState(() => isListening = true);

  speech.listen(
    onResult: (result) {
      print("Speech result: ${result.recognizedWords}");

      final aiResult = aiAnalyzer.analyze(result.recognizedWords);

      setState(() {
        detectedText = result.recognizedWords;
        riskScore = aiResult["risk_score"];
        aiLabel = aiResult["label"];
        aiReason = aiResult["reason"];
      });

      if (riskScore >= 0.6 && !alertAlreadyTriggered) {
        alertAlreadyTriggered = true;
        triggerGuardianAlert();
      }
    },
  );
}

  Future<void> triggerGuardianAlert() async {
    await speech.stop();

    setState(() {
      isListening = false;
    });

    await api.logCall(
      phone: "active_call",
      status: aiLabel,
      riskScore: riskScore,
      source: "ai_speech_detection",
    );

    await api.createGuardianAlert(
      phone: "active_call",
      status: aiLabel,
      riskScore: riskScore,
      message:
          "VocaSense detected suspicious scam language during an active call. Reason: $aiReason",
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Warning"),
        content: Text(
          "Suspicious scam language was detected.\n\nAI Analysis: $aiLabel\nRisk: ${(riskScore * 100).toStringAsFixed(0)}%\n\nYour guardian has been alerted.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool highRisk = riskScore >= 0.6;

    return Scaffold(
      backgroundColor: highRisk ? Colors.red[50] : const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Scam Listening"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E567B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Icon(
              isListening ? Icons.mic : Icons.mic_off,
              size: 110,
              color: isListening ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 25),
            Text(
              isListening ? "Listening for scam language..." : "Listening stopped",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Risk Score: ${(riskScore * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: highRisk ? Colors.red : Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "AI Analysis: ${aiLabel.toUpperCase()}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: highRisk ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              aiReason,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                detectedText.isEmpty
                    ? "Detected speech will appear here."
                    : detectedText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: () async {
                  await speech.stop();
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "STOP LISTENING",
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}