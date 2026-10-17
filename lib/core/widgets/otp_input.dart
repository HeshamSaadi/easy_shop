import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easyshop/core/theme/app_spacing.dart';

class OtpInput
    extends
        StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
  });

  final int length;
  final ValueChanged<
    String
  >
  onCompleted;
  final ValueChanged<
    String
  >?
  onChanged;

  @override
  State<
    OtpInput
  >
  createState() => _OtpInputState();
}

class _OtpInputState
    extends
        State<
          OtpInput
        > {
  late final List<
    TextEditingController
  >
  _controllers;
  late final List<
    FocusNode
  >
  _focusNodes;

  String get _code => _controllers
      .map(
        (
          c,
        ) => c.text,
      )
      .join();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (
        _,
      ) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (
        _,
      ) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onBoxChanged(
    int index,
    String value,
  ) {
    // The whole code was pasted into one box
    if (value.length >=
        widget.length) {
      _fillAll(
        value,
      );
      return;
    }

    if (value.length >
        1) {
      final lastDigit = value.substring(
        value.length -
            1,
      );
      _controllers[index].value = TextEditingValue(
        text: lastDigit,
        selection: const TextSelection.collapsed(
          offset: 1,
        ),
      );
      value = lastDigit;
    }

    if (value.isNotEmpty &&
        index <
            widget.length -
                1) {
      _focusNodes[index +
              1]
          .requestFocus();
    } else if (value.isEmpty &&
        index >
            0) {
      _focusNodes[index -
              1]
          .requestFocus();
    }

    _notify();
  }

  void _fillAll(
    String value,
  ) {
    for (
      var i = 0;
      i <
          widget.length;
      i++
    ) {
      _controllers[i].text = value[i];
    }
    _focusNodes.last.requestFocus();
    _notify();
  }

  void _notify() {
    final code = _code;
    widget.onChanged?.call(
      code,
    );
    if (code.length ==
        widget.length) {
      widget.onCompleted(
        code,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;

    return Row(
      children: List.generate(
        widget.length *
                2 -
            1,
        (
          i,
        ) {
          // Odd positions are the gaps between boxes
          if (i.isOdd) {
            return const SizedBox(
              width: AppSpacing.sm,
            );
          }
          final index =
              i ~/
              2;
          return Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: textTheme.titleLarge,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged:
                    (
                      value,
                    ) => _onBoxChanged(
                      index,
                      value,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
