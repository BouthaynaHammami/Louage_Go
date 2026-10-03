import 'package:flutter/material.dart';

import '../../../../features/profile/presentation/screens/profile_screen.dart';

class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ProfileScreen(fallbackName: (l10n) => l10n.profilePassengerFallback);
}
