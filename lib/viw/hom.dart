import 'package:flutter/material.dart';

// استيراد الشاشات التي تريد التنقل إليها
import '../controll/OrderManagementPage.dart';
import '../controll/ShippingManagementPage.dart';
import 'PaymentPage.dart';
import 'ProductDetailsPage.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'login.dart';
import 'stores_screen.dart';
import 'store_details_screen.dart';
import 'products_screen.dart';


class HomePage extends StatelessWidget {
	const HomePage({Key? key}) : super(key: key);

	// قائمة العناصر التي ستظهر في الشبكة
	// لكل عنصر: عنوان، و أيقونة، ودالة لإنشاء الشاشة (Widget)
	List<_NavItem> get _navItems => [
		_NavItem(
			label: 'المتاجر',
			iconData: Icons.store,
			builder: () =>  StoresScreen(categoryId: '', categoryName: '',),
		),

		_NavItem(
			label: 'الطلبات',
			iconData: Icons.shopping_bag,
			builder: () =>  OrderManagementPage(),
		),
		_NavItem(
			label: 'جميع المنتجات',
			iconData: Icons.list_alt,
			builder: () => const AllProductsPage(storeId: '', storeName: '',),
		),
		_NavItem(
			label: 'الشحن',
			iconData: Icons.list_alt,
			builder: () => const ShippingManagementPage(),
		),
		_NavItem(
			label: 'الدفع',
			iconData: Icons.payment,
			builder: () => const PaymentPage(
				amount: '0', // يمكنك تعديل القيم الافتراضية عند التنقل
				userId: '0', orderId: '',
			),
		),
		_NavItem(
			label: 'تسجيل دخول',
			iconData: Icons.login,
			builder: () => const LoginPage(),
		),
		_NavItem(
			label: 'الأقسام',
			iconData: Icons.category,
			builder: () =>  CategoriesScreen(),
		),
		_NavItem(
			label: 'عربة التسوق',
			iconData: Icons.shopping_cart,
			builder: () => const CartPage(userId: '',),
		),
	];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text(
					'الصفحة الرئيسية',
					style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
				),
				centerTitle: true,
				backgroundColor: Colors.blue.shade800,
				elevation: 0,
			),
			body: Container(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [
							Colors.blue.shade50,
							Colors.white,
						],
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
					),
				),
				child: GridView.builder(
					itemCount: _navItems.length,
					gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2,        // عمودين في كل صف
						childAspectRatio: 1,      // نسبة العرض إلى الارتفاع متساوية
						mainAxisSpacing: 16,      // المسافة عمودياً بين العناصر
						crossAxisSpacing: 16,     // المسافة أفقياً بين العناصر
					),
					itemBuilder: (context, index) {
						final item = _navItems[index];
						return _NavCard(
							label: item.label,
							iconData: item.iconData,
							onTap: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (_) => item.builder()),
								);
							},
						);
					},
				),
			),
		);
	}
}

/// نموذج بسيط لحفظ بيانات كل خيار تنقل
class _NavItem {
	final String label;
	final IconData iconData;
	final Widget Function() builder;

	_NavItem({
		required this.label,
		required this.iconData,
		required this.builder,
	});
}

/// بطاقة تحتوي على أيقونة ونص، وعند الضغط تنتقل للشاشة المحدّدة
class _NavCard extends StatelessWidget {
	final String label;
	final IconData iconData;
	final VoidCallback onTap;

	const _NavCard({
		Key? key,
		required this.label,
		required this.iconData,
		required this.onTap,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Card(
			elevation: 6,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			shadowColor: Colors.blue.shade100,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(12),
				splashColor: Colors.blue.shade100,
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								iconData,
								size: 48,
								color: Colors.blue.shade800,
							),
							const SizedBox(height: 12),
							Text(
								label,
								textAlign: TextAlign.center,
								style: const TextStyle(
									fontSize: 16,
									fontWeight: FontWeight.w600,
									color: Colors.black87,
								),
							),
						],
					),
				),
			),
		);
	}
}
