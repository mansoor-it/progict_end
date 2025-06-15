import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For grouping

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

// تعريف الألوان الرئيسية للتطبيق (أبيض وأسود)
class AppColors {
// نظام ألوان متدرج وأنيق
	static const Color primary = Color(0xFF1565C0); // أزرق داكن احترافي
	static const Color primaryLight = Color(0xFF42A5F5); // أزرق فاتح
	static const Color primaryDark = Color(0xFF0D47A1); // أزرق أغمق
	static const Color secondary = Color(0xFFE3F2FD); // أزرق فاتح جداً للخلفيات
	static const Color accent = Color(0xFF00BCD4); // سماوي للعناصر التفاعلية
	static const Color background = Color(0xFFFAFAFA); // خلفية رمادية فاتحة جداً
	static const Color surface = Color(0xFFFFFFFF); // أبيض للبطاقات والأسطح
	static const Color cardBackground = Color(0xFFFFFFFF); // أبيض للبطاقات
	static const Color textPrimary = Color(0xFF212121); // أسود داكن للنصوص الرئيسية
	static const Color textSecondary = Color(0xFF757575); // رمادي متوسط للنصوص الثانوية
	static const Color textHint = Color(0xFFBDBDBD); // رمادي فاتح للنصوص التوضيحية
	static const Color success = Color(0xFF4CAF50); // أخضر للنجاح
	static const Color warning = Color(0xFFFF9800); // برتقالي للتحذير
	static const Color error = Color(0xFFF44336); // أحمر للخطأ
	static const Color divider = Color(0xFFE0E0E0); // رمادي فاتح للفواصل
	static const Color iconColor = Color(0xFF1565C0); // لون الأيقونات أزرق داكن
	static const Color shimmerBase = Color(0xFFE0E0E0); // لون أساسي لتأثير التحميل
	static const Color shimmerHighlight = Color(0xFFF5F5F5); // لون تمييز لتأثير التحميل

// ألوان إضافية للتدرجات والظلال
	static const Color gradientStart = Color(0xFF1976D2); // بداية التدرج
	static const Color gradientEnd = Color(0xFF42A5F5); // نهاية التدرج
	static const Color shadowColor = Color(0x1A000000); // لون الظل // لون التحذيرات
	static const Color info = Color(0xFF1976D2); // لون المعلومات
}

// تعريف أنماط النصوص المستخدمة في التطبيق
class AppTextStyles {
	static const TextStyle heading = TextStyle(
		fontSize: 20,
		fontWeight: FontWeight.bold,
		color: AppColors.textPrimary,
	);

	static const TextStyle subheading = TextStyle(
		fontSize: 16,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
	);

	static const TextStyle body = TextStyle(
		fontSize: 14,
		color: AppColors.textPrimary,
	);

	static const TextStyle caption = TextStyle(
		fontSize: 12,
		color: AppColors.textSecondary,
	);
}

class NavigationHomePage extends StatefulWidget {
	const NavigationHomePage({super.key});

	@override
	State<NavigationHomePage> createState() => _NavigationHomePageState();
}

