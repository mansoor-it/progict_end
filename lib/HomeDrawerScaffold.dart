import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/viw/AllProductsPage.dart';
import 'package:untitled2/viw/EditProfilePage.dart';
import 'package:untitled2/viw/MostOrderedProductsPage.dart';
// تأكد من المسار الصحيح
import 'package:untitled2/viw/categories_screen.dart'; // تأكد من المسار الصحيح
import 'package:untitled2/viw/f/InvoicePage.dart';
import 'package:untitled2/viw/f/o.dart';
import 'package:untitled2/viw/login.dart'; // تأكد من المسار الصحيح
import 'package:untitled2/viw/products_screen.dart'; // تأكد من المسار الصحيح
import 'package:untitled2/viw/stores_all.dart'; // تأكد من المسار الصحيح
// تأكد من المسار الصحيح لصفحة نبذة عنا
import '../model/user_model.dart'; // تأكد من المسار الصحيح لنموذج المستخدم
import '../service/user_server.dart';
import 'AboutUsPage.dart';
import 'Support or Help.dart';
import 'controll/AdminLoginPage.dart'; // <-- استيراد خدمة المستخدم لجلب البيانات

// --- ألوان للتصميم الجذاب (يمكن تخصيصها) ---
const Color primaryDrawerColor = Color(0xFF08338F);
const Color accentDrawerColor = Color(0xFF399294);
const Color headerDrawerColor = Color(0xFF3D3C69);
const Color iconDrawerColor = Colors.white70;
const Color textDrawerColor = Colors.white;
const Color selectedTileColor = Color(0xFF4D988E);

class HomeDrawerScaffold extends StatefulWidget {
	final User user; // المستخدم الأولي عند تسجيل الدخول

	const HomeDrawerScaffold({Key? key, required this.user}) : super(key: key);

	@override
	_HomeDrawerScaffoldState createState() => _HomeDrawerScaffoldState();
}

class _HomeDrawerScaffoldState extends State<HomeDrawerScaffold> {
	int _selectedIndex = 0;
	String _title = 'الصفحة الرئيسي ';
	late User _currentUser; // لتخزين وعرض المستخدم الحالي
	bool _isLoadingUser = false; // لتتبع حالة تحميل بيانات المستخدم

	late List<Widget> _pages;

	@override
	void initState() {
		super.initState();
		_currentUser = widget.user; // ابدأ بالمستخدم الأولي
		_buildPages(); // بناء الصفحات أولاً
		_fetchAndUpdateUserData(); // ثم جلب أحدث بيانات للمستخدم
	}

	// بناء قائمة الصفحات
	void _buildPages() {
		_pages = [
			MainHomePage(user: _currentUser,),
			CategoriesScreen(user: _currentUser),
			SimpleStoreListPage(user: _currentUser),
			AllProductsPageNew(storeId: '', storeName: '',user: _currentUser),
			MostOrderedProductsPage(),
		];
	}

