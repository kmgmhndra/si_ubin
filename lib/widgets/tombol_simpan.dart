import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// ✅ IMPORT FLUTTER MAP
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../models/ubinan_history.dart';
import '../services/database_helper.dart';
import '../screens/home_page.dart';

class TombolSimpan extends StatefulWidget {
  final String komoditas;
  final double hasilPanen;
  final String catatan;
  final bool isVisible;
  final int? historyId;
  final String? existingPhotoPath;
  final TextEditingController? surveyorController;
  final TextEditingController? farmerController;
  final TextEditingController? poktanController;
  final TextEditingController? locationController;
  final double? existingLatitude;
  final double? existingLongitude;

  const TombolSimpan({
    super.key,
    required this.komoditas,
    required this.hasilPanen,
    required this.catatan,
    this.isVisible = false,
    this.historyId,
    this.existingPhotoPath,
    this.surveyorController,
    this.farmerController,
    this.poktanController,
    this.locationController,
    this.existingLatitude,
    this.existingLongitude,
  });

  @override
  State<TombolSimpan> createState() => _TombolSimpanState();
}

class _TombolSimpanState extends State<TombolSimpan> {
  bool _isSaving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ✅ Variabel untuk lokasi
  latlong.LatLng? _selectedLocation;
  bool _isLocationLocked = false;

