import 'package:flutter/material.dart';

class AppGradients {

  // 1️⃣ Dark Background (Ultra Deep Premium)
  static const LinearGradient darkBlueBackground = LinearGradient(
    colors: [
      Color(0xFF1E3A5F),
      Color(0xFF111827),
      Color(0xFF020617),   // almost black
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 2️⃣ Primary (Deep Indigo)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF5B5FF0),
      Color(0xFF3730A3),
      Color(0xFF0F172A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 3️⃣ Green (Premium Dark)
  static const LinearGradient greenGradient = LinearGradient(
    colors: [
      Color(0xFF22C55E),
      Color(0xFF15803D),
      Color(0xFF022C22),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 4️⃣ Yellow (Golden Premium)
  static const LinearGradient yellowGradient = LinearGradient(
    colors: [
      Color(0xFFFACC15),
      Color(0xFFB45309),
      Color(0xFF422006),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 5️⃣ Blue (Game Style Blue)
  static const LinearGradient blueGradient = LinearGradient(
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF1D4ED8),
      Color(0xFF0C1E3A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 6️⃣ Red (Deep Game Red)
  static const LinearGradient redGradient = LinearGradient(
    colors: [
      Color(0xFFEF4444),
      Color(0xFF991B1B),
      Color(0xFF2B0B0B),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 7️⃣ Purple (Premium Royal)
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [
      Color(0xFFA855F7),
      Color(0xFF6B21A8),
      Color(0xFF1E0A33),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 8️⃣ Orange (Game Button Style)
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [
      Color(0xFFF97316),
      Color(0xFF9A3412),
      Color(0xFF3F1A0A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}