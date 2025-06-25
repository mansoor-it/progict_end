import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:untitled2/viw/AllProductsPage.dart';
import 'package:untitled2/viw/MostOrderedProductsPage.dart';
import 'package:untitled2/viw/SignUpPage.dart';
import 'package:untitled2/viw/f/o.dart';

import 'package:untitled2/viw/hom.dart';
import 'package:untitled2/viw/login.dart';
import 'package:untitled2/viw/stores_all.dart';

import 'AboutUsPage.dart';
import 'HomeDrawerScaffold.dart';
import 'HomeDrawer_Admin.dart';
import 'Support or Help.dart';
import 'chatgpt/chat_query.dart';
import 'controll/AdminDashboardPage.dart';
import 'controll/AdminLoginPage.dart';
import 'controll/OrderDetailsManagementPage.dart';
import 'controll/OrdersAndDetailsManagementPage.dart';
import 'controll/PaymentsManagementPage.dart';
import 'controll/ShippingManagementPage.dart';
import 'controll/StoreManagementPage.dart';

import 'controll/VendorLoginPage.dart';
import 'controll/admin_control.dart';
import 'controll/orders_management_page.dart';
import 'controll/user_control.dart';
import 'controll/vendors_control.dart';
import 'home.dart';
import 'service/server_cart.dart';
import 'viw/categories_screen.dart';

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
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: window.locale.languageCode == 'ar' ? 'Cairo' : null,
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: window.locale.languageCode == 'ar' ? 'Cairo' : null,
          ),
        ),
      ),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
        home:LoginPage(),
     // home: isLoggedIn ? const CategoriesScreen() : const LoginPage(),
    );
  }
}
