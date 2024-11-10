import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/mount.dart';
import '../../../utils/rclone.dart';
import '../../../widgets/rounded_button.dart';
import '../../mount_info_editing/screen.dart';

class MountTile extends StatefulWidget {
  final Mount mount;
  final VoidCallback editCallback;
  final VoidCallback deleteCallback;

  const MountTile(
    this.mount, {
    required this.editCallback,
    required this.deleteCallback,
    super.key,
  });

  @override
  State<MountTile> createState() => _MountTileState();
}

class _MountTileState extends State<MountTile> {
  bool isMounted = false;
  bool isMounting = false;

  Future<void> mount() async {
    setState(() {
      isMounting = true;
    });

    await performMount(widget.mount);
    setState(() {
      isMounted = true;
      isMounting = false;
    });
  }

  Future<void> unMount() async {
    setState(() {
      isMounting = true;
    });

    await performUnmount(widget.mount);
    setState(() {
      isMounted = false;
      isMounting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  widget.mount.remote.getCommercialLogo,
                  fit: BoxFit.scaleDown,
                  height: 50,
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mount.name == null
                          ? widget.mount.remote.name
                          : widget.mount.name!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        widget.mount.mountPath.length == 1
                            ? '${widget.mount.remote.getCommercialName} (${widget.mount.mountPath}:)'
                            : widget.mount.remote.getCommercialName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        'Monta em: ${widget.mount.mountPath}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: isMounted
                    ? [
                        RoundedButton(
                          label: 'Desmontar',
                          onPressed: isMounting ? null : unMount,
                          enabledColor: Colors.red,
                        )
                      ]
                    : [
                        RoundedButton(
                          label: 'Montar',
                          enabledColor: Colors.green,
                          onPressed: isMounting ? null : mount,
                        ),
                        RoundedButton(
                          label: 'Editar mount',
                          onPressed: isMounting
                              ? null
                              : () {
                                  Navigator.of(context).push<Mount>(
                                    MaterialPageRoute(
                                      builder: (_) => MountInfoEditingScreen(
                                        mount: widget.mount,
                                        editCallback: widget.editCallback,
                                        deleteCallback: widget.deleteCallback,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
