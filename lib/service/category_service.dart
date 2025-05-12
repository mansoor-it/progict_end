import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/category_model.dart';

// رابط الـ API
const String apiUrl = "http://190.30.8.83/ecommerce/api.php";

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
}
