import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen/screen.dart';
import 'screens/rclone_not_installed/screen.dart';
import 'services/sqflite_service.dart';
import 'utils/rclone_server.dart';

void main() async {
  // Necessary because of sqflite
  WidgetsFlutterBinding.ensureInitialized();
  await SqfliteService.initialize();

  final serverStarted = await RcloneServer.start();

  runApp(ProviderScope(child: MyApp(serverStarted)));
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
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardThemeData(
          color: const Color(0xFF202020),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        colorScheme: ColorScheme.highContrastDark(
          brightness: Brightness.dark,
          onPrimary: const Color(0xFF202020),
          primary: const Color(0xFFc2c2c2),
        ),
        useMaterial3: true,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        ),
      ),
      home: rcloneInstalled ? const HomeScreen() : CouldNotStartServerScreen(),
    );
  }
}
