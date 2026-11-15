import 'package:easy_shop/features/client/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: HomeStrings.searchHint,
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
