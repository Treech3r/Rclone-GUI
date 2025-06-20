import 'dart:io';

import 'package:process_run/shell.dart';

abstract class SystemShell {
  static final _shell = Shell();

  static Future<ProcessResult> runCommand(String command) async {
    return (await _shell.run(command)).first;
  }
}
