import 'package:easy_shop/apps/client/client_route_names.dart';
import 'package:easy_shop/apps/client/session/router_refresh_stream.dart';
import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/apps/client/session/session_state.dart';
import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/login_screen.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/otp_screen.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _sl = GetIt.instance;

GoRouter createClientRouter(SessionCubit session) {
  return GoRouter(
    initialLocation: ClientRoutePaths.splash,
    refreshListenable: RouterRefreshStream(session.stream),
    redirect: (_, state) => _guard(session.state, state.matchedLocation),
    routes: [
      GoRoute(
        name: ClientRouteNames.splash,
        path: ClientRoutePaths.splash,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        name: ClientRouteNames.login,
        path: ClientRoutePaths.login,
        builder: (context, _) => BlocProvider(
          create: (_) => _sl<LoginCubit>(),
          child: LoginScreen(
            onOtpRequested: (email) =>
                context.pushNamed(ClientRouteNames.otp, extra: email),
            onRegisterTap: () => context.pushNamed(ClientRouteNames.register),
          ),
        ),
      ),
      GoRoute(
        name: ClientRouteNames.otp,
        path: ClientRoutePaths.otp,
        redirect: (_, state) =>
            state.extra is String ? null : ClientRoutePaths.login,
        builder: (_, state) =>
            _OtpPage(email: state.extra! as String, session: session),
      ),
      GoRoute(
        name: ClientRouteNames.register,
        path: ClientRoutePaths.register,
        builder: (_, _) => const _RegisterPage(),
      ),
      // Temporary home route until we implement the main app shell
      GoRoute(
        name: ClientRouteNames.home,
        path: ClientRoutePaths.home,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text('EasyShop Client'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: session.logout,
              ),
            ],
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 100),
                SizedBox(height: 16),
                Text(
                  'Welcome to EasyShop!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Client app features coming soon...'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

String? _guard(SessionState state, String location) {
  final isPublic = ClientRoutePaths.publicRoutes.contains(location);
  final isSplash = location == ClientRoutePaths.splash;
  return switch (state) {
    SessionUnknown() => isSplash ? null : ClientRoutePaths.splash,
    SessionAuthenticated() =>
      (isPublic || isSplash) ? ClientRoutePaths.home : null,
    SessionUnauthenticated() => isPublic ? null : ClientRoutePaths.login,
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

  void _onRegistered(BuildContext context, String email) {
    // Navigate to OTP screen after successful registration
    context.pushReplacementNamed(ClientRouteNames.otp, extra: email);
  }

  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ClientRouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _sl<ImagePickerService>();
    return BlocProvider(
      create: (_) => _sl<RegisterCubit>(),
      child: RegisterScreen(
        onRegistered: (email) => _onRegistered(context, email),
        onLoginTap: () => _backToLogin(context),
        pickPicture: images.pickImage,
      ),
    );
  }
}
