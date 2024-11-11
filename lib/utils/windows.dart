import 'shell.dart';

Future<List<String>> getAvailableDriveLetters() async {
  const powershellCommand =
      'wmic logicaldisk get caption | findstr /r "^[A-Z]"';

  var lettersCurrentlyInUse =
      (await runShellCommand(powershellCommand)).stdout as String;

  return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      .split('')
      .where((letter) => !lettersCurrentlyInUse.contains(letter))
      .toList();
}
