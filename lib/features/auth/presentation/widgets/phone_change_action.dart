import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/auth_exception.dart';
import '../../domain/otp_challenge.dart';
import '../../domain/phone_number.dart';
import '../auth_error_message.dart';
import '../otp_arguments.dart';

class PhoneChangeAction extends StatelessWidget {
  const PhoneChangeAction({super.key});

  Future<void> _requestPhoneChange(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final phoneInput = await showDialog<String>(
        context: context,
        builder: (_) => _PhoneChangeDialog(l10n: l10n),
      );
      if (phoneInput == null || !context.mounted) return;
      context.pushNamed(
        'profileVerifyPhone',
        extra: OtpArguments(
          phone: PhoneNumber(phoneInput),
          purpose: OtpPurpose.changePhone,
        ),
      );
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(l10n, error.code))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.phone_outlined),
      title: Text(l10n.profileChangePhone),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _requestPhoneChange(context, l10n),
    );
  }
}

class _PhoneChangeDialog extends StatefulWidget {
  const _PhoneChangeDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_PhoneChangeDialog> createState() => _PhoneChangeDialogState();
}

class _PhoneChangeDialogState extends State<_PhoneChangeDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.profileChangePhone),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          label: l10n.profileNewPhoneLabel,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          prefixText: '+216 ',
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          maxLength: 8,
          validator: (value) {
            try {
              PhoneNumber(value ?? '');
              return null;
            } on AuthException {
              return l10n.authInvalidPhone;
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.authCancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_controller.text.trim());
            }
          },
          child: Text(l10n.authContinue),
        ),
      ],
    );
  }
}
