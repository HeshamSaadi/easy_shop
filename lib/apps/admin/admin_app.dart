import 'package:flutter/material.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  static const String title = 'EasyShop Admin';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: Scaffold(body: Center(child: Text(title))),
    );
  }
}