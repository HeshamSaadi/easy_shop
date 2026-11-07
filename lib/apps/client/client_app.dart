import 'package:easy_shop/apps/client/client_router.dart';
import 'package:easy_shop/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({super.key});

  static const String title = 'EasyShop';

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  late final GoRouter _router = createClientRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: ClientApp.title,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.defaultMode,
      routerConfig: _router,
    );
  }
}
