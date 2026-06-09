import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'electricity_bills.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        units REAL NOT NULL,
        total_charges REAL NOT NULL,
        rebate_percent REAL NOT NULL,
        final_cost REAL NOT NULL
      )
    ''');
  }

  Future<int> insertBill(BillRecord record) async {
    final db = await database;
    return db.insert('bills', record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BillRecord>> getAllBills() async {
    final db = await database;
    final maps = await db.query('bills', orderBy: 'id DESC');
    return maps.map(BillRecord.fromMap).toList();
  }

  Future<BillRecord?> getBillById(int id) async {
    final db = await database;
    final maps = await db.query('bills', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BillRecord.fromMap(maps.first);
  }

  Future<int> updateBill(BillRecord record) async {
    final db = await database;
    return db.update('bills', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }
}