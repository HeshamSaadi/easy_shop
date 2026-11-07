import 'package:easy_shop/apps/client/client_app.dart';
import 'package:easy_shop/apps/client/client_injection.dart';
import 'package:easy_shop/core/di/core_injection.dart';
import 'package:easy_shop/core/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sl = GetIt.instance;
  final config = await AppConfig.load();
  await initCore(sl, config);
  initClient(sl);

  runApp(const ClientApp());
}
