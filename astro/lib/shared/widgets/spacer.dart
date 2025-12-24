import 'package:flutter/material.dart';

class Spacer extends StatelessWidget {
  final double? width;
  final double? height;

  const Spacer({super.key, this.width, this.height});

  factory Spacer.horizontal(double width) => Spacer(width: width);
  factory Spacer.vertical(double height) => Spacer(height: height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
