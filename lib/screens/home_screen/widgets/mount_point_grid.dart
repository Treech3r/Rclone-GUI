import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/mount_service.dart';
import 'mount_point_grid_tile.dart';

class MountPointGrid extends ConsumerStatefulWidget {
  const MountPointGrid({super.key});

  @override
  ConsumerState<MountPointGrid> createState() => _MountPointListState();
}

class _MountPointListState extends ConsumerState<MountPointGrid> {
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
              'Você não criou nenhum drive',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 70),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 270.0;
        const horizontalPadding = 12.0;
        const crossAxisSpacing = 12.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final crossAxisCount = (availableWidth / (itemWidth + crossAxisSpacing))
            .floor()
            .clamp(1, double.infinity)
            .toInt();

        return GridView.builder(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(8),
          itemCount: mounts.length,
          itemBuilder: (context, index) {
            return MountPointGridTile(mounts.elementAt(index));
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: itemWidth + 100,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        );
      },
    );
  }
}
