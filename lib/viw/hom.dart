import 'package:flutter/material.dart';
import 'package:untitled2/viw/stores_all.dart';
import 'AllProductsPage.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'login.dart';
import 'products_screen.dart';
// استيراد الصفحات الجديدة

class HomePage extends StatefulWidget {
	const HomePage({Key? key}) : super(key: key);

	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	int _selectedIndex = 0;

	final List<Widget> _pages = [
		DashboardScreen(), // شاشة المحتوى الرئيسي
		CategoriesScreen(), // الأقسام
		CartPage(userId: "1", cartItems: []), // السلة
		LoginPage(), // تسجيل الدخول
		ProductsScreen(storeId: "1", storeName: "متجر العرض"), // المنتجات
	];

	void _onItemTapped(int index) {
		setState(() {
			_selectedIndex = index;
		});
	}

	// دالة لبناء فوتر الصفحة
	Widget _buildFooter() {
		return Container(
			height: 60,
			decoration: BoxDecoration(
				color: Colors.teal[800],
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.1),
						blurRadius: 10,
						offset: const Offset(0, -5),
					),
				],
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceAround,
				children: [
					_buildFooterIcon(Icons.shopping_cart, 'السلة', CartPage(userId: "1", cartItems: [])),
					_buildFooterIcon(Icons.category, 'الأقسام', CategoriesScreen()),
					_buildFooterIcon(Icons.store, 'المتاجر', SimpleStoreListPage()),
					// تم استبدال الأكثر مبيعاً بجميع المنتجات
					_buildFooterIcon(Icons.shopping_bag, 'جميع المنتجات', AllProductsPageNew()),
				],
			),
		);
	}

	// دالة مساعدة لبناء أيقونات الفوتر
	Widget _buildFooterIcon(IconData icon, String label, Widget page) {
		return InkWell(
			onTap: () {
				Navigator.push(
					context,
					MaterialPageRoute(builder: (context) => page),
				);
			},
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(icon, color: Colors.white, size: 28),
					const SizedBox(height: 4),
					Text(
						label,
						style: const TextStyle(
							color: Colors.white,
							fontSize: 12,
							fontWeight: FontWeight.bold,
						),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('متجرك'),
				backgroundColor: Colors.teal,
				elevation: 4,
				actions: [
					IconButton(
						icon: const Icon(Icons.search),
						onPressed: () {},
					),
					IconButton(
						icon: const Icon(Icons.shopping_cart),
						onPressed: () {
							Navigator.push(
								context,
								MaterialPageRoute(
									builder: (context) => CartPage(userId: "1", cartItems: []),
								),
							);
						},
					),
				],
			),
			drawer: Drawer(
				backgroundColor: Colors.white,
				child: ListView(
					padding: EdgeInsets.zero,
					children: <Widget>[
						const DrawerHeader(
							decoration: BoxDecoration(
								color: Colors.teal,
							),
							child: Text(
								'قائمة التنقل',
								style: TextStyle(
									color: Colors.white,
									fontSize: 24,
								),
							),
						),
						ListTile(
							leading: const Icon(Icons.home),
							title: const Text('الرئيسية'),
							selected: _selectedIndex == 0,
							onTap: () {
								_onItemTapped(0);
								Navigator.pop(context);
							},
						),
						ListTile(
							leading: const Icon(Icons.category),
							title: const Text('الأقسام'),
							selected: _selectedIndex == 1,
							onTap: () {
								_onItemTapped(1);
								Navigator.pop(context);
							},
						),
						ListTile(
							leading: const Icon(Icons.shopping_cart),
							title: const Text('السلة'),
							selected: _selectedIndex == 2,
							onTap: () {
								_onItemTapped(2);
								Navigator.pop(context);
							},
						),
						ListTile(
							leading: const Icon(Icons.person),
							title: const Text('تسجيل الدخول'),
							selected: _selectedIndex == 3,
							onTap: () {
								_onItemTapped(3);
								Navigator.pop(context);
							},
						),
						ListTile(
							leading: const Icon(Icons.store),
							title: const Text('المنتجات'),
							selected: _selectedIndex == 4,
							onTap: () {
								_onItemTapped(4);
								Navigator.pop(context);
							},
						),
					],
				),
			),
			body: _pages[_selectedIndex],
			// إضافة الفوتر هنا
			bottomNavigationBar: _buildFooter(),
		);
	}
}

// شاشة المحتوى الرئيسي (الرئيسية)
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
						),
					),
					const SizedBox(height: 16),
					Container(
						height: 200,
						decoration: BoxDecoration(
							color: Colors.grey[200],
							borderRadius: BorderRadius.circular(12),
						),
						child: Center(
							child: Text(
								"عرض مميزات التطبيق هنا",
								style: Theme.of(context).textTheme.titleMedium,
							),
						),
					),
					const SizedBox(height: 20),
					Text(
						"آخر التصنيفات",
						style: Theme.of(context).textTheme.titleMedium?.copyWith(
							fontWeight: FontWeight.bold,
						),
					),
					const SizedBox(height: 12),
					Expanded(
						child: GridView.builder(
							gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
								crossAxisCount: 3,
								crossAxisSpacing: 10,
								mainAxisSpacing: 10,
							),
							itemCount: 6,
							itemBuilder: (context, index) {
								return Container(
									decoration: BoxDecoration(
										color: Colors.teal.withOpacity(0.2),
										borderRadius: BorderRadius.circular(8),
									),
									child: Center(child: Text("قسم $index")),
								);
							},
						),
					),
				],
			),
		);
	}
}