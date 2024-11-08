import 'package:flutter/material.dart';

import 'screens/mounts_screen/screen.dart';
import 'screens/rclone_not_installed/screen.dart';
import 'services/sqflite.dart';
import 'utils/rclone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqfliteService.initialize();
  runApp(MyApp(await isRcloneInstalled()));
}

class MyApp extends StatelessWidget {
  final bool rcloneInstalled;

  const MyApp(this.rcloneInstalled, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rclone GUI',
      theme: ThemeData(
        colorScheme: ColorScheme.highContrastDark(
          brightness: Brightness.dark,
          onPrimary: const Color(0xFF202020),
          primary: const Color(0xFFc2c2c2),
        ),
        useMaterial3: true,
      ),
      home: rcloneInstalled ? const MountsScreen() : RcloneNotInstalledScreen(),
    );
  }
}
