import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mount.dart';
import '../../models/remote.dart';
import '../../services/mount_service.dart';
import '../../utils/windows.dart';
import '../../widgets/remote_tile.dart';
import '../../widgets/rounded_button.dart';
import '../remote_selection/screen.dart';

class MountInfoEditingScreen extends ConsumerStatefulWidget {
  final Mount? mount;
  final Remote? selectedRemote;

  const MountInfoEditingScreen({
    this.mount,
    this.selectedRemote,
    super.key,
  });

  @override
  ConsumerState<MountInfoEditingScreen> createState() =>
      _MountInfoEditingScreenState();
}

class _MountInfoEditingScreenState
    extends ConsumerState<MountInfoEditingScreen> {
  String mountPath = 'A';
  bool readOnly = false;
  late Remote selectedRemote;
  final mountNameTextController = TextEditingController();

  @override
  void initState() {
    if (widget.selectedRemote != null) {
      selectedRemote = widget.selectedRemote!;
    }

    if (widget.mount != null) {
      readOnly = !widget.mount!.allowWrite;
      selectedRemote = widget.mount!.remote!;
      mountNameTextController.text = widget.mount!.name ?? '';
      mountPath = widget.mount!.mountPath;
    }

    super.initState();
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
      remote: selectedRemote,
      remotePath: '',
      mountPath: mountPath,
      allowWrite: !readOnly,
    );

    await ref.read(MountService.instance.notifier).createMount(mount);

    if (context.mounted) {
      Navigator.of(context).pop(mount);
    }
  }

  Future<void> editMount(BuildContext context) async {
    final newName = mountNameTextController.text.trim();

    final newMount = widget.mount!.copyWith(
      allowWrite: !readOnly,
      mountPath: mountPath,
      remote: selectedRemote,
    );

    if (newName.isEmpty) {
      newMount.name = null;
    } else {
      newMount.name = newName;
    }

    await ref.read(MountService.instance.notifier).editMount(newMount);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteMount(BuildContext context) async {
    await ref.read(MountService.instance.notifier).deleteMount(widget.mount!);

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
            WindowsHelper.allDriveLetters,
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
        title: Text(
          widget.mount != null ? 'Editando drive' : 'Criando novo drive',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Armazenamento que será montado:'),
            SizedBox(height: 12.0),
            SizedBox(
              width: 150,
              height: 150,
              child: RemoteTile(
                remote: selectedRemote,
                overrideCallback: () => selectRemote(context),
              ),
            ),
            SizedBox(height: 12.0),
            Text(
                'Você pode clicar no armazenamento acima para trocá-lo por outro armazenamento'),
            SizedBox(height: 12.0),
            TextFormField(
              controller: mountNameTextController,
              decoration: InputDecoration(
                labelText: 'Nome do drive (opcional)',
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
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RoundedButton(
            enabledColor: Colors.deepPurpleAccent,
            externalPadding: const EdgeInsets.all(12.0),
            label: widget.mount != null ? 'Salvar drive' : 'Criar drive',
            onPressed: mountPath.isEmpty
                ? null
                : () {
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
              label: 'Deletar drive',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Confirmar deleção'),
                    content: Text(
                      'Tem certeza que deseja deletar este drive? Fique tranquilo, seus arquivos não serão deletados e sua configuração do rclone não será afetada.',
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
  void initState() {
    _selectedDrive = widget.initialValue;
    super.initState();
  }

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
