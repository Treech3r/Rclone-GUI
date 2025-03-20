import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';

import '../models/mount.dart';
import '../models/remote.dart';

const kBaseUrl = "http://localhost:8965";

// This shell should be global. Otherwise, it will be destroyed by garbage
// collector, effectively taking down the server.
Shell? serverShell;

Future<bool> startRcloneServer() async {
  if (await _isServerRunning()) {
    return true;
  }

  _startRcloneServer();

  int attempts = 0;
  while (attempts < 40 && !(await _isServerRunning())) {
    await Future.delayed(Duration(milliseconds: 300));
    attempts++;
  }

  if (await _isServerRunning()) {
    return true;
  }

  return false;
}

Future<List<Remote>> getAllRemotes() async {
  List<String> remotesNames = await _getAllRemotes();

  if (remotesNames.isEmpty) {
    return [];
  }

  Map<String, String> remotesNamesAndTypes =
      await _fetchRemoteTypes(remotesNames);
  List<Remote> remotes = await _buildRemotes(remotesNamesAndTypes);

  Set<String> mountedRemotes = (await _getMountedRemotes()).toSet();

  for (var remote in remotes) {
    remote.mounted = mountedRemotes.contains(remote.name);
  }

  return remotes;
}

Future<Map<String, String>> _fetchRemoteTypes(List<String> remotesNames) async {
  Map<String, String> remotesWithType = {};

  for (String remote in remotesNames) {
    var response = await _makePostRequest('/config/get?name=$remote');
    remotesWithType[remote] = response['type'];
  }

  return remotesWithType;
}

Future<List<Remote>> _buildRemotes(
  Map<String, String> remotesWithNameAndType,
) async {
  List<Remote> remotes = [];

  remotesWithNameAndType.forEach(
    (key, value) => remotes.add(Remote(name: key, type: value)),
  );

  return remotes;
}

Future<void> performMount(Mount mount) async {
  var mountName = mount.name ?? '${mount.remote!.name}:';
  await _makePostRequest('/mount/mount', queryParameters: {
    'fs': '${mount.remote!.name}:',
    'mountPoint': _getMountPoint(mount),
    'mountOpt':
        '{"DeviceName": "$mountName", "VolumeName": "$mountName", "AllowNonEmpty": true, "AllowOther": true, "AttrTimeout": "1s"}',
    'vfsOpt':
        '{"CacheMode": 3, "ReadOnly": ${!mount.allowWrite}, "DirCacheTime": "60h", "ChunkSize": "32M", "ChunkSizeLimit": "512M", "CacheMaxAge": "5m"}',
    'TPSLimit': '10',
    'TPSLimitBurst': '10',
    'BufferSize': '1M',
  });
}

Future<void> performUnmount(Mount mount) async {
  await _makePostRequest(
    '/mount/unmount',
    queryParameters: {'mountPoint': _getMountPoint(mount)},
  );
}

Future<List<String>> _getAllRemotes() async {
  var response = await _makePostRequest('/config/listremotes');

  if (response['remotes'] == null) {
    return [];
  }

  return List<String>.from(response['remotes']);
}

Future<List<String>> _getMountedRemotes() async {
  var response = await _makePostRequest('/mount/listmounts');

  if (response['mountPoints'] == null) {
    return [];
  }

  return (response['mountPoints'] as List<dynamic>)
      .map((mount) => (mount['Fs'] as String).replaceAll(':', ''))
      .toList();
}

void _startRcloneServer() async {
  if (serverShell != null) {
    serverShell!.kill();
  }

  serverShell = Shell(throwOnError: false);

  String rcloneBin = 'rclone';

  // On macOS, the PATH variable might not work for GUI apps.
  // Use the full path to rclone as a workaround.
  if (Platform.isMacOS) {
    rcloneBin = '/usr/local/bin/rclone';
  }

  serverShell!.run('$rcloneBin rcd --rc-addr=localhost:8965 --rc-no-auth');
}

Future<bool> _isServerRunning() async {
  try {
    var response = await http.post(Uri.parse('$kBaseUrl/config/listremotes'));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future<Map<String, dynamic>> _makePostRequest(
  String path, {
  Map<String, dynamic>? queryParameters,
}) async {
  var uri =
      Uri.parse('$kBaseUrl$path').replace(queryParameters: queryParameters);

  http.Response? response;

  int maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      response = await http.post(uri);
      if (response.statusCode == 200) {
        break;
      }
    } catch (_) {
      await startRcloneServer();
      retryCount++;
    }
  }

  if (response == null) {
    throw Error();
  }

  if (response.statusCode != 200) {
    throw Error();
  }

  return jsonDecode(response.body);
}

String _getMountPoint(Mount mount) {
  var mountPath = mount.mountPath;
  return mountPath.length == 1 ? '$mountPath:' : mountPath;
}
