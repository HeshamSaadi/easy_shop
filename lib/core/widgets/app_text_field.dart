import 'package:easyshop/core/theme/app_spacing.dart';
import 'package:easyshop/core/utils/app_strings.dart';
import 'package:flutter/material.dart';

class AppTextField
    extends
        StatefulWidget {
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
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  //! Varriables
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<
    String
  >?
  validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool isOptional;
  final IconData? prefixIcon;
  final int maxLines;
  final bool enabled;
  final ValueChanged<
    String
  >?
  onChanged;

  @override
  State<
    AppTextField
  >
  createState() => _AppTextFieldState();
}

class _AppTextFieldState
    extends
        State<
          AppTextField
        > {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(
      () => _isObscured = !_isObscured,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (widget.isOptional)
                TextSpan(
                  text: ' ${AppStrings.optional}',
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _isObscured,
          // A password field must stay on one line
          maxLines: widget.isPassword
              ? 1
              : widget.maxLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon:
                widget.prefixIcon ==
                    null
                ? null
                : Icon(
                    widget.prefixIcon,
                  ),
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
