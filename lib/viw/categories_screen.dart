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
			child: AnimatedContainer(
				duration: Duration(milliseconds: 300),
				decoration: BoxDecoration(
					color: Colors.white,
					borderRadius: BorderRadius.circular(20),
					boxShadow: [
						BoxShadow(
							color: Colors.black12,
							blurRadius: 10,
							offset: Offset(0, 6),
						),
					],
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							child: ClipRRect(
								borderRadius:
								BorderRadius.vertical(top: Radius.circular(20)),
								child: category.image.isNotEmpty
										? Image.memory(
									base64Decode(category.image),
									fit: BoxFit.cover,
								)
										: Container(
									color: Colors.grey[200],
									child: Icon(Icons.image, size: 50, color: Colors.grey),
								),
							),
						),
						Padding(
							padding: const EdgeInsets.all(12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										category.name,
										style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 16,
											color: Colors.teal[800],
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
									SizedBox(height: 6),
									Text(
										category.description,
										style: TextStyle(
											fontSize: 13,
											color: Colors.grey[600],
										),
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
									)
								],
							),
						)
					],
				),
			),
		);
	}

	Widget _buildGridView() {
		return GridView.builder(
			padding: EdgeInsets.all(14),
			itemCount: categories.length,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: 2,
				crossAxisSpacing: 16,
				mainAxisSpacing: 16,
				childAspectRatio: 0.78,
			),
			itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
		);
	}

	Widget _buildListView() {
		return ListView.separated(
			padding: EdgeInsets.all(14),
			itemCount: categories.length,
			separatorBuilder: (_, __) => SizedBox(height: 14),
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
						borderRadius: BorderRadius.circular(10),
						child: Image.memory(
							base64Decode(category.image),
							width: 55,
							height: 55,
							fit: BoxFit.cover,
						),
					)
							: Icon(Icons.image, size: 55, color: Colors.grey),
					title: Text(
						category.name,
						style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
					),
					subtitle: Text(
						category.description,
						maxLines: 2,
						overflow: TextOverflow.ellipsis,
						style: TextStyle(fontSize: 13, color: Colors.grey[600]),
					),
					tileColor: Colors.white,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
					contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
				);
			},
		);
	}

	Widget _buildHorizontalView() {
		return Container(
			height: 220,
			padding: EdgeInsets.symmetric(vertical: 14),
			child: ListView.separated(
				padding: EdgeInsets.symmetric(horizontal: 14),
				scrollDirection: Axis.horizontal,
				itemCount: categories.length,
				separatorBuilder: (_, __) => SizedBox(width: 14),
				itemBuilder: (context, index) {
					final category = categories[index];
					return Container(
						width: 165,
						child: _buildCategoryCard(category),
					);
				},
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[100],
			appBar: AppBar(
				title: Text(
					"الأقسام",
					style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
				),
				backgroundColor: Colors.teal,
				elevation: 4,
				actions: [
					IconButton(
						tooltip: "عرض شبكة",
						icon: Icon(Icons.grid_view),
						color: _displayType == DisplayType.grid ? Colors.white : Colors.white60,
						onPressed: () => setState(() => _displayType = DisplayType.grid),
					),
					IconButton(
						tooltip: "عرض قائمة",
						icon: Icon(Icons.list),
						color: _displayType == DisplayType.list ? Colors.white : Colors.white60,
						onPressed: () => setState(() => _displayType = DisplayType.list),
					),
					IconButton(
						tooltip: "عرض أفقي",
						icon: Icon(Icons.view_carousel),
						color: _displayType == DisplayType.horizontal ? Colors.white : Colors.white60,
						onPressed: () => setState(() => _displayType = DisplayType.horizontal),
					),
				],
			),
			body: isLoading
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
		);
	}
}
