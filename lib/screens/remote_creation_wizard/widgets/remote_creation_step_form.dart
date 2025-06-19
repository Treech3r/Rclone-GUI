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
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.globalKey,
      child: Column(
        children: [
          ...widget.step.parameters!.asMap().entries.map((entry) {
            final index = entry.key;
            final param = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < widget.step.parameters!.length - 1 ? 16.0 : 0.0,
              ),
              child: _buildInputField(param),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInputField(RemoteCreationTextInput param) {
    switch (param.type) {
      case RemoteCreationInputType.text:
      case RemoteCreationInputType.password:
        return CustomTextField(
          param: param,
          stateManager: widget.stateManager,
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
          onSaved: (value) =>
              widget.stateManager.updateConfig({param.key: value ?? ''}),
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

class CustomTextField extends StatelessWidget {
  final RemoteCreationTextInput param;
  final RemoteCreationStateManager stateManager;

  static const errorColor = Color(0xFFff5e5e);

  const CustomTextField({
    required this.param,
    required this.stateManager,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 170),
      child: Tooltip(
        padding: const EdgeInsets.all(8),
        waitDuration: const Duration(seconds: 1),
        message: param.hint ?? '',
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent.withAlpha(95),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextFormField(
          maxLines: 1,
          minLines: 1,
          obscureText: param.type == RemoteCreationInputType.password,
          initialValue: param.defaultValue,
          validator: (value) {
            if (param.required && (value == null || value.isEmpty)) {
              return '${param.label} é obrigatório';
            }
            return null;
          },
          onChanged: (value) => stateManager.updateConfig({param.key: value}),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: Colors.deepPurpleAccent,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0c0c0c),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            labelText: param.label,
            labelStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            hintMaxLines: 2,
            errorStyle: const TextStyle(
              color: errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.white24,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.deepPurpleAccent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: errorColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
