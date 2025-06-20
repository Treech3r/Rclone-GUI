import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mount.dart';
import '../../services/mount_service.dart';
import '../../widgets/rounded_button.dart';
import '../mount_info_editing/screen.dart';
import '../remote_creation_wizard/screen.dart';
import 'widgets/custom_tab_bar.dart';
import 'widgets/mount_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Tab currentTab = Tab.mount;

  List<Mount> _mounts = [];
  bool fetched = false;

  @override
  void initState() {
    MountService.getAllMounts().then((mounts) => setState(() {
          _mounts = mounts;
          fetched = true;
        }));

    super.initState();
  }

  Future<void> addMount(BuildContext context) async {
    Mount? mount = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => MountInfoEditingScreen()));

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
    Widget bodyContent;

    if (!fetched) {
      bodyContent = Center(child: Text('Buscando remotes...'));
    } else if (_mounts.isEmpty) {
      bodyContent = EmptyWarning();
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
        itemCount: _mounts.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: MountTile(
            _mounts[index],
            editCallback: () => setState(() {}),
            deleteCallback: () => setState(() => _mounts.removeAt(index)),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: _mounts.isEmpty
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              title: Text('Seus mounts'),
              centerTitle: true,
            ),
      floatingActionButton: _mounts.isEmpty
          ? null
          : FloatingActionButton(
              shape: CircleBorder(),
              tooltip: 'Criar novo mount',
              onPressed: () => addMount(context),
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.add, color: Colors.white),
            ),
      body: Column(
        children: [
          CustomTabBar(
            onTabChange: (tab) => setState(() {
              currentTab = tab;
            }),
            onPlusButtonTap: () => currentTab == Tab.mount
                ? addMount(context)
                : addRemote(context),
          ),
          // bodyContent,
        ],
      ),
      bottomSheet: _mounts.isNotEmpty
          ? null
          : RoundedButton(
              onPressed: () => addMount(context),
              label: 'Criar primeiro mount',
              externalPadding: const EdgeInsets.all(12.0),
            ),
    );
  }
}

class EmptyWarning extends StatelessWidget {
  const EmptyWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(children: []),
        SizedBox(height: 40),
        Spacer(),
        Text(
          'Um pouco vazio por aqui...',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/images/treecher_sleeping.png',
          height: MediaQuery.of(context).size.height * 0.4,
        ),
        SizedBox(height: 20),
        Text(
          'Que tal criar seu primeiro ponto de montagem?',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        Spacer(
          flex: 1,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
