import 'package:flutter/material.dart';

enum RoundedButtonStyle {
  primary,
  secondary,
  danger,
}

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final RoundedButtonStyle style;
  final EdgeInsets? externalPadding;
  final EdgeInsets? internalPadding;

  const RoundedButton({
    required this.label,
    this.onPressed,
    this.style = RoundedButtonStyle.primary,
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
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide.none;
              }

              if (states.contains(WidgetState.hovered)) {
                return BorderSide(
                  color: _getHoverBorderColor(style),
                  width: 2,
                );
              }

              return BorderSide(color: _getEnabledBorderColor(style), width: 2);
            },
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.white12;
              }

              if (states.contains(WidgetState.hovered)) {
                return _getHoverColor(style);
              }

              return _getFillColor(style);
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

Color _getEnabledBorderColor(RoundedButtonStyle style) {
  switch (style) {
    case RoundedButtonStyle.primary:
      return Colors.blueAccent.shade700;
    case RoundedButtonStyle.secondary:
      return Colors.white;
    case RoundedButtonStyle.danger:
      return const Color(0xFF8b1414);
    default:
      return Colors.black;
  }
}

Color _getFillColor(RoundedButtonStyle style) {
  switch (style) {
    case RoundedButtonStyle.primary:
      return Colors.blueAccent.shade700;
    case RoundedButtonStyle.secondary:
      return Colors.black;
    case RoundedButtonStyle.danger:
      return const Color(0xFF8b1414);
    default:
      return Colors.black;
  }
}

Color _getHoverBorderColor(RoundedButtonStyle style) {
  switch (style) {
    case RoundedButtonStyle.primary:
      return Colors.blueAccent;
    case RoundedButtonStyle.secondary:
      return Colors.white70;
    case RoundedButtonStyle.danger:
      return const Color(0xFFb21b1b);
    default:
      return Colors.black;
  }
}

Color _getHoverColor(RoundedButtonStyle style) {
  switch (style) {
    case RoundedButtonStyle.primary:
      return Colors.blueAccent;
    case RoundedButtonStyle.secondary:
      return Colors.white12;
    case RoundedButtonStyle.danger:
      return const Color(0xFFb21b1b);
    default:
      return Colors.black;
  }
}