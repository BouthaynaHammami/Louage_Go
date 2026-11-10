import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final TextDirection? textDirection;
  final int? minLines;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixText,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.autofillHints,
    this.textDirection,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _passwordVisible = false;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconColor = _focused
        ? primary
        : (isDark ? Colors.white38 : Colors.black38);

    // fond blanc, fond sombre si dark mode
    final fillColor = isDark
        ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.85)
        : Colors.white;

    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      obscureText: widget.isPassword && !_passwordVisible,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      textDirection: widget.textDirection,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
      buildCounter: widget.maxLength == null
          ? null
          : (_, {required currentLength, required isFocused, maxLength}) => null,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: widget.label,
        hintStyle: TextStyle(
          fontSize: 14.5,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        prefix: widget.prefixText == null
            ? null
            : Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  widget.prefixText!,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
        prefixIcon: Icon(widget.icon, size: 20, color: iconColor),
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _passwordVisible ? l10n.passwordHide : l10n.passwordReveal,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsetsDirectional.zero,
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: iconColor,
                ),
              )
            : null,
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(0, 16, 16, 16),
        // Un seul border — pill shape, aucune bordure visible
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error, width: 1.5),
        ),
        errorMaxLines: 2,
      ),
    );
  }
}

typedef CustomTextField = AppTextField;
