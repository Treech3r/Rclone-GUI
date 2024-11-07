import 'package:process_run/process_run.dart';

Future<bool> isRcloneInstalled() async {
  return whichSync('rclone') != null;
}
