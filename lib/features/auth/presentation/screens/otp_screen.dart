import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_config.dart';
import '../../../../core/theme/app_preferences.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../auth_providers.dart';
import '../../domain/auth_exception.dart';
import '../../domain/otp_challenge.dart';
import '../auth_error_message.dart';
import '../auth_home_route.dart';
import '../otp_arguments.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.arguments, super.key});

  final OtpArguments? arguments;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  OtpChallenge? _challenge;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  bool _working = false;
  bool _requesting = false;
  bool _redirected = false;
  String? _errorMessage;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _challenge = widget.arguments?.challenge;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final arguments = widget.arguments;
      if (arguments == null) {
        if (!_redirected) {
          _redirected = true;
          context.go('/login');
        }
        return;
      }
      if (_challenge == null) {
        unawaited(_requestCode());
      } else {
        _startCountdown();
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    final availableAt = _challenge?.resendAvailableAt;
    final remainingMilliseconds =
        availableAt?.difference(DateTime.now()).inMilliseconds ?? 0;
    final seconds = math.max(0, (remainingMilliseconds + 999) ~/ 1000);
    setState(() => _secondsRemaining = seconds);
    if (seconds == 0) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsRemaining = math.max(0, _secondsRemaining - 1));
      if (_secondsRemaining == 0) timer.cancel();
    });
  }

  Future<void> _requestCode({bool isResend = false}) async {
    final arguments = widget.arguments;
    if (arguments == null || _requesting) return;
    setState(() {
      _requesting = true;
      _errorMessage = null;
      _notice = null;
    });
    try {
      final challenge = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(arguments.phone, arguments.purpose);
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _notice = isResend ? AppLocalizations.of(context)!.otpCodeResent : null;
      });
      _clearCode(requestFocus: false);
      _startCountdown();
      _focusNodes.first.requestFocus();
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = authErrorMessage(
          AppLocalizations.of(context)!,
          error.code,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = AppLocalizations.of(context)!.authUnexpectedError,
      );
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  void _clearCode({bool requestFocus = true}) {
    for (final controller in _controllers) {
      controller.clear();
    }
    if (requestFocus) _focusNodes.first.requestFocus();
  }

  void _onDigitChanged(int index, String value) {
    if (_working) return;
    if (value.length > 1) {
      _applyPastedCode(value);
      return;
    }
    setState(() {
      _errorMessage = null;
      _notice = null;
    });
    if (value.isEmpty) {
      if (index > 0) _focusNodes[index - 1].requestFocus();
      return;
    }
    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (_currentCode.length == 6) {
      unawaited(_verifyCode());
    }
  }

  void _applyPastedCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final code = digits.substring(0, math.min(digits.length, 6));
    for (var index = 0; index < _controllers.length; index++) {
      _controllers[index].text = index < code.length ? code[index] : '';
    }
    setState(() {
      _errorMessage = null;
      _notice = null;
    });
    if (code.length == 6) {
      unawaited(_verifyCode());
    } else {
      _focusNodes[code.length].requestFocus();
    }
  }

  String get _currentCode =>
      _controllers.map((controller) => controller.text).join();

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      setState(() {
        _errorMessage = null;
        _notice = null;
      });
      return KeyEventResult.handled;
    }
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {
        _errorMessage = null;
        _notice = null;
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _verifyCode() async {
    final arguments = widget.arguments;
    final challenge = _challenge;
    if (arguments == null || challenge == null || _working) return;
    if (_currentCode.length != 6) return;
    setState(() {
      _working = true;
      _errorMessage = null;
      _notice = null;
    });
    try {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.verifyOtp(challenge.id, _currentCode);

      final user = switch (arguments.purpose) {
        OtpPurpose.login => await controller.loginWithPhone(arguments.phone),
        OtpPurpose.recover => await controller.loginWithPhone(arguments.phone),
        OtpPurpose.register => await controller.registerWithPhone(
          name: arguments.name ?? '',
          phone: arguments.phone,
          role: arguments.role ?? 'passenger',
          email: arguments.email,
          acceptedTermsVersion: arguments.acceptedTermsVersion,
          acceptedTermsAt: arguments.acceptedTermsAt,
        ),
        OtpPurpose.changePhone => await controller.changePhone(arguments.phone),
      };
      if (!mounted) return;
      if (arguments.purpose == OtpPurpose.changePhone) {
        final message = AppLocalizations.of(context)!.profilePhoneUpdated;
        final messenger = ScaffoldMessenger.of(context);
        context.go('/profile/edit');
        messenger.showSnackBar(SnackBar(content: Text(message)));
        return;
      }
      if (user.language.isNotEmpty) {
        await ref
            .read(localeProvider.notifier)
            .setLocale(Locale(user.language));
      }
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
      setState(
        () => _errorMessage = authErrorMessage(
          AppLocalizations.of(context)!,
          error.code,
        ),
      );
      _clearCode();
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = AppLocalizations.of(context)!.authUnexpectedError,
      );
      _clearCode();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final arguments = widget.arguments;
    final challenge = _challenge;
    final demoCode = challenge?.demoCode;

    return AuthScaffold(
      title: l10n.otpPageTitle,
      subtitle: arguments == null
          ? null
          : l10n.otpCodeSentTo(arguments.phone.canonical),
      showBackButton: true,
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppConfig.showDemoOtp && demoCode != null) ...[
            AppCard(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                l10n.otpDemoCode(demoCode),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Directionality(
            textDirection: TextDirection.ltr,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fields = List<Widget>.generate(
                  _controllers.length,
                  _buildDigitField,
                );
                if (constraints.maxWidth >= 6 * 48 + 5 * 8) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < fields.length; index++) ...[
                        if (index > 0) const SizedBox(width: 8),
                        fields[index],
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (var row = 0; row < 2; row++) ...[
                      if (row > 0) const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var column = 0; column < 3; column++) ...[
                            if (column > 0) const SizedBox(width: 8),
                            fields[row * 3 + column],
                          ],
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          if (_errorMessage case final message?) ...[
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_notice case final message?) ...[
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
          const SizedBox(height: 20),
          AppButton(
            label: l10n.otpVerifyAction,
            onPressed: _working || _requesting || _currentCode.length != 6
                ? null
                : _verifyCode,
            isLoading: _working,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _working || _requesting || _secondsRemaining > 0
                ? null
                : () => _requestCode(isResend: true),
            icon: const Icon(Icons.refresh),
            label: Text(
              _secondsRemaining > 0
                  ? l10n.otpResendCountdown(_secondsRemaining)
                  : l10n.otpResendAction,
            ),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitField(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: (_, event) => _handleKeyEvent(index, event),
        child: TextField(
          key: ValueKey('otp-digit-$index'),
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          autofocus: index == 0,
          keyboardType: TextInputType.number,
          textInputAction: index == 5
              ? TextInputAction.done
              : TextInputAction.next,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (value) => _onDigitChanged(index, value),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.58,
            ),
            contentPadding: EdgeInsetsDirectional.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
            ),
          ),
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}
