import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/remotes.dart';
import '../../services/rclone_service.dart';
import 'remote_creation_wizard.dart';

class RemoteCreationScreen extends ConsumerWidget {
  const RemoteCreationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteTypes = ref.watch(Config.remotes);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Remote Type')),
      body: ListView.builder(
        itemCount: remoteTypes.length,
        itemBuilder: (context, index) {
          final remoteType = remoteTypes[index];
          return ListTile(
            title: Text(remoteType.displayName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderScope(
                    child: RemoteCreationWizard(
                      remoteCreation: remoteType,
                      onComplete: RcloneService.createRemote,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
