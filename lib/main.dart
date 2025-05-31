import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/viw/AllProductsPage.dart';
import 'package:untitled2/viw/MostOrderedProductsPage.dart';
import 'package:untitled2/viw/SignUpPage.dart';
import 'package:untitled2/viw/hom.dart';
import 'package:untitled2/viw/login.dart';
import 'package:untitled2/viw/stores_all.dart';
import 'controll/OrderDetailsManagementPage.dart';
import 'controll/OrdersAndDetailsManagementPage.dart';

import 'controll/PaymentsManagementPage.dart';
import 'controll/ShippingManagementPage.dart';
import 'controll/StoreManagementPage.dart';
import 'controll/orders_management_page.dart';
import 'controll/user_control.dart';
import 'home.dart';
import 'service/server_cart.dart';
import 'viw/categories_screen.dart'; // الصفحة الرئيسية

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // توجيه المستخدم حسب حالة تسجيل الدخول
      home:LoginPage(),
      ///home: isLoggedIn ? CategoriesScreen()MainDrawer : const LoginPage(),
    );
  }
}
