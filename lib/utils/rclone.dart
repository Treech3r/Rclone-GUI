import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';

import '../models/mount.dart';
import '../models/remote.dart';

const kBaseUrl = "http://localhost:8965";

Future<bool> isRcloneInstalled() async {
  try {
    var shell = Shell();
    var result = await shell.run('./rclone --version');

    return result.first.stdout.toString().contains('os/version');
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

  var shell = Shell();
  await shell.run('rclone rcd --rc-addr=localhost:8965 --rc-no-auth');

  int attempts = 0;
  while (attempts < 3 && !await _isRcServerAlreadyRunning()) {
    await Future.delayed(Duration(milliseconds: 2500));
    attempts++;
  }
}

Future<bool> _isRcServerAlreadyRunning() async {
  try {
    var response = await http.post(
      Uri.parse('$kBaseUrl/rc/noop?potato=1&sausage=2'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['potato'] == "1" && jsonResponse['sausage'] == "2";
    }
  } catch (_) {
    return false;
  }

  return false;
}

Future<List<Remote>> getRcloneDriveRemotes() async {
  var shell = Shell();
  var result = await shell.run('rclone listremotes --json --type drive');

  if ((result.first.stderr as String).isNotEmpty) {
    return [];
  }

  var rawRemotes = (result.first.stdout as String);

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

  var shell = Shell();
  shell.run(mountCommand);
}
