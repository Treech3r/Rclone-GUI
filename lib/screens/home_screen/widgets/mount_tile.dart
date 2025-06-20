import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/mount.dart';
import '../../../services/mount_service.dart';
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
  bool isMounting = false;

  Future<void> mount() async {
    setState(() {
      isMounting = true;
    });

    await MountService.mount(widget.mount);
    setState(() {
      widget.mount.toggleMountStatus();
      isMounting = false;
    });
  }

  Future<void> unMount() async {
    setState(() {
      isMounting = true;
    });

    await MountService.unmount(widget.mount);
    widget.mount.toggleMountStatus();

    setState(() {
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
                widget.mount.remote == null
                    ? Icon(Icons.error, color: Colors.red, size: 50)
                    : Stack(
                        children: [
                          SvgPicture.asset(
                            widget.mount.remote!.commercialLogo,
                            fit: BoxFit.scaleDown,
                            height: 50,
                          ),
                          if (widget.mount.remote!.parentRemote != null &&
                              widget.mount.remote!.type == 'crypt')
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.lock,
                                shadows: [
                                  BoxShadow(color: Colors.black, blurRadius: 5),
                                ],
                              ),
                            ),
                        ],
                      ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mount.name ?? widget.mount.remote?.name ?? 'Erro',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        widget.mount.mountPath.length == 1
                            ? '${widget.mount.remote?.commercialName} (${widget.mount.mountPath}:)'
                            : widget.mount.remote?.commercialName ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    if (widget.mount.mountPath.length > 1)
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          widget.mount.mountPath,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
              child: ValueListenableBuilder(
                valueListenable: widget.mount.isMounted,
                builder: (ctx, isMounted, _) {
                  if (isMounted) {
                    return RoundedButton(
                      label: 'Desmontar',
                      onPressed: isMounting ? null : unMount,
                      enabledColor: Colors.red,
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RoundedButton(
                        label: 'Montar',
                        enabledColor: Colors.purpleAccent,
                        onPressed: isMounting || widget.mount.remote == null
                            ? null
                            : mount,
                      ),
                      RoundedButton(
                        label: 'Editar',
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
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
