
import 'package:coffee_exult_app/Features/Profile/data/paymentorder_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('payments.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productName TEXT,
            quantity INTEGER,
            price REAL,
            totalPrice REAL,
            status TEXT,
            completedAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertPayment(PaymentData payment) async {
    final db = await database;
    await db.insert('payments', payment.toMap());
  }

  Future<List<PaymentData>> getPayments() async {
    final db = await database;
    final maps = await db.query('payments');
    return List.generate(maps.length, (i) => PaymentData.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}