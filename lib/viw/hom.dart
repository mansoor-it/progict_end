import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:untitled2/viw/stores_all.dart'; // تأكد من صحة المسار
import 'AllProductsPage.dart'; // تأكد من صحة المسار
import 'categories_screen.dart'; // تأكد من صحة المسار
import 'cart_screen.dart'; // تأكد من صحة المسار
import 'login.dart'; // تأكد من صحة المسار
import 'products_screen.dart'; // تأكد من صحة المسار
import '../model/user_model.dart'; // <-- إضافة استيراد لنموذج المستخدم

// --- تعديل هنا: استقبال المستخدم ---
class HomePage extends StatefulWidget {
	final User user; // <-- إضافة متغير لاستقبال المستخدم

	const HomePage({Key? key, required this.user}) : super(key: key); // <-- تعديل المنشئ

	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	int _selectedIndex = 0;

	// قائمة الصفحات يجب أن يتم بناؤها داخل initState أو build
	// لتتمكن من الوصول إلى widget.user
	late final List<Widget> _pages;

	@override
	void initState() {
		super.initState();
		// بناء قائمة الصفحات هنا للوصول إلى widget.user
		_pages = [
			DashboardScreen(),
			CategoriesScreen(user: widget.user), // <-- تمرير المستخدم هنا
			CartPage(userId: widget.user.id, cartItems: cartItems), // استخدام user.id هنا
			SimpleStoreListPage(user: widget.user), // <-- تمرير المستخدم هنا
			AllProductsPageNew(), // تأكد من أن هذه الصفحة لا تحتاج للمستخدم أو قم بتمريره
		];
	}

	void _onItemTapped(int index) {
		setState(() {
			_selectedIndex = index;
		});
	}

	@override
	Widget build(BuildContext context) {
		// يمكنك الوصول إلى بيانات المستخدم هنا عبر widget.user
		// مثال: widget.user.name

		return Scaffold(
			backgroundColor: Colors.brown[50],
			appBar: AppBar(
				title: Text('متجرك - ${widget.user.name}'), // مثال: عرض اسم المستخدم
				backgroundColor: Colors.brown[700],
				elevation: 6,
				shadowColor: Colors.brown[200],
				centerTitle: true,
				actions: [
					IconButton(
						icon: const Icon(Icons.search),
						onPressed: () {
							// يمكنك إضافة وظيفة البحث هنا
						},
					),
					IconButton(
						icon: Badge(
							label: Text(cartItems.length.toString()), // استخدام قائمة السلة العامة
							isLabelVisible: cartItems.isNotEmpty,
							child: const Icon(Icons.shopping_cart_outlined),
						),
						onPressed: () {
							// الانتقال إلى صفحة السلة باستخدام _onItemTapped أو Navigator.push
							// إذا استخدمت Navigator.push، تأكد من تمرير المستخدم
							_onItemTapped(2); // الانتقال إلى تبويب السلة
							/*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(userId: widget.user.id, cartItems: cartItems),
                ),
              );
              */
						},
					),
				],
			),
			drawer: Drawer(
				backgroundColor: Colors.white,
				child: ListView(
					padding: EdgeInsets.zero,
					children: <Widget>[
						DrawerHeader(
							decoration: BoxDecoration(
								gradient: LinearGradient(
									colors: [Colors.brown[600]!, Colors.brown[400]!],
								),
							),
							child: Align(
								alignment: Alignment.bottomLeft,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									mainAxisAlignment: MainAxisAlignment.end,
									children: [
										CircleAvatar(
											radius: 30,
											backgroundImage: widget.user.image != null && widget.user.image!.isNotEmpty
													? NetworkImage(widget.user.image!) // أو MemoryImage إذا كانت base64
													: null,
											child: widget.user.image == null || widget.user.image!.isEmpty
													? Icon(Icons.person, size: 30, color: Colors.white)
													: null,
											backgroundColor: Colors.brown[800],
										),
										SizedBox(height: 8),
										Text(
											widget.user.name, // عرض اسم المستخدم
											style: TextStyle(
												color: Colors.white,
												fontSize: 18,
												fontWeight: FontWeight.bold,
											),
										),
										Text(
											widget.user.email, // عرض بريد المستخدم
											style: TextStyle(
												color: Colors.white70,
												fontSize: 14,
											),
										),
									],
								),
							),
						),
						_buildDrawerItem(Icons.home, 'الرئيسية', 0),
						_buildDrawerItem(Icons.category, 'الأقسام', 1),
						_buildDrawerItem(Icons.shopping_cart, 'السلة', 2),
						_buildDrawerItem(Icons.store, 'المتاجر', 3),
						_buildDrawerItem(Icons.shopping_bag, 'المنتجات', 4),
						Divider(),
						ListTile(
							leading: const Icon(Icons.logout, color: Colors.red),
							title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
							onTap: () async {
								// منطق تسجيل الخروج
								// مسح البيانات المحفوظة والانتقال لصفحة تسجيل الدخول
								// SharedPreferences prefs = await SharedPreferences.getInstance();
								// await prefs.clear();
								Navigator.of(context).pushAndRemoveUntil(
									MaterialPageRoute(builder: (_) => LoginPage()),
											(Route<dynamic> route) => false,
								);
							},
						),
					],
				),
			),
			body: AnimatedSwitcher(
				duration: const Duration(milliseconds: 300),
				transitionBuilder: (Widget child, Animation<double> animation) {
					return FadeTransition(opacity: animation, child: child);
				},
				child: _pages[_selectedIndex],
			),
			bottomNavigationBar: ConvexAppBar(
				style: TabStyle.react,
				backgroundColor: Colors.brown[700],
				activeColor: Colors.white,
				color: Colors.brown[100],
				elevation: 10,
				items: const [
					TabItem(icon: Icons.home, title: 'الرئيسية'),
					TabItem(icon: Icons.category, title: 'الأقسام'),
					TabItem(icon: Icons.shopping_cart, title: 'السلة'),
					TabItem(icon: Icons.store, title: 'المتاجر'),
					TabItem(icon: Icons.shopping_bag, title: 'المنتجات'),
				],
				initialActiveIndex: _selectedIndex,
				onTap: _onItemTapped,
			),
		);
	}

	Widget _buildDrawerItem(IconData icon, String title, int index) {
		bool isSelected = _selectedIndex == index;
		return Material(
			color: isSelected ? Colors.brown[100] : Colors.transparent,
			child: ListTile(
				leading: Icon(icon, color: isSelected ? Colors.brown[900] : Colors.brown[700]),
				title: Text(
					title,
					style: TextStyle(color: isSelected ? Colors.brown[900] : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
				),
				selected: isSelected,
				onTap: () {
					_onItemTapped(index);
					Navigator.pop(context); // إغلاق الـ Drawer
				},
				selectedTileColor: Colors.brown[100],
			),
		);
	}
}

