import 'package:flutter/material.dart';

class ElevatedBottomSheet {
  void showElevatedBottomSheet({required BuildContext context, required Widget body}) {
    showModalBottomSheet(
      barrierColor: Theme.of(context).colorScheme.background.withOpacity(0.4),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: body,
          ),
        );
      },
    );
  }
}