	// --- دالة لجلب أحدث بيانات المستخدم من قاعدة البيانات وتحديث الواجهة ---
	Future<void> _fetchAndUpdateUserData() async {
		if (!mounted) return;
		setState(() => _isLoadingUser = true);
		try {
			final prefs = await SharedPreferences.getInstance();
			final userId = prefs.getString('id') ?? widget.user.id;

			// --- تصحيح: استخدام اسم الدالة الصحيح من UserService ---
			// !!! تأكد من أن اسم الدالة `fetchUserDataById` هو الصحيح في ملف user_server.dart !!!
			User? fetchedUser = await UserService.fetchUserDataById(userId);

			if (fetchedUser != null && mounted) {
				setState(() {
					_currentUser = fetchedUser;
					_buildPages();
				});
				_updatePrefs(_currentUser);
			} else if (mounted) {
				print("لم يتم العثور على المستخدم أو حدث خطأ أثناء الجلب باستخدام ID: $userId");
			}
		} catch (e) {
			print("Error fetching user data: $e");
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('خطأ في تحميل بيانات المستخدم: ${e.toString()}'), backgroundColor: Colors.orange),
				);
			}
		} finally {
			if (mounted) {
				setState(() => _isLoadingUser = false);
			}
		}
	}

	void _updateTitle(int index) {
		switch (index) {
			case 0:
				_title = 'الرئيسي';
				break;
			case 1:
				_title = 'الاقسام';
				break;
			case 2:
				_title = 'المتاجر';
				break;
			case 3:
				_title = 'جميع المنتجات';
				break;
			default:
				_title = 'متجرك';
		}
	}

	void _onSelectItem(int index) {
		setState(() {
			_selectedIndex = index;
			_updateTitle(index);
		});
		Navigator.of(context).pop();
	}

	Future<void> _logout() async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.clear();
		if (!mounted) return;
		Navigator.of(context).pushAndRemoveUntil(
			MaterialPageRoute(builder: (_) => LoginPage()),
					(Route<dynamic> route) => false,
		);
	}

	Uint8List? _decodeImage(String? base64String) {
		if (base64String == null || base64String.isEmpty) return null;
		try {
			String actualBase64 = base64String.contains(',')
					? base64String.substring(base64String.indexOf(',') + 1)
					: base64String;
			return base64Decode(actualBase64);
		} catch (e) {
			print("Error decoding image in drawer: $e");
			return null;
		}
	}

	void _navigateToEditProfile() {
		Navigator.pop(context);
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => EditProfilePage(
					user: _currentUser,
					onProfileUpdateSuccess: () {
						_fetchAndUpdateUserData();
					},
				),
			),
		);
	}

	Future<void> _updatePrefs(User user) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', user.id);
		await prefs.setString('name', user.name);
		await prefs.setString('email', user.email);
		await prefs.setString('mobile', user.mobile ?? '');
		await prefs.setString('image', user.image ?? '');
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final user = _currentUser;
		final userImageBytes = _decodeImage(user.image);

		return Scaffold(
			appBar: AppBar(
				title: Text(_title),
				centerTitle: true,
				elevation: 2,
			),
			drawer: Drawer(
				backgroundColor: primaryDrawerColor,
				child: ListView(
					padding: EdgeInsets.zero,
					children: <Widget>[
						Container(
							padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 16, right: 16),
							decoration: BoxDecoration(
								color: headerDrawerColor,
								// image: DecorationImage(
								// 	image: AssetImage('assets/m.png'), // تأكد من وجود هذا المسار
								// 	fit: BoxFit.cover,
								// 	colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
								// ),
							),
							child: _isLoadingUser
									? Center(child: CircularProgressIndicator(color: Colors.white))
									: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									CircleAvatar(
										radius: 40,
										backgroundColor: Colors.white.withOpacity(0.9),
										backgroundImage: userImageBytes != null
												? MemoryImage(userImageBytes)
												: null,
										child: userImageBytes == null
												? Icon(Icons.person, size: 45, color: primaryDrawerColor)
												: null,
									),
									const SizedBox(height: 12),
									Text(
										user.name,
										style: TextStyle(
											fontSize: 18,
											fontWeight: FontWeight.bold,
											color: textDrawerColor,
											shadows: [Shadow(blurRadius: 1, color: Colors.black.withOpacity(0.5))],
										),
									),
									const SizedBox(height: 4),
									Text(
										user.email,
										style: TextStyle(
											fontSize: 14,
											color: textDrawerColor.withOpacity(0.8),
											shadows: [Shadow(blurRadius: 1, color: Colors.black.withOpacity(0.5))],
										),
									),
								],
							),
						),

						const Divider(color: Colors.white24, height: 20, thickness: 0.5, indent: 16, endIndent: 16),
						_buildNavigationItem(Icons.edit_outlined, 'تعديل الملف الشخصي', _navigateToEditProfile),
						const Divider(color: Colors.white24, height: 20, thickness: 0.5, indent: 16, endIndent: 16),
						_buildDrawerItem(Icons.category_outlined, 'الرئيسي', 0, _selectedIndex == 0),
						_buildDrawerItem(Icons.store_mall_directory_outlined, 'الأقسام', 1, _selectedIndex == 1),
						_buildDrawerItem(Icons.shopping_bag_outlined, 'المتاجر ', 2, _selectedIndex == 2),
						_buildDrawerItem(Icons.shopping_cart_outlined, 'جميع المنتجات ', 3, _selectedIndex == 3),
						const Divider(color: Colors.white24, height: 20, thickness: 0.5, indent: 16, endIndent: 16),

						ListTile(
							leading: Icon(Icons.info_outline, color: iconDrawerColor, size: 24),
							title: Text('الادارة', style: TextStyle(color: textDrawerColor, fontSize: 14)),
							onTap: () {
								Navigator.pop(context);
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => AdminLoginPage()),
								);
							},
							dense: true,
							contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
						),

						ListTile(
							leading: Icon(Icons.info_outline, color: iconDrawerColor, size: 24),
							title: Text('ادارة المحل ', style: TextStyle(color: textDrawerColor, fontSize: 14)),
							onTap: () {
								Navigator.pop(context);
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => LoginPage()),
								);
							},
							dense: true,
							contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
						),

						// إضافة عنصر "من نحن"
						ListTile(
							leading: Icon(Icons.info_outline, color: iconDrawerColor, size: 24),
							title: Text('من نحن', style: TextStyle(color: textDrawerColor, fontSize: 14)),
							onTap: () {
								Navigator.pop(context);
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => AboutUsPage()),
								);
							},
							dense: true,
							contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
						),

						// إضافة عنصر "نبذة عنا"
						ListTile(
							leading: Icon(Icons.support_agent_outlined, color: iconDrawerColor, size: 24),
							title: Text('نبذة عنا', style: TextStyle(color: textDrawerColor, fontSize: 14)),
							onTap: () {
								Navigator.pop(context);
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => SupportPage()),
								);
							},
							dense: true,
							contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
						),


						ListTile(
							leading: Icon(Icons.logout, color: Colors.redAccent, size: 24),
							title: Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
							onTap: _logout,
							dense: true,
							contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
						),
					],
				),
			),
			body: IndexedStack(
				index: _selectedIndex,
				children: _pages,
			),
		);
	}

	Widget _buildDrawerItem(IconData icon, String title, int index, bool isSelected) {
		return Material(
			color: isSelected ? selectedTileColor : Colors.transparent,
			child: ListTile(
				leading: Icon(icon, color: isSelected ? Colors.white : iconDrawerColor, size: 24),
				title: Text(
					title,
					style: TextStyle(
						fontSize: 14,
						fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
						color: textDrawerColor,
					),
				),
				onTap: () => _onSelectItem(index),
				dense: true,
				contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
			),
		);
	}

	Widget _buildNavigationItem(IconData icon, String title, VoidCallback onTap) {
		return ListTile(
			leading: Icon(icon, color: iconDrawerColor, size: 24),
			title: Text(title, style: TextStyle(color: textDrawerColor, fontSize: 14)),
			onTap: onTap,
			dense: true,
			contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
		);
	}
}

// --- صفحة المنتجات الجديدة الافتراضية (مثال) ---


// --- قائمة السلة العامة (مثال) ---
List<Map<String, dynamic>> cartItems = [];
