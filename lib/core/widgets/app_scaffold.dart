import 'package:flutter/material.dart';

import 'animated_background.dart';

/// Scaffold avec arrière-plan animé "LouageGo Living World" intégré.
///
/// Remplace [Scaffold] sur tous les écrans fonctionnels.
/// L'animation [BackgroundIntensity.subtle] est appliquée automatiquement.
///
/// Usage :
/// ```dart
/// return AppScaffold(
///   appBar: AppBar(title: Text('Mon écran')),
///   body: ...,
/// );
/// ```
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.intensity = BackgroundIntensity.subtle,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final BackgroundIntensity intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBackground(intensity: intensity),
        Scaffold(
          backgroundColor: backgroundColor ?? Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
          bottomSheet: bottomSheet,
          drawer: drawer,
          endDrawer: endDrawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        ),
      ],
    );
  }
}
