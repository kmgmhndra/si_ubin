import 'package:flutter/material.dart';
import '../widgets/result_cards.dart';
import '../widgets/tombol_simpan.dart';
import '../models/ubinan_history.dart';
import '../utils/input_validator.dart';

class PadiCalculatorPage extends StatefulWidget {
  final UbinanHistory? dataEdit;

  const PadiCalculatorPage({super.key, this.dataEdit});

  @override
  State<PadiCalculatorPage> createState() => _PadiCalculatorPageState();
}

class _PadiCalculatorPageState extends State<PadiCalculatorPage> {
  // --- 1. CONTROLLER BARU DITAMBAHKAN ---
  final TextEditingController _luasLahanController = TextEditingController();
  final TextEditingController _dataUbinanController = TextEditingController();
  final TextEditingController _namaPengubinController = TextEditingController();
  final TextEditingController _farmerController = TextEditingController();
  final TextEditingController _poktanController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  // Data konversi (Tetap Sama)
  final Map<String, double> konversiGKPkeGKG = {
    'Nusa Tenggara Timur': 0.8939,
    'Riau': 0.8876,
    'Aceh': 0.8786,
    'Sumatera Barat': 0.8686,
    'Kalimantan Timur': 0.8667,
    'Kalimantan Selatan': 0.8628,
    'Sulawesi Utara': 0.8604,
    'Sumatera Selatan': 0.8586,
    'Sulawesi Tengah': 0.8579,
    'Kalimantan Tengah': 0.8576,
    'Sumatera Utara': 0.8574,
    'Papua Barat': 0.8568,
    'Kalimantan Barat': 0.8554,
    'Bengkulu': 0.8547,
    'Jambi': 0.8476,
    'Bali': 0.8456,
    'Gorontalo': 0.8425,
    'Papua': 0.8421,
    'DKI Jakarta': 0.8412,
    'Sulawesi Barat': 0.8398,
    'Sulawesi Selatan': 0.8381,
    'Nasional': 0.8338,
    'Sulawesi Tenggara': 0.8337,
    'Jawa Timur': 0.8317,
    'Banten': 0.8304,
    'Nusa Tenggara Barat': 0.8300,
    'Lampung': 0.8292,
    'Kep. Riau': 0.8273,
    'Jawa Tengah': 0.8260,
    'Maluku': 0.8219,
    'Jawa Barat': 0.8199,
    'Kalimantan Utara': 0.8163,
    'DI Yogyakarta': 0.8087,
    'Maluku Utara': 0.8046,
    'Kep. Bangka Belitung': 0.7412,
  };

  final Map<String, double> konversiGKGkeBeras = {
    'Papua Barat': 0.6670,
    'Kalimantan Tengah': 0.6594,
    'Kalimantan Utara': 0.6581,
    'Kep. Bangka Belitung': 0.6580,
    'Kalimantan Selatan': 0.6569,
    'Kalimantan Barat': 0.6568,
    'Sulawesi Tengah': 0.6553,
    'DKI Jakarta': 0.6544,
    'Nusa Tenggara Timur': 0.6503,
    'Kalimantan Timur': 0.6457,
    'Sumatera Barat': 0.6428,
    'Jambi': 0.6422,
    'Jawa Barat': 0.6411,
    'Jawa Timur': 0.6410,
    'Nasional': 0.6402,
    'Aceh': 0.6395,
    'Bengkulu': 0.6394,
    'Jawa Tengah': 0.6384,
    'Lampung': 0.6382,
    'Sulawesi Barat': 0.6376,
    'Sulawesi Tenggara': 0.6375,
    'Sumatera Selatan': 0.6375,
    'Riau': 0.6371,
    'Sulawesi Selatan': 0.6371,
    'Sumatera Utara': 0.6368,
    'Kep. Riau': 0.6353,
    'Papua': 0.6339,
    'Nusa Tenggara Barat': 0.6323,
    'Banten': 0.6323,
    'DI Yogyakarta': 0.6306,
    'Bali': 0.6261,
    'Sulawesi Utara': 0.6238,
    'Maluku': 0.6217,
    'Maluku Utara': 0.6213,
    'Gorontalo': 0.6199,
  };

  String? selectedProvinsi = 'Nasional';
  double produktivitasGKP = 0;
  double produktivitasGKG = 0;
  double produktivitasBeras = 0;
  double produksiGKP = 0;
  double produksiGKG = 0;
  double produksiBeras = 0;

  @override
  void initState() {
    super.initState();
    if (widget.dataEdit != null) {
      // Parse data lama (Luas, Ubinan, & Provinsi dari Notes)
      _parseDataFromNotes(widget.dataEdit!.notes);

      // --- 2. ISI KOLOM BARU SAAT EDIT ---
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
      // -----------------------------------

      WidgetsBinding.instance.addPostFrameCallback((_) => hitung());
    }
  }

  void _parseDataFromNotes(String notes) {
    try {
      final regexLuas = RegExp(r'Luas Lahan: ([\d.]+)');
      final regexUbinan = RegExp(r'Input Ubinan: ([\d.]+)');
      final regexProv = RegExp(r'Prov: ([a-zA-Z .]+)');

      final matchLuas = regexLuas.firstMatch(notes);
      final matchUbinan = regexUbinan.firstMatch(notes);
      final matchProv = regexProv.firstMatch(notes);

      if (matchLuas != null) {
        _luasLahanController.text = matchLuas.group(1) ?? '';
      }
      if (matchUbinan != null) {
        _dataUbinanController.text = matchUbinan.group(1) ?? '';
      }

      // Logic khusus Provinsi (Agar saat Edit, dropdown terpilih otomatis)
      if (matchProv != null) {
        String prov = matchProv.group(1)?.trim() ?? 'Nasional';
        if (konversiGKPkeGKG.containsKey(prov)) {
          selectedProvinsi = prov;
        }
      }
    } catch (e) {
      debugPrint("Gagal parsing data Padi: $e");
    }
  }

