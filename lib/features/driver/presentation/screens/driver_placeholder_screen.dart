import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/generated/app_localizations.dart';

class DriverPlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const DriverPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: AppLocalizations.of(context)!.comingSoon,
        description: title,
      ),
    );
  }
}
