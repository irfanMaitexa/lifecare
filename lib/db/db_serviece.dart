import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'user_database.db';
  static const _databaseVersion = 1;
  static const table = 'user_table';

  static const columnId = 'id';
  static const columnEmail = 'email';
  static const columnName = 'name';
  static const columnPhone = 'phone';
  static const columnHeight = 'height';
  static const columnWeight = 'weight';
  static const columnOtherProblems = 'otherProblems';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  late Database _database;

  Future<Database> get database async {
  
    _database = await _initDatabase();
    return _database;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnEmail TEXT NOT NULL,
        $columnName TEXT NOT NULL,
        $columnPhone TEXT NOT NULL,
        $columnHeight REAL NOT NULL,
        $columnWeight REAL NOT NULL,
        $columnOtherProblems TEXT
      )
    ''');
  }

  // Insert user data directly into the database
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    return await db.insert(table, user,conflictAlgorithm:ConflictAlgorithm.replace);
  }

  // Get all users from the database
  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Get a specific user by ID
  Future<Map<String, dynamic>?> getUser(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  // Delete a user by ID
  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Update user data
  Future<int> updateUser(Map<String, dynamic> user, int id) async {
    Database db = await instance.database;
    return await db.update(
      table,
      user,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }


  Future<bool> isUserExist() async {
  Database db = await instance.database;
  List<Map<String, dynamic>> result = await db.query('user_table', limit: 1);

  return result.isNotEmpty; // Returns true if a user exists, false otherwise
}



}
