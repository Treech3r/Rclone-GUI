import 'shell.dart';

Future<List<String>> getAvailableDriveLetters() async {
  const powershellCommand =
      'Get-PSDrive -PSProvider FileSystem | ForEach-Object { \$_.Name }';

  var lettersCurrentlyInUse =
      (await runShellCommand(powershellCommand)).stdout as String;

  return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      .split('')
      .where((letter) => !lettersCurrentlyInUse.contains(letter))
      .toList();
}
