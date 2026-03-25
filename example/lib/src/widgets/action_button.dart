import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
