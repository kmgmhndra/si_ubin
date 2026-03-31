import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Hanya perlu import Splash Screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Ubinan Pertanian',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        // Menggunakan warna hijau spesifik agar sama dengan Header Home Page
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
        // Opsional: Jika ingin font default yang lebih modern
        fontFamily: 'Poppins',
      ),
      // Alur: Main -> Splash Screen --(3 detik)--> Home Page
      home: const SplashScreen(),
    );
  }
}
