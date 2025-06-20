import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/remote.dart';

class RemoteTile extends StatefulWidget {
  final Remote? remote;
  final String? remoteType;
  final VoidCallback? overrideCallback;

  RemoteTile({
    this.remote,
    String? remoteType,
    this.overrideCallback,
    super.key,
  }) : remoteType = remoteType ?? remote?.type {
    assert(remote != null || remoteType != null,
        'Either remote or remoteType must be provided');
  }

  @override
  State<RemoteTile> createState() => _RemoteTileState();
}

class _RemoteTileState extends State<RemoteTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF333333);
    final inversePrimaryColor = Theme.of(context).colorScheme.inversePrimary;
    return MouseRegion(
      cursor: widget.overrideCallback != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.overrideCallback,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 170),
          // Match GridView mainAxisExtent
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: isHovered ? primaryColor : inversePrimaryColor,
            clipBehavior: Clip.hardEdge,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 130),
              // 170 - (20 top + 20 bottom)
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 50,
                        child: SvgPicture.asset(
                          Remote.commercialLogoFromType(widget.remoteType!),
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      if (widget.remote?.parentRemote != null &&
                          widget.remote?.type == 'crypt')
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
                  const SizedBox(height: 18),
                  if (widget.remote != null)
                    CustomText(
                      text: widget.remote!.name,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                  Opacity(
                    opacity: widget.remote == null ? 0.8 : 0.6,
                    child: CustomText(
                      text: Remote.commercialNameFromType(widget.remoteType!),
                    ),
                  ),
                  if (widget.remote?.parentRemote != null &&
                      widget.remote?.type == 'crypt')
                    Opacity(
                      opacity: 0.3,
                      child: CustomText(
                        text: '(criptografado)',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovering) {
    setState(() {
      isHovered = isHovering;
    });
  }
}

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextStyle? style;

  const CustomText({
    required this.text,
    this.color,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: style == null
          ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)
          : style?.copyWith(color: color),
    );
  }
}
