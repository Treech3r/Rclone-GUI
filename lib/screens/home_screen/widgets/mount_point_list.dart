import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/mount_service.dart';
import 'mount_tile.dart';

class MountPointList extends ConsumerStatefulWidget {
  const MountPointList({super.key});

  @override
  ConsumerState<MountPointList> createState() => _MountPointListState();
}

class _MountPointListState extends ConsumerState<MountPointList> {
  @override
  void initState() {
    ref.read(MountService.instance.notifier).getAllMounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mounts = ref.watch(MountService.instance);

    if (mounts.isEmpty) {
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
      itemCount: mounts.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: MountTile(mounts[index]),
      ),
    );
  }
}
