import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {

  const ProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
