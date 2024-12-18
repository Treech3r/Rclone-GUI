import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/mount.dart';
import '../../models/remote.dart';
import '../../services/sqflite.dart';
import '../../utils/windows.dart';
import '../../widgets/rounded_button.dart';
import '../remote_selection/screen.dart';
import '../remote_selection/widgets/remote_tile.dart';

class MountInfoEditingScreen extends StatefulWidget {
  final Mount? mount;
  final VoidCallback? editCallback;
  final VoidCallback? deleteCallback;

  const MountInfoEditingScreen({
    this.mount,
    this.editCallback,
    this.deleteCallback,
    super.key,
  });

  @override
  State<MountInfoEditingScreen> createState() => _MountInfoEditingScreenState();
}

class _MountInfoEditingScreenState extends State<MountInfoEditingScreen> {
  List<String> windowsDriveLetters = [];
  String mountPath = '';
  bool readOnly = false;
  Remote? selectedRemote;
  final mountNameTextController = TextEditingController();

  @override
  void initState() {
    if (Platform.isWindows) {
      getAvailableDriveLetters().then((letters) => setState(() {
            windowsDriveLetters = letters;
          }));

      super.initState();
    }

    if (widget.mount != null) {
      mountPath = widget.mount!.mountPath;
      readOnly = !widget.mount!.allowWrite;
      selectedRemote = widget.mount!.remote;
      mountNameTextController.text = widget.mount!.name ?? '';
    }
  }

  @override
  void dispose() {
    mountNameTextController.dispose();
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

  Future<void> selectMountPoint() async {
    String? path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Selecione onde deseja montar',
      lockParentWindow: true,
    );

    if (path == null) {
      return;
    }

    setState(() {
      mountPath = path;
    });
  }

  Future<void> createMount(BuildContext context) async {
    var mount = Mount(
      id: 0,
      name: mountNameTextController.text.isNotEmpty
          ? mountNameTextController.text
          : null,
      remote: selectedRemote!,
      remotePath: '',
      mountPath: mountPath,
      allowWrite: !readOnly,
    );

    await SqfliteService.insertMount(mount);

    if (context.mounted) {
      Navigator.of(context).pop(mount);
    }
  }

  Future<void> editMount(BuildContext context) async {
    widget.mount!.remote = selectedRemote!;
    if (mountNameTextController.text.trim().isEmpty) {
      widget.mount?.name = null;
    } else {
      widget.mount?.name = mountNameTextController.text;
    }
    widget.mount!.allowWrite = !readOnly;

    await SqfliteService.updateMount(widget.mount!);

    widget.editCallback!();

    if (context.mounted) {
      Navigator.of(context).pop(widget.mount!);
    }
  }

  Future<void> deleteMount(BuildContext context) async {
    SqfliteService.deleteMount(widget.mount!);
    widget.deleteCallback!();

    if (context.mounted) {
      Navigator.of(context).pop(widget.mount!);
    }
  }

  void chooseWindowsPath(String path) {
    setState(() {
      mountPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mountPathPicker = Platform.isWindows
        ? WindowsDriveLetterPicker(
            windowsDriveLetters,
            chooseWindowsPath,
            mountPath,
          )
        : RoundedButton(
            onPressed: () => selectMountPoint(),
            label: mountPath.isEmpty
                ? 'Selecionar pasta vazia para montar'
                : mountPath,
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.mount != null ? 'Editando mount' : 'Criando novo mount',
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            selectedRemote == null
                ? RoundedButton(
                    label: 'Selecionar remote',
                    onPressed: () => selectRemote(context),
                  )
                : RemoteTile(
                    remote: selectedRemote!,
                    overrideCallback: () => selectRemote(context),
                  ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: mountNameTextController,
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
            SizedBox(height: 12.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  activeColor: Colors.deepPurpleAccent,
                  checkColor: Colors.white,
                  value: readOnly,
                  onChanged: (newValue) => setState(() {
                    readOnly = newValue!;
                  }),
                ),
                Text('Apenas leitura'),
              ],
            ),
            SizedBox(height: 12.0),
            mountPathPicker,
          ],
        ),
      ),
      bottomSheet: selectedRemote == null || mountPath.isEmpty
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RoundedButton(
                  enabledColor: Colors.purpleAccent,
                  externalPadding: const EdgeInsets.all(12.0),
                  label: widget.mount != null ? 'Salvar mount' : 'Criar mount',
                  onPressed: () {
                    if (widget.mount != null) {
                      editMount(context);
                    } else {
                      createMount(context);
                    }
                  },
                ),
                if (widget.mount != null)
                  RoundedButton(
                    enabledColor: Colors.red,
                    externalPadding: const EdgeInsets.all(12.0),
                    label: 'Deletar mount',
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
                                RoundedButton(
                                  label: 'Cancelar',
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                RoundedButton(
                                  label: 'Deletar',
                                  onPressed: () {
                                    deleteMount(context);
                                    Navigator.of(ctx).pop();
                                  },
                                  enabledColor: Colors.red,
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class WindowsDriveLetterPicker extends StatefulWidget {
  final List<String> letters;
  final String initialValue;
  final void Function(String mountPath) chooseWindowsMountPath;

  const WindowsDriveLetterPicker(
      this.letters, this.chooseWindowsMountPath, this.initialValue,
      {super.key});

  @override
  State<WindowsDriveLetterPicker> createState() =>
      _WindowsDriveLetterPickerState();
}

class _WindowsDriveLetterPickerState extends State<WindowsDriveLetterPicker> {
  String? _selectedDrive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Selecione uma letra para montar:'),
        SizedBox(width: 20),
        widget.letters.isEmpty
            ? RefreshProgressIndicator()
            : DropdownButton<String>(
                alignment: Alignment.center,
                value: _selectedDrive,
                items: widget.letters.map((String drive) {
                  return DropdownMenuItem<String>(
                    value: drive,
                    alignment: Alignment.center,
                    child: Text('$drive:'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == null) {
                    return;
                  }

                  setState(() {
                    _selectedDrive = newValue;
                    widget.chooseWindowsMountPath(newValue);
                  });
                },
              ),
      ],
    );
  }
}
