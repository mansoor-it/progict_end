import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/category_model.dart';
import 'package:untitled2/viw/stores_screen.dart';
import '../service/category_service.dart';

class CategoriesScreen extends StatefulWidget {
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
		setState(() => isLoading = true);
		final fetched = await _controller.fetchCategories();
		setState(() {
			categories = fetched;
			isLoading = false;
		});
	}

	Widget _buildCategoryCard(Category category) {
		return GestureDetector(
			onTap: () {
				Navigator.push(
					context,
					MaterialPageRoute(
						builder: (context) => StoresScreen(
							categoryId: category.id,
							categoryName: category.name,
						),
					),
				);
			},
			child: Card(
				elevation: 8,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
				margin: EdgeInsets.zero,
				clipBehavior: Clip.antiAlias,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							child: Container(
								decoration: BoxDecoration(
									color: Colors.grey[300],
									borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
								),
								child: category.image.isNotEmpty
										? Image.memory(
									base64Decode(category.image),
									fit: BoxFit.cover,
								)
										: Icon(Icons.image, size: 60, color: Colors.grey.shade500),
							),
						),
						Padding(
							padding: const EdgeInsets.all(12.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										category.name,
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 17,
											color: Theme.of(context).primaryColor,
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
									SizedBox(height: 4),
									Text(
										category.description,
										style: TextStyle(
											fontSize: 14,
											color: Colors.grey[700],
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
			gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: 2,
				crossAxisSpacing: 16,
				mainAxisSpacing: 16,
				childAspectRatio: 0.8,
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
				return ListTile(
					onTap: () {
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (_) => StoresScreen(
									categoryId: category.id,
									categoryName: category.name,
								),
							),
						);
					},
					leading: category.image.isNotEmpty
							? ClipRRect(
						borderRadius: BorderRadius.circular(12),
						child: Image.memory(
							base64Decode(category.image),
							width: 60,
							height: 60,
							fit: BoxFit.cover,
						),
					)
							: Icon(Icons.image, size: 60, color: Colors.grey),
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
					tileColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
					contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
				);
			},
		);
	}

	Widget _buildHorizontalView() {
		return Container(
			height: 230,
			padding: const EdgeInsets.symmetric(vertical: 12),
			child: ListView.separated(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				scrollDirection: Axis.horizontal,
				itemCount: categories.length,
				separatorBuilder: (_, __) => const SizedBox(width: 16),
				itemBuilder: (context, index) {
					final category = categories[index];
					return SizedBox(
						width: 180,
						child: _buildCategoryCard(category),
					);
				},
			),
		);
	}

	// Header جميل في بداية الصفحة
	Widget _buildHeader() {
		return Container(
			padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
			decoration: BoxDecoration(
				color: Theme.of(context).primaryColor,
				borderRadius: BorderRadius.only(
					bottomLeft: Radius.circular(25),
					bottomRight: Radius.circular(25),
				),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						"اكتشف أقسامنا",
						style: TextStyle(
							fontSize: 24,
							fontWeight: FontWeight.bold,
							color: Colors.white,
						),
					),
					SizedBox(height: 6),
					Text(
						"تصفح المنتجات حسب القسم الذي يناسبك",
						style: TextStyle(
							fontSize: 15,
							color: Colors.white70,
						),
					),
				],
			),
		);
	}

	// Footer جميل في نهاية الصفحة
	Widget _buildFooter() {
		return Container(
			padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
			decoration: BoxDecoration(
				color: Theme.of(context).primaryColor.withOpacity(0.1),
				border: Border(
					top: BorderSide(color: Colors.grey.shade300),
				),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Text(
						"جميع الحقوق محفوظة © 2025",
						style: TextStyle(
							fontSize: 14,
							color: Colors.grey[600],
						),
					),
					Row(
						children: [
							Icon(Icons.facebook, color: Colors.blue, size: 20),
							SizedBox(width: 10),
							Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor, size: 20),
						],
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[200],
			appBar: AppBar(
				title: Text("الأقسام"),
				backgroundColor: Theme.of(context).primaryColor,
				actions: [
					IconButton(
						icon: Icon(Icons.grid_view),
						color: _displayType == DisplayType.grid ? Colors.white : Colors.white60,
						onPressed: () => setState(() => _displayType = DisplayType.grid),
					),
					IconButton(
						icon: Icon(Icons.list),
						color: _displayType == DisplayType.list ? Colors.white : Colors.white60,
						onPressed: () => setState(() => _displayType = DisplayType.list),
					),
					IconButton(
						icon: Icon(Icons.view_carousel),
						color: _displayType == DisplayType.horizontal ? Colors.white : Colors.white60,
						onPressed: () => setState(() => _displayType = DisplayType.horizontal),
					),
				],
			),
			body: Column(
				children: [
					_buildHeader(),
					Expanded(
						child: isLoading
								? Center(child: CircularProgressIndicator())
								: Builder(
							builder: (_) {
								switch (_displayType) {
									case DisplayType.list:
										return _buildListView();
									case DisplayType.horizontal:
										return _buildHorizontalView();
									case DisplayType.grid:
									default:
										return _buildGridView();
								}
							},
						),
					),
					_buildFooter(),
				],
			),
		);
	}
}