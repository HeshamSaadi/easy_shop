import 'package:easy_shop/apps/admin/admin_route_names.dart';
import 'package:easy_shop/apps/admin/admin_shell.dart';
import 'package:easy_shop/apps/admin/session/router_refresh_stream.dart';
import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/apps/admin/session/session_state.dart';
import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_screen.dart';
import 'package:easy_shop/core/location/picked_location.dart' as core;
import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/login_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/otp_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/screens/register_screen.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_pickers.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/presentation/screens/categories_screen.dart';
import 'package:easy_shop/features/admin/categories/presentation/screens/category_form_screen.dart';
import 'package:easy_shop/features/admin/home/presentation/screens/home_screen.dart';
import 'package:easy_shop/features/admin/orders/presentation/screens/order_details_screen.dart';
import 'package:easy_shop/features/admin/orders/presentation/screens/orders_screen.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/screens/product_details_screen.dart';
import 'package:easy_shop/features/admin/products/presentation/screens/product_form_screen.dart';
import 'package:easy_shop/features/admin/products/presentation/screens/products_screen.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_state.dart';
import 'package:easy_shop/features/admin/profile/presentation/screens/edit_profile_page.dart';
import 'package:easy_shop/features/admin/profile/presentation/screens/profile_screen.dart';
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
                builder: (context, _) => BlocProvider(
                  create: (_) => _sl<ProfileCubit>()..load(),
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final profile = state is ProfileLoaded
                          ? state.profile
                          : null;
                      return HomeScreen(
                        adminName: profile?.name,
                        storeName: profile?.businessName,
                        onAddProduct: () => context.pushNamed<bool>(
                          AdminRouteNames.productForm,
                        ),
                        onManageCategories: () =>
                            context.pushNamed(AdminRouteNames.categories),
                        onSeeAllProducts: () =>
                            context.goNamed(AdminRouteNames.products),
                        onSeeAllOrders: () =>
                            context.goNamed(AdminRouteNames.orders),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AdminRouteNames.products,
                path: AdminRoutePaths.products,
                builder: (context, _) => ProductsScreen(
                  onOpenDetails: (product) => context.pushNamed<bool>(
                    AdminRouteNames.productDetails,
                    pathParameters: {AdminRouteParams.slug: product.slug},
                  ),
                  onOpenForm: () =>
                      context.pushNamed<bool>(AdminRouteNames.productForm),
                  onManageCategories: () =>
                      context.pushNamed(AdminRouteNames.categories),
                ),
                routes: [
                  GoRoute(
                    name: AdminRouteNames.productDetails,
                    path: 'details/:${AdminRouteParams.slug}',
                    builder: (context, state) => ProductDetailsScreen(
                      slug: state.pathParameters[AdminRouteParams.slug] ?? '',
                      onEdit: (product) => context.pushNamed<bool>(
                        AdminRouteNames.productForm,
                        extra: product,
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AdminRouteNames.productForm,
                    path: 'form',
                    builder: (_, state) {
                      final extra = state.extra;
                      return ProductFormScreen(
                        product: extra is ProductEntity ? extra : null,
                      );
                    },
                  ),
                  GoRoute(
                    name: AdminRouteNames.categories,
                    path: 'categories',
                    builder: (context, _) => CategoriesScreen(
                      showBack: true,
                      onOpenForm: (category) => context.pushNamed<bool>(
                        AdminRouteNames.categoryForm,
                        extra: category,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        name: AdminRouteNames.categoryForm,
                        path: 'form',
                        builder: (_, state) {
                          final extra = state.extra;
                          return CategoryFormScreen(
                            category: extra is CategoryEntity ? extra : null,
                          );
                        },
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
                builder: (context, _) => OrdersScreen(
                  onOpenDetails: (order) => context.pushNamed(
                    AdminRouteNames.orderDetails,
                    pathParameters: {AdminRouteParams.code: order.code},
                  ),
                ),
                routes: [
                  GoRoute(
                    name: AdminRouteNames.orderDetails,
                    path: 'details/:${AdminRouteParams.code}',
                    builder: (_, state) => OrderDetailsScreen(
                      code: state.pathParameters[AdminRouteParams.code] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AdminRouteNames.profile,
                path: AdminRoutePaths.profile,
                builder: (context, _) => BlocProvider(
                  create: (_) => _sl<ProfileCubit>()..load(),
                  child: ProfileScreen(
                    onEdit: (profile) => context.pushNamed<bool>(
                      AdminRouteNames.profileEdit,
                      extra: profile,
                    ),
                    onLogout: session.logout,
                  ),
                ),
                routes: [
                  GoRoute(
                    name: AdminRouteNames.profileEdit,
                    path: 'edit',
                    redirect: (_, state) => state.extra is ProfileEntity
                        ? null
                        : AdminRoutePaths.profile,
                    builder: (_, state) =>
                        EditProfilePage(profile: state.extra! as ProfileEntity),
                  ),
                ],
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

  static PickedLocation? _toRecord(core.PickedLocation? location) {
    if (location == null) return null;
    return (latitude: location.latitude, longitude: location.longitude);
  }

  static Future<PickedLocation?> _pickLocation(BuildContext context) async {
    final result = await LocationPickerScreen.open(
      context,
      createCubit: () => _sl<LocationPickerCubit>(param1: null),
    );
    return _toRecord(result);
  }

  void _backToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AdminRouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _sl<ImagePickerService>();
    return BlocProvider(
      create: (_) => _sl<RegisterCubit>(),
      child: RegisterScreen(
        onRegistered: () => _backToLogin(context),
        onExit: () => _backToLogin(context),
        pickDocument: images.pickImage,
        pickPicture: images.pickImage,
        pickLocation: () => _pickLocation(context),
      ),
    );
  }
}
