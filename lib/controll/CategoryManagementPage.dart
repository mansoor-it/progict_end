import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/category_model.dart';
import '../service/category_service.dart';

class CategoriesManagementScreen extends StatefulWidget {
	@override
	_CategoriesManagementScreenState createState() => _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState extends State<CategoriesManagementScreen> {
	List<Category> categories = [];
	bool isLoading = false;
	final CategoryController _controller = CategoryController();
	final ImagePicker _picker = ImagePicker();
	String base64Image = '';

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

	Future<void> showDeleteDialog(String categoryId) async {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text("حذف القسم"),
					content: Text("هل أنت متأكد من أنك تريد حذف هذا القسم؟"),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context),
							child: Text("إلغاء"),
						),
						TextButton(
							onPressed: () async {
								Navigator.pop(context);
								await _controller.deleteCategory(categoryId);
								fetchCategories();
							},
							child: Text("حذف"),
						),
					],
				);
			},
		);
	}

	Future<void> pickImage() async {
		final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
		if (pickedFile != null) {
			final imageBytes = await pickedFile.readAsBytes();
			setState(() {
				base64Image = base64Encode(imageBytes);
			});
		}
	}

	Future<void> showCategoryDialog({Category? category}) async {
		TextEditingController nameController = TextEditingController(text: category?.name ?? '');
		TextEditingController descriptionController = TextEditingController(text: category?.description ?? '');
		String image = category?.image ?? '';

		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text(category == null ? "إضافة قسم" : "تعديل قسم"),
					content: SingleChildScrollView(
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								TextField(
									controller: nameController,
									decoration: InputDecoration(labelText: "اسم القسم"),
								),
								TextField(
									controller: descriptionController,
									decoration: InputDecoration(labelText: "وصف القسم"),
								),
								SizedBox(height: 10),
								ElevatedButton(
									onPressed: pickImage,
									child: Text("اختيار صورة من المعرض"),
								),
								SizedBox(height: 10),
								base64Image.isNotEmpty || image.isNotEmpty
										? Image.memory(
									base64Decode(base64Image.isNotEmpty ? base64Image : image),
									height: 100,
									width: 100,
									fit: BoxFit.cover,
								)
										: Icon(Icons.image, size: 100, color: Colors.grey),
							],
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context),
							child: Text("إلغاء"),
						),
						TextButton(
							onPressed: () async {
								String finalImage = base64Image.isNotEmpty ? base64Image : image;
								if (category == null) {
									Category newCategory = Category(
										id: DateTime.now().millisecondsSinceEpoch.toString(),
										name: nameController.text,
										description: descriptionController.text,
										image: finalImage,
										createdAt: DateTime.now().toString(),
										updatedAt: DateTime.now().toString(),
									);
									await _controller.addCategory(newCategory);
								} else {
									Category updatedCategory = category.copyWith(
										name: nameController.text,
										description: descriptionController.text,
										image: finalImage,
										updatedAt: DateTime.now().toString(),
									);
									await _controller.updateCategory(updatedCategory);
								}
								Navigator.pop(context);
								fetchCategories();
							},
							child: Text(category == null ? "إضافة" : "تعديل"),
						),
					],
				);
			},
		);
	}

	Widget buildTable() {
		return SingleChildScrollView(
			scrollDirection: Axis.horizontal,
			child: DataTable(
				columnSpacing: 20,
				columns: [
					DataColumn(label: Text('رقم')),
					DataColumn(label: Text('الاسم')),
					DataColumn(label: Text('الوصف')),
					DataColumn(label: Text('الصورة')),
					DataColumn(label: Text('تاريخ الإنشاء')),
					DataColumn(label: Text('آخر تعديل')),
					DataColumn(label: Text('الخيارات')),
				],
				rows: categories.asMap().entries.map((entry) {
					final index = entry.key;
					final category = entry.value;
					return DataRow(cells: [
						DataCell(Text('${index + 1}')),
						DataCell(Text(category.name)),
						DataCell(SizedBox(
							width: 200,
							child: Text(
								category.description,
								overflow: TextOverflow.ellipsis,
							),
						)),
						DataCell(category.image.isNotEmpty
								? Image.memory(base64Decode(category.image), width: 50, height: 50)
								: Icon(Icons.image)),
						DataCell(Text(category.createdAt ?? '-')),
						DataCell(Text(category.updatedAt ?? '-')),
						DataCell(Row(
							children: [
								IconButton(
									icon: Icon(Icons.edit),
									onPressed: () => showCategoryDialog(category: category),
								),
								IconButton(
									icon: Icon(Icons.delete),
									onPressed: () => showDeleteDialog(category.id),
								),
							],
						)),
					]);
				}).toList(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[100],
			appBar: AppBar(
				title: Text("إدارة الأقسام"),
				backgroundColor: Colors.teal,
				actions: [
					IconButton(
						icon: Icon(Icons.add),
						onPressed: () => showCategoryDialog(),
					),
				],
			),
			body: isLoading
					? Center(child: CircularProgressIndicator())
					: Padding(
				padding: const EdgeInsets.all(12.0),
				child: buildTable(),
			),
		);
	}
}