class _NavigationHomePageState extends State<NavigationHomePage> with SingleTickerProviderStateMixin {
	final List<NavMenuItem> allItems = [
		NavMenuItem(
			label: 'إدارة الألوان',
			icon: Icons.color_lens,
			page: ProductColorsManagementPage(),
			category: 'products',
			color: AppColors.primary,
			description: 'إدارة ألوان المنتجات المتاحة في المتجر.',
		),
		NavMenuItem(
			label: 'إدارة المقاسات',
			icon: Icons.straighten,
			page: ProductSizesManagementPage(),
			category: 'products',
			color: AppColors.primary,
			description: 'إدارة مقاسات المنتجات المتاحة في المتجر.',
		),
		NavMenuItem(
			label: 'إدارة المنتجات',
			icon: Icons.shopping_cart,
			page: ProductsManagementPage(),
			category: 'products',
			color: AppColors.primary,
			description: 'إضافة وتعديل وحذف المنتجات في المتجر.',
		),
		NavMenuItem(
			label: 'إدارة المتجر',
			icon: Icons.store,
			page: StoreManagementPage(),
			category: 'store',
			color: AppColors.primary,
			description: 'إدارة إعدادات المتجر الرئيسية.',
		),
		NavMenuItem(
			label: 'إدارة الأقسام',
			icon: Icons.category,
			page: CategoriesManagementScreen(),
			category: 'store',
			color: AppColors.primary,
			description: 'إدارة أقسام وتصنيفات المنتجات.',
		),
		NavMenuItem(
			label: 'إدارة البائعين',
			icon: Icons.person_outline,
			page: const VendorManagementPage(),
			category: 'users',
			color: AppColors.primary,
			description: 'إدارة حسابات البائعين وصلاحياتهم.',
		),
		NavMenuItem(
			label: 'إدارة العملاء',
			icon: Icons.people,
			page: const UserManagementPage(),
			category: 'users',
			color: AppColors.primary,
			description: 'إدارة حسابات العملاء والمستخدمين.',
		),
		NavMenuItem(
			label: 'إدارة البنرات',
			icon: Icons.image,
			page: const BannerManagementPage(),
			category: 'settings',
			color: AppColors.primary,
			description: 'إدارة البنرات الإعلانية في المتجر.',
		),
		NavMenuItem(
			label: 'الصفحة الرئيسية',
			icon: Icons.home,
			page: const MyHomePage(),
			category: 'settings',
			color: AppColors.primary,
			description: 'العودة إلى الصفحة الرئيسية للتطبيق.',
		),
		NavMenuItem(
			label: 'إدارة الإداريين',
			icon: Icons.admin_panel_settings,
			page: const AdminHomePage(),
			category: 'settings',
			color: AppColors.primary,
			description: 'إدارة حسابات وصلاحيات المشرفين.',
		),
		// الصفحات الجديدة
		NavMenuItem(
			label: 'تفاصيل الشحن',
			icon: Icons.local_shipping,
			page: ShippingDetailsPage(),
			category: 'orders',
			color: AppColors.primary,
			description: 'إدارة تفاصيل وخيارات الشحن المتاحة.',
		),
		NavMenuItem(
			label: 'إدارة المدفوعات',
			icon: Icons.payment,
			page: PaymentsManagementPage(),
			category: 'orders',
			color: AppColors.primary,
			description: 'إدارة طرق الدفع والمعاملات المالية.',
		),
		NavMenuItem(
			label: 'إدارة الطلبات والتفاصيل',
			icon: Icons.list_alt,
			page: OrdersAndDetailsManagementPage(),
			category: 'orders',
			color: AppColors.primary,
			description: 'عرض وإدارة الطلبات وتفاصيلها.',
		),
		NavMenuItem(
			label: 'إدارة الطلبات',
			icon: Icons.shopping_basket,
			page: OrdersManagementPage(),
			category: 'orders',
			color: AppColors.primary,
			description: 'إدارة طلبات العملاء ومتابعة حالتها.',
		),
		NavMenuItem(
			label: 'تفاصيل الطلب',
			icon: Icons.receipt_long,
			page: OrderDetailManagementPage(),
			category: 'orders',
			color: AppColors.primary,
			description: 'عرض تفاصيل الطلبات وإدارتها.',
		),
	];

	List<NavMenuItem> displayedItems = [];
	final ScrollController _scrollController = ScrollController();
	int _viewMode = 0; // 0: شبكي, 1: قائمة, 2: تبويبي

	// إضافة متغير لتتبع التبويب النشط
	int _activeTabIndex = 0;

	// إضافة متغير لتتبع الصفحة المفضلة
	List<String> _favoriteItems = [];

	// إضافة متغير لتتبع آخر الصفحات المزارة
	List<String> _recentItems = [];

	// إضافة متغير للتحكم في الانتقال بين الصفحات
	final PageController _pageController = PageController();

	@override
	void initState() {
		super.initState();
		displayedItems = allItems;

		// استرجاع العناصر المفضلة من التخزين المحلي (يمكن استبدالها بـ SharedPreferences)
		_loadFavorites();

		// استرجاع آخر الصفحات المزارة
		_loadRecentItems();
	}

	@override
	void dispose() {
		_scrollController.dispose();
		_pageController.dispose();
		super.dispose();
	}

	// استرجاع العناصر المفضلة (محاكاة)
	void _loadFavorites() {
		// في التطبيق الحقيقي، يمكن استرجاع هذه القيم من SharedPreferences
		_favoriteItems = ['إدارة المنتجات', 'إدارة الطلبات', 'إدارة البائعين'];
	}

	// استرجاع آخر الصفحات المزارة (محاكاة)
	void _loadRecentItems() {
		// في التطبيق الحقيقي، يمكن استرجاع هذه القيم من SharedPreferences
		_recentItems = ['إدارة المنتجات', 'إدارة المدفوعات', 'إدارة العملاء'];
	}

	// إضافة أو إزالة عنصر من المفضلة
	void _toggleFavorite(String label) {
		setState(() {
			if (_favoriteItems.contains(label)) {
				_favoriteItems.remove(label);
				_showSnackBar('تم إزالة $label من المفضلة', success: false);
			} else {
				_favoriteItems.add(label);
				_showSnackBar('تم إضافة $label إلى المفضلة', success: true);
			}
			// في التطبيق الحقيقي، يمكن حفظ هذه القيم في SharedPreferences
		});
	}

