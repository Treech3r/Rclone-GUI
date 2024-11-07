import 'dart:convert';

import 'package:process_run/process_run.dart';

Future<bool> isRcloneInstalled() async {
  return whichSync('rclone') != null;
}

Future<List<Map<String, String>>> getRcloneDriveRemotes() async {
  var shell = Shell();
  var result = await shell.run('rclone listremotes --json --type drive');

  if ((result.first.stderr as String).isNotEmpty) {
    return [];
  }

  var rawRemotes = (result.first.stdout as String);

  List<dynamic> remotes = jsonDecode(rawRemotes);

  var remotesMap = remotes
      .map((remote) => ({
            'name': remote['name'] as String,
            'type': remote['type'] as String,
          }))
      .toList();

  return remotesMap;
}
