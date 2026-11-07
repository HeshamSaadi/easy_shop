import 'package:easy_shop/apps/client/client_route_names.dart';
import 'package:easy_shop/apps/client/client_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createClientRouter() {
  return GoRouter(
    initialLocation: ClientRoutePaths.home,
    redirect: (_, state) => _guard(state.matchedLocation),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => ClientShell(navigationShell: shell),
        branches: [
          _tabBranch(
            ClientRouteNames.home,
            ClientRoutePaths.home,
            ClientShellStrings.home,
          ),
          _tabBranch(
            ClientRouteNames.favorites,
            ClientRoutePaths.favorites,
            ClientShellStrings.favorites,
          ),
          _tabBranch(
            ClientRouteNames.cart,
            ClientRoutePaths.cart,
            ClientShellStrings.cart,
          ),
          _tabBranch(
            ClientRouteNames.orders,
            ClientRoutePaths.orders,
            ClientShellStrings.orders,
          ),
          _tabBranch(
            ClientRouteNames.profile,
            ClientRoutePaths.profile,
            ClientShellStrings.profile,
          ),
        ],
      ),
    ],
  );
}

/// Guard skeleton. CL-A7 replaces this with the real session check
/// (unknown -> splash, unauthenticated -> login, authenticated -> home).
String? _guard(String location) => null;

StatefulShellBranch _tabBranch(String name, String path, String label) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        name: name,
        path: path,
        builder: (_, _) => _TabPlaceholder(label: label),
      ),
    ],
  );
}

/// Temporary screen. Each tab owner replaces it with the real screen.
class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
