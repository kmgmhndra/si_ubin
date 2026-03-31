import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Library OSM
import 'package:latlong2/latlong.dart'; // Helper Koordinat
import '../services/database_helper.dart';
import '../models/ubinan_history.dart';

// --- IMPORT HALAMAN KALKULATOR ---
import 'jagung_calculator.dart';
import 'padi_calculator.dart';
import 'kedelai_calculator.dart';
import 'kacang_tanah_calculator.dart';
import 'kacang_ijo_calculator.dart';
import 'ubi_kayu_calculator.dart';

class RiwayatMapsPage extends StatefulWidget {
  const RiwayatMapsPage({super.key});

  @override
  State<RiwayatMapsPage> createState() => _RiwayatMapsPageState();
}

class _RiwayatMapsPageState extends State<RiwayatMapsPage> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = true;

  // Posisi default (Indonesia Tengah)
  late LatLng _initialCenter;
  double _initialZoom = 5.0;

  @override
  void initState() {
    _initialCenter = const LatLng(-2.5489, 118.0149);
    super.initState();
    _loadData();
  }

  // --- 1. FUNGSI LOAD DATA ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dataList = await DatabaseHelper().getHistoryList();

    if (dataList.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _markers = [];
        });
      }
      return;
    }

    List<Marker> tempMarkers = [];

    for (var data in dataList) {
      tempMarkers.add(
        Marker(
          point: LatLng(data.latitude, data.longitude),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showDetailDialog(data),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _getMarkerColor(data.cropType),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: _getMarkerColor(data.cropType),
                    size: 30,
                  ),
                ),
                // Label kecil di bawah marker (Opsional)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data.cropType,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Auto zoom ke data terakhir
    if (dataList.isNotEmpty && _markers.isEmpty) {
      final newest = dataList.first;
      _initialCenter = LatLng(newest.latitude, newest.longitude);
      _initialZoom = 15.0;
    }

    if (mounted) {
      setState(() {
        _markers = tempMarkers;
        _isLoading = false;
      });
    }
  }

  // --- 2. FUNGSI NOTIFIKASI ---
  void _showTopNotification(
    String message,
    Color color, {
    IconData icon = Icons.info,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: -100, end: 0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  // --- 3. FUNGSI HAPUS ---
  Future<void> _deleteData(int id) async {
    await DatabaseHelper().deleteHistory(id);
    if (mounted) Navigator.pop(context);
    _loadData();
    if (mounted) {
      _showTopNotification(
        "Data berhasil dihapus",
        Colors.red[700]!,
        icon: Icons.delete_forever_rounded,
      );
    }
  }

  // --- 4. NAVIGASI EDIT ---
  void _navigateToCalculator(UbinanHistory data) {
    Navigator.pop(context);
    Widget? targetPage;
    String type = data.cropType.toLowerCase();

    if (type.contains('jagung')) {
      targetPage = JagungCalculatorPage(dataEdit: data);
    } else if (type.contains('padi')) {
      targetPage = PadiCalculatorPage(dataEdit: data);
    } else if (type.contains('kedelai')) {
      targetPage = KedelaiCalculatorPage(dataEdit: data);
    } else if (type.contains('kacang tanah')) {
      targetPage = KacangTanahCalculatorPage(dataEdit: data);
    } else if (type.contains('kacang hijau') || type.contains('kacang ijo')) {
      targetPage = KacangIjoCalculatorPage(dataEdit: data);
    } else if (type.contains('ubi kayu')) {
      targetPage = UbiKayuCalculatorPage(dataEdit: data);
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage!),
      ).then((_) => _loadData());
    } else {
      _showTopNotification("Fitur edit belum tersedia", Colors.orange);
    }
  }

  // --- MODERN DELETE CONFIRMATION DIALOG ---
  void _showDeleteConfirmationDialog(BuildContext context, UbinanHistory data) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder:
          (ctx) => Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ ICON & TITLE (MINIMAL)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 36,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Hapus Data?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ MESSAGE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Info data yang akan dihapus
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Warning text
                        Text(
                          "Data ini akan dihapus secara permanen dan tidak dapat dikembalikan.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ✅ BUTTONS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteData(data.id!);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Hapus",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Color _getMarkerColor(String crop) {
    String c = crop.toLowerCase();
    if (c.contains('padi')) return Colors.green[700]!;
    if (c.contains('jagung')) return Colors.orange[800]!;
    if (c.contains('kedelai')) return Colors.yellow[800]!;
    if (c.contains('kacang tanah')) return const Color(0xFFD84315);
    if (c.contains('kacang hijau') || c.contains('kacang ijo')) {
      return const Color(0xFF689F38);
    }
    if (c.contains('ubi kayu')) return const Color(0xFF795548);
    return Colors.red;
  }

  String _getProductionDetail(String crop) {
    String c = crop.toLowerCase();
    if (c.contains('padi')) return 'Beras';
    if (c.contains('jagung')) return 'Panen Kering';
    if (c.contains('kedelai')) return 'Biji Kering';
    if (c.contains('kacang tanah')) return 'Biji Kering';
    if (c.contains('kacang hijau') || c.contains('kacang ijo')) {
      return 'Biji Kering';
    }
    if (c.contains('ubi kayu')) return 'Ubi Berkulit';
    return 'Hasil';
  }

  // --- 5. TAMPILAN DETAIL (Redesigned) ---
  // --- 5. TAMPILAN DETAIL (SUDAH DITAMBAHKAN PETANI, POKTAN, LOKASI) ---
  void _showDetailDialog(UbinanHistory data) {
    Color themeColor = _getMarkerColor(data.cropType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => DraggableScrollableSheet(
            initialChildSize: 0.65, // Tinggi awal sedikit ditambah
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),

                    // --- FOTO (HERO ANIMATION) ---
                    if (data.photoPath != null &&
                        data.photoPath!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DetailFotoPage(
                                    imagePath: data.photoPath!,
                                    heroTag: 'img_${data.id}',
                                  ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'img_${data.id}',
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              image: DecorationImage(
                                image: FileImage(File(data.photoPath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.zoom_out_map,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Tap untuk memperbesar",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // HEADER JUDUL
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.spa, color: themeColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data.date,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CARD HASIL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [themeColor, themeColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Produksi ${data.cropType} (${_getProductionDetail(data.cropType)})",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    data.result.toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Ton/Ha",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ==========================================================
                    // --- BAGIAN BARU: LOKASI LAHAN (DITAMBAHKAN) ---
                    // ==========================================================
                    const Text(
                      "Lokasi Lahan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama Lokasi (Desa/Blok)
                                Text(
                                  data.locationName != null &&
                                          data.locationName!.isNotEmpty
                                      ? data.locationName!
                                      : "Lokasi tidak disebutkan",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Koordinat GPS
                                Text(
                                  "${data.latitude}, ${data.longitude}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================================
                    // --- BAGIAN BARU: INFORMASI PERSONIL (PETANI, POKTAN, SURVEYOR) ---
                    // ==========================================================
                    const Text(
                      "Informasi Personil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // 1. Baris Petani
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Nama Petani",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      data.farmerName != null &&
                                              data.farmerName!.isNotEmpty
                                          ? data.farmerName!
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, indent: 50),

                          // 2. Baris Poktan (Kelompok Tani)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.groups,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Kelompok Tani (Poktan)",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      data.poktanName != null &&
                                              data.poktanName!.isNotEmpty
                                          ? data.poktanName!
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, indent: 50),

                          // 3. Baris Surveyor
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.orange.withOpacity(
                                    0.1,
                                  ),
                                  child: const Icon(
                                    Icons.assignment_ind,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Petugas Surveyor",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      data.surveyorName != null &&
                                              data.surveyorName!.isNotEmpty
                                          ? data.surveyorName!
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // RINCIAN (NOTES) - Tetap sama
                    const Text(
                      "Detail Perhitungan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            data.notes.split('\n').map((line) {
                              if (line.trim().isEmpty) {
                                return const SizedBox.shrink();
                              }
                              if (line.contains('---')) return const Divider();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  line.trim(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                    height: 1.4,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL AKSI
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToCalculator(data),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit Data"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.blue[600]!),
                              foregroundColor: Colors.blue[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, data);
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text("Hapus"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false, // Biar Appbar tidak transparan numpuk map
      appBar: AppBar(
        title: const Text(
          "Peta Persebaran",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialCenter,
                      initialZoom: _initialZoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        // lyrs=y itu kode rahasia Google untuk "Hybrid" (Satelit + Nama Jalan/Tempat)
                        urlTemplate:
                            'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                        userAgentPackageName: 'com.example.multicalculator',
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                  // Tombol Floating Recenter (Opsional)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'btnRecenter',
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: Colors.blue),
                      onPressed: () {
                        if (_markers.isNotEmpty) {
                          // Kembali ke marker pertama
                          _mapController.move(_markers.first.point, 15);
                        } else {
                          _mapController.move(_initialCenter, 5);
                        }
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

// --- CLASS BARU: HALAMAN FULL SCREEN FOTO ---
class DetailFotoPage extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const DetailFotoPage({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam agar fokus
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            panEnabled: true, // Bisa digeser
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0, // Bisa di-zoom sampai 4x
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
