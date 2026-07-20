import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 1024;

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 6;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double cardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = gridColumns(context);
    final spacing = (cols + 1) * 10.0;
    return (width - 48 - spacing) / cols;
  }

  static double padding(BuildContext context) =>
      isTablet(context) ? 48 : 24;

  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile * 1.4;
    if (isTablet(context)) return tablet ?? mobile * 1.2;
    return mobile;
  }
}
