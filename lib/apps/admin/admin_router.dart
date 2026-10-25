import 'package:easy_shop/apps/admin/admin_route_names.dart';
import 'package:easy_shop/apps/admin/admin_shell.dart';
import 'package:easy_shop/apps/admin/placeholder_screen.dart';
import 'package:easy_shop/apps/admin/session/router_refresh_stream.dart';
import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/apps/admin/session/session_state.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/login_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/otp_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/register_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _sl = GetIt.instance;

GoRouter createAdminRouter(SessionCubit session) {
  return GoRouter(
    initialLocation: AdminRoutePaths.splash,
    refreshListenable: RouterRefreshStream(session.stream),
    redirect: (_, state) => _guard(session.state, state.matchedLocation),
    routes: [
      GoRoute(
        name: AdminRouteNames.splash,
        path: AdminRoutePaths.splash,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        name: AdminRouteNames.login,
        path: AdminRoutePaths.login,
        builder: (context, _) => BlocProvider(
          create: (_) => _sl<LoginCubit>(),
          child: LoginScreen(
            onOtpRequested: (email) =>
                context.pushNamed(AdminRouteNames.otp, extra: email),
            onRegisterTap: () => context.pushNamed(AdminRouteNames.register),
          ),
        ),
      ),
      GoRoute(
        name: AdminRouteNames.otp,
        path: AdminRoutePaths.otp,
        redirect: (_, state) =>
            state.extra is String ? null : AdminRoutePaths.login,
        builder: (_, state) =>
            _OtpPage(email: state.extra! as String, session: session),
      ),
      GoRoute(
        name: AdminRouteNames.register,
        path: AdminRoutePaths.register,
        builder: (_, _) => const _RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AdminShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AdminRouteNames.home,
                path: AdminRoutePaths.home,
                builder: (_, _) => const PlaceholderScreen('Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AdminRouteNames.products,
                path: AdminRoutePaths.products,
                builder: (_, _) => const PlaceholderScreen('Products'),
                routes: [
                  GoRoute(
                    name: AdminRouteNames.categories,
                    path: 'categories',
                    builder: (_, _) => const PlaceholderScreen('Categories'),
                    routes: [
                      GoRoute(
                        name: AdminRouteNames.categoryForm,
                        path: 'form',
                        builder: (_, _) =>
                            const PlaceholderScreen('Category form'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AdminRouteNames.orders,
                path: AdminRoutePaths.orders,
                builder: (_, _) => const PlaceholderScreen('Orders'), // C14
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AdminRouteNames.profile,
                path: AdminRoutePaths.profile,
                builder: (_, _) => const PlaceholderScreen('Profile'), // A11
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

String? _guard(SessionState state, String location) {
  final isPublic = AdminRoutePaths.publicRoutes.contains(location);
  final isSplash = location == AdminRoutePaths.splash;
  return switch (state) {
    SessionUnknown() => isSplash ? null : AdminRoutePaths.splash,
    SessionAuthenticated() =>
      (isPublic || isSplash) ? AdminRoutePaths.home : null,
    SessionUnauthenticated() => isPublic ? null : AdminRoutePaths.login,
  };
}

class _OtpPage extends StatelessWidget {
  const _OtpPage({required this.email, required this.session});

  final String email;
  final SessionCubit session;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _sl<OtpCubit>(param1: email)..start(),
      child: OtpScreen(onVerified: session.signedIn),
    );
  }
}

class _RegisterPage extends StatelessWidget {
  const _RegisterPage();

  static Future<String?> _noFilePicker() async => null;

  static Future<PickedLocation?> _noLocationPicker() async => null;

  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AdminRouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _sl<RegisterCubit>(),
      child: RegisterScreen(
        onRegistered: () => _backToLogin(context),
        onExit: () => _backToLogin(context),
        pickDocument: _noFilePicker,
        pickPicture: _noFilePicker,
        pickLocation: _noLocationPicker,
      ),
    );
  }
}
