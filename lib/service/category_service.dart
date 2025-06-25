import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/category_model.dart'; // تم تحديث الاستيراد

// رابط الـ API

//const String apiUrl = "http://190.30.24.218/ecommerce/api.php";
final String apiUrl = ApiHelper.url('api.php');

class CategoryController {
	Future<List<Category>> fetchCategories() async {
		final List<Category> categories = [];

		try {
			final response = await http.get(Uri.parse("$apiUrl?action=categories"));

			if (response.statusCode == 200) {
				final jsonResponse = json.decode(response.body);

				if (jsonResponse['success'] == true) {
					List data = jsonResponse['data'];
					for (var item in data) {
						categories.add(Category.fromJson(item));
					}
				}
			}
		} catch (e) {
			print("Error fetching categories: $e");
		}

		return categories;
	}
	// إضافة قسم
	Future<void> addCategory(Category category) async {
		try {
			final response = await http.post(
				Uri.parse('$apiUrl?action=add_category'),
				headers: {'Content-Type': 'application/json'},
				body: json.encode(category.toJson()),
			);

			final jsonResponse = json.decode(response.body);
			if (jsonResponse['success'] == true) {
				print("✅ Success: ${jsonResponse['message']}");
			} else {
				print("❌ Error: ${jsonResponse['message']}");
			}
		} catch (e) {
			print("❌ Exception during add: $e");
		}
	}

// تعديل قسم
	Future<void> updateCategory(Category category) async {
		try {
			final response = await http.post(
				Uri.parse('$apiUrl?action=update_category'),
				headers: {'Content-Type': 'application/json'},
				body: json.encode(category.toJson()),
			);

			final jsonResponse = json.decode(response.body);
			if (jsonResponse['success'] == true) {
				print("✅ Success: ${jsonResponse['message']}");
			} else {
				print("❌ Error: ${jsonResponse['message']}");
			}
		} catch (e) {
			print("❌ Exception during update: $e");
		}
	}

// حذف قسم
	Future<void> deleteCategory(String id) async {
		try {
			final response = await http.post(
				Uri.parse('$apiUrl?action=delete_category'),
				headers: {'Content-Type': 'application/json'},
				body: json.encode({'id': id}),
			);

			final jsonResponse = json.decode(response.body);
			if (jsonResponse['success'] == true) {
				print("✅ Success: ${jsonResponse['message']}");
			} else {
				print("❌ Error: ${jsonResponse['message']}");
			}
		} catch (e) {
			print("❌ Exception during delete: $e");
		}
	}

}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../ApiConfig.dart';
// import '../model/category_model.dart';
//
// // رابط الـ API
//
// //const String apiUrl = "http://190.30.24.218/ecommerce/api.php";
// final String apiUrl = ApiHelper.url('api.php');
//
// class CategoryController {
// 	Future<List<Category>> fetchCategories() async {
// 		final List<Category> categories = [];
//
// 		try {
// 			final response = await http.get(Uri.parse("$apiUrl?action=categories"));
//
// 			if (response.statusCode == 200) {
// 				final jsonResponse = json.decode(response.body);
//
// 				if (jsonResponse['success'] == true) {
// 					List data = jsonResponse['data'];
// 					for (var item in data) {
// 						categories.add(Category.fromJson(item));
// 					}
// 				}
// 			}
// 		} catch (e) {
// 			print("Error fetching categories: $e");
// 		}
//
// 		return categories;
// 	}
// 	// إضافة قسم
// 	Future<void> addCategory(Category category) async {
// 		try {
// 			final response = await http.post(
// 				Uri.parse('$apiUrl?action=add_category'),
// 				headers: {'Content-Type': 'application/json'},
// 				body: json.encode(category.toJson()),
// 			);
//
// 			final jsonResponse = json.decode(response.body);
// 			if (jsonResponse['success'] == true) {
// 				print("✅ Success: ${jsonResponse['message']}");
// 			} else {
// 				print("❌ Error: ${jsonResponse['message']}");
// 			}
// 		} catch (e) {
// 			print("❌ Exception during add: $e");
// 		}
// 	}
//
// // تعديل قسم
// 	Future<void> updateCategory(Category category) async {
// 		try {
// 			final response = await http.post(
// 				Uri.parse('$apiUrl?action=update_category'),
// 				headers: {'Content-Type': 'application/json'},
// 				body: json.encode(category.toJson()),
// 			);
//
// 			final jsonResponse = json.decode(response.body);
// 			if (jsonResponse['success'] == true) {
// 				print("✅ Success: ${jsonResponse['message']}");
// 			} else {
// 				print("❌ Error: ${jsonResponse['message']}");
// 			}
// 		} catch (e) {
// 			print("❌ Exception during update: $e");
// 		}
// 	}
//
// // حذف قسم
// 	Future<void> deleteCategory(String id) async {
// 		try {
// 			final response = await http.post(
// 				Uri.parse('$apiUrl?action=delete_category'),
// 				headers: {'Content-Type': 'application/json'},
// 				body: json.encode({'id': id}),
// 			);
//
// 			final jsonResponse = json.decode(response.body);
// 			if (jsonResponse['success'] == true) {
// 				print("✅ Success: ${jsonResponse['message']}");
// 			} else {
// 				print("❌ Error: ${jsonResponse['message']}");
// 			}
// 		} catch (e) {
// 			print("❌ Exception during delete: $e");
// 		}
// 	}
//
// }
