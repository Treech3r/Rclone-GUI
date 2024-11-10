import 'dart:io';

import 'package:process_run/shell.dart';

Future<ProcessResult> runShellCommand(String command) async {
  var shell = Shell();
  return (await shell.run(command)).first;
}
