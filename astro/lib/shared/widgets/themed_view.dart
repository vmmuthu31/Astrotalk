import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ThemedView extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const ThemedView({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.backgroundRoot,
      padding: padding,
      child: child,
    );
  }
}
