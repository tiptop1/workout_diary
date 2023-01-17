import 'package:flutter/material.dart';

class RemovableButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback onRemoved;
  final Widget child;

  const RemovableButton(
      {Key? key,
      required this.onPressed,
      required this.onRemoved,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        children: [
          child,
          IconButton(
            icon: Icon(Icons.cancel_outlined),
            onPressed: onRemoved,
          ),
        ],
      ),
    );
  }
}
