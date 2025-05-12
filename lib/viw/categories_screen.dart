import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/category_model.dart';
import 'package:untitled2/viw/stores_screen.dart';
import '../service/category_service.dart';

class CategoriesScreen extends StatefulWidget {
	@override
	_CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
	List<Category> categories = [];
	bool isLoading = false;
	final CategoryController _controller = CategoryController();

	@override
	void initState() {
		super.initState();
		fetchCategories();
	}

	Future<void> fetchCategories() async {
		setState(() => isLoading = true);
		final fetchedCategories = await _controller.fetchCategories();
		setState(() {
			categories = fetchedCategories;
			isLoading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[100],
			appBar: AppBar(
				title: Text("الأقسام"),
				backgroundColor: Colors.teal,
				elevation: 4,
			),
			body: isLoading
					? Center(child: CircularProgressIndicator())
					: Padding(
				padding: const EdgeInsets.all(12.0),
				child: GridView.builder(
					itemCount: categories.length,
					gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2, // عمودين
						crossAxisSpacing: 12,
						mainAxisSpacing: 12,
						childAspectRatio: 0.85,
					),
					itemBuilder: (context, index) {
						final category = categories[index];
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
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(16),
								),
								elevation: 5,
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										Expanded(
											child: ClipRRect(
												borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
												child: category.image.isNotEmpty
														? Image.memory(
													base64Decode(category.image),
													fit: BoxFit.cover,
												)
														: Container(
													color: Colors.grey[300],
													child: Icon(Icons.image, size: 48, color: Colors.grey[600]),
												),
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
															fontSize: 16,
															fontWeight: FontWeight.bold,
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
					},
				),
			),
		);
	}
}
