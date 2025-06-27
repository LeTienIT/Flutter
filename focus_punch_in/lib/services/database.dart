import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/work_session.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  static const _databaseVersion = 2;

  Future<Database> get db async => _db ??= await _initDatabase();

  Future<Database> _initDatabase() async{
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, "work_session.db");
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  Future<void> _onCreate(Database db, int v) async{
    await db.execute('''
    CREATE TABLE sessions(
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        day        TEXT    NOT NULL,
        check_in   TEXT    NOT NULL,
        check_out  TEXT
      )
    ''');
    await db.execute('''
        ALTER TABLE sessions 
        ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0
      ''');

    await db.execute('''
        UPDATE sessions 
        SET isCompleted = CASE 
          WHEN check_out IS NOT NULL THEN 1 
          ELSE 0 
        END
      ''');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion)async {

  }

  Future<int> insert(WorkSession w) async =>
      (await db).insert('sessions', w.toMap());

  Future<void> update(WorkSession w, int id) async =>
      (await db).update('sessions', w.toMap(), where: 'id=?',whereArgs: [id]);

  Future<List<WorkSession>> fetchAll() async {
    final maps = await (await db).query('sessions', orderBy: 'id');
    // print("log: $maps");
    return maps.map((map) => WorkSession.fromMap(map)).toList();
  }
  Future<void> delete(int id) async =>
      (await db).delete('sessions', where: 'id=?',whereArgs: [id]);
}