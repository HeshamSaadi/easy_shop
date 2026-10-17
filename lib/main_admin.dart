import 'package:easy_shop/apps/admin/admin_app.dart';
import 'package:easy_shop/core/utils/app_config.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const AdminApp());
}