	// إضافة عنصر إلى آخر الصفحات المزارة
	void _addToRecentItems(String label) {
		setState(() {
			// إزالة العنصر إذا كان موجودًا بالفعل
			_recentItems.remove(label);
			// إضافة العنصر في المقدمة
			_recentItems.insert(0, label);
			// الاحتفاظ بآخر 5 عناصر فقط
			if (_recentItems.length > 5) {
				_recentItems = _recentItems.sublist(0, 5);
			}
			// في التطبيق الحقيقي، يمكن حفظ هذه القيم في SharedPreferences
		});
	}

	// عرض رسالة Snackbar
	void _showSnackBar(String message, {bool success = true}) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: success ? AppColors.success : AppColors.error,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
				action: SnackBarAction(
					label: 'إغلاق',
					textColor: AppColors.secondary,
					onPressed: () {
						ScaffoldMessenger.of(context).hideCurrentSnackBar();
					},
				),
			),
		);
	}

	void _filterItems(String query) {
		setState(() {
			displayedItems = allItems
					.where((item) =>
			item.label.toLowerCase().contains(query.toLowerCase()) ||
					item.description.toLowerCase().contains(query.toLowerCase()))
					.toList();
		});
	}

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: 5,
			child: Scaffold(
				appBar: AppBar(
					title: const Text(
						'لوحة التحكم الإدارية',
						style: TextStyle(
							color: AppColors.secondary,
							fontWeight: FontWeight.bold,
						),
					),
					centerTitle: true,
					backgroundColor: AppColors.primary,
					elevation: 4,
					leading: IconButton(
						icon: const Icon(Icons.menu, color: AppColors.secondary),
						onPressed: () {
							_showDrawer(context);
						},
						tooltip: 'القائمة الجانبية',
					),
					actions: [
						IconButton(
							icon: const Icon(Icons.search, color: AppColors.secondary),
							onPressed: () => _showSearchDialog(context),
							tooltip: 'بحث',
						),
						PopupMenuButton<int>(
							icon: const Icon(Icons.view_module, color: AppColors.secondary),
							tooltip: 'تغيير طريقة العرض',
							itemBuilder: (context) => [
								PopupMenuItem(
									value: 0,
									child: Row(
										children: [
											Icon(Icons.grid_view, color: AppColors.primary),
											const SizedBox(width: 8),
											const Text('عرض شبكي'),
										],
									),
								),
								PopupMenuItem(
									value: 1,
									child: Row(
										children: [
											Icon(Icons.list, color: AppColors.primary),
											const SizedBox(width: 8),
											const Text('عرض قائمة'),
										],
									),
								),
								PopupMenuItem(
									value: 2,
									child: Row(
										children: [
											Icon(Icons.tab, color: AppColors.primary),
											const SizedBox(width: 8),
											const Text('عرض تبويبي'),
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
						IconButton(
							icon: const Icon(Icons.help_outline, color: AppColors.secondary),
							onPressed: () {
								_showHelpDialog(context);
							},
							tooltip: 'مساعدة',
						),
					],
					bottom: _viewMode == 2
							? TabBar(
						indicatorColor: AppColors.secondary,
						labelColor: AppColors.secondary,
						unselectedLabelColor: AppColors.secondary.withOpacity(0.7),
						tabs: [
							Tab(text: "المنتجات", icon: Icon(Icons.shopping_bag)),
							Tab(text: "المتجر", icon: Icon(Icons.store)),
							Tab(text: "المستخدمين", icon: Icon(Icons.people)),
							Tab(text: "الطلبات", icon: Icon(Icons.shopping_cart)),
							Tab(text: "الإعدادات", icon: Icon(Icons.settings)),
						],
						onTap: (index) {
							setState(() {
								_activeTabIndex = index;
							});
						},
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
					backgroundColor: AppColors.primary,
					child: const Icon(Icons.arrow_upward, color: AppColors.secondary),
					tooltip: 'العودة للأعلى',
				),
				bottomNavigationBar: _viewMode != 2 ? _buildBottomNavigationBar() : null,
			),
		);
	}

	// إضافة شريط تنقل سفلي
	Widget _buildBottomNavigationBar() {
		return BottomAppBar(
			color: AppColors.primary,
			shape: const CircularNotchedRectangle(),
			notchMargin: 8,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceAround,
				children: [
					IconButton(
						icon: const Icon(Icons.home, color: AppColors.secondary),
						tooltip: 'الرئيسية',
						onPressed: () {
							setState(() {
								_selectedCategory = 'all';
								displayedItems = allItems;
							});
						},
					),
					IconButton(
						icon: const Icon(Icons.favorite, color: AppColors.secondary),
						tooltip: 'المفضلة',
						onPressed: () {
							setState(() {
								displayedItems = allItems.where((item) => _favoriteItems.contains(item.label)).toList();
							});
							_showSnackBar('تم عرض العناصر المفضلة', success: true);
						},
					),
					const SizedBox(width: 48), // مساحة للزر العائم
					IconButton(
						icon: const Icon(Icons.history, color: AppColors.secondary),
						tooltip: 'الأخيرة',
						onPressed: () {
							setState(() {
								displayedItems = allItems.where((item) => _recentItems.contains(item.label)).toList();
							});
							_showSnackBar('تم عرض آخر العناصر المزارة', success: true);
						},
					),
					IconButton(
						icon: const Icon(Icons.settings, color: AppColors.secondary),
						tooltip: 'الإعدادات',
						onPressed: () {
							setState(() {
								_selectedCategory = 'settings';
								displayedItems = allItems.where((item) => item.category == 'settings').toList();
							});
						},
					),
				],
			),
		);
	}

	// إضافة قائمة جانبية
	void _showDrawer(BuildContext context) {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (context) => Container(
				height: MediaQuery.of(context).size.height * 0.85,
				decoration: const BoxDecoration(
					color: AppColors.background,
					borderRadius: BorderRadius.only(
						topLeft: Radius.circular(20),
						topRight: Radius.circular(20),
					),
				),
				child: Column(
					children: [
						Container(
							padding: const EdgeInsets.all(16),
							decoration: const BoxDecoration(
								color: AppColors.primary,
								borderRadius: BorderRadius.only(
									topLeft: Radius.circular(20),
									topRight: Radius.circular(20),
								),
							),
							child: Row(
								children: [
									const CircleAvatar(
										backgroundColor: AppColors.secondary,
										child: Icon(Icons.person, color: AppColors.primary),
									),
									const SizedBox(width: 16),
									const Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'مرحبًا، المدير',
												style: TextStyle(
													color: AppColors.secondary,
													fontWeight: FontWeight.bold,
													fontSize: 16,
												),
											),
											Text(
												'admin@example.com',
												style: TextStyle(
													color: AppColors.secondary,
													fontSize: 12,
												),
											),
										],
									),
									const Spacer(),
									IconButton(
										icon: const Icon(Icons.close, color: AppColors.secondary),
										onPressed: () {
											Navigator.pop(context);
										},
									),
								],
							),
						),
						Expanded(
							child: ListView(
								padding: const EdgeInsets.all(16),
								children: [
									const Text(
										'الإحصائيات',
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 18,
										),
									),
									const SizedBox(height: 8),
									_buildStatisticsSection(),
									const Divider(),
									const Text(
										'الفئات',
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 18,
										),
									),
									const SizedBox(height: 8),
									_buildDrawerItem('الكل', 'all', Icons.apps),
									_buildDrawerItem('المنتجات', 'products', Icons.shopping_bag),
									_buildDrawerItem('المتجر', 'store', Icons.store),
									_buildDrawerItem('المستخدمين', 'users', Icons.people),
									_buildDrawerItem('الطلبات', 'orders', Icons.shopping_cart),
									_buildDrawerItem('الإعدادات', 'settings', Icons.settings),
									const Divider(),
									const Text(
										'المفضلة',
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 18,
										),
									),
									const SizedBox(height: 8),
									if (_favoriteItems.isEmpty)
										const Padding(
											padding: EdgeInsets.all(8.0),
											child: Text(
												'لا توجد عناصر مفضلة',
												style: TextStyle(
													color: AppColors.textSecondary,
													fontStyle: FontStyle.italic,
												),
											),
										)
									else
										..._favoriteItems.map((label) {
											final item = allItems.firstWhere((item) => item.label == label);
											return ListTile(
												leading: Icon(item.icon, color: AppColors.primary),
												title: Text(item.label),
												onTap: () {
													Navigator.pop(context);
													_navigateTo(item.page);
													_addToRecentItems(item.label);
												},
											);
										}).toList(),
									const Divider(),
									const Text(
										'آخر الزيارات',
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 18,
										),
									),
									const SizedBox(height: 8),
									if (_recentItems.isEmpty)
										const Padding(
											padding: EdgeInsets.all(8.0),
											child: Text(
												'لا توجد زيارات حديثة',
												style: TextStyle(
													color: AppColors.textSecondary,
													fontStyle: FontStyle.italic,
												),
											),
										)
									else
										..._recentItems.map((label) {
											final item = allItems.firstWhere((item) => item.label == label);
											return ListTile(
												leading: Icon(item.icon, color: AppColors.primary),
												title: Text(item.label),
												trailing: Text(
													'منذ قليل',
													style: TextStyle(
														color: AppColors.textSecondary,
														fontSize: 12,
													),
												),
												onTap: () {
													Navigator.pop(context);
													_navigateTo(item.page);
													_addToRecentItems(item.label);
												},
											);
										}).toList(),
								],
							),
						),
						Container(
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: AppColors.cardBackground,
								border: Border(
									top: BorderSide(color: AppColors.divider),
								),
							),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceAround,
								children: [
									TextButton.icon(
										icon: const Icon(Icons.logout),
										label: const Text('تسجيل الخروج'),
										style: TextButton.styleFrom(
											foregroundColor: AppColors.error,
										),
										onPressed: () {
											Navigator.pop(context);
											_showSnackBar('تم تسجيل الخروج', success: false);
										},
									),
									TextButton.icon(
										icon: const Icon(Icons.help),
										label: const Text('مساعدة'),
										style: TextButton.styleFrom(
											foregroundColor: AppColors.primary,
										),
										onPressed: () {
											Navigator.pop(context);
											_showHelpDialog(context);
										},
									),
								],
							),
						),
					],
				),
			),
		);
	}

	// بناء قسم الإحصائيات
	Widget _buildStatisticsSection() {
		final groupedItems = groupBy(allItems, (NavMenuItem item) => item.category);

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_buildStatisticItem('إجمالي العناصر', allItems.length, Icons.all_inclusive, AppColors.primary),
				_buildStatisticItem('المنتجات', groupedItems['products']?.length ?? 0, Icons.shopping_bag, AppColors.info),
				_buildStatisticItem('المتجر', groupedItems['store']?.length ?? 0, Icons.store, AppColors.success),
				_buildStatisticItem('المستخدمين', groupedItems['users']?.length ?? 0, Icons.people, AppColors.warning),
				_buildStatisticItem('الطلبات', groupedItems['orders']?.length ?? 0, Icons.shopping_cart, AppColors.error),
				_buildStatisticItem('الإعدادات', groupedItems['settings']?.length ?? 0, Icons.settings, AppColors.textSecondary),
			],
		);
	}

	// بناء عنصر إحصائي
	Widget _buildStatisticItem(String title, int count, IconData icon, Color color) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4.0),
			child: Row(
				children: [
					Icon(icon, color: color, size: 20),
					const SizedBox(width: 8),
					Text(
						'$title: ',
						style: const TextStyle(
							fontWeight: FontWeight.bold,
						),
					),
					Text(
						'$count',
						style: TextStyle(
							color: color,
							fontWeight: FontWeight.bold,
						),
					),
				],
			),
		);
	}

	// بناء عنصر في القائمة الجانبية
	Widget _buildDrawerItem(String title, String category, IconData icon) {
		bool isSelected = _selectedCategory == category;

		return ListTile(
			leading: Icon(
				icon,
				color: isSelected ? AppColors.primary : AppColors.textSecondary,
			),
			title: Text(
				title,
				style: TextStyle(
					color: isSelected ? AppColors.primary : AppColors.textPrimary,
					fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
				),
			),
			selected: isSelected,
			onTap: () {
				Navigator.pop(context);
				setState(() {
					_selectedCategory = category;
					if (category == 'all') {
						displayedItems = allItems;
					} else {
						displayedItems = allItems.where((item) => item.category == category).toList();
					}
				});
			},
		);
	}

	// إضافة نافذة مساعدة
	void _showHelpDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => Dialog(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20),
				),
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Text(
								'مساعدة',
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 16),
							const Text(
								'لوحة التحكم الإدارية تتيح لك إدارة جميع جوانب المتجر الإلكتروني بسهولة.',
								textAlign: TextAlign.center,
							),
							const SizedBox(height: 16),
							const Text(
								'طرق العرض المتاحة:',
								style: TextStyle(
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 8),
							_buildHelpItem(Icons.grid_view, 'عرض شبكي', 'عرض العناصر في شكل شبكة.'),
							_buildHelpItem(Icons.list, 'عرض قائمة', 'عرض العناصر في شكل قائمة.'),
							_buildHelpItem(Icons.tab, 'عرض تبويبي', 'عرض العناصر مقسمة حسب الفئات.'),
							const SizedBox(height: 16),
							const Text(
								'الميزات المتاحة:',
								style: TextStyle(
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 8),
							_buildHelpItem(Icons.favorite, 'المفضلة', 'إضافة العناصر المهمة إلى المفضلة للوصول السريع.'),
							_buildHelpItem(Icons.history, 'آخر الزيارات', 'عرض آخر العناصر التي تمت زيارتها.'),
							_buildHelpItem(Icons.search, 'البحث', 'البحث عن العناصر بالاسم أو الوصف.'),
							const SizedBox(height: 16),
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.primary,
									foregroundColor: AppColors.secondary,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
								),
								onPressed: () {
									Navigator.pop(context);
								},
								child: const Text('فهمت'),
							),
						],
					),
				),
			),
		);
	}

	// بناء عنصر في نافذة المساعدة
	Widget _buildHelpItem(IconData icon, String title, String description) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4),
			child: Row(
				children: [
					Icon(icon, color: AppColors.primary, size: 20),
					const SizedBox(width: 8),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									title,
									style: const TextStyle(
										fontWeight: FontWeight.bold,
									),
								),
								Text(
									description,
									style: const TextStyle(
										fontSize: 12,
										color: AppColors.textSecondary,
									),
								),
							],
						),
					),
				],
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
				_buildCategoryView('orders'),
				_buildCategoryView('settings'),
			],
		);
	}

	Widget _buildCategoryView(String category) {
		final items = displayedItems.where((item) => item.category == category).toList();

		if (items.isEmpty) {
			return Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.search_off,
							size: 64,
							color: AppColors.textSecondary,
						),
						const SizedBox(height: 16),
						Text(
							'لا توجد عناصر في هذه الفئة',
							style: TextStyle(
								fontSize: 18,
								color: AppColors.textSecondary,
							),
						),
						const SizedBox(height: 24),
						ElevatedButton.icon(
							icon: const Icon(Icons.refresh),
							label: const Text('عرض الكل'),
							style: ElevatedButton.styleFrom(
								backgroundColor: AppColors.primary,
								foregroundColor: AppColors.secondary,
							),
							onPressed: () {
								setState(() {
									displayedItems = allItems;
								});
							},
						),
					],
				),
			);
		}

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
			color: AppColors.background,
			child: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					children: [
						// شريط البحث
						TextField(
							onChanged: _filterItems,
							decoration: InputDecoration(
								hintText: "ابحث هنا...",
								prefixIcon: Icon(Icons.search, color: AppColors.primary),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(30),
									borderSide: BorderSide(color: AppColors.primary),
								),
								focusedBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(30),
									borderSide: BorderSide(color: AppColors.primary, width: 2),
								),
								filled: true,
								fillColor: AppColors.cardBackground,
								suffixIcon: displayedItems.length != allItems.length
										? IconButton(
									icon: Icon(Icons.close, color: AppColors.primary),
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

						// عرض الفئات
						SizedBox(
							height: 50,
							child: ListView(
								scrollDirection: Axis.horizontal,
								children: [
									_buildCategoryChip('الكل', 'all'),
									_buildCategoryChip('المنتجات', 'products'),
									_buildCategoryChip('المتجر', 'store'),
									_buildCategoryChip('المستخدمين', 'users'),
									_buildCategoryChip('الطلبات', 'orders'),
									_buildCategoryChip('الإعدادات', 'settings'),
								],
							),
						),
						const SizedBox(height: 20),

						// العرض الشبكي
						Expanded(
							child: displayedItems.isEmpty
									? Center(
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(
											Icons.search_off,
											size: 64,
											color: AppColors.textSecondary,
										),
										const SizedBox(height: 16),
										Text(
											'لا توجد نتائج مطابقة للبحث',
											style: TextStyle(
												fontSize: 18,
												color: AppColors.textSecondary,
											),
										),
										const SizedBox(height: 24),
										ElevatedButton.icon(
											icon: const Icon(Icons.refresh),
											label: const Text('عرض الكل'),
											style: ElevatedButton.styleFrom(
												backgroundColor: AppColors.primary,
												foregroundColor: AppColors.secondary,
											),
											onPressed: () {
												setState(() {
													displayedItems = allItems;
												});
											},
										),
									],
								),
							)
									: GridView.builder(
								controller: _scrollController,
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 2,
									crossAxisSpacing: 15,
									mainAxisSpacing: 15,
									childAspectRatio: 1.0, // تعديل النسبة لتناسب المحتوى
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

	// فلتر الفئات
	String _selectedCategory = 'all';

	Widget _buildCategoryChip(String label, String category) {
		bool isSelected = _selectedCategory == category;

		return Padding(
			padding: const EdgeInsets.only(right: 8.0),
			child: FilterChip(
				label: Text(
					label,
					style: TextStyle(
						color: isSelected ? AppColors.secondary : AppColors.textPrimary,
						fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
					),
				),
				selected: isSelected,
				onSelected: (selected) {
					setState(() {
						_selectedCategory = category;
						if (category == 'all') {
							displayedItems = allItems;
						} else {
							displayedItems = allItems.where((item) => item.category == category).toList();
						}
					});
				},
				backgroundColor: AppColors.cardBackground,
				selectedColor: AppColors.primary,
				checkmarkColor: AppColors.secondary,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20),
					side: BorderSide(
						color: isSelected ? AppColors.primary : AppColors.divider,
					),
				),
				showCheckmark: false,
				avatar: isSelected ? const Icon(Icons.check, color: AppColors.secondary, size: 16) : null,
			),
		);
	}

	Widget _buildListView() {
		return Container(
			color: AppColors.background,
			child: CustomScrollView(
				controller: _scrollController,
				slivers: [
					SliverPadding(
						padding: const EdgeInsets.all(16),
						sliver: SliverToBoxAdapter(
							child: Column(
								children: [
									TextField(
										onChanged: _filterItems,
										decoration: InputDecoration(
											hintText: "ابحث هنا...",
											prefixIcon: Icon(Icons.search, color: AppColors.primary),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(30),
												borderSide: BorderSide(color: AppColors.primary),
											),
											focusedBorder: OutlineInputBorder(
												borderRadius: BorderRadius.circular(30),
												borderSide: BorderSide(color: AppColors.primary, width: 2),
											),
											filled: true,
											fillColor: AppColors.cardBackground,
											suffixIcon: displayedItems.length != allItems.length
													? IconButton(
												icon: Icon(Icons.close, color: AppColors.primary),
												onPressed: () {
													setState(() {
														displayedItems = allItems;
													});
												},
											)
													: null,
										),
									),
									const SizedBox(height: 16),
									SizedBox(
										height: 50,
										child: ListView(
											scrollDirection: Axis.horizontal,
											children: [
												_buildCategoryChip('الكل', 'all'),
												_buildCategoryChip('المنتجات', 'products'),
												_buildCategoryChip('المتجر', 'store'),
												_buildCategoryChip('المستخدمين', 'users'),
												_buildCategoryChip('الطلبات', 'orders'),
												_buildCategoryChip('الإعدادات', 'settings'),
											],
										),
									),
								],
							),
						),
					),
					displayedItems.isEmpty
							? SliverFillRemaining(
						child: Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(
										Icons.search_off,
										size: 64,
										color: AppColors.textSecondary,
									),
									const SizedBox(height: 16),
									Text(
										'لا توجد نتائج مطابقة للبحث',
										style: TextStyle(
											fontSize: 18,
											color: AppColors.textSecondary,
										),
									),
									const SizedBox(height: 24),
									ElevatedButton.icon(
										icon: const Icon(Icons.refresh),
										label: const Text('عرض الكل'),
										style: ElevatedButton.styleFrom(
											backgroundColor: AppColors.primary,
											foregroundColor: AppColors.secondary,
										),
										onPressed: () {
											setState(() {
												displayedItems = allItems;
											});
										},
									),
								],
							),
						),
					)
							: SliverPadding(
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
		bool isFavorite = _favoriteItems.contains(item.label);

		return InkWell(
			onTap: () => _navigateTo(item.page),
			borderRadius: BorderRadius.circular(15),
			child: Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(15),
					color: AppColors.primary,
					boxShadow: [
						BoxShadow(
							color: Colors.black.withOpacity(0.1),
							blurRadius: 10,
							offset: const Offset(0, 5),
						),
					],
				),
				child: Stack(
					children: [
						// المحتوى الرئيسي
						Padding(
							padding: const EdgeInsets.all(16.0),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(item.icon, size: 40, color: AppColors.secondary),
									const SizedBox(height: 10),
									Text(
										item.label,
										textAlign: TextAlign.center,
										style: const TextStyle(
											color: AppColors.secondary,
											fontSize: 16,
											fontWeight: FontWeight.bold,
										),
									),
									const SizedBox(height: 5),
									Container(
										padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
										decoration: BoxDecoration(
											color: AppColors.secondary.withOpacity(0.2),
											borderRadius: BorderRadius.circular(10),
										),
										child: Text(
											_getCategoryName(item.category),
											style: TextStyle(
												color: AppColors.secondary,
												fontSize: 12,
											),
										),
									),
									const SizedBox(height: 8),
									Text(
										item.description,
										textAlign: TextAlign.center,
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
										style: TextStyle(
											color: AppColors.secondary.withOpacity(0.8),
											fontSize: 12,
										),
									),
								],
							),
						),

						// زر المفضلة
						Positioned(
							top: 8,
							right: 8,
							child: InkWell(
								onTap: () {
									_toggleFavorite(item.label);
								},
								child: Container(
									padding: const EdgeInsets.all(4),
									decoration: BoxDecoration(
										color: AppColors.secondary.withOpacity(0.2),
										shape: BoxShape.circle,
									),
									child: Icon(
										isFavorite ? Icons.favorite : Icons.favorite_border,
										color: isFavorite ? Colors.red : AppColors.secondary,
										size: 20,
									),
								),
							),
						),
					],
				),
			),
		);
	}

	String _getCategoryName(String category) {
		switch (category) {
			case 'products':
				return 'المنتجات';
			case 'store':
				return 'المتجر';
			case 'users':
				return 'المستخدمين';
			case 'orders':
				return 'الطلبات';
			case 'settings':
				return 'الإعدادات';
			default:
				return '';
		}
	}

	Widget _buildCardItem(NavMenuItem item) {
		bool isFavorite = _favoriteItems.contains(item.label);

		return Card(
			elevation: 2,
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
						color: AppColors.cardBackground,
					),
					child: Padding(
						padding: const EdgeInsets.all(16.0),
						child: Row(
							children: [
								Container(
									padding: const EdgeInsets.all(12),
									decoration: BoxDecoration(
										color: AppColors.primary,
										shape: BoxShape.circle,
									),
									child: Icon(item.icon, color: AppColors.secondary),
								),
								const SizedBox(width: 16),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												item.label,
												style: TextStyle(
													fontSize: 18,
													color: AppColors.textPrimary,
													fontWeight: FontWeight.bold,
												),
											),
											const SizedBox(height: 4),
											Row(
												children: [
													Container(
														padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
														decoration: BoxDecoration(
															color: AppColors.primary,
															borderRadius: BorderRadius.circular(10),
														),
														child: Text(
															_getCategoryName(item.category),
															style: TextStyle(
																color: AppColors.secondary,
																fontSize: 12,
															),
														),
													),
													const SizedBox(width: 8),
													Expanded(
														child: Text(
															item.description,
															maxLines: 1,
															overflow: TextOverflow.ellipsis,
															style: TextStyle(
																fontSize: 14,
																color: AppColors.textSecondary,
															),
														),
													),
												],
											),
										],
									),
								),
								IconButton(
									icon: Icon(
										isFavorite ? Icons.favorite : Icons.favorite_border,
										color: isFavorite ? Colors.red : AppColors.textSecondary,
									),
									tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
									onPressed: () {
										_toggleFavorite(item.label);
									},
								),
								Icon(Icons.chevron_left, color: AppColors.primary),
							],
						),
					),
				),
			),
		);
	}

	void _navigateTo(Widget page) {
		// إضافة العنصر إلى آخر الزيارات
		final item = displayedItems.firstWhere((item) => item.page == page, orElse: () => allItems.firstWhere((item) => item.page == page));
		_addToRecentItems(item.label);

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
				backgroundColor: AppColors.background,
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Text(
								"بحث في لوحة التحكم",
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.bold,
									color: AppColors.textPrimary,
								),
							),
							const SizedBox(height: 16),
							TextField(
								onChanged: (value) {
									_filterItems(value);
									if (value.isEmpty) {
										setState(() {
											displayedItems = allItems;
										});
									}
								},
								autofocus: true,
								decoration: InputDecoration(
									hintText: "اكتب للبحث...",
									prefixIcon: Icon(Icons.search, color: AppColors.primary),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(15),
										borderSide: BorderSide(color: AppColors.primary),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(15),
										borderSide: BorderSide(color: AppColors.primary, width: 2),
									),
								),
							),
							const SizedBox(height: 16),
							const Text(
								"يمكنك البحث بالاسم أو الوصف",
								style: TextStyle(
									color: AppColors.textSecondary,
									fontSize: 12,
								),
							),
							const SizedBox(height: 16),
							Row(
								mainAxisAlignment: MainAxisAlignment.end,
								children: [
									TextButton(
										onPressed: () => Navigator.of(context).pop(),
										style: TextButton.styleFrom(
											foregroundColor: AppColors.primary,
										),
										child: const Text("إغلاق"),
									),
									const SizedBox(width: 8),
									ElevatedButton(
										onPressed: () {
											Navigator.of(context).pop();
										},
										style: ElevatedButton.styleFrom(
											backgroundColor: AppColors.primary,
											foregroundColor: AppColors.secondary,
										),
										child: const Text("بحث"),
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
	final String description;

	const NavMenuItem({
		required this.label,
		required this.icon,
		required this.page,
		required this.category,
		required this.color,
		this.description = '',
	});
}


