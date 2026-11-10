import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_config.dart';
import '../../../../core/theme/app_preferences.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/auth/domain/auth_exception.dart';
import '../../../../features/auth/domain/otp_challenge.dart';
import '../../../../features/auth/domain/phone_number.dart';
import '../../../../features/auth/presentation/auth_error_message.dart';
import '../../../../features/auth/presentation/auth_home_route.dart';
import '../../../../features/auth/presentation/otp_arguments.dart';
import '../../../../l10n/generated/app_localizations.dart';

// ══════════════════════════════════════════════════════════════════════════════
// LoginScreen — Design premium v2
// ══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phone    = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();

  bool _loading   = false;
  bool _phoneMode = true;

  // Animation du switch Téléphone/Email
  late final AnimationController _tabCtrl;
  late final Animation<double>    _tabSlide;

  @override
  void initState() {
    super.initState();
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _tabSlide = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Switchmode ─────────────────────────────────────────────────────────
  void _switchMode(bool toPhone) {
    if (toPhone == _phoneMode) return;
    setState(() => _phoneMode = toPhone);
    if (toPhone) {
      _tabCtrl.reverse();
    } else {
      _tabCtrl.forward();
    }
  }

  // ── Auth actions ───────────────────────────────────────────────────────
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
    } on AuthException catch (e) {
      if (!mounted) return;
      _showAnimatedSnack(authErrorMessage(AppLocalizations.of(context)!, e.code));
    } catch (_) {
      if (!mounted) return;
      _showAnimatedSnack(l10n.authUnexpectedError);
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
    } on AuthException catch (e) {
      if (!mounted) return;
      _showAnimatedSnack(authErrorMessage(AppLocalizations.of(context)!, e.code));
    } catch (_) {
      if (!mounted) return;
      _showAnimatedSnack(l10n.authUnexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    final email    = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _showAnimatedSnack(l10n.formRequiredFields);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
      if (!mounted) return;
      await ref.read(localeProvider.notifier).setLocale(
            user.language.isNotEmpty ? Locale(user.language) : const Locale('fr'),
          );
      if (!mounted) return;
      final welcomeMessage =
          AppLocalizations.of(context)!.authWelcomeMessage(user.name);
      final messenger = ScaffoldMessenger.of(context);
      context.go(authHomeRouteForRole(user.role));
      messenger.showSnackBar(
        SnackBar(
          content: Text(welcomeMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showAnimatedSnack(authErrorMessage(AppLocalizations.of(context)!, e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context)!;

    // ── Popup animé : saisie email ──────────────────────────────────────
    final email = await _showAnimatedDialog<String>(
      child: _ForgotPasswordEmailDialog(
        initialEmail: _email.text.trim(),
        l10n: l10n,
      ),
    );
    if (email == null || !mounted) return;

    try {
      final code = await ref
          .read(authControllerProvider.notifier)
          .resetPassword(email);
      if (!mounted) return;

      // ── Popup animé : affichage code + nouveau mot de passe ────────────
      _showAnimatedSnack(
        l10n.authResetCodeGenerated(code),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: l10n.authContinue,
          onPressed: () async {
            if (!mounted) return;
            final credentials = await _showAnimatedDialog<_ResetCredentials>(
              child: _ResetPasswordDialog(
                expectedCode: code,
                l10n: l10n,
              ),
            );
            if (credentials == null || !mounted) return;
            try {
              await ref
                  .read(authControllerProvider.notifier)
                  .completePasswordReset(
                    email: email,
                    code: credentials.code,
                    newPassword: credentials.password,
                  );
              if (mounted) _showAnimatedSnack(l10n.authResetCompleted);
            } on AuthException catch (e) {
              if (mounted) {
                _showAnimatedSnack(
                  authErrorMessage(AppLocalizations.of(context)!, e.code));
              }
            }
          },
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showAnimatedSnack(authErrorMessage(l10n, e.code));
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = ref.read(socialAuthProvider);
    if (provider == null) {
      _showAnimatedSnack(l10n.loginGoogleUnavailable);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await provider.signInWithGoogle();
      if (!mounted) return;
      await ref.read(localeProvider.notifier).setLocale(
            user.language.isNotEmpty ? Locale(user.language) : const Locale('fr'),
          );
      if (!mounted) return;
      context.go(authHomeRouteForRole(user.role));
    } on AuthException catch (e) {
      if (!mounted) return;
      _showAnimatedSnack(authErrorMessage(l10n, e.code));
    } catch (_) {
      if (!mounted) return;
      _showAnimatedSnack(l10n.authUnexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Snack animé ────────────────────────────────────────────────────────
  void _showAnimatedSnack(
    String text, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  // ── Popup animé générique ──────────────────────────────────────────────
  Future<T?> _showAnimatedDialog<T>({required Widget child}) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (_, __, ___) => child,
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AuthScaffold(
      title: l10n.loginWelcome,
      subtitle: l10n.loginSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Sélecteur Téléphone / Email ─────────────────────────────
          AuthStaggerItem(
            index: 3,
            child: _AnimatedTabSelector(
              phoneMode: _phoneMode,
              phoneLabel: l10n.loginMethodPhone,
              emailLabel: l10n.loginMethodEmail,
              disabled: _loading,
              onChanged: _loading ? null : _switchMode,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(height: 20),

          // ── Champs animés (slide selon le mode) ─────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve:  Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _phoneMode
                ? _PhoneFields(
                    key: const ValueKey('phone'),
                    controller: _phone,
                    loading: _loading,
                    l10n: l10n,
                    onSend: _requestPhoneCode,
                    onRecover: _recoverPhoneAccount,
                  )
                : _EmailFields(
                    key: const ValueKey('email'),
                    emailCtrl: _email,
                    passwordCtrl: _password,
                    loading: _loading,
                    l10n: l10n,
                    onLogin: _login,
                    onForgot: _forgotPassword,
                  ),
          ),

          const SizedBox(height: 20),

          // ── Divider ─────────────────────────────────────────────────
          AuthStaggerItem(
            index: 8,
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: colorScheme.outlineVariant,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ou',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: colorScheme.outlineVariant,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Lien inscription ─────────────────────────────────────────
          AuthStaggerItem(
            index: 9,
            child: _RegisterLink(l10n: l10n),
          ),

          // ── Google ───────────────────────────────────────────────────
          if (AppConfig.googleSignInEnabled) ...[
            const SizedBox(height: 10),
            AuthStaggerItem(
              index: 10,
              child: _GoogleButton(
                loading: _loading,
                label: l10n.loginContinueWithGoogle,
                onPressed: _signInWithGoogle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sélecteur onglets animé
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedTabSelector extends StatelessWidget {
  const _AnimatedTabSelector({
    required this.phoneMode,
    required this.phoneLabel,
    required this.emailLabel,
    required this.disabled,
    required this.onChanged,
    required this.colorScheme,
  });

  final bool phoneMode;
  final String phoneLabel;
  final String emailLabel;
  final bool disabled;
  final ValueChanged<bool>? onChanged;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.60),
        ),
      ),
      child: Stack(
        children: [
          // Indicateur animé
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: phoneMode
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Labels
          Row(
            children: [
              Expanded(
                child: _TabLabel(
                  label: phoneLabel,
                  selected: phoneMode,
                  onTap: disabled ? null : () => onChanged?.call(true),
                  selectedColor: colorScheme.onPrimary,
                  unselectedColor: colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _TabLabel(
                  label: emailLabel,
                  selected: !phoneMode,
                  onTap: disabled ? null : () => onChanged?.call(false),
                  selectedColor: colorScheme.onPrimary,
                  unselectedColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: selected ? selectedColor : unselectedColor,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Champs Téléphone
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneFields extends StatelessWidget {
  const _PhoneFields({
    super.key,
    required this.controller,
    required this.loading,
    required this.l10n,
    required this.onSend,
    required this.onRecover,
  });

  final TextEditingController controller;
  final bool loading;
  final AppLocalizations l10n;
  final VoidCallback onSend;
  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indicateur pays
        _CountryChip(),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller,
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
        const SizedBox(height: 20),
        _PrimaryBtn(
          label: l10n.loginSendCode,
          loading: loading,
          icon: Icons.send_rounded,
          onPressed: loading ? null : onSend,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: loading ? null : onRecover,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 44),
            ),
            child: Text(l10n.loginAccountInaccessible),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Champs Email
// ─────────────────────────────────────────────────────────────────────────────
class _EmailFields extends StatelessWidget {
  const _EmailFields({
    super.key,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.loading,
    required this.l10n,
    required this.onLogin,
    required this.onForgot,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool loading;
  final AppLocalizations l10n;
  final VoidCallback onLogin;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: emailCtrl,
          label: l10n.loginEmailLabel,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: passwordCtrl,
          label: l10n.loginPasswordLabel,
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: loading ? null : onForgot,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 44),
              padding: const EdgeInsetsDirectional.only(end: 0),
            ),
            child: Text(l10n.loginForgotPassword),
          ),
        ),
        _PrimaryBtn(
          label: l10n.loginSubmit,
          loading: loading,
          icon: Icons.login_rounded,
          onPressed: loading ? null : onLogin,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip pays Tunisie
// ─────────────────────────────────────────────────────────────────────────────
class _CountryChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇹🇳', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'Tunisie  +216',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton primaire avec effet ripple + scale
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryBtn extends StatefulWidget {
  const _PrimaryBtn({
    required this.label,
    required this.loading,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pressScale,
      builder: (_, child) => Transform.scale(
        scale: _pressScale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.loading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          key: const ValueKey('label'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.icon,
                              size: 20,
                              color: colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lien inscription
// ─────────────────────────────────────────────────────────────────────────────
class _RegisterLink extends StatelessWidget {
  const _RegisterLink({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.loginNoAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.pushNamed('register'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.loginCreateAccount,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton Google
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1.2,
        ),
        foregroundColor: colorScheme.onSurface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('G', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4285F4),
          )),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Popup animé : Email réinitialisation
// ─────────────────────────────────────────────────────────────────────────────
class _ForgotPasswordEmailDialog extends StatefulWidget {
  const _ForgotPasswordEmailDialog({
    required this.initialEmail,
    required this.l10n,
  });

  final String initialEmail;
  final AppLocalizations l10n;

  @override
  State<_ForgotPasswordEmailDialog> createState() =>
      _ForgotPasswordEmailDialogState();
}

class _ForgotPasswordEmailDialogState
    extends State<_ForgotPasswordEmailDialog> {
  late final TextEditingController _ctrl;
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1B232D)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône animée
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.authResetPasswordTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saisissez votre adresse e-mail pour recevoir un code.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                AppTextField(
                  controller: _ctrl,
                  label: l10n.authResetEmailLabel,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.authInvalidEmail
                      : null,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.authCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_key.currentState?.validate() ?? false) {
                            Navigator.of(context).pop(_ctrl.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(l10n.authContinue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Popup animé : Nouveau mot de passe
// ─────────────────────────────────────────────────────────────────────────────
class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({
    required this.expectedCode,
    required this.l10n,
  });

  final String expectedCode;
  final AppLocalizations l10n;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _codeCtrl     = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B232D) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.key_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.authResetPasswordTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppTextField(
                    controller: _codeCtrl,
                    label: l10n.authResetCodeLabel,
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.trim() == widget.expectedCode
                        ? null
                        : l10n.authInvalidResetCode,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _passwordCtrl,
                    label: l10n.authNewPasswordLabel,
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (v) => v == null || v.length < 6
                        ? l10n.authWeakPassword
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirmCtrl,
                    label: l10n.authConfirmPasswordLabel,
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (v) => v != _passwordCtrl.text
                        ? l10n.authPasswordMismatch
                        : null,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.authCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_key.currentState?.validate() ?? false) {
                              Navigator.of(context).pop(
                                _ResetCredentials(
                                  code:     _codeCtrl.text.trim(),
                                  password: _passwordCtrl.text,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(l10n.authResetAction),
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────────────────────
class _ResetCredentials {
  const _ResetCredentials({required this.code, required this.password});
  final String code;
  final String password;
}
