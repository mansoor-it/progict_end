// controller/store_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/stor_model.dart';


class StoreController {
	final String apiUrl = "http://190.30.8.83/ecommerce/api.php";

	Future<List<Store>> fetchStores(String categoryId) async {
		final response = await http.get(Uri.parse("$apiUrl?action=stores&category_id=$categoryId"));
		if (response.statusCode == 200) {
			final jsonResponse = json.decode(response.body);
			if (jsonResponse['success'] == true) {
				List data = jsonResponse['data'];
				return data.map((item) => Store.fromJson(item)).toList();
			}
		}
		return [];
	}
}
