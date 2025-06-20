import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/remotes.dart';
import '../../services/rclone_service.dart';
import '../../widgets/remote_picker_grid.dart';
import '../../widgets/remote_tile.dart';
import 'remote_creation_wizard.dart';

class RemoteCreationScreen extends ConsumerWidget {
  const RemoteCreationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteTypes = ref.watch(Config.remotes);

    return Scaffold(
      appBar: AppBar(title: const Text('Qual é o tipo do armazenamento que deseja adicionar?')),
      body: RemotePickerGrid(
        itemCount: remoteTypes.length,
        itemBuilder: (_, index) => RemoteTile(
          remoteType: remoteTypes[index].type,
          overrideCallback: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProviderScope(
                  child: RemoteCreationWizard(
                    remoteCreation: remoteTypes[index],
                    onComplete: RcloneService.createRemote,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
