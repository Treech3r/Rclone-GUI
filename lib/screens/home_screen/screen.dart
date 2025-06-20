import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/remote_service.dart';
import 'widgets/custom_tab_bar.dart';
import 'widgets/mount_point_list.dart';
import 'widgets/remote_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Tab currentTab = Tab.mount;

  late RemoteService remoteServiceReader;

  @override
  void initState() {
    // This has to be loaded here. If loaded on the RemoteGrid just as
    // it is with MountPointList, the user would see an empty remote list
    // when trying to create a new mount config if it hasn't switched to
    // the RemoteGrid tab at least once.
    remoteServiceReader = ref.read(RemoteService.instance.notifier);
    remoteServiceReader.getAllRemotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 60),
          CustomTabBar(onTabChange: (tab) => setState(() => currentTab = tab)),
          SizedBox(height: 60),
          Expanded(
            child: currentTab == Tab.mount
                ? MountPointList()
                : RemoteGrid(),
          ),
        ],
      ),
    );
  }
}
