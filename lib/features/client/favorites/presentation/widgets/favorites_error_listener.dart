import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows a snackbar when a favorites action fails. The router wraps the
/// screens that show a heart, so those screens do not import this feature.
class FavoritesErrorListener extends StatelessWidget {
  const FavoritesErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listenWhen: (_, current) =>
          current is FavoritesLoaded && current.actionError != null,
      listener: (context, state) {
        if (state is! FavoritesLoaded) return;
        final message = state.actionError;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: child,
    );
  }
}
