import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/mount.dart';
import '../../../services/mount_service.dart';
import '../../../widgets/rounded_button.dart';
import '../../mount_info_editing/screen.dart';

class MountPointGridTile extends StatefulWidget {
  final Mount mount;

  const MountPointGridTile(
    this.mount, {
    super.key,
  });

  @override
  State<MountPointGridTile> createState() => _MountPointGridTileState();
}

class _MountPointGridTileState extends State<MountPointGridTile> {
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
    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth - 155;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    widget.mount.remote == null
                        ? Icon(Icons.error, color: Colors.red, size: 50)
                        : Image.asset('assets/images/hard-drive.png'),
                    SizedBox(width: 15),
                    SizedBox(
                      width: availableWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.mount.mountPath}:',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.mount.name ?? 'Drive sem nome',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 12),
                    Stack(
                      children: [
                        SvgPicture.asset(
                          widget.mount.remote!.commercialLogo,
                          fit: BoxFit.scaleDown,
                          height: 35,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.lock,
                            size: 15,
                            shadows: [
                              BoxShadow(color: Colors.black, blurRadius: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mount.remote?.commercialName ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Opacity(
                          opacity: 0.8,
                          child: Text(widget.mount.remote?.name ?? ''),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: widget.mount.isMounted,
                builder: (ctx, isMounted, _) {
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMounted ? Colors.red.withAlpha(30) : Colors.blue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: isMounted
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween,
                        children: isMounted
                            ? [
                                RoundedButton(
                                  label: 'Desmontar',
                                  onPressed: isMounting ? null : unMount,
                                  style: RoundedButtonStyle.danger,
                                )
                              ]
                            : [
                                RoundedButton(
                                  label: 'Montar',
                                  style: RoundedButtonStyle.primary,
                                  onPressed:
                                      isMounting || widget.mount.remote == null
                                          ? null
                                          : mount,
                                ),
                                RoundedButton(
                                  style: RoundedButtonStyle.secondary,
                                  label: 'Editar',
                                  onPressed: isMounting
                                      ? null
                                      : () {
                                          Navigator.of(context).push<Mount>(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MountInfoEditingScreen(
                                                mount: widget.mount,
                                              ),
                                            ),
                                          );
                                        },
                                )
                              ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
