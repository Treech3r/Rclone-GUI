import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/remote_service.dart';
import '../mount_info_editing/screen.dart';
import '../remote_creation_wizard/screen.dart';
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

  late RemoteService remoteReader;


  @override
  void initState() {
    remoteReader = ref.read(RemoteService.instance.notifier);
    remoteReader.getAllRemotes();

    super.initState();
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
    final remotes = ref.watch(RemoteService.instance);

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
                ? MountPointList()
                : RemoteGrid(remotes: remotes),
          ),
        ],
      ),
    );
  }
}
