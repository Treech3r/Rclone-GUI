import 'package:flutter/material.dart';

import '../../../models/mount.dart';
import 'mount_tile.dart';

class MountPointList extends StatefulWidget {
  final List<Mount> mounts;

  const MountPointList({
    super.key,
    required this.mounts,
  });

  @override
  State<MountPointList> createState() => _MountPointListState();
}

class _MountPointListState extends State<MountPointList> {
  @override
  Widget build(BuildContext context) {
    if (widget.mounts.isEmpty) {
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
              'Você não criou nenhum ponto de montagem',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 70),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
      itemCount: widget.mounts.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: MountTile(
          widget.mounts[index],
          editCallback: () => setState(() {}),
          deleteCallback: () => setState(() => widget.mounts.removeAt(index)),
        ),
      ),
    );
  }
}
