class AiScamAnalyzer {
  Map<String, dynamic> analyze(String text) {
    final lower = text.toLowerCase();

    double score = 0.0;
    List<String> reasons = [];

    void addRisk(String pattern, double value, String reason) {
      if (lower.contains(pattern)) {
        score += value;
        reasons.add(reason);
      }
    }

    addRisk("otp", 0.30, "Caller mentioned OTP");
    addRisk("verification code", 0.35, "Caller asked for a verification code");
    addRisk("password", 0.35, "Caller mentioned password");
    addRisk("bank", 0.25, "Caller mentioned bank information");
    addRisk("account", 0.20, "Caller mentioned account details");
    addRisk("card blocked", 0.35, "Caller claimed a card is blocked");
    addRisk("urgent", 0.20, "Caller used urgent language");
    addRisk("urgently", 0.20, "Caller used urgent language");
    addRisk("quickly", 0.20, "Caller used urgent language");
    addRisk("no time", 0.20, "Caller used urgent language");
    addRisk("credit card information", 0.70, "Caller asked for credit card infromation");
    addRisk("transfer", 0.30, "Caller mentioned money transfer");
    addRisk("send money", 0.40, "Caller asked to send money");
    addRisk("gift card", 0.40, "Caller mentioned gift cards");
    addRisk("whish", 0.25, "Caller mentioned Whish payment");

    if (score > 1.0) score = 1.0;

    String label;
    if (score >= 0.7) {
      label = "scam";
    } else if (score >= 0.4) {
      label = "suspicious";
    } else {
      label = "safe";
    }

    return {
      "label": label,
      "risk_score": score,
      "reason": reasons.isEmpty
          ? "No strong scam pattern detected"
          : reasons.join(", "),
    };
  }
}