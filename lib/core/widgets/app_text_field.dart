import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.isOptional = false,
    this.prefixIcon,
    this.prefixText,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  //! Variables
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool isOptional;
  final IconData? prefixIcon;

  /// Fixed text shown before the typed value (for example `+20 `).
  /// It is display only and is not part of the controller text.
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() => _isObscured = !_isObscured);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final prefixText = widget.prefixText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            children: [
              if (widget.isOptional)
                TextSpan(
                  text: ' ${AppStrings.optional}',
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          obscureText: _isObscured,
          // A password field must stay on one line
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon),
            // `prefix` (not `prefixText`) so it is always visible,
            // even when the field is empty and showing the hint.
            prefix: prefixText == null
                ? null
                : Text(prefixText, style: textTheme.bodyLarge),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: _toggleVisibility,
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
