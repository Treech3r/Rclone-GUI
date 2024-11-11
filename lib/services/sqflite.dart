import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/mount.dart';
import '../models/remote.dart';
import '../utils/rclone.dart';

class SqfliteService {
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

  static Future<List<Mount>> getAllMounts() async {
    var remotes = await getAllRemotes();
    var result = await _db.query('Mount');

    // TODO: deal with the case where no remote is found by name
    return result.map((r) {
      Remote? remote;
      try {
        remote = remotes.firstWhere((a) => a.name == r['remote']);
      } catch (_) {}
      return Mount.fromJson({...r, 'remote': remote});
    }).toList();
  }
}
