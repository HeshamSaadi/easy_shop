import 'package:easy_shop/apps/client/client_router.dart';
import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ClientApp extends StatefulWidget {
  const ClientApp({super.key});

  static const String title = 'EasyShop';

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  late final SessionCubit _session = GetIt.instance<SessionCubit>()..restore();
  late final GoRouter _router = createClientRouter(_session);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _session,
      child: MaterialApp.router(
        title: ClientApp.title,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: AppTheme.defaultMode,
        routerConfig: _router,
      ),
    );
  }
}
