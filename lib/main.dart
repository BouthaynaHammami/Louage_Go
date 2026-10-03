import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_preferences.dart';
import 'core/storage/hive_service.dart';
import 'core/storage/seed_data.dart';
import 'core/widgets/notification_lifecycle.dart';
import 'features/legal/presentation/legal_consent_gate.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  if (HiveService.isReady) {
    try {
      await SeedData.runIfNeeded();
    } catch (error) {
      debugPrint('Seed data initialization failed: $error');
    }
  }
  runApp(const ProviderScope(child: LouageGoApp()));
}

class LouageGoApp extends ConsumerWidget {
  const LouageGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = HiveService.isReady ? ref.watch(appRouterProvider) : null;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    Widget appBuilder(BuildContext context, Widget? child) {
      final routedChild = child ?? const SizedBox.shrink();
      return Theme(
        data: AppTheme.withLocale(Theme.of(context), locale),
        child: LegalConsentGate(
          child: router == null
              ? routedChild
              : NotificationLifecycle(child: routedChild),
        ),
      );
    }

    if (router == null) {
      return MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: appBuilder,
        home: const _StorageErrorScreen(),
      );
    }

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: appBuilder,
      routerConfig: router,
    );
  }
}

class _StorageErrorScreen extends StatelessWidget {
  const _StorageErrorScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.storageUnavailableTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(l10n.storageUnavailableBody, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
