import 'package:flutter/material.dart';

import '../../../../features/profile/presentation/screens/profile_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ProfileScreen(fallbackName: (l10n) => l10n.profileDriverFallback);
}
