import 'package:flutter/material.dart';

import '../../models/mount.dart';
import '../../models/remote.dart';
import '../../services/sqflite.dart';
import '../remote_selection/screen.dart';
import '../remote_selection/widgets/remote_tile.dart';

class MountCreationScreen extends StatefulWidget {
  const MountCreationScreen({super.key});

  @override
  State<MountCreationScreen> createState() => _MountCreationScreenState();
}

class _MountCreationScreenState extends State<MountCreationScreen> {
  bool readOnly = false;
  Remote? selectedRemote;
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> selectRemote(BuildContext context) async {
    Remote? remote = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RemoteSelectionScreen()));

    if (remote == null) {
      return;
    }

    setState(() {
      selectedRemote = remote;
    });
  }

  Future<void> createMount(BuildContext context) async {
    var mount = Mount(
      id: 0,
      name: textController.text,
      remote: selectedRemote!,
      remotePath: '',
      mountPoint: '',
      allowWrite: !readOnly,
    );

    await SqfliteService.insertMount(mount);

    if (context.mounted) {
      Navigator.of(context).pop(mount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: selectedRemote == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: FilledButton(
                onPressed: () => createMount(context),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.deepPurpleAccent),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Criar mount',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Criando novo mount'),
        centerTitle: true,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            selectedRemote == null
                ? TextButton(
                    onPressed: () => selectRemote(context),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Selecionar remote'),
                    ),
                  )
                : RemoteTile(
                    remote: selectedRemote!,
                    overrideCallback: () => selectRemote(context),
                  ),
            SizedBox(height: 25),
            TextFormField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Nome do mount (opcional)',
                labelStyle: TextStyle(
                  fontSize: 16.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                prefixIcon: Icon(Icons.info, color: Colors.grey),
                filled: true,
              ),
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.deepPurpleAccent,
                  checkColor: Colors.white,
                  value: readOnly,
                  onChanged: (newValue) => setState(() {
                    readOnly = newValue!;
                  }),
                ),
                Text('Apenas leitura')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
