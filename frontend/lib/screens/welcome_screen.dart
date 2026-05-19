import 'package:flutter/material.dart';

// Reusable gradient used across the app
const LinearGradient logoGradient = LinearGradient(
  colors: [
    Color(0xFF1E567B),
    Color(0xFFC0A16B),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// LOGO IMAGE
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.05),
                child: Semantics(
                  label: "VocaSense security logo",
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              /// TITLE
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E567B),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              /// BRAND NAME
              const Text(
                "to VocaSense",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC0A16B),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Intelligent protection from spam and dangerous calls.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: screenHeight * 0.1),

              /// GRADIENT BUTTON
              Ink(
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(screenWidth * 0.75, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// TAGLINE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "VIGILANT ELDERLY CALL PROTECTION",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}