  // VALIDASI: Menggunakan utility class
  String? _validateInputs(double? luasLahan, double? dataUbinan) {
    return InputValidator.validateByKomoditas('padi', luasLahan, dataUbinan);
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

    if (selectedProvinsi == null) return;

    final double konversiGKG = konversiGKPkeGKG[selectedProvinsi] ?? 0.8338;
    final double konversiBeras = konversiGKGkeBeras[selectedProvinsi] ?? 0.6402;

    setState(() {
      produktivitasGKP = dataUbinan! * 16;
      produktivitasGKG = produktivitasGKP * konversiGKG;
      produktivitasBeras = produktivitasGKG * konversiBeras;

      produksiGKP = (produktivitasGKP * luasLahan!) / 10;
      produksiGKG = (produktivitasGKG * luasLahan) / 10;
      produksiBeras = (produktivitasBeras * luasLahan) / 10;
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
      selectedProvinsi = 'Nasional';
      produktivitasGKP = 0;
      produktivitasGKG = 0;
      produktivitasBeras = 0;
      produksiGKP = 0;
      produksiGKG = 0;
      produksiBeras = 0;
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
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
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
                                ? 'Edit Data Padi'
                                : 'Kalkulator Ubinan Padi',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Masukkan Data Ubinan & Pilih Provinsi',
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
            // --- 3. INPUT DATA LENGKAP (PERSONIL & LOKASI) ---
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
                fillColor: Colors.green.shade50,
              ),
            ),

            const SizedBox(height: 10),
            // Nama Petani
            TextField(
              controller: _farmerController,
              decoration: const InputDecoration(
                labelText: "Nama Petani (Pemilik Lahan)",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),
            // Nama Poktan
            TextField(
              controller: _poktanController,
              decoration: const InputDecoration(
                labelText: "Nama Poktan (Kelompok Tani)",
                prefixIcon: Icon(Icons.groups_rounded),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),
            // Lokasi
            TextField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: "Lokasi (Cth: Blok A / Desa X)",
                prefixIcon: Icon(Icons.add_location_alt_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            // ------------------------------------------------
            const SizedBox(height: 20),

            // --- 4. DROPDOWN PROVINSI (PENTING UNTUK PADI) ---
            DropdownButtonFormField<String>(
              value: selectedProvinsi,
              decoration: const InputDecoration(
                labelText: 'Pilih Provinsi (Acuan Konversi)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_rounded),
                filled: true,
                fillColor: Colors.white,
              ),
              items:
                  konversiGKPkeGKG.keys.map((String provinsi) {
                    return DropdownMenuItem<String>(
                      value: provinsi,
                      child: Text(provinsi),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => selectedProvinsi = val),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _luasLahanController,
              decoration: const InputDecoration(
                labelText: 'Luas Lahan (hektar)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.landscape),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dataUbinanController,
              decoration: const InputDecoration(
                labelText: 'Data Ubinan (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.data_thresholding),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox(height: 20),

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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: hitung,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            ResultCard(
              title: 'PRODUKTIVITAS',
              gkp: produktivitasGKP,
              gkg: produktivitasGKG,
              hasil: produktivitasBeras,
              unit: 'Kw/Ha',
              labelTiga: 'Beras',
            ),
            const SizedBox(height: 10),
            ResultCard(
              title: 'PRODUKSI',
              gkp: produksiGKP,
              gkg: produksiGKG,
              hasil: produksiBeras,
              unit: 'Ton',
              labelTiga: 'Beras',
            ),

            const SizedBox(height: 24),

            // --- 5. TOMBOL SIMPAN LENGKAP ---
            TombolSimpan(
              komoditas: "Padi",
              historyId: widget.dataEdit?.id,
              hasilPanen: produksiBeras,
              isVisible: true,
              // Kirim TextEditingController secara langsung untuk ambil nilai CURRENT
              surveyorController: _namaPengubinController,
              farmerController: _farmerController,
              poktanController: _poktanController,
              locationController: _locationNameController,
              existingPhotoPath: widget.dataEdit?.photoPath,
              existingLatitude: widget.dataEdit?.latitude,
              existingLongitude: widget.dataEdit?.longitude,

              // Catatan tetap memuat Provinsi
              catatan:
                  "Prov: $selectedProvinsi\n"
                  "Luas Lahan: ${_luasLahanController.text} Ha\n"
                  "Input Ubinan: ${_dataUbinanController.text} kg\n"
                  "----------------------\n"
                  "Produktivitas Gabah Basah/Panen (GKP): ${produktivitasGKP.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Gabah Kering Giling (GKG): ${produktivitasGKG.toStringAsFixed(2)} Kw/Ha\n"
                  "Produktivitas Beras: ${produktivitasBeras.toStringAsFixed(2)} Kw/Ha\n"
                  "Produksi Gabah Basah/Panen (GKP): ${produksiGKP.toStringAsFixed(2)} Ton\n"
                  "Produksi Gabah Kering Giling (GKG): ${produksiGKG.toStringAsFixed(2)} Ton\n"
                  "Produksi Beras: ${produksiBeras.toStringAsFixed(2)} Ton",
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
