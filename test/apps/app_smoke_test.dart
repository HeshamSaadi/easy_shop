import 'package:easy_shop/apps/admin/admin_app.dart';
import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/apps/client/client_app.dart';
import 'package:easy_shop/apps/client/session/session_cubit.dart'
    as client_session;
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/remove_from_cart.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/login_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/logout_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/restore_session.dart'
    as client_restore;
import 'package:easy_shop/features/client/auth/presentation/cubit/login_cubit.dart'
    as client_login;
import 'package:easy_shop/features/client/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../features/admin/auth/fake_auth_repository.dart';
import '../features/client/auth/fake_client_auth_repository.dart';
import '../features/client/cart/fake_cart_repository.dart';

void main() {
  final sl = GetIt.instance;

  group('ClientApp', () {
    Future<void> registerClient({required bool hasSession}) async {
      await sl.reset();
      final repository = FakeClientAuthRepository(hasSession: hasSession);
      final cartRepository = FakeCartRepository();
      sl
        ..registerSingleton(SessionEvents())
        ..registerSingleton(
          client_session.SessionCubit(
            restoreSession: client_restore.RestoreSession(repository),
            logout: LogoutClient(repository),
            sessionEvents: sl<SessionEvents>(),
          ),
        )
        ..registerFactory(
          () => client_login.LoginCubit(loginClient: LoginClient(repository)),
        )
        ..registerSingleton(
          CartCubit(
            getCart: GetCart(cartRepository),
            addToCart: AddToCart(cartRepository),
            removeFromCart: RemoveFromCart(cartRepository),
          ),
        );
    }

    tearDown(() async {
      await sl<CartCubit>().close();
      await sl<client_session.SessionCubit>().close();
      await sl.reset();
    });

    testWidgets('shows the five navigation tabs when a session exists', (
      tester,
    ) async {
      await registerClient(hasSession: true);

      await tester.pumpWidget(const ClientApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('opens the login screen when there is no session', (
      tester,
    ) async {
      await registerClient(hasSession: false);

      await tester.pumpWidget(const ClientApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('AdminApp', () {
    setUp(() async {
      await sl.reset();
      final repository = FakeAuthRepository();
      sl
        ..registerSingleton(SessionEvents())
        ..registerSingleton(
          SessionCubit(
            restoreSession: RestoreSession(repository),
            logout: LogoutAdmin(repository),
            sessionEvents: sl<SessionEvents>(),
          ),
        )
        ..registerFactory(() => LoginCubit(loginAdmin: LoginAdmin(repository)));
    });

    tearDown(() async {
      await sl<SessionCubit>().close();
      await sl.reset();
    });

    testWidgets('opens the login screen when there is no session', (
      tester,
    ) async {
      await tester.pumpWidget(const AdminApp());
      await tester.pumpAndSettle();

      expect(find.text(AuthStrings.welcomeBack), findsOneWidget);
    });
  });
}
