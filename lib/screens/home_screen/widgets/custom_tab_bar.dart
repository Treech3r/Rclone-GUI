import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/remote_service.dart';
import '../../mount_info_editing/screen.dart';
import '../../remote_creation_wizard/screen.dart';

enum Tab { mount, remote }

var _currentTab = Tab.mount;

class CustomTabBar extends StatelessWidget {
  final Function(Tab) onTabChange;

  const CustomTabBar({
    required this.onTabChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: _TabBar(onToggle: onTabChange),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _RoundPlusButton(),
        ),
      ],
    );
  }
}

class _RoundPlusButton extends ConsumerStatefulWidget {
  const _RoundPlusButton();

  @override
  ConsumerState<_RoundPlusButton> createState() => _RoundPlusButtonState();
}

class _RoundPlusButtonState extends ConsumerState<_RoundPlusButton> {
  late RemoteService remoteReader;
  bool isHovered = false;

  @override
  void initState() {
    remoteReader = ref.read(RemoteService.instance.notifier);
    super.initState();
  }

  void _onHover(bool isHovering) {
    setState(() {
      isHovered = isHovering;
    });
  }

  Future<void> addMount(BuildContext context) async {
    final selectedRemote = await remoteReader.askUserToSelectRemote(context);

    if (selectedRemote == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MountInfoEditingScreen(selectedRemote: selectedRemote),
      ),
    );
  }

  Future<void> addRemote(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RemoteCreationScreen(parentContext: context),
      ),
    );

    await remoteReader.getAllRemotes(force: true);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _currentTab == Tab.remote
            ? () => addRemote(context)
            : () => addMount(context),
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          height: 63,
          width: 63,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF212121), width: 2),
            borderRadius: BorderRadius.circular(30),
            color: isHovered
                ? const Color(0xFF212121)
                : Theme.of(context).scaffoldBackgroundColor,
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TabBar extends StatefulWidget {
  final Function(Tab) onToggle;

  const _TabBar({required this.onToggle});

  @override
  State<_TabBar> createState() => _TabBarState();
}

class _TabBarState extends State<_TabBar> {
  double mountTextWidth = 0.0;
  double remoteTextWidth = 0.0;

  static const firstTabLabel = 'Pontos de montagem';
  static const secondTabLabel = 'Serviços de armazenamento';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mountTextPainter = TextPainter(
        text: TextSpan(
            text: firstTabLabel,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();

      final remoteTextPainter = TextPainter(
        text: TextSpan(
            text: secondTabLabel,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();

      setState(() {
        mountTextWidth = mountTextPainter.width + 45;
        remoteTextWidth = remoteTextPainter.width + 45;
      });
    });
  }

  void _toggleTab(Tab tab) {
    setState(() => _currentTab = tab);
    widget.onToggle(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF212121), width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastEaseInToSlowEaseOut,
            top: 4.5,
            left: _currentTab == Tab.mount ? 8 : mountTextWidth + 8,
            child: AnimatedContainer(
              width: _currentTab == Tab.mount ? mountTextWidth : remoteTextWidth,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastEaseInToSlowEaseOut,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(firstTabLabel, Tab.mount, 30, 0),
              const SizedBox(width: 45),
              _buildToggleButton(secondTabLabel, Tab.remote, 0, 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String text,
    Tab tab,
    double leftPadding,
    double rightPadding,
  ) {
    return MouseRegion(
      cursor: _currentTab == tab
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _toggleTab(tab),
        child: Container(
          padding: EdgeInsets.fromLTRB(leftPadding, 20, rightPadding, 18),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _currentTab == tab ? Colors.black : Colors.white,
              fontSize: 16,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
