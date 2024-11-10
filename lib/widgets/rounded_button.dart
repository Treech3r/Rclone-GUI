import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? enabledColor;
  final EdgeInsets? externalPadding;
  final EdgeInsets? internalPadding;

  const RoundedButton({
    required this.label,
    this.onPressed,
    this.enabledColor,
    this.externalPadding,
    this.internalPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: externalPadding ?? EdgeInsets.zero,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey;
              }
              return enabledColor ?? Colors.deepPurpleAccent;
            },
          ),
        ),
        child: Padding(
          padding: internalPadding ?? const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
