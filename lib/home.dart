import 'package:flutter/material.dart';

// استيراد الصفحات
import 'controll/CategoryManagementPage.dart';
import 'controll/OrderDetailsManagementPage.dart';
import 'controll/ProductColorsManagementPage.dart';
import 'controll/ProductSizesManagementPage.dart';
import 'controll/ProductsPage.dart';
import 'controll/ShippingManagementPage.dart';
import 'controll/StoreManagementPage.dart';
import 'controll/admin_control.dart';
import 'controll/aimg.dart';
import 'controll/banners_control.dart';
import 'controll/orders_management_page.dart';
import 'controll/user_control.dart';
import 'controll/vendors_control.dart';

// استيراد الصفحات الجديدة

import 'controll/PaymentsManagementPage.dart';
import 'controll/OrdersAndDetailsManagementPage.dart';



class NavigationHomePage extends StatefulWidget {
	const NavigationHomePage({super.key});

	@override
	State<NavigationHomePage> createState() => _NavigationHomePageState();
}

class _NavigationHomePageState extends State<NavigationHomePage> {
	final List<NavMenuItem> allItems = [
		NavMenuItem(
			label: 'إدارة الألوان',
			icon: Icons.color_lens,
			page: ProductColorsManagementPage(),
			category: 'products',
			color: Colors.purple,
		),
		NavMenuItem(
			label: 'إدارة المقاسات',
			icon: Icons.straighten,
			page: ProductSizesManagementPage(),
			category: 'products',
			color: Colors.blue,
		),
		NavMenuItem(
			label: 'إدارة المنتجات',
			icon: Icons.shopping_cart,
			page: ProductsManagementPage(),
			category: 'products',
			color: Colors.green,
		),
		NavMenuItem(
			label: 'إدارة المتجر',
			icon: Icons.store,
			page: StoreManagementPage(),
			category: 'store',
			color: Colors.orange,
		),
		NavMenuItem(
			label: 'إدارة الأقسام',
			icon: Icons.category,
			page: CategoriesManagementScreen(),
			category: 'store',
			color: Colors.red,
		),
		NavMenuItem(
			label: 'إدارة البائعين',
			icon: Icons.person_outline,
			page: const VendorManagementPage(),
			category: 'users',
			color: Colors.teal,
		),
		NavMenuItem(
			label: 'إدارة العملاء',
			icon: Icons.people,
			page: const UserManagementPage(),
			category: 'users',
			color: Colors.cyan,
		),
		NavMenuItem(
			label: 'إدارة البنرات',
			icon: Icons.image,
			page: const BannerManagementPage(),
			category: 'settings',
			color: Colors.indigo,
		),
		NavMenuItem(
			label: 'الصفحة الرئيسية',
			icon: Icons.home,
			page: const MyHomePage(),
			category: 'settings',
			color: Colors.deepOrange,
		),
		NavMenuItem(
			label: 'إدارة الإداريين',
			icon: Icons.admin_panel_settings,
			page: const AdminHomePage(),
			category: 'settings',
			color: Colors.blueGrey,
		),
		// الصفحات الجديدة
		NavMenuItem(
			label: 'تفاصيل الشحن',
			icon: Icons.local_shipping,
			page: ShippingDetailsPage(),
			category: 'orders',
			color: Colors.brown,
		),
		NavMenuItem(
			label: 'إدارة المدفوعات',
			icon: Icons.payment,
			page: PaymentsManagementPage(),
			category: 'orders',
			color: Colors.deepPurple,
		),
		NavMenuItem(
			label: 'إدارة الطلبات والتفاصيل',
			icon: Icons.list_alt,
			page: OrdersAndDetailsManagementPage(),
			category: 'orders',
			color: Colors.amber,
		),
		NavMenuItem(
			label: 'إدارة الطلبات',
			icon: Icons.shopping_basket,
			page: OrdersManagementPage(),
			category: 'orders',
			color: Colors.lightBlue,
		),
		NavMenuItem(
			label: 'تفاصيل الطلب',
			icon: Icons.receipt_long,
			page: OrderDetailManagementPage(),
			category: 'orders',
			color: Colors.pink,
		),
	];

	List<NavMenuItem> displayedItems = [];
	final ScrollController _scrollController = ScrollController();
	int _viewMode = 0; // 0: شبكي, 1: قائمة, 2: تبويبي

	@override
	void initState() {
		super.initState();
		displayedItems = allItems;
	}

