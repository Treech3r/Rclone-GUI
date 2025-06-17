import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/mount.dart';

abstract class SqfliteService {
  static late Database _db;

  static const kCurrentDatabaseVersion = 1;

  static Future<void> initialize() async {
    sqfliteFfiInit();

    // This line might seem redundant but will cause the application not to
    // launch on Windows if deleted.
    var databaseFactory = databaseFactoryFfi;

    _db = await databaseFactory.openDatabase(
      'rclone_gui.db',
      options: OpenDatabaseOptions(
        version: kCurrentDatabaseVersion,
        onCreate: _createDatabase,
      ),
    );
  }

  static Future<void> _createDatabase(Database database, int _) async {
    await database.execute(
      'CREATE TABLE Mount(id INTEGER PRIMARY KEY, name TEXT, remote TEXT, remotePath TEXT, mountPath TEXT, allowWrite BOOLEAN)',
    );
  }

  static Future<int> insertMount(Mount mount) async {
    var mountMap = mount.toJson();
    mountMap.remove('id');

    return await _db.insert('Mount', mountMap);
  }

  static Future<void> updateMount(Mount mount) async {
    var mountMap = mount.toJson();

    await _db.update(
      'Mount',
      mountMap,
      where: 'ID = ?',
      whereArgs: [mount.id],
    );
  }

  static Future<void> deleteMount(Mount mount) async {
    await _db.delete(
      'Mount',
      where: 'ID = ?',
      whereArgs: [mount.id],
    );
  }

  // I decided to return a list of maps instead of Mount objects because we
  // also need to fetch Remote objects from the RemoteService in order to
  // properly construct Mount objects. This is done in the MountService.
  static Future<List<Map<String, Object?>>> getAllMounts() async {
    return await _db.query('Mount');
  }
}
