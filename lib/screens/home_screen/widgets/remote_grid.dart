import 'package:flutter/material.dart';

import '../../../models/remote.dart';
import '../../../widgets/remote_picker_grid.dart';
import '../../../widgets/remote_tile.dart';

class RemoteGrid extends StatefulWidget {
  final List<Remote> remotes;

  const RemoteGrid({super.key, required this.remotes});

  @override
  State<RemoteGrid> createState() => _RemoteGridState();
}

class _RemoteGridState extends State<RemoteGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.remotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/treecher_sleeping.png',
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            SizedBox(height: 20),
            Text(
              'Você não conectou nenhum serviço de armazenamento',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 70),
          ],
        ),
      );
    }

    return RemotePickerGrid(
      itemCount: widget.remotes.length,
      itemBuilder: (_, index) => RemoteTile(remote: widget.remotes[index]),
    );
  }
}
