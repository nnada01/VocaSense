import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const LinearGradient logoGradient = LinearGradient(
  colors: [
    Color(0xFF1E567B),
    Color(0xFFC0A16B),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

void verifyCode(String verificationId) async {
  final code = otpController.text.trim();

  print("Verify pressed");
  print("verificationId: $verificationId");
  print("code: $code");

  if (code.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter valid 6-digit code")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final result = await authService.verifyOtp(
      verificationId: verificationId,
      smsCode: code,
    );

    print("Verified successfully");
    print("UID: ${result.user?.uid}");
    print("Phone: ${result.user?.phoneNumber}");

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  } catch (e) {
    print("OTP verify error: $e");

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Verification failed: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String verificationId = args['verificationId'];

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: screenHeight * 0.1,
                bottom: screenHeight * 0.05,
              ),
              child: Image.asset(
                "assets/images/logo.png",
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              "Enter the 6-digit verification code sent to your phone",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                hintText: "enter code eg.13xxxx",
                hintStyle: const TextStyle(
                  fontSize: 14,),
              ),
              style: const TextStyle(fontSize: 22, letterSpacing: 10),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: logoGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => verifyCode(verificationId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLoading ? "Verifying..." : "Verify",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}