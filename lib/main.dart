import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/spam_cache_service.dart';
import 'services/pending_call_log_service.dart';
import 'app_lifecycle_handler.dart';
import 'screens/history_screen.dart';
import 'screens/listening_prompt_screen.dart';
import 'screens/listening_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await SpamCacheService().syncSpamNumbers();
  } catch (e) {
    print("Initial spam sync failed: $e");
  }

  try {
    await PendingCallLogService().uploadPendingLogs();
  } catch (e) {
    print("Pending call log upload failed: $e");
  }

  runApp(
    const AppLifecycleHandler(
      child: VocaApp(),
    ),
  );
}

class VocaApp extends StatelessWidget {
  const VocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Voca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Use named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/listening-prompt': (context) => const ListeningPromptScreen(),
        '/listening': (context) => const ListeningScreen(),
      },
    );
  }
}