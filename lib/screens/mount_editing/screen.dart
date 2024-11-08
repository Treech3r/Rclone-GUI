import 'package:flutter/material.dart';

import '../../models/mount.dart';
import '../../models/remote.dart';
import '../../services/sqflite.dart';
import '../remote_selection/screen.dart';
import '../remote_selection/widgets/remote_tile.dart';

class MountEditingScreen extends StatefulWidget {
  final Mount mount;
  final VoidCallback editCallback;
  final VoidCallback deleteCallback;

  const MountEditingScreen(
      {required this.mount,
      required this.editCallback,
      required this.deleteCallback,
      super.key});

  @override
  State<MountEditingScreen> createState() => _MountEditingScreenState();
}

class _MountEditingScreenState extends State<MountEditingScreen> {
  bool readOnly = false;
  Remote? selectedRemote;
  final textController = TextEditingController();
  late final Mount mount;

  @override
  void initState() {
    mount = widget.mount;
    textController.text = mount.name;
    readOnly = !mount.allowWrite;
    selectedRemote = mount.remote;
    super.initState();
  }

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

  Future<void> editMount(BuildContext context) async {
    mount.remote = selectedRemote!;
    mount.name = textController.text;
    mount.allowWrite = !readOnly;

    await SqfliteService.updateMount(mount);

    widget.editCallback();

    if (context.mounted) {
      Navigator.of(context).pop(mount);
    }
  }

  Future<void> deleteMount(BuildContext context) async {
    SqfliteService.deleteMount(mount);
    widget.deleteCallback();

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
                onPressed: () => editMount(context),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.deepPurpleAccent),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Salvar alterações',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Editando mount'),
        centerTitle: true,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Confirmar deleção'),
                  content: Text(
                    'Tem certeza que deseja deletar este mount? Fique tranquilo, sua configuração do rclone e seus arquivos permanecerão intactos.',
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.deepPurpleAccent,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Cancelar',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FilledButton(
                            onPressed: () {
                              deleteMount(context);
                              Navigator.of(ctx).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.redAccent),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Deletar',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
            icon: Icon(
              Icons.delete_forever_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
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
