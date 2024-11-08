import 'package:flutter/material.dart';

import '../../utils/rclone.dart';
import '../remote_selection/screen.dart';

class RcloneNotInstalledScreen extends StatefulWidget {
  const RcloneNotInstalledScreen({super.key});

  @override
  State<RcloneNotInstalledScreen> createState() =>
      _RcloneNotInstalledScreenState();
}

class _RcloneNotInstalledScreenState extends State<RcloneNotInstalledScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Não foi possível localizar o rclone em seu sistema.'),
            Text('Certifique-se de que o adicionou à variável PATH.'),
            SizedBox(height: 20),
            TryAgainButton(),
          ],
        ),
      ),
    );
  }
}

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        final rcloneInstalled = await isRcloneInstalled();

        if (context.mounted) {
          if (!rcloneInstalled) {
            showRcloneNotFoundModalSheet(context);
          } else {
            navigateToHomePage(context);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('Verificar novamente'),
      ),
    );
  }

  void showRcloneNotFoundModalSheet(BuildContext context) {
    Scaffold.of(context).showBottomSheet(
      enableDrag: false,
      (_) => BottomSheet(
        enableDrag: false,
        shape: ContinuousRectangleBorder(),
        backgroundColor: Colors.redAccent,
        onClosing: () {},
        builder: (_) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Não foi possível localizar'),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RemoteSelectionScreen()));
  }
}
