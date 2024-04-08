import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.flickr(
        leftDotColor: Theme.of(context).colorScheme.onBackground,
        rightDotColor: Theme.of(context).colorScheme.onBackground,
        size: 22,
      ),
    );
  }
}
