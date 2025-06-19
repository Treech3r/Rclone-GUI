import 'package:flutter/material.dart';

class RemotePickerGrid extends StatelessWidget {
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;

  const RemotePickerGrid({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 150.0;
        const horizontalPadding = 12.0;
        const crossAxisSpacing = 12.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final crossAxisCount = (availableWidth / (itemWidth + crossAxisSpacing))
            .floor()
            .clamp(1, double.infinity)
            .toInt();

        return GridView.builder(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(12),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return SizedBox(
              width: itemWidth,
              child: itemBuilder(context, index),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        );
      },
    );
  }
}
