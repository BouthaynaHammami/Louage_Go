import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../auth_providers.dart';
import '../../domain/auth_exception.dart';
import '../../domain/otp_challenge.dart';
import '../../domain/phone_number.dart';
import '../auth_error_message.dart';
import '../auth_home_route.dart';
import '../otp_arguments.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String role = 'passenger';
  bool loading = false;
  bool _phoneMode = true;
  bool _acceptedTerms = false;
  bool _consentError = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _password.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final password = _password.text;
    final strength = password.isEmpty
        ? 0
        : password.length >= 12 &&
              RegExp(r'[0-9]').hasMatch(password) &&
              RegExp(r'[^A-Za-z0-9]').hasMatch(password)
        ? 3
        : password.length >= 8
        ? 2
        : 1;
    if (_passwordStrength != strength) {
      setState(() => _passwordStrength = strength);
    }
  }

  @override
  void dispose() {
    _password.removeListener(_updatePasswordStrength);
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (!_acceptedTerms) {
      setState(() => _consentError = true);
      _msg(l10n.registerConsentRequired);
      return;
    }
    if (name.isEmpty ||
        phone.isEmpty ||
        (!_phoneMode && (email.isEmpty || password.isEmpty))) {
      _msg(l10n.formRequiredFields);
      return;
    }
    if (!_phoneMode && password != _confirm.text) {
      _msg(l10n.passwordMismatch);
      return;
    }

    setState(() => loading = true);
    try {
      final controller = ref.read(authControllerProvider.notifier);
      if (_phoneMode) {
        final parsedPhone = PhoneNumber(phone);
        final challenge = await controller.requestOtp(
          parsedPhone,
          OtpPurpose.register,
        );
        if (!mounted) return;
        context.pushNamed(
          'otp',
          extra: OtpArguments(
            phone: parsedPhone,
            purpose: OtpPurpose.register,
            challenge: challenge,
            name: name,
            role: role,
            email: email.isEmpty ? null : email,
            acceptedTermsVersion: AppConfig.legalVersion,
            acceptedTermsAt: DateTime.now().toIso8601String(),
          ),
        );
      } else {
        final user = await controller.register(
          name: name,
          phone: phone,
          email: email,
          password: password,
          role: role,
          acceptedTermsVersion: AppConfig.legalVersion,
          acceptedTermsAt: DateTime.now().toIso8601String(),
        );
        if (!mounted) return;

        final messenger = ScaffoldMessenger.of(context);
        context.go(authHomeRouteForRole(user.role));
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.authWelcomeMessage(user.name)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _msg(authErrorMessage(AppLocalizations.of(context)!, e.code));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildConsent(AppLocalizations l10n) => Material(
    color: Colors.transparent,
    child: CheckboxListTile(
      value: _acceptedTerms,
      onChanged: (accepted) => setState(() {
        _acceptedTerms = accepted ?? false;
        _consentError = false;
      }),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsetsDirectional.zero,
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.registerAcceptTerms),
          TextButton(
            onPressed: () => context.pushNamed('legalTerms'),
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
            ),
            child: Text(l10n.registerTermsLink),
          ),
          Text(l10n.registerAnd),
          TextButton(
            onPressed: () => context.pushNamed('legalPrivacy'),
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
            ),
            child: Text(l10n.registerPrivacyLink),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      title: l10n.registerTitle,
      showBackButton: true,
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthStaggerItem(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.registerRolePrompt,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleOption(
                        label: l10n.registerPassengerRole,
                        icon: Icons.person_outline,
                        selected: role == 'passenger',
                        onTap: () => setState(() => role = 'passenger'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleOption(
                        label: l10n.registerDriverRole,
                        icon: Icons.badge_outlined,
                        selected: role == 'driver',
                        onTap: () => setState(() => role = 'driver'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.center,
            child: TextButton.icon(
              onPressed: loading
                  ? null
                  : () => setState(() => _phoneMode = !_phoneMode),
              icon: Icon(
                _phoneMode ? Icons.alternate_email : Icons.phone_outlined,
              ),
              label: Text(
                _phoneMode ? l10n.registerUseEmail : l10n.registerUsePhone,
              ),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            ),
          ),
          const SizedBox(height: 20),
          AuthStaggerItem(
            index: 4,
            child: AppTextField(
              controller: _name,
              label: l10n.registerNameLabel,
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 12),
          AuthStaggerItem(
            index: 5,
            child: AppTextField(
              controller: _phone,
              label: l10n.registerPhoneLabel,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              prefixText: _phoneMode ? '+216 ' : null,
              textDirection: _phoneMode ? TextDirection.ltr : null,
              inputFormatters: _phoneMode
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ]
                  : null,
              maxLength: _phoneMode ? 8 : null,
            ),
          ),
          const SizedBox(height: 12),
          AuthStaggerItem(
            index: 6,
            child: AppTextField(
              controller: _email,
              label: _phoneMode
                  ? l10n.registerEmailOptional
                  : l10n.registerEmailLabel,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
          ),
          if (!_phoneMode) ...[
            const SizedBox(height: 12),
            AuthStaggerItem(
              index: 7,
              child: AppTextField(
                controller: _password,
                label: l10n.registerPasswordLabel,
                icon: Icons.lock_outline,
                isPassword: true,
                autofillHints: const [AutofillHints.newPassword],
              ),
            ),
            const SizedBox(height: 8),
            AuthStaggerItem(
              index: 8,
              child: _PasswordStrengthIndicator(strength: _passwordStrength),
            ),
            const SizedBox(height: 12),
            AuthStaggerItem(
              index: 9,
              child: AppTextField(
                controller: _confirm,
                label: l10n.registerConfirmPasswordLabel,
                icon: Icons.lock_outline,
                isPassword: true,
                autofillHints: const [AutofillHints.newPassword],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildConsent(l10n),
          if (_consentError) ...[
            const SizedBox(height: 4),
            Text(
              l10n.registerConsentRequired,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          AuthStaggerItem(
            index: 10,
            child: AppButton(
              label: _phoneMode ? l10n.loginSendCode : l10n.registerSubmit,
              onPressed: loading ? null : _register,
              isLoading: loading,
            ),
          ),
          const SizedBox(height: 8),
          AuthStaggerItem(
            index: 11,
            child: Center(
              child: TextButton(
                onPressed: () => context.goNamed('login'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text(l10n.registerSignInLink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final animationDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: animationDuration,
        height: 104,
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.secondary.withValues(alpha: 0.14)
              : colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? colorScheme.secondary
                : colorScheme.outlineVariant.withValues(alpha: 0.65),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: selected
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 6,
                end: 6,
                child: AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: animationDuration,
                  child: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final int strength;

  const _PasswordStrengthIndicator({required this.strength});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final strengthColor = switch (strength) {
      1 => AppColors.error,
      2 => AppColors.accent,
      3 => AppColors.success,
      _ => colorScheme.outlineVariant,
    };
    final strengthLabel = switch (strength) {
      1 => l10n.registerPasswordStrengthWeak,
      2 => l10n.registerPasswordStrengthMedium,
      3 => l10n.registerPasswordStrengthStrong,
      _ => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var index = 0; index < 3; index++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index < strength
                        ? strengthColor
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 6),
            ],
          ],
        ),
        if (strength > 0) ...[
          const SizedBox(height: 4),
          Text(
            '${l10n.registerPasswordStrengthLabel}: $strengthLabel',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: strengthColor),
          ),
        ],
      ],
    );
  }
}
