import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mount.dart';
import '../models/remote.dart';
import '../utils/rclone_server.dart';
import 'remote_service.dart';
import 'sqflite_service.dart';

class MountService extends StateNotifier<List<Mount>> {
  MountService._(super.createNotifier);

  Future<List<Mount>> getAllMounts() async {
    if (state.isEmpty) {
      state = await _getAllMounts();
    }

    return state;
  }

  static dynamic _instance;

  static StateNotifierProvider<MountService, List<Mount>> get instance {
    _instance ??= StateNotifierProvider<MountService, List<Mount>>((ref) {
      return MountService._([]);
    });

    return _instance;
  }

  static Future<void> mount(Mount mount) async {
    var mountName = mount.name ?? '${mount.remote!.name}:';
    final String mountPath = _sanitizeMountPath(mount.mountPath);
    await RcloneServer.request('/mount/mount', queryParameters: {
      'fs': '${mount.remote!.name}:',
      'mountPoint': mountPath,
      'mountOpt':
          '{"DeviceName": "$mountName", "VolumeName": "$mountName", "AllowNonEmpty": true, "AllowOther": true, "AttrTimeout": "1s", "MaxDepth": "1", "NonChecksum": true, "NoModtime": true}',
      'vfsOpt':
          '{"CacheMode": 3, "ReadOnly": ${!mount.allowWrite}, "DirCacheTime": "60h", "ReadChunkSize": "5M", "ReadChunkStreams": 10, "CacheMaxAge": "5m", "FastFingerprint": true}',
      'TPSLimit': '10',
      'TPSLimitBurst': '10',
      'BufferSize': '1M',
    });
  }

  static Future<void> unmount(Mount mount) async {
    final String mountPath = _sanitizeMountPath(mount.mountPath);
    await RcloneServer.request(
      '/mount/unmount',
      queryParameters: {'mountPoint': mountPath},
    );
  }

  Future<void> createMount(Mount mount) async {
    await SqfliteService.insertMount(mount);
    state = [...state, mount];
  }

  Future<void> editMount(Mount mount) async {
    await SqfliteService.updateMount(mount);
    state = state.map((m) => m.id == mount.id ? mount : m).toList();
  }

  Future<void> deleteMount(Mount mount) async {
    await SqfliteService.deleteMount(mount);
    state = state.where((m) => m != mount).toList();
  }

  Future<List<Mount>> _getAllMounts() async {
    var remotes = await ProviderContainer()
        .read(RemoteService.instance.notifier)
        .getAllRemotes();
    var result = await SqfliteService.getAllMounts();

    Map<String, Mount> mountPathAndRemote = {};

    for (var mountJson in result) {
      Remote? remote = remotes.firstWhere((a) => a.name == mountJson['remote']);
      Mount mount = Mount.fromJson({...mountJson, 'remote': remote});
      state = [...state, mount];
      mountPathAndRemote[mountJson['mountPath'] as String] = mount;
    }

    for (String mountPathInUse in await _getMountPointsCurrentlyInUse()) {
      mountPathAndRemote[mountPathInUse]?.isMounted.value = true;
    }

    return state;
  }

  static Future<List<String>> _getMountPointsCurrentlyInUse() async {
    var response = await RcloneServer.request('/mount/listmounts');

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
