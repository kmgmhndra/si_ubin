import 'package:flutter/material.dart';

/// Utility class untuk validasi input di calculator screens
class InputValidator {
  /// Validasi input Luas Lahan dan Data Ubinan
  ///
  /// Returns null jika valid, atau pesan error jika ada masalah
  static String? validateCalculatorInputs(
    double? luasLahan,
    double? dataUbinan,
  ) {
    // Cek apakah bisa diparse
    if (luasLahan == null) {
      return '⚠️ Luas Lahan harus berupa angka yang valid';
    }
    if (dataUbinan == null) {
      return '⚠️ Data Ubinan harus berupa angka yang valid';
    }

    // Cek range nilai untuk Luas Lahan
    if (luasLahan <= 0) {
      return '⚠️ Luas Lahan harus lebih dari 0 hektar';
    }
    if (luasLahan > 5000) {
      return '⚠️ Luas Lahan tidak boleh lebih dari 5000 hektar (nilai tidak realistis)';
    }

    // Cek range nilai untuk Data Ubinan
    if (dataUbinan <= 0) {
      return '⚠️ Data Ubinan harus lebih dari 0 kg';
    }
    if (dataUbinan > 500000) {
      return '⚠️ Data Ubinan tidak boleh lebih dari 500.000 kg (nilai tidak realistis)';
    }

    return null; // Tidak ada error
  }

  /// Helper untuk menampilkan error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Helper untuk menampilkan success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Validasi custom untuk komoditas tertentu (jika ada kebutuhan khusus)
  static String? validateByKomoditas(
    String komoditas,
    double? luasLahan,
    double? dataUbinan,
  ) {
    // Validasi umum dulu
    final basicError = validateCalculatorInputs(luasLahan, dataUbinan);
    if (basicError != null) return basicError;

    // Validasi khusus per komoditas (bisa ditambahkan nanti jika ada kebutuhan)
    switch (komoditas.toLowerCase()) {
      case 'padi':
        // Contoh: Padi biasanya range tertentu
        if (luasLahan! > 100 && dataUbinan! < 100) {
          return '⚠️ Kombinasi Luas Lahan dan Ubinan tidak realistis untuk Padi';
        }
        break;

      case 'jagung':
        // Contoh validasi jagung
        break;

      default:
        break;
    }

    return null;
  }

  /// Parse double dari text dengan error handling
  static double? parseDouble(String text) {
    try {
      return double.parse(text.replaceAll(',', '.').trim());
    } catch (e) {
      return null;
    }
  }
}
