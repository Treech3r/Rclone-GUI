import 'dart:convert';
import 'dart:io';

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

Future<bool> _isRcServerAlreadyRunning() async {
  try {
    var response = await makePostRequest('/rc/noop?potato=1&sausage=2');
    return response['potato'] == "1" && response['sausage'] == "2";
  } catch (_) {
    return false;
  }
}

Future<Map<String, dynamic>> makePostRequest(String path,
    {dynamic payload}) async {
  var response = await http.post(
    Uri.parse('$kBaseUrl$path'),
    body: jsonEncode(payload),
  );

  if (response.statusCode != 200) {
    throw Error();
  }

  return jsonDecode(response.body);
}

Future<List<Remote>> getRcloneDriveRemotes() async {
  var result = await runShellCommand('rclone listremotes --json --type drive');

  if ((result.stderr as String).isNotEmpty) {
    return [];
  }

  var rawRemotes = (result.stdout as String);

  List<dynamic> remotes = jsonDecode(rawRemotes);

  var remotesMap = remotes.map(Remote.fromJson).toList();

  return remotesMap;
}

Future<void> performMount(Mount mount) async {
  var mountCommand =
      'rclone mount "${mount.remote.name}:" "${mount.mountPath}" --vfs-cache-mode=minimal';

  if (!mount.allowWrite) {
    mountCommand = '$mountCommand --read-only';
  }

  if (!Platform.isWindows) {
    mountCommand = '$mountCommand --daemon';
  }

  runShellCommand(mountCommand);
}
