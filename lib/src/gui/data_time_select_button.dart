import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

class DateTimeSelectButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool selectTime;
  final bool selectDate;

  const DateTimeSelectButton({
    Key? key,
    this.selectTime = false,
    this.selectDate = true,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var applocs = AppLocalizations.of(context)!;
    String? text;
    if (selectDate && selectTime) {
      text = applocs.setDateOrTime;
    } else if (selectTime) {
      text = applocs.setTime;
    } else if (selectDate) {
      text = applocs.setDate;
    }
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.access_time),
          if (text != null) Text(text),
        ],
      ),
    );
  }
}
