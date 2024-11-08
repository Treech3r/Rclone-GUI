import 'package:process_run/process_run.dart';

Future<List<String>> getAvailableDriveLetters() async {
  const powerShellCommand =
      "'ABCDEFGHIJKLMNOPQRSTUVWXYZ' -split '' | Where-Object { \$_ -notin ([System.IO.DriveInfo]::GetDrives().Name).Substring(0,1) }";

  var shell = Shell();
  var result = (await shell.run(powerShellCommand)).first.stdout as String;

  return result.split('\n').where((letter) => letter.isNotEmpty).toList();
}
