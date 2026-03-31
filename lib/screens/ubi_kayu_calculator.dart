import 'package:flutter/material.dart';
import '../widgets/result_cards.dart';
import '../widgets/tombol_simpan.dart';
import '../models/ubinan_history.dart';
import '../utils/input_validator.dart';

class UbiKayuCalculatorPage extends StatefulWidget {
  final UbinanHistory? dataEdit;

  const UbiKayuCalculatorPage({super.key, this.dataEdit});

  @override
  State<UbiKayuCalculatorPage> createState() => _UbiKayuCalculatorPageState();
}

class _UbiKayuCalculatorPageState extends State<UbiKayuCalculatorPage> {
  // --- 1. CONTROLLER LENGKAP ---
  final TextEditingController _luasLahanController = TextEditingController();
  final TextEditingController _dataUbinanController = TextEditingController();

  // Controller Data Personil & Lokasi
  final TextEditingController _namaPengubinController = TextEditingController();
  final TextEditingController _farmerController = TextEditingController();
  final TextEditingController _poktanController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  // Variabel Hasil (Produktivitas)
  double produktivitasUbiBerkulit = 0;
  double produktivitasUbiLepasKulit = 0;
  double produktivitasGaplek = 0;
  double produktivitasTepungKampung = 0;

  // Variabel Hasil (Produksi Total)
  double produksiUbiBerkulit = 0;
  double produksiUbiLepasKulit = 0;
  double produksiGaplek = 0;
  double produksiTepungKampung = 0;

  @override
  void initState() {
    super.initState();
    // LOGIKA EDIT: Isi otomatis jika ada data lama
    if (widget.dataEdit != null) {
      _parseDataFromNotes(widget.dataEdit!.notes);

      // --- 2. ISI DATA LAMA SAAT EDIT ---
      if (widget.dataEdit!.surveyorName != null) {
        _namaPengubinController.text = widget.dataEdit!.surveyorName!;
      }
      if (widget.dataEdit!.farmerName != null) {
        _farmerController.text = widget.dataEdit!.farmerName!;
      }
      if (widget.dataEdit!.poktanName != null) {
        _poktanController.text = widget.dataEdit!.poktanName!;
      }
      if (widget.dataEdit!.locationName != null) {
        _locationNameController.text = widget.dataEdit!.locationName!;
      }
      // ---------------------------------

      WidgetsBinding.instance.addPostFrameCallback((_) => hitung());
    }
  }

  void _parseDataFromNotes(String notes) {
    try {
      final regexLuas = RegExp(r'Luas Lahan: ([\d.]+)');
      final regexUbinan = RegExp(r'Input Ubinan: ([\d.]+)');

      final matchLuas = regexLuas.firstMatch(notes);
      final matchUbinan = regexUbinan.firstMatch(notes);

      if (matchLuas != null) {
        _luasLahanController.text = matchLuas.group(1) ?? '';
      }
      if (matchUbinan != null) {
        _dataUbinanController.text = matchUbinan.group(1) ?? '';
      }
    } catch (e) {
      debugPrint("Gagal parsing data Ubi Kayu: $e");
    }
  }

  // VALIDASI: Menggunakan utility class
  String? _validateInputs(double? luasLahan, double? dataUbinan) {
    return InputValidator.validateByKomoditas(
      'ubi kayu',
      luasLahan,
      dataUbinan,
    );
  }

  void hitung() {
    final double? luasLahan = InputValidator.parseDouble(
      _luasLahanController.text,
    );
    final double? dataUbinan = InputValidator.parseDouble(
      _dataUbinanController.text,
    );

    // Gunakan validasi helper
    final String? errorMessage = _validateInputs(luasLahan, dataUbinan);
    if (errorMessage != null) {
      InputValidator.showErrorSnackBar(context, errorMessage);
      return;
    }

    setState(() {
      // Produktivitas (Kw/Ha)
      produktivitasUbiBerkulit = dataUbinan! * 16; // 100%
      produktivitasUbiLepasKulit = produktivitasUbiBerkulit * 0.80; // 80%
      produktivitasGaplek = produktivitasUbiBerkulit * 0.36; // 36%
      produktivitasTepungKampung = produktivitasUbiBerkulit * 0.265; // 26.5%

      // Produksi (Ton)
      produksiUbiBerkulit = (produktivitasUbiBerkulit * luasLahan!) / 10;
      produksiUbiLepasKulit = (produktivitasUbiLepasKulit * luasLahan) / 10;
      produksiGaplek = (produktivitasGaplek * luasLahan) / 10;
      produksiTepungKampung = (produktivitasTepungKampung * luasLahan) / 10;
    });
  }

