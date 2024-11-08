import 'package:sqflite/sqflite.dart';

import '../models/mount.dart';
import '../utils/check_rclone_installation.dart';

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
    var mountMap = mount.toJson();
    mountMap.remove('id');

    return await _db.insert('Mount', mountMap);
  }

  static Future<List<Mount>> getAllMounts() async {
    var remotes = await getRcloneDriveRemotes();
    var result = await _db.query('Mount');

    // TODO: deal with the case where no remote is found by name
    return result.map((r) {
      var remote = remotes.firstWhere((a) => a.name == r['remote']);
      return Mount.fromJson({...r, 'remote': remote});
    }).toList();
  }
}
