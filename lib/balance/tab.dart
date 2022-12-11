import 'package:flutter/material.dart';

import '../config.dart';
import '../essentials/app_theme.dart';

class CustomTab extends StatelessWidget {
  final bool selected;
  final String text;
  final Function() onDoubleTap;
  final Widget child;
  final double width, height;
  const CustomTab(
      {this.selected, this.onDoubleTap, this.child, this.width, this.height, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onDoubleTap: this.onDoubleTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          width: width ?? null,
          height: height ?? null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: selected
                ? AppTheme.gradientFromTheme(currentThemeName)
                : LinearGradient(colors: [
                    ElevationOverlay.applyOverlay(
                        context, Theme.of(context).colorScheme.surface, 10),
                    ElevationOverlay.applyOverlay(
                        context, Theme.of(context).colorScheme.surface, 10)
                  ]),
          ),
          padding: child == null
              ? EdgeInsets.symmetric(vertical: 10, horizontal: 20)
              : EdgeInsets.all(0),
          child: Center(
            child: child ??
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge.copyWith(
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
          ),
        ),
      ),
    );
  }
}
