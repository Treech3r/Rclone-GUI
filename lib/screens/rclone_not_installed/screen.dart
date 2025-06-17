import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/rclone.dart';
import '../../widgets/rounded_button.dart';
import '../mounts_screen/screen.dart';

class CouldNotStartServerScreen extends StatelessWidget {
  late final String message;

  CouldNotStartServerScreen({super.key}) {
    if (Platform.isWindows) {
      message =
          'Para sistemas Windows, certifique-se de adicionar o rclone à variável de ambiente PATH. Após fazer isso, tente novamente.';
    } else {
      message =
          'Para sistemas ${Platform.isMacOS ? 'macOS' : 'Linux'}, por favor, instale o rclone através do site oficial (rclone.org). Após instalar, tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent.withOpacity(0.2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Não foi possível iniciar o servidor rclone.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.red),
              ),
              SizedBox(height: 50),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TryAgainButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class TryAgainButton extends StatefulWidget {
  const TryAgainButton({super.key});

  @override
  State<TryAgainButton> createState() => _TryAgainButtonState();
}

class _TryAgainButtonState extends State<TryAgainButton> {
  bool isTrying = false;

  Future<void> tryToStartServer(BuildContext context) async {
    setState(() {
      isTrying = true;
    });

    final serverStarted = await startRcloneServer();

    if (context.mounted) {
      if (!serverStarted) {
        setState(() {
          isTrying = false;
        });
        showRcloneNotFoundModalSheet(context);
      } else {
        navigateToHomePage(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      label: 'Tentar novamente',
      onPressed: isTrying ? null : () => tryToStartServer(context),
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
              child: Text('Não foi possível iniciar o servidor'),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => MountsScreen()));
  }
}
