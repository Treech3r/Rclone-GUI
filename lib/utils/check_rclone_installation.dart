import 'dart:convert';

import 'package:process_run/process_run.dart';

import '../models/remote.dart';

Future<bool> isRcloneInstalled() async {
  return whichSync('rclone') != null;
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
