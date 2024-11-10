import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mount.dart';
import '../models/remote.dart';
import 'shell.dart';

const kBaseUrl = "http://localhost:8965";

Future<bool> isRcloneInstalled() async {
  try {
    var result = await runShellCommand('./rclone --version');

    return result.stdout.toString().contains('os/version');
  } catch (_) {
    return false;
  }
}

Future<void> initializeRcloneServer() async {
  try {
    if (await _isRcServerAlreadyRunning()) {
      return;
    }
  } catch (_) {}

  await runShellCommand('rclone rcd --rc-addr=localhost:8965 --rc-no-auth');

  int attempts = 0;
  while (attempts < 3 && !await _isRcServerAlreadyRunning()) {
    await Future.delayed(Duration(milliseconds: 2500));
    attempts++;
  }
}

Future<List<Remote>> getAllRemotes() async {
  List<String> allRemotes = await _getAllRemotes();
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
  var mountName = mount.name ?? '${mount.remote.name}:';
  await _makePostRequest('/mount/mount', queryParameters: {
    'fs': '${mount.remote.name}:',
    'mountPoint': mount.mountPath,
    'mountOpt': '{"DeviceName": "$mountName", "VolumeName": "$mountName"}',
    'vfsOpt': '{"CacheMode": 1, "ReadOnly": ${!mount.allowWrite}}'
  });
}

// TODO: check how rclone returns the response in case there are no remotes
Future<List<String>> _getAllRemotes() async {
  var response = await _makePostRequest('/config/listremotes');
  return List<String>.from(response['remotes']);
}

Future<bool> _isRcServerAlreadyRunning() async {
  try {
    var response = await _makePostRequest('/rc/noop?potato=1&sausage=2');
    return response['potato'] == "1" && response['sausage'] == "2";
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

  var response = await http.post(uri);

  if (response.statusCode != 200) {
    throw Error();
  }

  return jsonDecode(response.body);
}
