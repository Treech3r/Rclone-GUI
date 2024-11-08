import 'dart:convert';
import 'dart:io';

import 'package:process_run/process_run.dart';

import '../models/mount.dart';
import '../models/remote.dart';

Future<bool> isRcloneInstalled() async {
  var shell = Shell();
  var result = await shell.run('./rclone --version');

  return result.first.stdout.toString().contains('os/version');
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
