import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/remote.dart';

class RemoteTile extends StatefulWidget {
  final Remote remote;
  final BuildContext parentContext;

  const RemoteTile({
    required this.remote,
    required this.parentContext,
    super.key,
  });

  @override
  _RemoteTileState createState() => _RemoteTileState();
}

class _RemoteTileState extends State<RemoteTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final inversePrimaryColor = Theme.of(context).colorScheme.inversePrimary;
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: () => Navigator.of(widget.parentContext).pop(widget.remote),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: isHovered ? primaryColor : inversePrimaryColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  widget.remote.getCommercialLogo,
                  fit: BoxFit.scaleDown,
                  height: 50,
                ),
                SizedBox(height: 18),
                CustomText(
                  text: widget.remote.name,
                  color: isHovered ? inversePrimaryColor : primaryColor,
                ),
                Opacity(
                  opacity: 0.7,
                  child: CustomText(
                    text: widget.remote.getCommercialName,
                    color: isHovered ? inversePrimaryColor : primaryColor,
                  ),
                ),
              ],
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
  final Color color;

  const CustomText({
    required this.text,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
    );
  }
}
