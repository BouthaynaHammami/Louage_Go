import 'package:flutter/material.dart';

AppBar driverAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) {
  final colors = Theme.of(context).colorScheme;
  final dark = colors.brightness == Brightness.dark;
  final foreground = dark ? colors.onSurface : colors.onPrimary;
  return AppBar(
    title: Text(title),
    actions: actions,
    backgroundColor: dark ? colors.surfaceContainerHigh : colors.secondary,
    foregroundColor: foreground,
    iconTheme: IconThemeData(color: foreground),
    actionsIconTheme: IconThemeData(color: foreground),
  );
}