	void _filterItems(String query) {
		setState(() {
			displayedItems = allItems
					.where((item) => item.label.toLowerCase().contains(query.toLowerCase()))
					.toList();
		});
	}

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: 5, // تم زيادة طول التبويب
			child: Scaffold(
				appBar: AppBar(
					title: const Text('لوحة التحكم الإدارية'),
					centerTitle: true,
					flexibleSpace: Container(
						decoration: BoxDecoration(
							gradient: LinearGradient(
								colors: [Colors.blue.shade800, Colors.blue.shade600],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
						),
					),
					elevation: 10,
					shadowColor: Colors.blue.withOpacity(0.5),
					actions: [
						IconButton(
							icon: const Icon(Icons.search),
							onPressed: () => _showSearchDialog(context),
							tooltip: 'بحث',
						),
						PopupMenuButton<int>(
							icon: const Icon(Icons.view_module),
							itemBuilder: (context) => [
								const PopupMenuItem(
									value: 0,
									child: Row(
										children: [
											Icon(Icons.grid_view, color: Colors.blue),
											SizedBox(width: 8),
											Text('عرض شبكي'),
										],
									),
								),
								const PopupMenuItem(
									value: 1,
									child: Row(
										children: [
											Icon(Icons.list, color: Colors.blue),
											SizedBox(width: 8),
											Text('عرض قائمة'),
										],
									),
								),
								const PopupMenuItem(
									value: 2,
									child: Row(
										children: [
											Icon(Icons.tab, color: Colors.blue),
											SizedBox(width: 8),
											Text('عرض تبويبي'),
										],
									),
								),
							],
							onSelected: (value) {
								setState(() {
									_viewMode = value;
								});
							},
						),
					],
					bottom: _viewMode == 2
							? TabBar(
						tabs: [
							Tab(text: "المنتجات", icon: Icon(Icons.shopping_bag)),
							Tab(text: "المتجر", icon: Icon(Icons.store)),
							Tab(text: "المستخدمين", icon: Icon(Icons.people)),
							Tab(text: "الطلبات", icon: Icon(Icons.shopping_cart)), // تبويب جديد
							Tab(text: "الإعدادات", icon: Icon(Icons.settings)),
						],
					)
							: null,
				),
				body: _buildBody(),
				floatingActionButton: FloatingActionButton(
					onPressed: () => _scrollController.animateTo(
						0,
						duration: const Duration(milliseconds: 500),
						curve: Curves.easeInOut,
					),
					backgroundColor: Colors.blue,
					child: const Icon(Icons.arrow_upward, color: Colors.white),
					tooltip: 'العودة للأعلى',
				),
			),
		);
	}

	Widget _buildBody() {
		switch (_viewMode) {
			case 0:
				return _buildGridView();
			case 1:
				return _buildListView();
			case 2:
				return _buildTabView();
			default:
				return _buildGridView();
		}
	}

	Widget _buildTabView() {
		return TabBarView(
			children: [
				_buildCategoryView('products'),
				_buildCategoryView('store'),
				_buildCategoryView('users'),
				_buildCategoryView('orders'), // تبويب الطلبات الجديد
				_buildCategoryView('settings'),
			],
		);
	}

	Widget _buildCategoryView(String category) {
		final items = displayedItems.where((item) => item.category == category).toList();

		return ListView.builder(
			controller: _scrollController,
			padding: const EdgeInsets.all(16),
			itemCount: items.length,
			itemBuilder: (context, index) {
				final item = items[index];
				return _buildCardItem(item);
			},
		);
	}

	Widget _buildGridView() {
		return Container(
			decoration: BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topCenter,
					end: Alignment.bottomCenter,
					colors: [Colors.blue.shade50, Colors.white],
				),
			),
			child: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					children: [
						// شريط البحث
						TextField(
							onChanged: _filterItems,
							decoration: InputDecoration(
								hintText: "ابحث هنا...",
								prefixIcon: const Icon(Icons.search),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(30),
									borderSide: BorderSide.none,
								),
								filled: true,
								fillColor: Colors.white,
								suffixIcon: displayedItems.length != allItems.length
										? IconButton(
									icon: const Icon(Icons.close),
									onPressed: () {
										setState(() {
											displayedItems = allItems;
										});
									},
								)
										: null,
							),
						),
						const SizedBox(height: 20),

						// العرض الشبكي
						Expanded(
							child: GridView.builder(
								controller: _scrollController,
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 2,
									crossAxisSpacing: 15,
									mainAxisSpacing: 15,
									childAspectRatio: 1.2,
								),
								itemCount: displayedItems.length,
								itemBuilder: (context, index) {
									final item = displayedItems[index];
									return _buildGridItem(item);
								},
							),
						),
					],
				),
			),
		);
	}

	Widget _buildListView() {
		return Container(
			decoration: BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topCenter,
					end: Alignment.bottomCenter,
					colors: [Colors.blue.shade50, Colors.white],
				),
			),
			child: CustomScrollView(
				controller: _scrollController,
				slivers: [
					SliverPadding(
						padding: const EdgeInsets.all(16),
						sliver: SliverToBoxAdapter(
							child: TextField(
								onChanged: _filterItems,
								decoration: InputDecoration(
									hintText: "ابحث هنا...",
									prefixIcon: const Icon(Icons.search),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(30),
										borderSide: BorderSide.none,
									),
									filled: true,
									fillColor: Colors.white,
								),
							),
						),
					),
					SliverPadding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						sliver: SliverList(
							delegate: SliverChildBuilderDelegate(
										(context, index) {
									final item = displayedItems[index];
									return _buildCardItem(item);
								},
								childCount: displayedItems.length,
							),
						),
					),
				],
			),
		);
	}

	Widget _buildGridItem(NavMenuItem item) {
		return InkWell(
			onTap: () => _navigateTo(item.page),
			borderRadius: BorderRadius.circular(15),
			child: Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(15),
					color: item.color.withOpacity(0.8),
					boxShadow: [
						BoxShadow(
							color: Colors.black.withOpacity(0.1),
							blurRadius: 10,
							offset: const Offset(0, 5),
						),
					],
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(item.icon, size: 40, color: Colors.white),
						const SizedBox(height: 10),
						Text(
							item.label,
							textAlign: TextAlign.center,
							style: const TextStyle(
								color: Colors.white,
								fontSize: 16,
								fontWeight: FontWeight.bold,
							),
						),
					],
				),
			),
		);
	}

	Widget _buildCardItem(NavMenuItem item) {
		return Card(
			elevation: 4,
			margin: const EdgeInsets.symmetric(vertical: 8),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(15),
			),
			child: InkWell(
				onTap: () => _navigateTo(item.page),
				borderRadius: BorderRadius.circular(15),
				child: Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(15),
						gradient: LinearGradient(
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
							colors: [
								item.color.withOpacity(0.8),
								item.color.withOpacity(0.6),
							],
						),
					),
					child: Padding(
						padding: const EdgeInsets.all(16.0),
						child: Row(
							children: [
								Container(
									padding: const EdgeInsets.all(12),
									decoration: BoxDecoration(
										color: Colors.white.withOpacity(0.2),
										shape: BoxShape.circle,
									),
									child: Icon(item.icon, color: Colors.white),
								),
								const SizedBox(width: 16),
								Expanded(
									child: Text(
										item.label,
										style: const TextStyle(
											fontSize: 18,
											color: Colors.white,
											fontWeight: FontWeight.bold,
										),
									),
								),
								const Icon(Icons.chevron_left, color: Colors.white),
							],
						),
					),
				),
			),
		);
	}

	void _navigateTo(Widget page) {
		Navigator.push(
			context,
			PageRouteBuilder(
				transitionDuration: const Duration(milliseconds: 500),
				pageBuilder: (_, __, ___) => page,
				transitionsBuilder: (_, animation, __, child) {
					return FadeTransition(
						opacity: animation,
						child: child,
					);
				},
			),
		);
	}

	void _showSearchDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => Dialog(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20),
				),
				elevation: 10,
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Text(
								"بحث في لوحة التحكم",
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 16),
							TextField(
								onChanged: _filterItems,
								autofocus: true,
								decoration: InputDecoration(
									hintText: "اكتب للبحث...",
									prefixIcon: const Icon(Icons.search),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(15),
									),
								),
							),
							const SizedBox(height: 16),
							Row(
								mainAxisAlignment: MainAxisAlignment.end,
								children: [
									TextButton(
										onPressed: () => Navigator.of(context).pop(),
										child: const Text("إغلاق"),
									),
								],
							),
						],
					),
				),
			),
		);
	}
}

class NavMenuItem {
	final String label;
	final IconData icon;
	final Widget page;
	final String category;
	final Color color;

	const NavMenuItem({
		required this.label,
		required this.icon,
		required this.page,
		required this.category,
		required this.color,
	});
}