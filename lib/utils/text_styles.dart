import 'package:flutter/material.dart';

class CustomTextStyles {
  final BuildContext context;

  CustomTextStyles(this.context);

  TextStyle title({Color? color, String? text, double? fontSize}) {
    return TextStyle(
      color: color ?? Theme.of(context).colorScheme.onBackground,
      fontSize: fontSize ?? 20,
      overflow: TextOverflow.ellipsis,
    );
  }

  TextStyle subtitle({Color? color, String? text, double? fontSize}) {
    return TextStyle(
      color: color ?? Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
      fontSize: fontSize ?? 12,
      fontFamily: 'EpilogueMedium',
      overflow: TextOverflow.ellipsis,
    );
  }
}
