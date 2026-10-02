import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/domain/auth_exception.dart';
import '../../features/auth/presentation/auth_error_message.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

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

  @override
  void dispose() {
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

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _msg(l10n.formRequiredFields);
      return;
    }
    if (password != _confirm.text) {
      _msg(l10n.passwordMismatch);
      return;
    }

    setState(() => loading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            name: name,
            phone: phone,
            email: email,
            password: password,
            role: role,
          );
    } on AuthException catch (e) {
      if (!mounted) return;
      _msg(authErrorMessage(AppLocalizations.of(context)!, e.code));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.registerRolePrompt,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'passenger',
                        label: Text(l10n.registerPassengerRole),
                        icon: Icon(Icons.person),
                      ),
                      ButtonSegment(
                        value: 'driver',
                        label: Text(l10n.registerDriverRole),
                        icon: Icon(Icons.badge),
                      ),
                    ],
                    selected: {role},
                    onSelectionChanged: (s) => setState(() => role = s.first),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _name,
                    label: l10n.registerNameLabel,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phone,
                    label: l10n.registerPhoneLabel,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _email,
                    label: l10n.registerEmailLabel,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _password,
                    label: l10n.registerPasswordLabel,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirm,
                    label: l10n.registerConfirmPasswordLabel,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: l10n.registerSubmit,
                    onPressed: loading ? null : _register,
                    isLoading: loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
