import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/remote_service.dart';
import '../../../widgets/remote_picker_grid.dart';
import '../../../widgets/remote_tile.dart';

class RemoteGrid extends ConsumerStatefulWidget {
  const RemoteGrid({super.key});

  @override
  ConsumerState<RemoteGrid> createState() => _RemoteGridState();
}

class _RemoteGridState extends ConsumerState<RemoteGrid> {
  @override
  Widget build(BuildContext context) {
    final remotes = ref.watch(RemoteService.instance);

    if (remotes.isEmpty) {
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
      itemCount: remotes.length,
      itemBuilder: (_, index) => RemoteTile(remote: remotes[index]),
    );
  }
}
