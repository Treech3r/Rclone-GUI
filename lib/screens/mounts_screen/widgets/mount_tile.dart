import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/mount.dart';
import '../../../utils/rclone.dart';
import '../../mount_editing/screen.dart';

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

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isMounted = true;
    });

    await Future.delayed(Duration(seconds: 3));

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
                      widget.mount.name.isEmpty
                          ? widget.mount.remote.name
                          : widget.mount.name,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: isMounted
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FilledButton(
                          onPressed: isMounting ? null : mount,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey;
                                }
                                return Colors.red;
                              },
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Desmontar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FilledButton(
                          onPressed: isMounting ? null : mount,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey;
                                }
                                return Colors.green;
                              },
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Montar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FilledButton(
                          onPressed: isMounting
                              ? null
                              : () {
                                  Navigator.of(context).push<Mount>(
                                    MaterialPageRoute(
                                      builder: (_) => MountEditingScreen(
                                        mount: widget.mount,
                                        editCallback: widget.editCallback,
                                        deleteCallback: widget.deleteCallback,
                                      ),
                                    ),
                                  );
                                },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey;
                                }
                                return Colors.deepPurpleAccent;
                              },
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Editar mount',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
