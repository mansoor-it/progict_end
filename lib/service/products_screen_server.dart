// products_screen_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/products_screen_model.dart';

// رابط الـ API

//const String apiUrl = "http://190.30.24.218/ecommerce/api.php";
final String apiUrl = ApiHelper.url('api.php');


class ProductsScreenController {

	Future<List<Product>> fetchProducts(String storeId) async {
		final response = await http.get(Uri.parse("$apiUrl?action=products&store_id=$storeId"));
		if (response.statusCode == 200) {
			final jsonResponse = json.decode(response.body);
			if (jsonResponse['success'] == true) {
				List data = jsonResponse['data'];
				return data.map((item) => Product.fromJson(item)).toList();
			}
		}
		return [];
	}
}
