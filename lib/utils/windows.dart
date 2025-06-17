import 'shell.dart';

Future<List<String>> getAvailableDriveLetters() async {
  const powershellCommand =
      'powershell -c \'(Get-WmiObject -Class Win32_LogicalDisk).DeviceID.Replace(":","")\'';

  var lettersCurrentlyInUse =
      (await runShellCommand(powershellCommand)).stdout as String;

  lettersCurrentlyInUse = lettersCurrentlyInUse.replaceAll(':', '');
  lettersCurrentlyInUse.replaceFirst('Caption', '');

  return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      .split('')
      .where((letter) => !lettersCurrentlyInUse.contains(letter))
      .toList();
}
