import 'package:flutter/material.dart';

import '../../models/mount.dart';
import '../../services/sqflite.dart';
import '../mount_info_editing/screen.dart';
import 'widgets/mount_tile.dart';

class MountsScreen extends StatefulWidget {
  const MountsScreen({super.key});

  @override
  State<MountsScreen> createState() => _MountsScreenState();
}

class _MountsScreenState extends State<MountsScreen> {
  List<Mount> _mounts = [];
  bool fetched = false;

  @override
  void initState() {
    SqfliteService.getAllMounts().then((mounts) => setState(() {
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

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (!fetched) {
      bodyContent = Center(child: Text('Buscando remotes...'));
    } else if (_mounts.isEmpty) {
      bodyContent = EmptyWarning(() => addMount(context));
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 80),
        itemCount: _mounts.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
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
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('Seus mounts'),
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
      body: bodyContent,
    );
  }
}

class EmptyWarning extends StatelessWidget {
  final VoidCallback callback;

  const EmptyWarning(this.callback, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: []),
        Text(
          'Um pouco vazio por aqui...',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/images/treecher_sleeping.png',
          height: MediaQuery.of(context).size.height * 0.4,
        ),
        SizedBox(height: 20),
        Text(
          'Que tal criar seu primeiro mount?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 20),
        FilledButton(
          onPressed: callback,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.deepPurpleAccent),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Criar primeiro mount',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
