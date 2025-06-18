import 'package:flutter/material.dart';

import '../../../models/remote_creation/remote_creation_input.dart';
import '../../../models/remote_creation/remote_creation_step.dart';

class RemoteCreationStepForm extends StatefulWidget {
  final RemoteCreationStep step;
  final Function(Map<String, String>) onSubmit;

  const RemoteCreationStepForm({
    super.key,
    required this.step,
    required this.onSubmit,
  });

  @override
  RemoteCreationStepFormState createState() => RemoteCreationStepFormState();
}

class RemoteCreationStepFormState extends State<RemoteCreationStepForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  @override
  void initState() {
    super.initState();
    for (var param in widget.step.parameters!) {
      _formData[param.key] = param.defaultValue ?? '';
    }
  }

  Widget _buildInputField(RemoteCreationInput param) {
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
              return '${param.label} is required';
            }
            return null;
          },
          onSaved: (value) => _formData[param.key] = value ?? '',
        );
      case RemoteCreationInputType.boolean:
        return CheckboxListTile(
          title: Text(param.label),
          value: _formData[param.key] == 'true',
          onChanged: (value) {
            setState(() {
              _formData[param.key] = value.toString();
            });
          },
        );
      case RemoteCreationInputType.dropdown:
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: param.label),
          value: param.defaultValue,
          items: param.options?.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _formData[param.key] = value ?? '';
            });
          },
          validator: (value) {
            if (param.required && value == null) {
              return '${param.label} is required';
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
              return '${param.label} is required';
            }
            if (value != null && double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onSaved: (value) => _formData[param.key] = value ?? '',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...widget.step.parameters!.map(_buildInputField),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onSubmit(_formData);
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
