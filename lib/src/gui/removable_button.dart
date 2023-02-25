import 'package:flutter/material.dart';

class RemovableButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onRemoved;
  final Widget child;

  const RemovableButton(
      {Key? key, this.onPressed, this.onRemoved, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        children: [
          child,
          if (onRemoved != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: onRemoved,
            ),
        ],
      ),
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    );
  }
}
