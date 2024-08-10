import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/bank_transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'banking.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE bank_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        type TEXT,
        amount REAL,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    Database db = await this.db;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    Database db = await this.db;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> insertTransaction(BankTransaction transaction) async {
    Database db = await this.db;
    return await db.insert('bank_transactions', transaction.toMap());
  }

  Future<List<BankTransaction>> getUserTransactions(int userId) async {
    Database db = await this.db;
    List<Map<String, dynamic>> result = await db.query(
      'bank_transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => BankTransaction.fromMap(e)).toList();
  }

  Future<int> updateUserBalance(int userId, double balance) async {
    Database db = await this.db;
    return await db.update(
      'users',
      {'balance': balance},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
