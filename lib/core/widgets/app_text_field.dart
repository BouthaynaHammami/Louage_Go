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
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused
              ? colorScheme.secondary
              : colorScheme.surface.withValues(alpha: 0),
          width: 1.5,
        ),
      ),
      child: TextFormField(
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
        buildCounter: widget.maxLength == null
            ? null
            : (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.58,
          ),
          labelText: widget.label,
          prefix: widget.prefixText == null
              ? null
              : Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(widget.prefixText!),
                ),
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          floatingLabelStyle: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colorScheme.secondary),
          prefixIcon: Icon(widget.icon),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorMaxLines: 2,
          errorStyle: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colorScheme.error),
          suffixIcon: widget.isPassword
              ? IconButton(
                  tooltip: _passwordVisible
                      ? l10n.passwordHide
                      : l10n.passwordReveal,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: EdgeInsetsDirectional.zero,
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Icon(
                      _passwordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey(_passwordVisible),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

typedef CustomTextField = AppTextField;
