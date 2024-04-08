import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final double? width;
  final double? height;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final String hintText;
  final TextInputType keyboardType;
  final String? errorMessage;
  final Widget? suffixIcon;
  const CustomTextField({
    super.key,
    this.width,
    this.height,
    required this.hintText,
    required this.controller,
    this.validator,
    required this.obscureText,
    this.errorMessage,
    this.suffixIcon,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: threeDimensionalBoxDecoration(
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          borderColor: Theme.of(context).colorScheme.onBackground),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: customTextStyles.subtitle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'EpilogueMedium',
            fontSize: 12,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
          errorStyle: TextStyle(
            fontFamily: 'EpilogueMedium',
            fontSize: 10,
            color: Theme.of(context).colorScheme.error,
          ),
          errorMaxLines: 3,
          errorText: errorMessage,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
