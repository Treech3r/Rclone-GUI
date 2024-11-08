import 'package:sqflite/sqflite.dart';

import '../models/mount.dart';

class SqfliteService {
  static late Database _db;

  static const kCurrentDatabaseVersion = 1;

  static Future<void> initialize() async {
    _db = await openDatabase(
      'rclone_gui.db',
      version: kCurrentDatabaseVersion,
      onCreate: _createDatabase,
    );
  }

  static Future<void> _createDatabase(Database database, int _) async {
    await database.execute(
      'CREATE TABLE Mount(id INTEGER PRIMARY KEY, name TEXT, remote TEXT, remotePath TEXT, mountPoint TEXT, allowWrite BOOLEAN)',
    );
  }

  static Future<int> insertMount(Mount mount) async {
    return await _db.insert('Mount', mount.toJson());
  }

  static Future<List<Mount>> getAllMounts() async {
    var result = await _db.query('Mount');
    return result.map(Mount.fromJson).toList();
  }
}
