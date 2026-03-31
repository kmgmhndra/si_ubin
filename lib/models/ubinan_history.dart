class UbinanHistory {
  final int? id;
  final String title; // Contoh: "Lahan Pak Budi"
  final String cropType; // Contoh: "Padi", "Jagung"
  final double result; // Hasil (Ton/Ha)
  final double latitude; // Koordinat
  final double longitude; // Koordinat
  final String date; // Tanggal simpan
  final String notes; // Catatan tambahan
  final String? photoPath; // Path lokasi foto di penyimpanan HP
  final String? surveyorName; // Nama Petugas/Pengubin
  final String? farmerName; // Nama Petani
  final String? poktanName;
  final String? locationName; // Nama Lokasi (Desa/Blok)

  UbinanHistory({
    this.id,
    required this.title,
    required this.cropType,
    required this.result,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.notes,
    this.photoPath,
    this.surveyorName,
    this.farmerName,
    this.poktanName,
    this.locationName,
  });

  // Konversi dari Class ke Map (untuk simpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'cropType': cropType,
      'result': result,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'notes': notes,
      'photoPath': photoPath,
      'surveyorName': surveyorName,
      'farmerName': farmerName,
      'poktanName': poktanName,
      'locationName': locationName,
    };
  }

  // Konversi dari Map ke Class (untuk ambil dari SQLite)
  factory UbinanHistory.fromMap(Map<String, dynamic> map) {
    return UbinanHistory(
      id: map['id'],
      title: map['title'],
      cropType: map['cropType'],
      result: map['result'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      date: map['date'],
      notes: map['notes'],
      photoPath: map['photoPath'],
      surveyorName: map['surveyorName'],
      farmerName: map['farmerName'],
      poktanName: map['poktanName'],
      locationName: map['locationName'],
    );
  }
}
