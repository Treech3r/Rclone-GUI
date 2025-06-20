import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rclone_gui/models/remote.dart';

import '../../models/mount.dart';
import '../../services/mount_service.dart';
import '../../services/remote_service.dart';
import '../mount_info_editing/screen.dart';
import '../remote_creation_wizard/screen.dart';
import 'widgets/custom_tab_bar.dart';
import 'widgets/mount_point_list.dart';
import 'widgets/remote_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Tab currentTab = Tab.mount;

  List<Mount> _mounts = [];
  List<Remote> _remotes = [];

  @override
  void initState() {
    MountService.getAllMounts().then((mounts) => setState(() {
          _mounts = mounts;
        }));

    RemoteService.getAllRemotes().then((remotes) => setState(() {
          _remotes = remotes;
        }));

    super.initState();
  }

  Future<void> addMount(BuildContext context) async {
    Mount? mount = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MountInfoEditingScreen()),
    );

    if (mount == null) {
      return;
    }

    setState(() {
      _mounts.add(mount);
    });
  }

  Future<void> addRemote(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderScope(child: RemoteCreationScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 60),
          CustomTabBar(
            onTabChange: (tab) => setState(() => currentTab = tab),
            onPlusButtonTap: () => currentTab == Tab.mount
                ? addMount(context)
                : addRemote(context),
          ),
          SizedBox(height: 60),
          Expanded(
            child: currentTab == Tab.mount
                ? MountPointList(mounts: _mounts)
                : RemoteGrid(remotes: _remotes),
          ),
        ],
      ),
    );
  }
}