  void reset() {
    setState(() {
      _luasLahanController.clear();
      _dataUbinanController.clear();
      _namaPengubinController.clear();
      _farmerController.clear();
      _poktanController.clear();
      _locationNameController.clear();

      produktivitasUbiBerkulit = 0;
      produktivitasUbiLepasKulit = 0;
      produktivitasGaplek = 0;
      produktivitasTepungKampung = 0;
      produksiUbiBerkulit = 0;
      produksiUbiLepasKulit = 0;
      produksiGaplek = 0;
      produksiTepungKampung = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6D4C41), Color(0xFF795548)], // Coklat Kayu
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.dataEdit != null
                                ? 'Edit Data Ubi Kayu'
                                : 'Kalkulator Ubinan Ubi Kayu',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Masukkan Luas Lahan dan Jumlah Sampel Ubinan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- 3. INPUT FORM BARU (Personil & Lokasi) ---
            const SizedBox(height: 10),
            TextField(
              controller: _namaPengubinController,
              decoration: InputDecoration(
                labelText: 'Nama Petugas/Pengubin (Opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: Colors.brown.shade50,
              ),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _farmerController,
              decoration: const InputDecoration(
                labelText: "Nama Petani (Pemilik Lahan)",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _poktanController,
              decoration: const InputDecoration(
                labelText: "Nama Poktan (Kelompok Tani)",
                prefixIcon: Icon(Icons.groups_rounded),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: "Lokasi (Cth: Blok A / Desa X)",
                prefixIcon: Icon(Icons.add_location_alt_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            // ---------------------------------------------
            const SizedBox(height: 20),

            // Input Teknis
            TextField(
              controller: _luasLahanController,
              decoration: InputDecoration(
                labelText: 'Luas Lahan (hektar)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.landscape),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dataUbinanController,
              decoration: InputDecoration(
                labelText: 'Data Ubinan (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.data_thresholding),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Hitung
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: reset,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    label: const Text('Hitung'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF795548),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: hitung,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Result Cards (4 Varian Ubi)
            ResultCardEmpat(
              title: 'PRODUKTIVITAS (Kwintal/Hektar)',
              label1: 'Ubi Basah Berkulit',
              value1: produktivitasUbiBerkulit,
              label2: 'Ubi Lepas Kulit',
              value2: produktivitasUbiLepasKulit,
              label3: 'Gaplek',
              value3: produktivitasGaplek,
              label4: 'Tepung Kampung',
              value4: produktivitasTepungKampung,
              unit: 'Kw/Ha',
            ),
            const SizedBox(height: 12),
            ResultCardEmpat(
              title: 'PRODUKSI (Ton)',
              label1: 'Ubi Basah Berkulit',
              value1: produksiUbiBerkulit,
              label2: 'Ubi Lepas Kulit',
              value2: produksiUbiLepasKulit,
              label3: 'Gaplek',
              value3: produksiGaplek,
              label4: 'Tepung Kampung',
              value4: produksiTepungKampung,
              unit: 'Ton',
            ),
            const SizedBox(height: 24),

            // --- 4. TOMBOL SIMPAN UPDATE ---
            TombolSimpan(
              komoditas: "Ubi Kayu",
              historyId: widget.dataEdit?.id,

              // Simpan Ubi Basah Berkulit (Raw Material) sebagai acuan utama
              hasilPanen: produksiUbiBerkulit,
              isVisible: true,

              // Kirim TextEditingController secara langsung untuk ambil nilai CURRENT
              surveyorController: _namaPengubinController,
              farmerController: _farmerController,
              poktanController: _poktanController,
              locationController: _locationNameController,
              existingPhotoPath: widget.dataEdit?.photoPath,
              existingLatitude: widget.dataEdit?.latitude,
              existingLongitude: widget.dataEdit?.longitude,

              catatan:
                  "Luas Lahan: ${_luasLahanController.text} Ha\n"
                  "Input Ubinan: ${_dataUbinanController.text} kg\n"
                  "----------------------\n"
                  "Produktivitas Ubi Berkulit: ${produktivitasUbiBerkulit.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Lepas Kulit: ${produktivitasUbiLepasKulit.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Gaplek: ${produktivitasGaplek.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Tepung: ${produktivitasTepungKampung.toStringAsFixed(2)} Kw/Ha\n"
                  "----------------------\n"
                  "Produksi Ubi Berkulit: ${produksiUbiBerkulit.toStringAsFixed(2)} Ton\n"
                  "Produksi Lepas Kulit: ${produksiUbiLepasKulit.toStringAsFixed(2)} Ton\n"
                  "Produksi Gaplek: ${produksiGaplek.toStringAsFixed(2)} Ton\n"
                  "Produksi Tepung: ${produksiTepungKampung.toStringAsFixed(2)} Ton",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _luasLahanController.dispose();
    _dataUbinanController.dispose();
    _namaPengubinController.dispose();
    _farmerController.dispose();
    _poktanController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }
}
