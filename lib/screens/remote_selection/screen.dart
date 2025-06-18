import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rclone_gui/screens/remote_creation_wizard/screen.dart';

import '../../services/remote_service.dart';
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
        future: RemoteService.getAllRemotes(),
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
              mainAxisExtent: 170,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        tooltip: 'Configurar novo remote',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProviderScope(child: RemoteCreationScreen()))),
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
