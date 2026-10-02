import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/auth/domain/auth_exception.dart';
import '../../../../features/auth/presentation/auth_error_message.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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

      final destination = switch (user.role) {
        'driver' => '/driver/home',
        'admin' => '/admin/dashboard',
        _ => '/passenger/home',
      };
      final messenger = ScaffoldMessenger.of(context);
      context.go(destination);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.authWelcomeMessage(user.name)),
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
            child: AppTextField(
              controller: _email,
              label: l10n.loginEmailLabel,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 14),
          AuthStaggerItem(
            index: 4,
            child: AppTextField(
              controller: _password,
              label: l10n.loginPasswordLabel,
              icon: Icons.lock_outline,
              isPassword: true,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
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
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text(l10n.loginCreateAccount),
                ),
              ],
            ),
          ),
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
