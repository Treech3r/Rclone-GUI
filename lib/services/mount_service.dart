import '../models/mount.dart';
import '../models/remote.dart';
import '../utils/rclone.dart';
import 'remote_service.dart';
import 'sqflite.dart';

class MountService {
  static List<Mount> _mounts = [];

  static Future<List<Mount>> getAllMounts() async {
    if (_mounts.isEmpty) {
      _mounts = await _getAllMounts();
    }

    return _mounts;
  }

  static Future<void> mount(Mount mount) async {
    var mountName = mount.name ?? '${mount.remote!.name}:';
    final String mountPath = _sanitizeMountPath(mount.mountPath);
    await requestToRcloneApi('/mount/mount', queryParameters: {
      'fs': '${mount.remote!.name}:',
      'mountPoint': mountPath,
      'mountOpt':
          '{"DeviceName": "$mountName", "VolumeName": "$mountName", "AllowNonEmpty": true, "AllowOther": true, "AttrTimeout": "1s"}',
      'vfsOpt':
          '{"CacheMode": 3, "ReadOnly": ${!mount.allowWrite}, "DirCacheTime": "60h", "ChunkSize": "32M", "ChunkSizeLimit": "512M", "CacheMaxAge": "5m"}',
      'TPSLimit': '10',
      'TPSLimitBurst': '10',
      'BufferSize': '1M',
    });
  }

  static Future<void> unmount(Mount mount) async {
    final String mountPath = _sanitizeMountPath(mount.mountPath);
    await requestToRcloneApi(
      '/mount/unmount',
      queryParameters: {'mountPoint': mountPath},
    );
  }

  static Future<List<Mount>> _getAllMounts() async {
    var remotes = await RemoteService.getAllRemotes();
    var result = await SqfliteService.getAllMounts();

    Map<String, Mount> mountPathAndRemote = {};

    for (var mountJson in result) {
      Remote? remote = remotes.firstWhere((a) => a.name == mountJson['remote']);
      Mount mount = Mount.fromJson({...mountJson, 'remote': remote});
      _mounts.add(mount);
      mountPathAndRemote[mountJson['mountPath'] as String] = mount;
    }

    for (String mountPathInUse in await _getMountPointsCurrentlyInUse()) {
      mountPathAndRemote[mountPathInUse]?.isMounted.value = true;
    }

    return _mounts;
  }

  static Future<List<String>> _getMountPointsCurrentlyInUse() async {
    var response = await requestToRcloneApi('/mount/listmounts');

    if (response['mountPoints'] == null) {
      return [];
    }

    return (response['mountPoints'] as List<dynamic>)
        .map((mount) => (mount['MountPoint'] as String).replaceAll(':', ''))
        .toList();
  }

  static String _sanitizeMountPath(String mountPath) {
    // If this is a single character, it means it's a drive letter on Windows
    return mountPath.length == 1 ? '$mountPath:' : mountPath;
  }
}
