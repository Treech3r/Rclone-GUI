import 'shell.dart';

Future<List<String>> getAvailableDriveLetters() async {
  const powerShellCommand =
      "'ABCDEFGHIJKLMNOPQRSTUVWXYZ' -split '' | Where-Object { \$_ -notin ([System.IO.DriveInfo]::GetDrives().Name).Substring(0,1) }";

  var result = (await runShellCommand(powerShellCommand)).stdout as String;

  return result.split('\n').where((letter) => letter.isNotEmpty).toList();
}
