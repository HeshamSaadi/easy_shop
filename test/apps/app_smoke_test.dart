import 'package:easy_shop/apps/admin/admin_app.dart';
import 'package:easy_shop/apps/client/client_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ClientApp shows its title', (tester) async {
    await tester.pumpWidget(const ClientApp());
    expect(find.text(ClientApp.title), findsOneWidget);
  });

  testWidgets('AdminApp shows its title', (tester) async {
    await tester.pumpWidget(const AdminApp());
    expect(find.text(AdminApp.title), findsOneWidget);
  });
}
