import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/remote_service.dart';
import '../../widgets/remote_picker_grid.dart';
import '../../widgets/remote_tile.dart';

class RemoteSelectionScreen extends ConsumerStatefulWidget {
  const RemoteSelectionScreen({super.key});

  @override
  ConsumerState<RemoteSelectionScreen> createState() =>
      _RemoteSelectionScreenState();
}

class _RemoteSelectionScreenState extends ConsumerState<RemoteSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final remotes = ref.read(RemoteService.instance);

    return Scaffold(
      appBar: AppBar(
        title: Text('Qual armazenamento deseja montar?'),
      ),
      body: RemotePickerGrid(
        itemCount: remotes.length,
        itemBuilder: (_, index) => RemoteTile(
          remote: remotes[index],
          overrideCallback: () => Navigator.of(context).pop(remotes[index]),
        ),
      ),
    );
  }
}
