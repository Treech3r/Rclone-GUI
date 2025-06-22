import 'system_shell.dart';

abstract class WindowsHelper {
  static List<String> get allDriveLetters {
    return [
      'A',
      'B',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];
  }

  static Future<List<String>> getAvailableDriveLetters() async {
    const powershellCommand =
        'powershell -c \'(Get-WmiObject -Class Win32_LogicalDisk).DeviceID.Replace(":","")\'';

    var lettersCurrentlyInUse =
        (await SystemShell.runCommand(powershellCommand)).stdout as String;

    lettersCurrentlyInUse = lettersCurrentlyInUse.replaceAll(':', '');
    lettersCurrentlyInUse.replaceFirst('Caption', '');

    return allDriveLetters
        .where((letter) => !lettersCurrentlyInUse.contains(letter))
        .toList();
  }
}
