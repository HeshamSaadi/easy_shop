import 'package:easy_shop/features/client/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class ClientShellStrings {
  static const home = 'Home';
  static const favorites = 'Faves';
  static const cart = 'Cart';
  static const orders = 'Orders';
  static const profile = 'Profile';
}

class ClientShell extends StatelessWidget {
  const ClientShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: ClientShellStrings.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: ClientShellStrings.favorites,
          ),
          NavigationDestination(
            icon: _CartIcon(selected: false),
            selectedIcon: _CartIcon(selected: true),
            label: ClientShellStrings.cart,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: ClientShellStrings.orders,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: ClientShellStrings.profile,
          ),
        ],
      ),
    );
  }
}

/// The cart icon with the number of items in the cart.
class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.selected});

  final bool selected;

  static int _count(CartState state) =>
      state is CartLoaded ? state.items.length : 0;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
    );

    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) => _count(previous) != _count(current),
      builder: (_, state) {
        final count = _count(state);
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: icon,
        );
      },
    );
  }
}
