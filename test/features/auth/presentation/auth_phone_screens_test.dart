import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:louage_go/core/theme/app_theme.dart';
import 'package:louage_go/core/theme/app_preferences.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/auth/domain/auth_exception.dart';
import 'package:louage_go/features/auth/domain/auth_repository.dart';
import 'package:louage_go/features/auth/domain/otp_challenge.dart';
import 'package:louage_go/features/auth/domain/phone_number.dart';
import 'package:louage_go/features/auth/presentation/otp_arguments.dart';
import 'package:louage_go/features/auth/presentation/screens/login_screen.dart';
import 'package:louage_go/features/auth/presentation/screens/otp_screen.dart';
import 'package:louage_go/features/auth/presentation/screens/register_screen.dart';
import 'package:louage_go/features/auth/presentation/widgets/phone_change_action.dart';
import 'package:louage_go/features/profile/data/profile_photo.dart';
import 'package:louage_go/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:louage_go/features/users/presentation/screens/passenger_profile_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  test('embedded profile photos can be decoded from the Hive value', () {
    final image = profilePhotoProvider('data:image/jpeg;base64,AQID');

    expect(image, isA<MemoryImage>());
    expect((image! as MemoryImage).bytes, [1, 2, 3]);
  });

  testWidgets('OTP accepts typed and pasted codes and localizes errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeAuthRepository(
      verificationError: AuthException.otpInvalid,
    );
    final phone = PhoneNumber('20000001');
    final challenge = _newChallenge();
    await tester.pumpWidget(
      _testApp(
        repository: repository,
        locale: const Locale('fr'),
        child: OtpScreen(
          arguments: OtpArguments(
            phone: phone,
            purpose: OtpPurpose.login,
            challenge: challenge,
          ),
        ),
      ),
    );
    await tester.pump();

    for (var index = 0; index < 6; index++) {
      await tester.enterText(
        find.byKey(ValueKey('otp-digit-$index')),
        '000000'[index],
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(repository.verifiedCodes, ['000000']);
    expect(find.text('Code de vérification incorrect'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('otp-digit-0')), '123456');
    await tester.pumpAndSettle();

    expect(repository.verifiedCodes, ['000000', '123456']);
    expect(find.text('Code de vérification incorrect'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'OTP resend countdown enables a new request after thirty seconds',
    (tester) async {
      final repository = _FakeAuthRepository();
      final locale = const Locale('en');
      final l10n = await AppLocalizations.delegate.load(locale);
      await tester.pumpWidget(
        _testApp(
          repository: repository,
          locale: locale,
          child: OtpScreen(
            arguments: OtpArguments(
              phone: PhoneNumber('20000001'),
              purpose: OtpPurpose.login,
              challenge: _newChallenge(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(l10n.otpResendCountdown(30)), findsOneWidget);
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      expect(find.text(l10n.otpResendAction), findsOneWidget);

      await tester.tap(find.text(l10n.otpResendAction));
      await tester.pumpAndSettle();

      expect(repository.requestCount, 1);
      expect(find.text(l10n.otpCodeResent), findsOneWidget);
    },
  );

  testWidgets('OTP renders on narrow screens in all locales and themes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      for (final isDark in [false, true]) {
        await tester.pumpWidget(
          _testApp(
            repository: _FakeAuthRepository(),
            locale: locale,
            isDark: isDark,
            child: OtpScreen(
              arguments: OtpArguments(
                phone: PhoneNumber('20000001'),
                purpose: OtpPurpose.login,
                challenge: _newChallenge(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const ValueKey('otp-digit-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('otp-digit-5')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('login switches between phone and email in every locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      await tester.pumpWidget(
        _testApp(
          repository: _FakeAuthRepository(),
          locale: locale,
          child: LoginScreen(key: ValueKey(locale)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('+216 '), findsOneWidget);
      final prefixText = tester.widget<Text>(find.text('+216 '));
      expect(
        Directionality.of(tester.element(find.byWidget(prefixText))),
        TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(l10n.loginMethodEmail));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text(l10n.loginForgotPassword), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('profile options navigate to full pages, not modal routes', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const PassengerProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          name: 'profileEdit',
          builder: (context, state) =>
              const Scaffold(body: Text('Edit profile destination')),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) =>
              const Scaffold(body: Text('Settings destination')),
        ),
        GoRoute(
          path: '/help/faq',
          name: 'helpFaq',
          builder: (context, state) =>
              const Scaffold(body: Text('Help destination')),
        ),
        GoRoute(
          path: '/legal/terms',
          name: 'legalTerms',
          builder: (context, state) =>
              const Scaffold(body: Text('Terms destination')),
        ),
        GoRoute(
          path: '/legal/privacy',
          name: 'legalPrivacy',
          builder: (context, state) =>
              const Scaffold(body: Text('Privacy destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                id: 'profile-user',
                name: 'Profile User',
                role: 'passenger',
              ),
            ),
          ),
        ],
        child: MaterialApp.router(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final (label, destination) in [
      ('Modifier le profil', 'Edit profile destination'),
      ('Aide', 'Help destination'),
      ('Conditions d’utilisation', 'Terms destination'),
      ('Confidentialité', 'Privacy destination'),
    ]) {
      for (
        var attempt = 0;
        attempt < 5 && find.text(label).evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -360));
        await tester.pumpAndSettle();
      }
      expect(find.text(label), findsWidgets);
      await tester.ensureVisible(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();

      expect(find.text(destination), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(BottomSheet), findsNothing);
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(PassengerProfileScreen), findsOneWidget);
    }
  });

  testWidgets('profile language and theme selectors apply their selections', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          currentUserProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _PreferencePickerHost(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisir la langue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsLanguageEnglish));
    await tester.pumpAndSettle();
    expect(find.text('en'), findsOneWidget);

    await tester.tap(find.text('Choisir le thème'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsThemeDark));
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile supports every locale and theme at 320 dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      for (final isDark in [false, true]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
              currentUserProvider.overrideWith(
                (ref) => Stream.value(
                  const AppUser(
                    id: 'profile-user',
                    name: 'LouageGo Passenger',
                    phone: '+21620000001',
                    email: 'passenger@example.tn',
                    city: 'Tunis',
                    role: 'passenger',
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) => Theme(
                data: AppTheme.withLocale(Theme.of(context), locale),
                child: child ?? const SizedBox.shrink(),
              ),
              home: const PassengerProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PassengerProfileScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('delete account requires the localized confirmation word', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    final router = _profileFlowRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_profileFlowApp(router, repository));
    await tester.pumpAndSettle();
    expect(find.byType(PassengerProfileScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(l10n.deleteAccountAction),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(l10n.deleteAccountAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.deleteAccountAction));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer le compte ?'), findsOneWidget);
    expect(repository.deleteCount, 0);
    await tester.tap(find.text(l10n.deleteAccountAction).last);
    await tester.pumpAndSettle();

    expect(find.text('Confirmer la suppression'), findsOneWidget);
    expect(repository.deleteCount, 0);
    await tester.enterText(find.byType(TextField), 'SUPPRIMER');
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.deleteAccountAction).last);
    await tester.pumpAndSettle();

    expect(repository.deleteCount, 1);
    expect(find.text('Login destination'), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign out confirmation clears the route stack', (tester) async {
    final repository = _FakeAuthRepository();
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    final router = _profileFlowRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_profileFlowApp(router, repository));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(l10n.driverLogout),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(l10n.driverLogout));
    await tester.pumpAndSettle();

    expect(find.text('Se déconnecter ?'), findsOneWidget);
    expect(repository.logoutCount, 0);
    await tester.tap(find.text(l10n.driverLogout).last);
    await tester.pumpAndSettle();

    expect(repository.logoutCount, 1);
    expect(find.text('Login destination'), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('register layouts support every locale and theme at 320 dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final isDark in [false, true]) {
        await tester.pumpWidget(
          _testApp(
            repository: _FakeAuthRepository(),
            locale: locale,
            isDark: isDark,
            child: RegisterScreen(key: ValueKey('$locale-$isDark')),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.registerPassengerRole), findsOneWidget);
        expect(find.text(l10n.registerDriverRole), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(l10n.registerUseEmail));
        await tester.pumpAndSettle();
        expect(find.text(l10n.registerPasswordLabel), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets(
    'phone change opens its protected OTP route with typed arguments',
    (tester) async {
      OtpArguments? receivedArguments;
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const Scaffold(body: PhoneChangeAction()),
          ),
          GoRoute(
            path: '/profile/verify-phone',
            name: 'profileVerifyPhone',
            builder: (context, state) {
              receivedArguments = state.extra as OtpArguments;
              return const Scaffold(body: Text('OTP route'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.tap(find.text('Modifier le numéro de téléphone'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '20123456');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.text('OTP route'), findsOneWidget);
      expect(receivedArguments?.phone, PhoneNumber('20123456'));
      expect(receivedArguments?.purpose, OtpPurpose.changePhone);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _testApp({
  required _FakeAuthRepository repository,
  required Widget child,
  Locale locale = const Locale('fr'),
  bool isDark = false,
}) => ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(size: const Size(320, 800), disableAnimations: true),
      child: Theme(
        data: AppTheme.withLocale(Theme.of(context), locale),
        child: child ?? const SizedBox.shrink(),
      ),
    ),
    home: child,
  ),
);

GoRouter _profileFlowRouter() => GoRouter(
  initialLocation: '/profile',
  routes: [
    GoRoute(
      path: '/profile',
      builder: (context, state) => const PassengerProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) =>
          const Scaffold(body: Text('Login destination')),
    ),
  ],
);

Widget _profileFlowApp(GoRouter router, _FakeAuthRepository repository) =>
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        currentUserProvider.overrideWith(
          (ref) => Stream.value(
            const AppUser(
              id: 'profile-user',
              name: 'Profile User',
              phone: '+21620000001',
              role: 'passenger',
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

OtpChallenge _newChallenge() {
  final now = DateTime.now();
  return OtpChallenge(
    id: 'widget-challenge',
    expiresAt: now.add(const Duration(minutes: 5)),
    resendAvailableAt: now.add(const Duration(seconds: 30)),
    demoCode: '123456',
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.verificationError});

  final String? verificationError;
  final verifiedCodes = <String>[];
  int requestCount = 0;
  int deleteCount = 0;
  int logoutCount = 0;

  @override
  Future<OtpChallenge> requestOtp(PhoneNumber phone, OtpPurpose purpose) async {
    requestCount++;
    final now = DateTime.now();
    return OtpChallenge(
      id: 'requested-$requestCount',
      expiresAt: now.add(const Duration(minutes: 5)),
      resendAvailableAt: now.add(const Duration(seconds: 30)),
      demoCode: '654321',
    );
  }

  @override
  Future<void> verifyOtp(String challengeId, String code) async {
    verifiedCodes.add(code);
    if (verificationError != null) {
      throw AuthException(verificationError!);
    }
  }

  @override
  Future<AppUser> registerWithPhone({
    required String name,
    required PhoneNumber phone,
    required String role,
    String? email,
  }) async => AppUser(name: name, phone: phone.canonical, role: role);

  @override
  Future<AppUser> loginWithPhone(PhoneNumber phone) async =>
      AppUser(name: 'Test', phone: phone.canonical);

  @override
  Future<AppUser> changePhone(PhoneNumber phone) async =>
      AppUser(name: 'Test', phone: phone.canonical);

  @override
  Future<AppUser> updateProfile({
    String? name,
    String? email,
    String? city,
    String? photo,
    String? language,
  }) async => AppUser(
    name: name ?? 'Test',
    email: email ?? '',
    city: city ?? '',
    photo: photo ?? '',
    language: language ?? '',
  );

  @override
  Future<AppUser> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async => AppUser(name: name, role: role);

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async => const AppUser(name: 'Test');

  @override
  Future<void> logout() async {
    logoutCount++;
  }

  @override
  Future<AppUser?> currentUser() async => null;

  @override
  Future<String?> currentRole() async => null;

  @override
  Future<String> resetPassword(String email) async => '000000';

  @override
  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<void> deleteAccount() async {
    deleteCount++;
  }
}

class _PreferencePickerHost extends ConsumerWidget {
  const _PreferencePickerHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Column(
      children: [
        Text(ref.watch(localeProvider).languageCode),
        Text(ref.watch(themeModeProvider).name),
        TextButton(
          onPressed: () => showProfileLanguagePicker(context, ref),
          child: const Text('Choisir la langue'),
        ),
        TextButton(
          onPressed: () => showProfileThemePicker(context, ref),
          child: const Text('Choisir le thème'),
        ),
      ],
    ),
  );
}
