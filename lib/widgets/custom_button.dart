import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? textColor;
  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: threeDimensionalBoxDecoration(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.surface,
            borderColor: Theme.of(context).colorScheme.onBackground),
        child: Text(
          text,
          style: TextStyle(color: textColor ?? Theme.of(context).colorScheme.onBackground, fontSize: 11),
        ),
      ),
    );
  }
}
