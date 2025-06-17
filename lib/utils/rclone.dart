import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';

import '../models/mount.dart';

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

Future<bool> _isServerRunning() async {
  try {
    var response = await http.post(Uri.parse('$kBaseUrl/config/listremotes'));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

void _startRcloneServer() async {
  if (serverShell != null) {
    serverShell!.kill();
  }

  serverShell = Shell(
    throwOnError: false,
    // Open shell in application directory because rclone binary will be bundled in final build
    workingDirectory: Directory.current.path,
  );

  // In macOS, it uses the full path to the rclone binary due to my laziness in finding a way to include the rclone binary in the final release
  String rcloneBin = Platform.isMacOS ? '/usr/local/bin/rclone' : 'rclone';

  serverShell!.run('$rcloneBin rcd --rc-addr=localhost:8965 --rc-no-auth');
}

Future<void> performMount(Mount mount) async {
  var mountName = mount.name ?? '${mount.remote!.name}:';
  await requestToRcloneApi('/mount/mount', queryParameters: {
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
  await requestToRcloneApi(
    '/mount/unmount',
    queryParameters: {'mountPoint': _getMountPoint(mount)},
  );
}

Future<List<String>> getMountPointsCurrentlyInUse() async {
  var response = await requestToRcloneApi('/mount/listmounts');

  if (response['mountPoints'] == null) {
    return [];
  }

  return (response['mountPoints'] as List<dynamic>)
      .map((mount) => (mount['Fs'] as String).replaceAll(':', ''))
      .toList();
}

Future<Map<String, dynamic>> requestToRcloneApi(
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
