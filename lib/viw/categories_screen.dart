import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/category_model.dart';
import '../service/category_service.dart';
import '../model/user_model.dart'; // <-- إضافة استيراد لنموذج المستخدم
import 'login.dart';
import 'stores_screen.dart';

// --- تعديل هنا: استقبال المستخدم ---
class CategoriesScreen extends StatefulWidget {
	final User user; // <-- إضافة متغير لاستقبال المستخدم

	const CategoriesScreen({Key? key, required this.user}) : super(key: key); // <-- تعديل المنشئ

	@override
	_CategoriesScreenState createState() => _CategoriesScreenState();
}

enum DisplayType { grid, list, horizontal }

class _CategoriesScreenState extends State<CategoriesScreen> {
	List<Category> categories = [];
	bool isLoading = false;
	final CategoryController _controller = CategoryController();
	DisplayType _displayType = DisplayType.grid;

	@override
	void initState() {
		super.initState();
		fetchCategories();
	}

	Future<void> fetchCategories() async {
		if (!mounted) return;
		setState(() => isLoading = true);
		try {
			final fetched = await _controller.fetchCategories();
			if (mounted) {
				setState(() {
					categories = fetched;
					isLoading = false;
				});
			}
		} catch (e) {
			if (mounted) {
				setState(() => isLoading = false);
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('❌ خطأ في جلب الأقسام: ${e.toString()}')),
				);
			}
		}
	}

	Future<void> _logout(BuildContext context) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.clear(); // مسح جميع بيانات الجلسة
		if (!mounted) return;
		Navigator.pushAndRemoveUntil(
			context,
			MaterialPageRoute(builder: (context) => LoginPage()),
					(Route<dynamic> route) => false,
		);
	}

	// --- تعديل هنا: تمرير المستخدم ---
	void _navigateToStores(Category category) {
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => StoresScreen(
					categoryId: category.id,
					categoryName: category.name,
					user: widget.user, // <-- تمرير المستخدم هنا
				),
			),
		);
	}

	Widget _buildCategoryCard(Category category) {
		return GestureDetector(
			onTap: () => _navigateToStores(category), // <-- استخدام الدالة المساعدة
			child: Card(
				elevation: 6, // Reduced elevation for a subtle look
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				margin: EdgeInsets.zero,
				clipBehavior: Clip.antiAlias,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							flex: 3, // Give more space to the image
							child: Container(
								color: Colors.grey[200], // Placeholder color
								child: category.image.isNotEmpty
										? Image.memory(
									base64Decode(category.image.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '')), // Clean base64 string
									fit: BoxFit.cover,
									errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
								)
										: Icon(Icons.category_outlined, size: 50, color: Colors.grey.shade500),
							),
						),
						Padding(
							padding: const EdgeInsets.all(10.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										category.name,
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 16,
											color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
									SizedBox(height: 4),
									Text(
										category.description,
										style: TextStyle(
											fontSize: 13,
											color: Colors.grey[600],
										),
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
									),
								],
							),
						),
					],
				),
			),
		);
	}

	Widget _buildGridView() {
		return GridView.builder(
			padding: const EdgeInsets.all(16),
			itemCount: categories.length,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: (MediaQuery.of(context).size.width / 180).floor().clamp(2, 4), // Responsive grid count
				crossAxisSpacing: 16,
				mainAxisSpacing: 16,
				childAspectRatio: 0.85, // Adjust aspect ratio for better look
			),
			itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
		);
	}

	Widget _buildListView() {
		return ListView.separated(
			padding: const EdgeInsets.all(16),
			itemCount: categories.length,
			separatorBuilder: (_, __) => const SizedBox(height: 12),
			itemBuilder: (context, index) {
				final category = categories[index];
				return Card(
					elevation: 3,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
					clipBehavior: Clip.antiAlias,
					child: ListTile(
						onTap: () => _navigateToStores(category), // <-- استخدام الدالة المساعدة
						leading: category.image.isNotEmpty
								? ClipRRect(
							borderRadius: BorderRadius.circular(8),
							child: Image.memory(
								base64Decode(category.image.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '')), // Clean base64 string
								width: 55,
								height: 55,
								fit: BoxFit.cover,
								errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 30, color: Colors.grey.shade400),
							),
						)
								: Container(
							width: 55, height: 55,
							decoration: BoxDecoration(
								color: Colors.grey[200],
								borderRadius: BorderRadius.circular(8),
							),
							child: Icon(Icons.category_outlined, size: 30, color: Colors.grey.shade500),
						),
						title: Text(
							category.name,
							style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
						),
						subtitle: Text(
							category.description,
							maxLines: 2,
							overflow: TextOverflow.ellipsis,
							style: TextStyle(fontSize: 14, color: Colors.grey[600]),
						),
						trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
						contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
					),
				);
			},
		);
	}

	Widget _buildHorizontalView() {
		return Container(
			height: 240, // Increased height slightly
			padding: const EdgeInsets.symmetric(vertical: 16),
			child: ListView.separated(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				scrollDirection: Axis.horizontal,
				itemCount: categories.length,
				separatorBuilder: (_, __) => const SizedBox(width: 12),
				itemBuilder: (context, index) {
					final category = categories[index];
					return SizedBox(
						width: 160, // Adjusted width
						child: _buildCategoryCard(category),
					);
				},
			),
		);
	}

	Widget _buildHeader() {
		return Container(
			padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
			decoration: BoxDecoration(
					color: Theme.of(context).primaryColor,
					// Optional: Add gradient or image background
					// gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
					borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
					boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))]
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						"اكتشف أقسامنا",
						style: TextStyle(
							fontSize: 22, // Slightly smaller
							fontWeight: FontWeight.bold,
							color: Colors.white,
						),
					),
					SizedBox(height: 4),
					Text(
						"تصفح المنتجات حسب القسم الذي يناسبك",
						style: TextStyle(
							fontSize: 14,
							color: Colors.white.withOpacity(0.85),
						),
					),
				],
			),
		);
	}

	// Footer is removed as it's usually part of the main scaffold (like in HomePage)
	/*
  Widget _buildFooter() { ... }
  */

	@override
	Widget build(BuildContext context) {
		// يمكنك الوصول إلى بيانات المستخدم هنا عبر widget.user
		// مثال: widget.user.name

		return Scaffold(
			backgroundColor: Colors.grey[100], // Lighter background
			// AppBar is removed as this screen is likely shown within HomePage's body
			/*
      appBar: AppBar(
        title: Text("الأقسام"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [ ... display type buttons ... ],
      ),
      */
			body: Column(
				children: [
					// Header can be optional if this screen is part of another page
					// _buildHeader(),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.end,
							children: [
								IconButton(
									icon: Icon(Icons.grid_view_outlined),
									color: _displayType == DisplayType.grid ? Theme.of(context).primaryColor : Colors.grey,
									tooltip: 'عرض شبكي',
									onPressed: () => setState(() => _displayType = DisplayType.grid),
								),
								IconButton(
									icon: Icon(Icons.view_list_outlined),
									color: _displayType == DisplayType.list ? Theme.of(context).primaryColor : Colors.grey,
									tooltip: 'عرض قائمة',
									onPressed: () => setState(() => _displayType = DisplayType.list),
								),
								IconButton(
									icon: Icon(Icons.view_carousel_outlined),
									color: _displayType == DisplayType.horizontal ? Theme.of(context).primaryColor : Colors.grey,
									tooltip: 'عرض أفقي',
									onPressed: () => setState(() => _displayType = DisplayType.horizontal),
								),
							],
						),
					),
					Expanded(
						child: isLoading
								? Center(child: CircularProgressIndicator())
								: categories.isEmpty
								? Center(child: Text('لا توجد أقسام متاحة حاليًا.', style: TextStyle(color: Colors.grey[600], fontSize: 16)))
								: AnimatedSwitcher(
							duration: Duration(milliseconds: 300),
							child: _displayType == DisplayType.grid
									? _buildGridView()
									: _displayType == DisplayType.list
									? _buildListView()
									: _buildHorizontalView(),
						),
					),
					// Footer is removed
					// _buildFooter(),
				],
			),
		);
	}
}