  // ✅ Controller untuk Flutter Map - Lazy initialization
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Initialize di initState
    if (widget.existingPhotoPath != null &&
        widget.existingPhotoPath!.isNotEmpty) {
      _selectedImage = File(widget.existingPhotoPath!);
    }
    // ✅ Saat Edit: Load lokasi terakhir
    if (widget.historyId != null &&
        widget.existingLatitude != null &&
        widget.existingLongitude != null) {
      _selectedLocation = latlong.LatLng(
        widget.existingLatitude!,
        widget.existingLongitude!,
      );
      _isLocationLocked = true;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ✅ FUNGSI UPDATE MARKER
  void _updateMarker(latlong.LatLng position) {
    setState(() {
      _selectedLocation = position;
      _isLocationLocked = false; // Marker sudah diedit manual
    });
  }

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
                builder:
                    (context, value, child) => Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    ),
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
                        color: Colors.black.withOpacity(0.2),
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
                            fontSize: 14,
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
    Future.delayed(
      const Duration(milliseconds: 2500),
      () => overlayEntry.remove(),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showTopNotification("Gagal mengambil foto: $e", Colors.red);
    }
  }

  // ✅ FUNGSI AMBIL LOKASI GPS
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showTopNotification('Aktifkan GPS Anda', Colors.orange[800]!);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showTopNotification('Izin lokasi ditolak', Colors.orange[800]!);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showTopNotification(
          'GPS dinonaktifkan permanen. Buka Settings.',
          Colors.red[700]!,
        );
        return;
      }

      // Loading dialog dengan background
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.teal),
                      const SizedBox(height: 16),
                      const Text(
                        'Mengambil Posisi GPS...',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Akurasi Tinggi (±20m)',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
        );
      }

      // Ambil posisi dengan timeout lebih lama untuk akurasi tinggi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30), // Timeout lebih lama
        forceAndroidLocationManager: true,
      ).timeout(
        const Duration(seconds: 35),
        onTimeout: () {
          throw 'GPS timeout - coba lagi dengan GPS in outdoor yang lebih terbuka';
        },
      );

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      final newLocation = latlong.LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
        _isLocationLocked = true;
      });

      // ✅ GERAKKAN KAMERA KE LOKASI BARU dengan delay
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          if (mounted) {
            _mapController.move(newLocation, 17);
          }
        } catch (e) {
          debugPrint('⚠️ Map move error: $e');
        }
      });

      _showTopNotification(
        'Lokasi berhasil diambil!\nAkurasi: ${position.accuracy.toStringAsFixed(1)}m',
        Colors.green[700]!,
        icon: Icons.location_on,
      );

      debugPrint(
        '📍 GPS: Lat=${position.latitude}, Lng=${position.longitude} (±${position.accuracy}m)',
      );
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showTopNotification(
        'Gagal: $e\n\n💡 Tips: Pastikan GPS aktif, kurangi hambatan sinyal',
        Colors.red[700]!,
        icon: Icons.gps_not_fixed,
      );
      debugPrint('❌ Error GPS: $e');
    }
  }

  // ✅ PREVIEW LOKASI DENGAN FLUTTER MAP (INTERAKTIF)
  Widget _buildLocationPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Lokasi Lahan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.gps_fixed, size: 16),
                label: const Text('Ambil GPS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ FLUTTER MAP INTERAKTIF
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                _selectedLocation != null
                    ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation!,
                        initialZoom: 17.0,
                        // ✅ IJINKAN KLIK PETA UNTUK PINDAHKAN MARKER
                        onTap: (TapPosition tapPosition, latlong.LatLng point) {
                          _updateMarker(point);
                          _showTopNotification(
                            'Lokasi diperbarui!',
                            Colors.blue[700]!,
                            icon: Icons.location_on,
                          );
                        },
                      ),
                      children: [
                        TileLayer(
                          // ✅ Google Hybrid: Satelit + Nama Jalan/Tempat
                          urlTemplate:
                              'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.mahendra.multicalculator',
                          tileSize: 256.0,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () {
                                  _showTopNotification(
                                    'Geser marker untuk adjust posisi',
                                    Colors.blue[700]!,
                                    icon: Icons.touch_app,
                                  );
                                },
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : _buildEmptyLocationPlaceholder(),
          ),

          const SizedBox(height: 12),

          // ✅ INFORMASI KOORDINAT
          if (_selectedLocation != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _isLocationLocked ? Icons.lock : Icons.edit_location,
                        size: 16,
                        color: _isLocationLocked ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLocationLocked
                            ? 'GPS Terkunci'
                            : 'Lokasi Diedit Manual',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              _isLocationLocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedLocation = null;
                            _isLocationLocked = false;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Hapus'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _selectedLocation!.latitude.toStringAsFixed(7),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Longitude',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _selectedLocation!.longitude.toStringAsFixed(7),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.amber[800],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Klik peta untuk pindahkan titik lokasi',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Klik tombol "Ambil GPS" untuk menandai lokasi lahan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ PLACEHOLDER SAAT BELUM ADA LOKASI
  Widget _buildEmptyLocationPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Peta akan muncul di sini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _saveImagePermanently(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = path.join(
        directory.path,
        'ubinan_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final File newlyCreatedFile = await imageFile.copy(newPath);
      return newlyCreatedFile.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _simpan() async {
    // Validasi Hasil
    if (widget.hasilPanen <= 0) {
      _showTopNotification(
        'Hitung dulu sebelum menyimpan!',
        Colors.orange[800]!,
        icon: Icons.warning_rounded,
      );
      return;
    }

    // ✅ Validasi Lokasi
    if (_selectedLocation == null) {
      _showTopNotification(
        'Tentukan titik lokasi lahan dulu!',
        Colors.orange[800]!,
        icon: Icons.location_on,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Simpan Foto
      String? finalPhotoPath = widget.existingPhotoPath;

      if (_selectedImage != null) {
        if (widget.existingPhotoPath == null ||
            _selectedImage!.path != widget.existingPhotoPath) {
          final savedPath = await _saveImagePermanently(_selectedImage!);
          if (savedPath != null) {
            finalPhotoPath = savedPath;
          }
        }
      }

      // ✅ Siapkan Data dengan Koordinat
      final history = UbinanHistory(
        id: widget.historyId,
        title: "Panen ${widget.komoditas}",
        cropType: widget.komoditas,
        result: widget.hasilPanen,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        notes: widget.catatan,
        surveyorName: widget.surveyorController?.text ?? '',
        photoPath: finalPhotoPath,
        farmerName: widget.farmerController?.text ?? '',
        poktanName: widget.poktanController?.text ?? '',
        locationName: widget.locationController?.text ?? '',
      );

      // Update atau Insert
      if (widget.historyId != null) {
        await DatabaseHelper().updateHistory(history);
        if (mounted) {
          _showTopNotification(
            'Data Berhasil Diperbarui!',
            Colors.blue[700]!,
            icon: Icons.check_circle,
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      } else {
        await DatabaseHelper().insertHistory(history);
        if (mounted) {
          _showTopNotification(
            'Berhasil Disimpan ke Peta!',
            Colors.green[700]!,
            icon: Icons.map_rounded,
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification(
          'Gagal: $e',
          Colors.red[700]!,
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Column(
      children: [
        // DOKUMENTASI FOTO
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dokumentasi (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                      image:
                          _selectedImage != null
                              ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _selectedImage == null
                            ? const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Kamera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Galeri"),
                        ),
                        if (_selectedImage != null)
                          TextButton.icon(
                            onPressed:
                                () => setState(() => _selectedImage = null),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 16,
                            ),
                            label: const Text(
                              "Hapus Foto",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ✅ PREVIEW LOKASI DENGAN FLUTTER MAP
        _buildLocationPreview(),

        // TOMBOL SIMPAN
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _simpan,
            icon:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Icon(
                      widget.historyId != null
                          ? Icons.update
                          : Icons.save_as_rounded,
                    ),
            label: Text(
              _isSaving
                  ? 'Menyimpan...'
                  : (widget.historyId != null
                      ? 'UPDATE DATA'
                      : 'SIMPAN KE MAPS'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.historyId != null
                      ? Colors.blue[800]
                      : Colors.green[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 5,
            ),
          ),
        ),
      ],
    );
  }
}
