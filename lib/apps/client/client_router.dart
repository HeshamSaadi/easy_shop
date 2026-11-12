import 'package:easy_shop/apps/client/client_route_names.dart';
import 'package:easy_shop/apps/client/client_shell.dart';
import 'package:easy_shop/apps/client/client_strings.dart';
import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/apps/client/session/session_state.dart';
import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_screen.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/core/utils/router_refresh_stream.dart';
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
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop/features/client/cart/presentation/screens/cart_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _ClientShellPage(navigationShell: shell),
        branches: [
          _placeholderBranch(
            ClientRouteNames.home,
            ClientRoutePaths.home,
            ClientShellStrings.home,
          ),
          _placeholderBranch(
            ClientRouteNames.favorites,
            ClientRoutePaths.favorites,
            ClientShellStrings.favorites,
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: ClientRouteNames.cart,
                path: ClientRoutePaths.cart,
                builder: (context, _) => CartScreen(
                  // CL-C7 opens the checkout here.
                  onCheckout: () {},
                  onStartShopping: () => context.goNamed(ClientRouteNames.home),
                ),
              ),
            ],
          ),
          _placeholderBranch(
            ClientRouteNames.orders,
            ClientRoutePaths.orders,
            ClientShellStrings.orders,
          ),
          _profileBranch(session),
        ],
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

StatefulShellBranch _profileBranch(SessionCubit session) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        name: ClientRouteNames.profile,
        path: ClientRoutePaths.profile,
        builder: (_, _) => BlocProvider(
          create: (_) => _sl<ProfileCubit>()..loadProfile(),
          child: _ProfilePage(session: session),
        ),
        routes: [
          GoRoute(
            name: ClientRouteNames.profileEdit,
            path: 'edit',
            redirect: (_, state) =>
                state.extra is ClientEntity ? null : ClientRoutePaths.profile,
            builder: (_, state) =>
                _EditProfilePage(client: state.extra! as ClientEntity),
          ),
        ],
      ),
    ],
  );
}

/// Temporary tab. The owner of each feature replaces it with the real screen.
StatefulShellBranch _placeholderBranch(String name, String path, String label) {
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

  // Register sends no OTP (only login does), so the next step is login.
  void _onRegistered(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(ClientStrings.accountCreated)),
      );
    context.goNamed(ClientRouteNames.login);
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
        onRegistered: (_) => _onRegistered(context),
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

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      onLogout: session.logout,
      onEditProfile: () => _openEdit(context),
      onMyOrders: () => context.goNamed(ClientRouteNames.orders),
      onFavorites: () => context.goNamed(ClientRouteNames.favorites),
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

/// Provides the shared [CartCubit] to the whole shell, so the Cart tab badge
/// and the Cart screen show the same cart. `BlocProvider.value` does not close
/// it, because it is a singleton. The shell is rebuilt after every login, so
/// the cart of the previous account is replaced by `load()`.
class _ClientShellPage extends StatefulWidget {
  const _ClientShellPage({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_ClientShellPage> createState() => _ClientShellPageState();
}

class _ClientShellPageState extends State<_ClientShellPage> {
  late final CartCubit _cart = _sl<CartCubit>();

  @override
  void initState() {
    super.initState();
    _cart.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cart,
      child: ClientShell(navigationShell: widget.navigationShell),
    );
  }
}
