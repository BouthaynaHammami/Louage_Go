import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_config.dart';
import '../../../../core/theme/app_preferences.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/auth/domain/auth_exception.dart';
import '../../../../features/auth/domain/otp_challenge.dart';
import '../../../../features/auth/domain/phone_number.dart';
import '../../../../features/auth/presentation/auth_error_message.dart';
import '../../../../features/auth/presentation/auth_home_route.dart';
import '../../../../features/auth/presentation/otp_arguments.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _phoneMode = true;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestPhoneCode() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final phone = PhoneNumber(_phone.text.trim());
      final challenge = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(phone, OtpPurpose.login);
      if (!mounted) return;
      context.pushNamed(
        'otp',
        extra: OtpArguments(
          phone: phone,
          purpose: OtpPurpose.login,
          challenge: challenge,
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _message(authErrorMessage(AppLocalizations.of(context)!, error.code));
    } catch (_) {
      if (!mounted) return;
      _message(l10n.authUnexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _recoverPhoneAccount() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final phone = PhoneNumber(_phone.text.trim());
      final challenge = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(phone, OtpPurpose.recover);
      if (!mounted) return;
      context.pushNamed(
        'otp',
        extra: OtpArguments(
          phone: phone,
          purpose: OtpPurpose.recover,
          challenge: challenge,
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _message(authErrorMessage(AppLocalizations.of(context)!, error.code));
    } catch (_) {
      if (!mounted) return;
      _message(l10n.authUnexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _message(l10n.formRequiredFields);
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
      if (!mounted) return;

      await _applyUserLanguage(user.language);
      if (!mounted) return;
      final welcomeMessage = AppLocalizations.of(context)!
          .authWelcomeMessage(user.name);
      final messenger = ScaffoldMessenger.of(context);
      context.go(authHomeRouteForRole(user.role));
      messenger.showSnackBar(
        SnackBar(
          content: Text(welcomeMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _message(authErrorMessage(AppLocalizations.of(context)!, error.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _applyUserLanguage(String language) async {
    if (language.isNotEmpty) {
      await ref.read(localeProvider.notifier).setLocale(Locale(language));
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = ref.read(socialAuthProvider);
    if (provider == null) {
      _message(l10n.loginGoogleUnavailable);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await provider.signInWithGoogle();
      if (!mounted) return;
      await _applyUserLanguage(user.language);
      if (!mounted) return;
      final welcomeMessage = AppLocalizations.of(context)!
          .authWelcomeMessage(user.name);
      final messenger = ScaffoldMessenger.of(context);
      context.go(authHomeRouteForRole(user.role));
      messenger.showSnackBar(SnackBar(content: Text(welcomeMessage)));
    } on AuthException catch (error) {
      if (!mounted) return;
      _message(authErrorMessage(l10n, error.code));
    } catch (_) {
      if (!mounted) return;
      _message(l10n.authUnexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = await _requestResetEmail(l10n);
    if (email == null || !mounted) return;

    try {
      final code = await ref
          .read(authControllerProvider.notifier)
          .resetPassword(email);
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      await messenger
          .showSnackBar(
            SnackBar(
              content: Text(l10n.authResetCodeGenerated(code)),
              duration: const Duration(seconds: 12),
              action: SnackBarAction(
                label: l10n.authContinue,
                onPressed: () {},
              ),
            ),
          )
          .closed;
      if (!mounted) return;

      final credentials = await _requestNewPassword(l10n, code);
      if (credentials == null || !mounted) return;

      await ref
          .read(authControllerProvider.notifier)
          .completePasswordReset(
            email: email,
            code: credentials.code,
            newPassword: credentials.password,
          );
      if (mounted) _message(l10n.authResetCompleted);
    } on AuthException catch (error) {
      if (!mounted) return;
      _message(authErrorMessage(l10n, error.code));
    }
  }

  Future<String?> _requestResetEmail(AppLocalizations l10n) async {
    final controller = TextEditingController(text: _email.text.trim());
    final formKey = GlobalKey<FormState>();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: Text(l10n.authResetPasswordTitle),
          content: Form(
            key: formKey,
            child: AppTextField(
              controller: controller,
              label: l10n.authResetEmailLabel,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.authInvalidEmail
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.authCancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: Text(l10n.authContinue),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<_ResetCredentials?> _requestNewPassword(
    AppLocalizations l10n,
    String expectedCode,
  ) async {
    final codeController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      return await showDialog<_ResetCredentials>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: Text(l10n.authResetPasswordTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: codeController,
                  label: l10n.authResetCodeLabel,
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.trim() == expectedCode
                      ? null
                      : l10n.authInvalidResetCode,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: passwordController,
                  label: l10n.authNewPasswordLabel,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => value == null || value.length < 6
                      ? l10n.authWeakPassword
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: confirmController,
                  label: l10n.authConfirmPasswordLabel,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => value != passwordController.text
                      ? l10n.authPasswordMismatch
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.authCancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(
                    _ResetCredentials(
                      code: codeController.text.trim(),
                      password: passwordController.text,
                    ),
                  );
                }
              },
              child: Text(l10n.authResetAction),
            ),
          ],
        ),
      );
    } finally {
      codeController.dispose();
      passwordController.dispose();
      confirmController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      title: l10n.loginWelcome,
      subtitle: l10n.loginSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthStaggerItem(
            index: 3,
            child: _LoginMethodSelector(
              phoneSelected: _phoneMode,
              phoneLabel: l10n.loginMethodPhone,
              emailLabel: l10n.loginMethodEmail,
              onChanged: _loading
                  ? null
                  : (phoneSelected) =>
                        setState(() => _phoneMode = phoneSelected),
            ),
          ),
          const SizedBox(height: 14),
          if (_phoneMode) ...[
            AuthStaggerItem(
              index: 4,
              child: AppTextField(
                controller: _phone,
                label: l10n.loginPhoneLabel,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                prefixText: '+216 ',
                textDirection: TextDirection.ltr,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                maxLength: 8,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
            ),
            const SizedBox(height: 8),
            AuthStaggerItem(
              index: 5,
              child: AppButton(
                label: l10n.loginSendCode,
                onPressed: _loading ? null : _requestPhoneCode,
                isLoading: _loading,
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _recoverPhoneAccount,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(l10n.loginAccountInaccessible),
            ),
          ] else ...[
            AuthStaggerItem(
              index: 4,
              child: AppTextField(
                controller: _email,
                label: l10n.loginEmailLabel,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
              ),
            ),
            const SizedBox(height: 14),
            AuthStaggerItem(
              index: 5,
              child: AppTextField(
                controller: _password,
                label: l10n.loginPasswordLabel,
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _forgotPassword,
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text(l10n.loginForgotPassword),
              ),
            ),
            const SizedBox(height: 8),
            AuthStaggerItem(
              index: 5,
              child: AppButton(
                label: l10n.loginSubmit,
                onPressed: _loading ? null : _login,
                isLoading: _loading,
              ),
            ),
          ],
          const SizedBox(height: 12),
          AuthStaggerItem(
            index: 6,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l10n.loginNoAccount),
                TextButton(
                  onPressed: () => context.pushNamed('register'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: Text(l10n.loginCreateAccount),
                ),
              ],
            ),
          ),
          if (AppConfig.googleSignInEnabled) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: Text(l10n.loginContinueWithGoogle),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResetCredentials {
  final String code;
  final String password;

  const _ResetCredentials({required this.code, required this.password});
}

class _LoginMethodSelector extends StatelessWidget {
  const _LoginMethodSelector({
    required this.phoneSelected,
    required this.phoneLabel,
    required this.emailLabel,
    required this.onChanged,
  });

  final bool phoneSelected;
  final String phoneLabel;
  final String emailLabel;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(4),
        child: Row(
          children: [
            Expanded(
              child: _LoginMethodSegment(
                label: phoneLabel,
                selected: phoneSelected,
                onTap: onChanged == null ? null : () => onChanged!(true),
              ),
            ),
            Expanded(
              child: _LoginMethodSegment(
                label: emailLabel,
                selected: !phoneSelected,
                onTap: onChanged == null ? null : () => onChanged!(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginMethodSegment extends StatelessWidget {
  const _LoginMethodSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 160);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: duration,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: selected ? colorScheme.secondaryContainer : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
