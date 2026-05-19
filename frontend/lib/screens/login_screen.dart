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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  void sendCode() async {
    String rawPhone = phoneController.text.trim();

    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter phone number")),
      );
      return;
    }
    rawPhone = rawPhone.replaceAll(' ', '');
    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1);
    }
    final phoneNumber = "+961$rawPhone";
    
    print("Sending OTP to: $phoneNumber");
    

    setState(() => isLoading = true);

    await authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        setState(() => isLoading = false);
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {
            'verificationId': verificationId,
            'phone': phoneNumber,
          },
        );
      },
      onFailed: (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "OTP failed")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              "Enter your phone number to get started",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixText: "+961 ",
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
              ),
              style: const TextStyle(fontSize: 18),
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
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLoading ? "Sending..." : "Send Verification Code",
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