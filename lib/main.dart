import 'package:flutter/material.dart';

import 'screens/home/screen.dart';
import 'screens/rclone_not_installed/screen.dart';
import 'utils/check_rclone_installation.dart';

void main() async {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: rcloneInstalled ? const HomeScreen() : RcloneNotInstalledScreen(),
    );
  }
}
