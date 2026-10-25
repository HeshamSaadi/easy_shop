import 'package:easy_shop/apps/admin/admin_app.dart';
import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/apps/client/client_app.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../features/admin/auth/fake_auth_repository.dart';

void main() {
  final sl = GetIt.instance;

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

  testWidgets('ClientApp shows its title', (tester) async {
    await tester.pumpWidget(const ClientApp());
    expect(find.text(ClientApp.title), findsOneWidget);
  });

  testWidgets('AdminApp opens the login screen when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(const AdminApp());
    await tester.pumpAndSettle();

    expect(find.text(AuthStrings.welcomeBack), findsOneWidget);
  });
}
