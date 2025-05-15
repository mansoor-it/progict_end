import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Category {
	final String id;
	final String name;
	final String description;
	final String image;

	Category({
		required this.id,
		required this.name,
		required this.description,
		required this.image,
	});

	factory Category.fromJson(Map<String, dynamic> json) {
		return Category(
			id: json['id'].toString(),
			name: json['name'],
			description: json['description'],
			image: json['image'],
		);
	}
}

class ManageCategoriesPage extends StatefulWidget {
	@override
	_ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
	List<Category> _categories = [];
	bool _isLoading = false;

	// Controllers للنموذج
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _imageController = TextEditingController();

	@override
	void initState() {
		super.initState();
		//_fetchCategories(); // يمكنك جلب البيانات تلقائياً إذا رغبت
	}

	// دالة لجلب الفئات مع طباعة رسائل على الترمنال عند حدوث خطأ
	Future<void> _fetchCategories() async {
		final String apiUrl =
				"http://192.168.43.129/ecommerce/categories.php?action=fetch";
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse(apiUrl));
			debugPrint("Response status: ${response.statusCode}");
			debugPrint("Response body: ${response.body}");

			if (response.statusCode == 200) {
				try {
					final List<dynamic> data = json.decode(response.body);
					setState(() {
						_categories = data.map((item) => Category.fromJson(item)).toList();
						_isLoading = false;
					});
				} catch (jsonError) {
					debugPrint("❌ خطأ أثناء فك JSON: $jsonError");
					setState(() {
						_isLoading = false;
					});
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text("❌ خطأ في تنسيق البيانات"),
							backgroundColor: Colors.red,
						),
					);
				}
			} else {
				debugPrint("❌ خطأ: استجابة السيرفر ليست 200");
				setState(() {
					_isLoading = false;
				});
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("❌ خطأ: لم يتم جلب البيانات من السيرفر"),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (e) {
			debugPrint("❌ استثناء أثناء جلب البيانات: $e");
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text("❌ حدث استثناء أثناء جلب البيانات: $e"),
					backgroundColor: Colors.red,
				),
			);
		}
	}

	// دالة لإضافة فئة جديدة مع طباعة رسائل التصحيح
	Future<void> _addCategory() async {
		final String apiUrl = "http://190.30.24.218/ecommerce/categories.php";
		final Map<String, String> data = {
			"action": "add",
			"name": _nameController.text.trim(),
			"description": _descriptionController.text.trim(),
			"image": _imageController.text.trim(),
		};

		setState(() {
			_isLoading = true;
		});

		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			debugPrint("Response status (add): ${response.statusCode}");
			debugPrint("Response body (add): ${response.body}");
			setState(() {
				_isLoading = false;
			});
			final responseBody = json.decode(response.body);
			if (responseBody['message'] == "Category created successfully") {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("✅ تمت الإضافة بنجاح"),
						backgroundColor: Colors.green,
					),
				);
				_fetchCategories();
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("❌ فشل الإضافة: ${responseBody['message']}"),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (e) {
			debugPrint("❌ استثناء أثناء الإضافة: $e");
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text("❌ حدث استثناء أثناء الإضافة: $e"),
					backgroundColor: Colors.red,
				),
			);
		}
	}

	// دالة لتعديل فئة موجودة مع طباعة رسائل التصحيح
	Future<void> _updateCategory(String id) async {
		final String apiUrl = "http://190.30.0.104/ecommerce/categories.php";
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"name": _nameController.text.trim(),
			"description": _descriptionController.text.trim(),
			"image": _imageController.text.trim(),
		};

		setState(() {
			_isLoading = true;
		});

		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			debugPrint("Response status (update): ${response.statusCode}");
			debugPrint("Response body (update): ${response.body}");
			setState(() {
				_isLoading = false;
			});
			final responseBody = json.decode(response.body);
			if (responseBody['message'] == "Category updated successfully") {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("✅ تم التعديل بنجاح"),
						backgroundColor: Colors.green,
					),
				);
				_fetchCategories();
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("❌ فشل التعديل: ${responseBody['message']}"),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (e) {
			debugPrint("❌ استثناء أثناء التعديل: $e");
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text("❌ حدث استثناء أثناء التعديل: $e"),
					backgroundColor: Colors.red,
				),
			);
		}
	}

	// دالة لحذف الفئة مع طباعة رسائل التصحيح
	Future<void> _deleteCategory(String id) async {
		final String apiUrl = "http://190.30.0.104/ecommerce/categories.php";
		final Map<String, String> data = {
			"action": "delete",
			"id": id,
		};

		setState(() {
			_isLoading = true;
		});

		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			debugPrint("Response status (delete): ${response.statusCode}");
			debugPrint("Response body (delete): ${response.body}");
			setState(() {
				_isLoading = false;
			});
			final responseBody = json.decode(response.body);
			if (responseBody['message'] == "Category deleted successfully") {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("✅ تم الحذف بنجاح"),
						backgroundColor: Colors.green,
					),
				);
				_fetchCategories();
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("❌ فشل الحذف: ${responseBody['message']}"),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (e) {
			debugPrint("❌ استثناء أثناء الحذف: $e");
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text("❌ حدث استثناء أثناء الحذف: $e"),
					backgroundColor: Colors.red,
				),
			);
		}
	}

	// دالة لإظهار حوار الإضافة أو التعديل
	void _showAddEditDialog({Category? category}) {
		if (category != null) {
			_nameController.text = category.name;
			_descriptionController.text = category.description;
			_imageController.text = category.image;
		} else {
			_nameController.clear();
			_descriptionController.clear();
			_imageController.clear();
		}

		showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: Text(category == null ? "إضافة فئة جديدة" : "تعديل الفئة"),
					content: SingleChildScrollView(
						child: Column(
							children: [
								TextField(
									controller: _nameController,
									decoration: InputDecoration(labelText: "اسم الفئة"),
								),
								TextField(
									controller: _descriptionController,
									decoration: InputDecoration(labelText: "الوصف"),
								),
								TextField(
									controller: _imageController,
									decoration: InputDecoration(labelText: "رابط الصورة"),
								),
							],
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(),
							child: Text("إلغاء"),
						),
						TextButton(
							onPressed: () {
								if (category == null) {
									_addCategory();
								} else {
									_updateCategory(category.id);
								}
								Navigator.of(context).pop();
							},
							child: Text(category == null ? "إضافة" : "تعديل"),
						),
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_nameController.dispose();
		_descriptionController.dispose();
		_imageController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text("إدارة البيانات"),
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchCategories,
						tooltip: "عرض البيانات",
					),
				],
			),
			body: _isLoading
					? Center(child: CircularProgressIndicator())
					: _categories.isEmpty
					? Center(child: Text("لا توجد بيانات لعرضها"))
					: ListView.builder(
				itemCount: _categories.length,
				itemBuilder: (context, index) {
					final category = _categories[index];
					return ListTile(
						leading: CircleAvatar(
							radius: 24,
							backgroundImage: NetworkImage(
								"http://190.30.24.218/ecommerce/img_stores/${category.image}",
							),
							backgroundColor: Colors.grey[200],
						),
						title: Text(category.name),
						subtitle: Text(category.description),
						trailing: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								IconButton(
									icon: Icon(Icons.edit),
									onPressed: () => _showAddEditDialog(category: category),
									tooltip: "تعديل الفئة",
								),
								IconButton(
									icon: Icon(Icons.delete),
									onPressed: () {
										showDialog(
											context: context,
											builder: (BuildContext context) {
												return AlertDialog(
													title: Text("تأكيد الحذف"),
													content: Text("هل أنت متأكد من حذف الفئة '${category.name}'؟"),
													actions: [
														TextButton(
															child: Text("إلغاء"),
															onPressed: () => Navigator.of(context).pop(),
														),
														TextButton(
															child: Text("حذف"),
															onPressed: () {
																Navigator.of(context).pop();
																_deleteCategory(category.id);
															},
														),
													],
												);
											},
										);
									},
									tooltip: "حذف الفئة",
								),
							],
						),
					);
				},
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _showAddEditDialog(),
				child: Icon(Icons.add),
				tooltip: "إضافة فئة جديدة",
			),
		);
	}
}

