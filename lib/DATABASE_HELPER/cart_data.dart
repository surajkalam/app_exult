import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL,
        quantity INTEGER,
        image TEXT,
        rating REAL,
        added_at TEXT,
      )
    ''');
  }
 // isAvailable INTEGER NOT NULL DEFAULT 1
  Future<int> insertCartItem(Map<String, dynamic> item) async {
    final db = await instance.database;
     log('Inserting item: ${item['name']}'); 
    final existingItems = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [item['id']],
    );
    
    if (existingItems.isNotEmpty) {
        log('Updating existing item quantity');
      final existingItem = existingItems.first;
      return await db.update(
        'cart_items',
        {'quantity': (existingItem['quantity'] as int) + 1},
        where: 'product_id = ?',
        whereArgs: [item['id']],
      );
    } else {
      log('Adding new item to cart');
      item['added_at'] = DateTime.now().toIso8601String();
      return await db.insert('cart_items', item);
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await instance.database;
    return await db.query('cart_items', orderBy: 'added_at DESC');
  }

  Future<int> removeCartItem(int id) async {
    final db = await instance.database;
    return await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCartItemQuantity(int id, int newQuantity) async {
    final db = await instance.database;
    return await db.update(
      'cart_items',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future<int> clearCart() async {
  final db = await database;
  return await db.delete('cart_items'); // Changed from 'cart' to 'cart_items'
}
}
