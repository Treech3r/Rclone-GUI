import 'package:flutter/material.dart';

import '../../models/mount.dart';
import '../../services/sqflite.dart';
import '../mount_creation/screen.dart';

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
        .push(MaterialPageRoute(builder: (_) => MountCreationScreen()));

    if (mount == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (!fetched) {
      bodyContent = Center(child: Text('Buscando remotes...'));
    } else if (_mounts.isEmpty) {
      bodyContent = EmptyWarning(() => addMount(context));
    } else {
      // TODO: return actual data
      bodyContent = Container();
    }
    return Scaffold(
      floatingActionButton: _mounts.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => addMount(context),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              child: Icon(Icons.add),
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
