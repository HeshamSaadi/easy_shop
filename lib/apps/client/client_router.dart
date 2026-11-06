import 'package:easy_shop/apps/client/client_route_names.dart';
import 'package:easy_shop/apps/client/client_strings.dart';
import 'package:easy_shop/apps/client/session/router_refresh_stream.dart';
import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/apps/client/session/session_state.dart';
import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_screen.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/login_screen.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/otp_screen.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/register_screen.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/splash_screen.dart';
import 'package:easy_shop/features/client/auth/presentation/screens/verified_screen.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_state.dart';
import 'package:easy_shop/features/client/profile/presentation/screens/edit_profile_screen.dart';
import 'package:easy_shop/features/client/profile/presentation/screens/profile_screen.dart';
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
        builder: (_, _) => const SplashScreen(),
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
      GoRoute(
        name: ClientRouteNames.verified,
        path: ClientRoutePaths.verified,
        builder: (context, _) => VerifiedScreen(
          onContinue: () => context.goNamed(ClientRouteNames.home),
        ),
      ),
      // Temporary home route until we implement the main app shell
      GoRoute(
        name: ClientRouteNames.home,
        path: ClientRoutePaths.home,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text(ClientStrings.easyShopClient),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.pushNamed(ClientRouteNames.profile),
              ),
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
                  ClientStrings.welcomeToEasyShop,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(ClientStrings.clientAppComingSoon),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        name: ClientRouteNames.profile,
        path: ClientRoutePaths.profile,
        builder: (_, _) => BlocProvider(
          create: (_) => _sl<ProfileCubit>()..loadProfile(),
          child: _ProfilePage(session: session),
        ),
      ),
      GoRoute(
        name: ClientRouteNames.profileEdit,
        path: '${ClientRoutePaths.profile}/edit',
        redirect: (_, state) =>
            state.extra is ClientEntity ? null : ClientRoutePaths.profile,
        builder: (_, state) =>
            _EditProfilePage(client: state.extra! as ClientEntity),
      ),
    ],
  );
}

String? _guard(SessionState state, String location) {
  final isPublic = ClientRoutePaths.publicRoutes.contains(location);
  final isSplash = location == ClientRoutePaths.splash;
  final isVerified = location == ClientRoutePaths.verified;
  return switch (state) {
    SessionUnknown() => isSplash ? null : ClientRoutePaths.splash,
    SessionAuthenticated() =>
      isVerified
          ? null
          : (isPublic || isSplash)
          ? ClientRoutePaths.home
          : null,
    SessionUnauthenticated() => isPublic ? null : ClientRoutePaths.login,
  };
}

class _OtpPage extends StatelessWidget {
  const _OtpPage({required this.email, required this.session});

  final String email;
  final SessionCubit session;

  void _onVerified(BuildContext context) {
    session.signedIn();
    context.goNamed(ClientRouteNames.verified);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _sl<OtpCubit>(param1: email)..start(),
      child: OtpScreen(onVerified: () => _onVerified(context)),
    );
  }
}

class _RegisterPage extends StatelessWidget {
  const _RegisterPage();

  void _onRegistered(BuildContext context, String email) {
    // Register sends an OTP, so go straight to the OTP screen.
    context.pushReplacementNamed(ClientRouteNames.otp, extra: email);
  }

  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(ClientRouteNames.login);
    }
  }

  Future<PickedLocation?> _pickLocation(BuildContext context) {
    return LocationPickerScreen.open(
      context,
      createCubit: () => _sl<LocationPickerCubit>(param1: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _sl<RegisterCubit>(),
      child: RegisterScreen(
        onRegistered: (email) => _onRegistered(context, email),
        onLoginTap: () => _backToLogin(context),
        onPickLocation: () => _pickLocation(context),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.session});

  final SessionCubit session;

  Future<void> _openEdit(BuildContext context) async {
    final state = context.read<ProfileCubit>().state;
    if (state is! ProfileLoaded) return;

    final updated = await context.pushNamed<bool>(
      ClientRouteNames.profileEdit,
      extra: state.client,
    );

    if (updated == true && context.mounted) {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  void _comingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      onLogout: session.logout,
      onEditProfile: () => _openEdit(context),
      onMyOrders: () => _comingSoon(context, ClientStrings.myOrdersComingSoon),
      onFavorites: () =>
          _comingSoon(context, ClientStrings.favoritesComingSoon),
    );
  }
}

class _EditProfilePage extends StatelessWidget {
  const _EditProfilePage({required this.client});

  final ClientEntity client;

  Future<PickedLocation?> _pickLocation(BuildContext context) {
    return LocationPickerScreen.open(
      context,
      createCubit: () => _sl<LocationPickerCubit>(param1: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _sl<ImagePickerService>();

    return BlocProvider(
      create: (_) => _sl<EditProfileCubit>(),
      child: EditProfileScreen(
        client: client,
        onUpdated: () => context.pop(true),
        pickPicture: images.pickImage,
        onPickLocation: () => _pickLocation(context),
      ),
    );
  }
}
