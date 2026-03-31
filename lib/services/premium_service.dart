import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ID Produk sesuai di Google Play Console
  static const String premiumId = 'premium_15k';
  static const String _premiumKey = 'is_premium_user';
  SharedPreferences? _prefs;

  // Callback untuk update UI secara otomatis
  Function()? onPurchaseSuccess;
  Function(String errorMessage)? onPurchaseError;

  /// 1. INITIALIZE (Panggil di main.dart atau initState awal)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Pastikan subscription lama dibersihkan jika ada
    await _subscription?.cancel();

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('❌ Error IAP Stream: $error');
      },
    );

    // OTOMATIS: Cek ke server Google apakah user ini sudah pernah beli
    // Kita panggil setelah jeda singkat agar stream siap
    Timer(const Duration(seconds: 2), () {
      restorePurchases();
    });
  }

  /// 2. CEK STATUS LOKAL (Untuk buka/tutup gembok di UI)
  Future<bool> isPremiumUser() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_premiumKey) ?? false;
  }

  /// 3. PROSES BELI (Dipanggil saat klik tombol "Beli")
  Future<void> buyPremium() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        _handleError('Layanan Google Play tidak tersedia.');
        return;
      }

      const Set<String> kIds = {premiumId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        kIds,
      );

      if (response.notFoundIDs.isNotEmpty) {
        _handleError(
          'Produk tidak ditemukan. Pastikan ID dan Akun Penguji benar.',
        );
        return;
      }

      if (response.productDetails.isNotEmpty) {
        final ProductDetails productDetails = response.productDetails.first;
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: productDetails,
        );

        // Memulai proses pembayaran
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      _handleError('Terjadi kesalahan sistem: $e');
    }
  }

  /// 4. RESTORE (Memulihkan pembelian lama)
  Future<void> restorePurchases() async {
    final bool available = await _iap.isAvailable();
    if (available) {
      debugPrint('🔄 Sinkronisasi status pembelian dengan Google...');
      await _iap.restorePurchases();
    }
  }

  /// 5. LISTENER (Otak yang menangani respon Google)
  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        debugPrint('⏳ Menunggu konfirmasi pembayaran...');
      } else if (purchase.status == PurchaseStatus.error) {
        _handleError('Gagal: ${purchase.error?.message ?? "Dibatalkan"}');
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Berhasil beli ATAU Berhasil dipulihkan (Restored)
        await _savePremiumStatus(true);
        debugPrint('✅ AKSES PREMIUM AKTIF!');

        if (onPurchaseSuccess != null) {
          onPurchaseSuccess!();
        }
      }

      // Selesaikan transaksi (Wajib!)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// 6. SIMPAN KE MEMORI HP
  Future<void> _savePremiumStatus(bool status) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_premiumKey, status);
  }

  /// 7. ERROR HANDLER
  void _handleError(String msg) {
    debugPrint('❌ $msg');
    if (onPurchaseError != null) {
      onPurchaseError!(msg);
    }
  }

  /// 8. RESET (Hanya untuk testing di Emulator/Debug)
  Future<void> resetPremiumStatus() async {
    if (kDebugMode) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setBool(_premiumKey, false);
      debugPrint('🗑️ Status Premium di-reset (Mode Debug)');
    }
  }
}
