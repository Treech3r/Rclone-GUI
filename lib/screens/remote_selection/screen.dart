import 'package:flutter/material.dart';

import '../../utils/rclone.dart';
import 'widgets/remote_tile.dart';

class RemoteSelectionScreen extends StatefulWidget {
  const RemoteSelectionScreen({super.key});

  @override
  State<RemoteSelectionScreen> createState() => _RemoteSelectionScreenState();
}

class _RemoteSelectionScreenState extends State<RemoteSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Qual remote deseja montar?'),
        centerTitle: true,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: FutureBuilder(
        future: getRcloneDriveRemotes(),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text('Lendo configuração do rclone...'));
          }

          var remotes = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: remotes.length,
            itemBuilder: (_, index) =>
                RemoteTile(remote: remotes[index], parentContext: context),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 150,
            ),
          );
        },
      ),
    );
  }
}