// --- شاشة لوحة التحكم الافتراضية ---
class DashboardScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.all(16.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						"مرحباً بك في متجرك",
						style: Theme.of(context).textTheme.headlineSmall?.copyWith(
							fontWeight: FontWeight.bold,
							color: Colors.brown[800],
						),
					),
					const SizedBox(height: 16),
					Container(
						height: 200,
						decoration: BoxDecoration(
							gradient: LinearGradient(
								colors: [Colors.brown.shade100, Colors.brown.shade300],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(16),
							boxShadow: [
								BoxShadow(
									color: Colors.brown.shade200,
									blurRadius: 10,
									offset: const Offset(0, 4),
								),
							],
						),
						child: Center(
							child: Text(
								"عرض مميزات التطبيق هنا",
								style: Theme.of(context).textTheme.titleMedium?.copyWith(
									color: Colors.brown[900],
									fontWeight: FontWeight.bold,
								),
							),
						),
					),
					const SizedBox(height: 20),
					Text(
						"آخر التصنيفات",
						style: Theme.of(context).textTheme.titleMedium?.copyWith(
							fontWeight: FontWeight.bold,
							color: Colors.brown[700],
						),
					),
					const SizedBox(height: 12),
					// يمكنك هنا عرض قائمة فعلية بالتصنيفات بدلاً من العناصر الثابتة
					Expanded(
						child: GridView.builder(
							gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
								crossAxisCount: 3,
								crossAxisSpacing: 10,
								mainAxisSpacing: 10,
							),
							itemCount: 6, // عدد العناصر الافتراضية
							itemBuilder: (context, index) {
								return Container(
									decoration: BoxDecoration(
										gradient: LinearGradient(
											colors: [Colors.brown.shade100, Colors.brown.shade200],
										),
										borderRadius: BorderRadius.circular(12),
										boxShadow: [
											BoxShadow(
												color: Colors.brown.shade100,
												blurRadius: 4,
												offset: const Offset(2, 2),
											),
										],
									),
									child: Center(
										child: Text(
											"قسم ${index + 1}",
											style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold),
										),
									),
								);
							},
						),
					),
				],
			),
		);
	}
}

// --- صفحة المنتجات الجديدة الافتراضية ---
// تأكد من أن هذه الصفحة إما لا تحتاج للمستخدم أو أنها تستقبله
class AllProductsPageNew extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Center(
			child: Text(
				'صفحة جميع المنتجات الجديدة',
				style: Theme.of(context).textTheme.headlineMedium,
			),
		);
	}
}

