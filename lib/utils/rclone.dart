import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';

import '../models/mount.dart';
import '../models/remote.dart';

const kBaseUrl = "http://localhost:8965";

// This shell should be global. Otherwise, it will be destroyed by garbage
// collector, effectively taking down the server.
var serverShell = Shell();

Future<bool> startRcloneServer() async {
  try {
    if (await _isServerRunning()) {
      return true;
    }
  } catch (_) {}

  _startRcloneServer();

  await Future.delayed(Duration(milliseconds: 500));

  int attempts = 0;
  while (attempts < 40 && !await _isServerRunning()) {
    print('Attempt #${attempts + 1}');
    await Future.delayed(Duration(milliseconds: 50));
    attempts++;
  }

  return false;
}

Future<List<Remote>> getAllRemotes() async {
  List<String> allRemotes = await _getAllRemotes();

  if (allRemotes.isEmpty) {
    return [];
  }

  Map<String, String> remoteTypes = {};

  for (String remote in allRemotes) {
    var response = await _makePostRequest('/config/get?name=$remote');
    remoteTypes[remote] = response['type'];
  }

  // TODO: remove this filter to support all remotes
  remoteTypes.removeWhere((key, value) => value != 'drive');

  List<Remote> remotes = [];

  remoteTypes.forEach(
    (key, value) => remotes.add(Remote(name: key, type: value)),
  );

  return remotes;
}

Future<void> performMount(Mount mount) async {
  var mountName = mount.name ?? '${mount.remote!.name}:';
  await _makePostRequest('/mount/mount', queryParameters: {
    'fs': '${mount.remote!.name}:',
    'mountPoint': mount.mountPath,
    'mountOpt': '{"DeviceName": "$mountName", "VolumeName": "$mountName"}',
    'vfsOpt': '{"CacheMode": 1, "ReadOnly": ${!mount.allowWrite}}'
  });
}

Future<void> performUnmount(Mount mount) async {
  await _makePostRequest(
    '/mount/unmount',
    queryParameters: {'mountPoint': mount.mountPath},
  );
}

Future<List<String>> _getAllRemotes() async {
  var response = await _makePostRequest('/config/listremotes');

  if (response['remotes'] == null) {
    return [];
  }

  return List<String>.from(response['remotes']);
}

void _startRcloneServer() async {
  serverShell.run('rclone rcd --rc-addr=localhost:8965 --rc-no-auth');
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
