// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:untitled2/viw/cart_screen.dart';
import 'package:untitled2/viw/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../service/user_server.dart';

// ألوان متبعة نفسها من الكود الأساسي
const Color _primaryAppBarColor = Color(0xFF6D4C41);
const Color _iconAppBarColor = Colors.white;
const Color _textAppBarColor = Colors.white;

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
	final String title;
	final User user;

	const CustomAppBar({
		Key? key,
		required this.title,
		required this.user,
	}) : super(key: key);

	@override
	_CustomAppBarState createState() => _CustomAppBarState();

	// الحجم الثابت لـ AppBar
	@override
	Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
	late User _currentUser;
	bool _isLoadingUser = false;

	@override
	void initState() {
		super.initState();
		_currentUser = widget.user;
		_fetchAndUpdateUserData();
	}

	Future<void> _fetchAndUpdateUserData() async {
		if (!mounted) return;
		setState(() => _isLoadingUser = true);
		try {
			final prefs = await SharedPreferences.getInstance();
			final userId = prefs.getString('id') ?? widget.user.id;
			// تأكد من أن الدالة صحيحة في user_server.dart
			User? fetched = await UserService.fetchUserDataById(userId);
			if (fetched != null && mounted) {
				setState(() => _currentUser = fetched);
				_updatePrefs(_currentUser);
			}
		} catch (e) {
			// خطأ في جلب بيانات المستخدم، يمكنك التعامل معه كما تفضل
			print("Error fetching user in AppBar: $e");
		} finally {
			if (mounted) setState(() => _isLoadingUser = false);
		}
	}

	Future<void> _updatePrefs(User user) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', user.id);
		await prefs.setString('name', user.name);
		await prefs.setString('email', user.email);
		await prefs.setString('mobile', user.mobile ?? '');
		await prefs.setString('image', user.image ?? '');
	}

	Future<void> _logout() async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.clear();
		if (!mounted) return;
		Navigator.of(context).pushAndRemoveUntil(
			MaterialPageRoute(builder: (_) => LoginPage()),
					(route) => false,
		);
	}

	@override
	Widget build(BuildContext context) {
		return AppBar(
			title: Text(
				widget.title,
				style: const TextStyle(color: _textAppBarColor),
			),
			backgroundColor: _primaryAppBarColor,
			elevation: 2,
			centerTitle: true,
			iconTheme: const IconThemeData(color: _iconAppBarColor),
			actions: [
				// زر عربة التسوق
				IconButton(
					icon: const Icon(Icons.shopping_cart_outlined),
					tooltip: 'السلة',
					onPressed: () {
						Navigator.push(
							context,
							MaterialPageRoute(builder: (_) => CartPage(userId: _currentUser.id)),
						);
					},
				),
				// زر تسجيل الخروج (يمكن إزالته إذا تريده فقط في Drawer)
				IconButton(
					icon: const Icon(Icons.logout),
					tooltip: 'تسجيل الخروج',
					onPressed: _logout,
				),
			],
		);
	}
}
