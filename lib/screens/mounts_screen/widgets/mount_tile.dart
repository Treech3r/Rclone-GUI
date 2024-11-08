import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/mount.dart';

class MountTile extends StatelessWidget {
  final Mount mount;

  const MountTile(this.mount, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(12),
      tileColor: Theme.of(context).colorScheme.inversePrimary,
      leading: SvgPicture.asset(
        mount.remote.getCommercialLogo,
        fit: BoxFit.scaleDown,
        height: 50,
      ),
      title: Text(mount.name.isEmpty ? mount.remote.name : mount.name),
      subtitle: Text(mount.remote.getCommercialName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Montar',
            onPressed: () {},
            icon: Icon(Icons.play_arrow),
            iconSize: 30,
          ),
          IconButton(
            tooltip: 'Configurar',
            onPressed: () {},
            icon: Icon(Icons.settings),
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}
