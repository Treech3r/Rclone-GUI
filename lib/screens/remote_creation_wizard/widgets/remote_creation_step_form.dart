import 'package:flutter/material.dart';

import '../../../models/remote_creation/remote_creation_input.dart';
import '../../../models/remote_creation/remote_creation_state_manager.dart';
import '../../../models/remote_creation/remote_creation_step.dart';

class RemoteCreationStepForm extends StatefulWidget {
  final GlobalKey<FormState> globalKey;
  final RemoteCreationStep step;
  final RemoteCreationStateManager stateManager;

  const RemoteCreationStepForm({
    super.key,
    required this.step,
    required this.globalKey,
    required this.stateManager,
  });

  @override
  RemoteCreationStepFormState createState() => RemoteCreationStepFormState();
}

class RemoteCreationStepFormState extends State<RemoteCreationStepForm> {
  @override
  void initState() {
    super.initState();
    // TODO: find a way to initialize default values
    // for (var param in widget.step.parameters!) {
    //   widget.stateManager.updateConfig({param.key: param.defaultValue ?? ''});
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.globalKey,
      child: Column(
        children: [
          ...widget.step.parameters!.map(_buildInputField),
        ],
      ),
    );
  }

  Widget _buildInputField(RemoteCreationTextInput param) {
    switch (param.type) {
      case RemoteCreationInputType.text:
      case RemoteCreationInputType.password:
        return TextFormField(
          decoration: InputDecoration(
            labelText: param.label,
            hintText: param.hint,
          ),
          obscureText: param.type == RemoteCreationInputType.password,
          initialValue: param.defaultValue,
          validator: (value) {
            if (param.required && (value == null || value.isEmpty)) {
              return '${param.label} é obrigatório';
            }
            return null;
          },
          onChanged: (value) =>
              widget.stateManager.updateConfig({param.key: value}),
        );
      case RemoteCreationInputType.boolean:
        return CheckboxListTile(
          title: Text(param.label),
          value: widget.stateManager.getConfigValue(param.key) == 'true',
          onChanged: (value) {
            setState(() {
              widget.stateManager.updateConfig(
                  {param.key: value != null ? value.toString() : 'false'});
            });
          },
        );
      case RemoteCreationInputType.dropdown:
        return DropdownButtonFormField<String>(
          alignment: Alignment.topLeft,
          decoration: InputDecoration(labelText: param.label),
          value: param.defaultValue,
          items: param.options?.keys.map((option) {
            return DropdownMenuItem(
              alignment: AlignmentDirectional.center,
              value: option,
              child: Text('$option: ${param.options![option]!}'),
            );
          }).toList(),
          onSaved: (value) => widget.stateManager.updateConfig({param.key: value ?? ''}),
          onChanged: (value) {
            setState(() {
              widget.stateManager.updateConfig({param.key: value ?? ''});
            });
          },
          validator: (value) {
            if (param.required && (value == null || value.isEmpty)) {
              return '${param.label} é obrigatório';
            }
            return null;
          },
        );
      case RemoteCreationInputType.number:
        return TextFormField(
          decoration: InputDecoration(
            labelText: param.label,
            hintText: param.hint,
          ),
          keyboardType: TextInputType.number,
          initialValue: param.defaultValue,
          validator: (value) {
            if (param.required && (value == null || value.isEmpty)) {
              return '${param.label} é obrigatório';
            }
            if (value != null && double.tryParse(value) == null) {
              return 'Digite um número válido';
            }
            return null;
          },
          onSaved: (value) =>
              widget.stateManager.updateConfig({param.key: value ?? ''}),
        );
    }
  }
}
