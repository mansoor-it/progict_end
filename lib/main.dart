import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/ProductDetailsPage_server.dart';
import 'home.dart';
import 'service/server_cart.dart';
import 'viw/categories_screen.dart'; // الصفحة الرئيسية لديك

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
        // هنا يمكنك إضافة Providers أخرى إذا احتجت
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home:  NavigationHomePage(),
    );
  }
}
