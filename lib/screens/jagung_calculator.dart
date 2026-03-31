import 'package:flutter/material.dart';
import '../widgets/result_cards.dart';
import '../widgets/tombol_simpan.dart';
import '../models/ubinan_history.dart';
import '../utils/input_validator.dart';

class JagungCalculatorPage extends StatefulWidget {
  final UbinanHistory? dataEdit;

  const JagungCalculatorPage({super.key, this.dataEdit});

  @override
  State<JagungCalculatorPage> createState() => _JagungCalculatorPageState();
}

class _JagungCalculatorPageState extends State<JagungCalculatorPage> {
  // Controller untuk Input
  final TextEditingController _luasLahanController = TextEditingController();
  final TextEditingController _dataUbinanController = TextEditingController();
  final TextEditingController _farmerController = TextEditingController();
  final TextEditingController _poktanController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  // 1. TAMBAHKAN CONTROLLER NAMA PENGUBIN
  final TextEditingController _namaPengubinController = TextEditingController();

  double produktivitasBasah = 0;
  double produktivitasKering = 0;
  double produksiBasah = 0;
  double produksiKering = 0;

  @override
  void initState() {
    super.initState();
    if (widget.dataEdit != null) {
      _parseDataFromNotes(widget.dataEdit!.notes);

      // 2. ISI NAMA JIKA EDIT (Jika ada di database)
      if (widget.dataEdit!.surveyorName != null) {
        _namaPengubinController.text = widget.dataEdit!.surveyorName!;
      }
      if (widget.dataEdit!.farmerName != null) {
        _farmerController.text = widget.dataEdit!.farmerName!;
      }
      if (widget.dataEdit!.poktanName != null) {
        // <--- Cek Poktan
        _poktanController.text = widget.dataEdit!.poktanName!;
      }
      if (widget.dataEdit!.locationName != null) {
        _locationNameController.text = widget.dataEdit!.locationName!;
      }

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
      debugPrint("Gagal parsing data lama: $e");
    }
  }

  // VALIDASI: Menggunakan utility class
  String? _validateInputs(double? luasLahan, double? dataUbinan) {
    return InputValidator.validateByKomoditas('jagung', luasLahan, dataUbinan);
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
      produktivitasBasah = dataUbinan! * 16;
      produktivitasKering = produktivitasBasah * 0.5673;
      produksiBasah = (produktivitasBasah * luasLahan!) / 10;
      produksiKering = (produktivitasKering * luasLahan) / 10;
    });
  }

  void reset() {
    setState(() {
      _luasLahanController.clear();
      _dataUbinanController.clear();
      _namaPengubinController.clear(); // Reset nama juga
      produktivitasBasah = 0;
      produktivitasKering = 0;
      produksiBasah = 0;
      produksiKering = 0;
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
                colors: [Color(0xFFF57C00), Color(0xFFFFB300)],
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
                                ? 'Edit Data Jagung'
                                : 'Kalkulator Ubinan Jagung',
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
            // 3. INPUT NAMA PENGUBIN
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
                fillColor: Colors.orange.shade50,
              ),
            ),

            const SizedBox(height: 10),

            // Input Nama Petani
            TextField(
              controller: _farmerController,
              decoration: const InputDecoration(
                labelText: "Nama Petani (Pemilik Lahan)",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // --- INPUT POKTAN BARU ---
            TextField(
              controller: _poktanController,
              decoration: const InputDecoration(
                labelText: "Nama Poktan (Kelompok Tani)",
                prefixIcon: Icon(Icons.groups_rounded), // Icon Group
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Input Nama Lokasi
            TextField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: "Lokasi (Cth: Blok A / Desa X)",
                prefixIcon: Icon(Icons.add_location_alt_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            // Input Luas & Ubinan
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

            // Tombol Reset & Hitung
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
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: hitung,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            ResultCardDua(
              title: 'PRODUKTIVITAS (Kwintal/Hektar)',
              label1: 'Kering Panen Tanpa Kulit dan Tangkai',
              value1: produktivitasBasah,
              label2: 'Jagung Pipilan Kering',
              value2: produktivitasKering,
              unit: 'Kw/Ha',
            ),
            ResultCardDua(
              title: 'PRODUKSI (Ton)',
              label1: 'Kering Panen Tanpa Kulit dan Tangkai',
              value1: produksiBasah,
              label2: 'Jagung Pipilan Kering',
              value2: produksiKering,
              unit: 'Ton',
            ),

            const SizedBox(height: 24),

            // 4. UPDATE TOMBOL SIMPAN
            TombolSimpan(
              komoditas: "Jagung",
              historyId: widget.dataEdit?.id,
              hasilPanen: produksiKering,
              isVisible: true,

              // Kirim TextEditingController secara langsung untuk ambil nilai CURRENT
              surveyorController: _namaPengubinController,
              farmerController: _farmerController,
              poktanController: _poktanController,
              locationController: _locationNameController,

              // Kirim path foto lama jika edit
              existingPhotoPath: widget.dataEdit?.photoPath,
              existingLatitude: widget.dataEdit?.latitude,
              existingLongitude: widget.dataEdit?.longitude,

              catatan:
                  "Luas Lahan: ${_luasLahanController.text} Ha\n"
                  "Input Ubinan: ${_dataUbinanController.text} kg\n"
                  "----------------------\n"
                  "Produktivitas Kering Panen Tanpa Kulit dan Tangkai: ${produktivitasBasah.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Jagung Pipilan Kering: ${produktivitasKering.toStringAsFixed(2)} Kw/Ha\n"
                  "Produksi Kering Panen Tanpa Kulit dan Tangkai: ${produksiBasah.toStringAsFixed(2)} Ton\n"
                  "Produksi Jagung Pipilan Kering: ${produksiKering.toStringAsFixed(2)} Ton",
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
