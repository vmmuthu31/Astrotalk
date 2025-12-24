import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

enum TextType { h1, h2, h3, h4, body, small, link }

class ThemedText extends StatelessWidget {
  final String text;
  final TextType type;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const ThemedText(
    this.text, {
    super.key,
    this.type = TextType.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  TextStyle _getStyle() {
    switch (type) {
      case TextType.h1:
        return GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color ?? AppColors.text,
        );
      case TextType.h2:
        return GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color ?? AppColors.text,
        );
      case TextType.h3:
        return GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.text,
        );
      case TextType.h4:
        return GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.text,
        );
      case TextType.body:
        return GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.text,
        );
      case TextType.small:
        return GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.text,
        );
      case TextType.link:
        return GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.secondary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
