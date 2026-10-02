import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_passwordVisible,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _passwordVisible
                    ? l10n.passwordHide
                    : l10n.passwordReveal,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsetsDirectional.zero,
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : null,
      ),
    );
  }
}

typedef CustomTextField = AppTextField;
