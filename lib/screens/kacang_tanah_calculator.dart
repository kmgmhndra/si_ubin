import 'package:flutter/material.dart';
import '../widgets/result_cards.dart';
import '../widgets/tombol_simpan.dart';
import '../models/ubinan_history.dart';
import '../utils/input_validator.dart';

class KacangTanahCalculatorPage extends StatefulWidget {
  final UbinanHistory? dataEdit;

  const KacangTanahCalculatorPage({super.key, this.dataEdit});

  @override
  State<KacangTanahCalculatorPage> createState() =>
      _KacangTanahCalculatorPageState();
}

class _KacangTanahCalculatorPageState extends State<KacangTanahCalculatorPage> {
  // --- 1. CONTROLLER LENGKAP ---
  final TextEditingController _luasLahanController = TextEditingController();
  final TextEditingController _dataUbinanController = TextEditingController();

  // Controller Data Personil & Lokasi
  final TextEditingController _namaPengubinController = TextEditingController();
  final TextEditingController _farmerController = TextEditingController();
  final TextEditingController _poktanController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  // Variabel Hasil
  double produktivitasGlondonganBasah = 0;
  double produktivitasGlondonganKeringPolong = 0;
  double produktivitasBijiKering = 0;
  double produksiGlondonganBasah = 0;
  double produksiGlondonganKeringPolong = 0;
  double produksiBijiKering = 0;

  @override
  void initState() {
    super.initState();
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
      debugPrint("Gagal parsing data Kacang Tanah: $e");
    }
  }

  // VALIDASI: Menggunakan utility class
  String? _validateInputs(double? luasLahan, double? dataUbinan) {
    return InputValidator.validateByKomoditas(
      'kacang tanah',
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
      // Rumus Produktivitas (Kw/Ha)
      produktivitasGlondonganBasah = dataUbinan! * 16; // 100%
      produktivitasGlondonganKeringPolong =
          produktivitasGlondonganBasah * 0.53; // Konversi 53%
      produktivitasBijiKering =
          produktivitasGlondonganBasah * 0.32; // Konversi 32%

      // Rumus Produksi Total (Ton)
      produksiGlondonganBasah =
          (produktivitasGlondonganBasah * luasLahan!) / 10;
      produksiGlondonganKeringPolong =
          (produktivitasGlondonganKeringPolong * luasLahan) / 10;
      produksiBijiKering = (produktivitasBijiKering * luasLahan) / 10;
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

      produktivitasGlondonganBasah = 0;
      produktivitasGlondonganKeringPolong = 0;
      produktivitasBijiKering = 0;
      produksiGlondonganBasah = 0;
      produksiGlondonganKeringPolong = 0;
      produksiBijiKering = 0;
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
                colors: [Color(0xFFD84315), Color(0xFFFF7043)], // Merah Bata
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
                                ? 'Edit Data Kacang Tanah'
                                : 'Kalkulator Kacang Tanah',
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
                fillColor: Colors.deepOrange.shade50,
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
                      backgroundColor: const Color(0xFFD84315),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: hitung,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Result Cards (Pakai yang 3 baris karena ada 3 fase kacang)
            ResultCard(
              title: 'PRODUKTIVITAS (Kwintal/Hektar)',
              gkp: produktivitasGlondonganBasah,
              gkg: produktivitasGlondonganKeringPolong,
              hasil: produktivitasBijiKering,
              unit: 'Kw/Ha',
              labelSatu: 'Glondongan Basah',
              labelDua: 'Glondongan Kering',
              labelTiga: 'Biji Kering',
            ),
            const SizedBox(height: 10),
            ResultCard(
              title: 'PRODUKSI (Ton)',
              gkp: produksiGlondonganBasah,
              gkg: produksiGlondonganKeringPolong,
              hasil: produksiBijiKering,
              unit: 'Ton',
              labelSatu: 'Glondongan Basah',
              labelDua: 'Glondongan Kering',
              labelTiga: 'Biji Kering',
            ),
            const SizedBox(height: 24),

            // --- 4. TOMBOL SIMPAN UPDATE ---
            TombolSimpan(
              komoditas: "Kacang Tanah",
              historyId: widget.dataEdit?.id,

              // Simpan Biji Kering (Hasil Akhir)
              hasilPanen: produksiBijiKering,
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
                  "Produktivitas Glondongan Basah: ${produktivitasGlondonganBasah.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Glondongan Kering: ${produktivitasGlondonganKeringPolong.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Biji Kering: ${produktivitasBijiKering.toStringAsFixed(2)} Kw/Ha\n"
                  "Produksi Glondongan Basah: ${produksiGlondonganBasah.toStringAsFixed(2)} Ton\n"
                  "Produksi Glondongan Kering: ${produksiGlondonganKeringPolong.toStringAsFixed(2)} Ton\n"
                  "Produksi Biji Kering: ${produksiBijiKering.toStringAsFixed(2)} Ton",
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
