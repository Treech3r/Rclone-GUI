import '../models/remote.dart';
import 'rclone_service.dart';

class RemoteService {
  static List<Remote> _remotes = [];

  static Future<List<Remote>> getAllRemotes() async {
    if (_remotes.isEmpty) {
      await _getAllRemotes();
    }

    return _remotes;
  }

  static Future<void> _getAllRemotes() async {
    final List<Map<String, dynamic>> remotesMap =
        await RcloneService.getAllRemotes();

    final Map<String, Remote> remotes = {};
    // Map to store deferred parent relationships (childName -> parentName)
    final deferredParents = <String, String>{};

    for (var i = 0; i < remotesMap.length; i++) {
      final remote = Remote(
        name: remotesMap[i]['name']!,
        type: remotesMap[i]['type']!,
      );

      remotes[remote.name] = remote;

      if (remotesMap[i]['parentRemote'] != null) {
        final String parentName = remotesMap[i]['parentRemote']!.split(':')[0];

        // Link parent immediately if parent is already processed
        if (remotes.containsKey(parentName)) {
          remote.parentRemote = remotes[parentName];
        } else {
          // Store in deferredParents if parent is not yet processed
          deferredParents[remote.name] = parentName;
        }
      }
    }

    // Resolve deferred parent relationships
    for (final entry in deferredParents.entries) {
      final childName = entry.key;
      final parentName = entry.value;

      if (remotes.containsKey(parentName)) {
        remotes[childName]?.parentRemote = remotes[parentName];
      }
    }

    _remotes = remotes.values.toList();
  }
}
