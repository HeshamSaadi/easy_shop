import 'package:flutter/material.dart';

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  static const String title = 'EasyShop';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: Scaffold(body: Center(child: Text(title))),
    );
  }
}
