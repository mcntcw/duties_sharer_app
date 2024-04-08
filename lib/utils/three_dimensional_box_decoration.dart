import 'package:flutter/material.dart';

BoxDecoration threeDimensionalBoxDecoration({
  required BuildContext context,
  required Color backgroundColor,
  required Color borderColor,
  Color? shadowColor,
}) {
  return BoxDecoration(
    border: Border.all(
      color: borderColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(12),
    color: backgroundColor,
    boxShadow: [
      BoxShadow(
        color: shadowColor ?? borderColor,
        offset: const Offset(3, 3),
      ),
    ],
  );
}

BoxDecoration thinThreeDimensionalBoxDecoration(
    {required BuildContext context, required Color backgroundColor, required Color borderColor}) {
  return BoxDecoration(
    border: Border.all(
      color: borderColor,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(10),
    color: backgroundColor,
    boxShadow: [
      BoxShadow(
        color: borderColor,
        offset: const Offset(1, 2),
      ),
    ],
  );
}
