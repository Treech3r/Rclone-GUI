import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/remote_service.dart';
import '../../widgets/remote_picker_grid.dart';
import '../remote_creation_wizard/screen.dart';
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
        title: Text('Qual remote deseja montar?'),
      ),
      body: FutureBuilder(
        future: RemoteService.getAllRemotes(),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text('Lendo configuração do rclone...'));
          }

          var remotes = snapshot.data!;

          return RemotePickerGrid(
            itemCount: remotes.length,
            itemBuilder: (_, index) => RemoteTile(
              remote: remotes[index],
              parentContext: context,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        tooltip: 'Configurar novo remote',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProviderScope(child: RemoteCreationScreen()))),
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
