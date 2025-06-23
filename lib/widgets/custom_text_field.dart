import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? tooltipMessage;
  final bool obscureText;
  final String? initialValue;
  final void Function(String)? onChanged;
  final String? labelText;
  final bool required;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  static const errorColor = Color(0xFFff5e5e);

  const CustomTextField({
    this.tooltipMessage,
    this.obscureText = false,
    this.initialValue,
    this.onChanged,
    this.labelText,
    this.required = false,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 170),
      child: Tooltip(
        padding: const EdgeInsets.all(8),
        waitDuration: const Duration(seconds: 1),
        message: tooltipMessage ?? '',
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextFormField(
          controller: controller,
          maxLines: 1,
          minLines: 1,
          obscureText: obscureText,
          initialValue: initialValue,
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return 'Campo obrigatório';
            }

            return validator != null ? validator!(value) : null;
          },
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: Colors.blue.shade700,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(prefixIcon, color: Colors.white54),
                )
                : null,
            filled: true,
            fillColor: const Color(0xFF0c0c0c),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            labelText: labelText,
            labelStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: Colors.blue.shade100,
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
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Colors.white24,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: Colors.blue.shade700,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
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
