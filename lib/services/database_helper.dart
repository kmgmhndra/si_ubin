import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ubinan_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // VERSI DIUBAH JADI 3 AGAR UPDATE TERDETEKSI
  static const int _dbVersion = 3;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ubinan.db');
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // --- 1. FUNGSI MEMBUAT TABEL BARU (Fresh Install) ---
  Future<void> _onCreate(Database db, int version) async {
    // Perhatikan setiap baris diakhiri KOMA (,) kecuali baris terakhir
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        cropType TEXT,
        result REAL,
        latitude REAL,
        longitude REAL,
        date TEXT,
        notes TEXT,
        photoPath TEXT,
        surveyorName TEXT,
        farmerName TEXT,
        poktanName TEXT,
        locationName TEXT
      )
    ''');
  }

  // --- 2. FUNGSI UPDATE STRUKTUR TABEL (Migration) ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Tahap 1: Jika user update dari versi 1 (tambah foto & surveyor)
    if (oldVersion < 2) {
      await _addColumnSafe(db, 'photoPath', 'TEXT');
      await _addColumnSafe(db, 'surveyorName', 'TEXT');
    }

    // Tahap 2: Jika user update dari versi 2 (tambah petani, poktan, lokasi)
    if (oldVersion < 3) {
      await _addColumnSafe(db, 'farmerName', 'TEXT');
      await _addColumnSafe(db, 'poktanName', 'TEXT');
      await _addColumnSafe(db, 'locationName', 'TEXT');
    }
  }

  // Helper agar tidak crash jika kolom sudah ada (Opsional tapi aman)
  Future<void> _addColumnSafe(
    Database db,
    String columnName,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE history ADD COLUMN $columnName $type');
    } catch (e) {
      // Abaikan error jika kolom ternyata sudah ada
      print("Kolom $columnName mungkin sudah ada: $e");
    }
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertHistory(UbinanHistory history) async {
    try {
      final db = await database;
      final result = await db.insert('history', history.toMap());
      print('✅ Data berhasil disimpan ke database (ID: $result)');
      return result;
    } catch (e) {
      print('❌ Error saat menyimpan data: $e');
      rethrow; // Lempar kembali error ke caller (widget)
    }
  }

  Future<List<UbinanHistory>> getHistoryList() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'history',
        orderBy: 'date DESC',
      );
      final result = List.generate(
        maps.length,
        (i) => UbinanHistory.fromMap(maps[i]),
      );
      print('✅ Berhasil membaca ${result.length} data dari database');
      return result;
    } catch (e) {
      print('❌ Error saat membaca data: $e');
      rethrow;
    }
  }

  Future<int> updateHistory(UbinanHistory history) async {
    try {
      final db = await database;
      final result = await db.update(
        'history',
        history.toMap(),
        where: 'id = ?',
        whereArgs: [history.id],
      );
      print('✅ Data berhasil diperbarui (ID: ${history.id})');
      return result;
    } catch (e) {
      print('❌ Error saat memperbarui data: $e');
      rethrow;
    }
  }

  Future<int> deleteHistory(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'history',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('✅ Data berhasil dihapus (ID: $id)');
      return result;
    } catch (e) {
      print('❌ Error saat menghapus data: $e');
      rethrow;
    }
  }
}
