import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/stor_model.dart';

class StoreController {
	//final String baseUrl = "http://10.0.2.2/api/stores.php"; // غيّره حسب السيرفر
	static var baseUrl = ApiHelper.url('stores.php');

	Future<List<Store>> fetchStores(String categoryId) async {
		final response = await http.post(Uri.parse(baseUrl), body: {
			'action': 'fetch',
			'category_id': categoryId,
		});

		if (response.statusCode == 200) {
			final List data = json.decode(response.body);
			return data.map((json) => Store.fromJson(json)).toList();
		} else {
			throw Exception("فشل في تحميل المحلات");
		}
	}

	Future<bool> addStore(Store store) async {
		final response = await http.post(Uri.parse(baseUrl), body: {
			'action': 'add',
			...store.toJson(),
		});

		return response.statusCode == 200;
	}

	Future<bool> updateStore(Store store) async {
		final response = await http.post(Uri.parse(baseUrl), body: {
			'action': 'update',
			...store.toJson(),
		});

		return response.statusCode == 200;
	}

	Future<bool> deleteStore(String id) async {
		final response = await http.post(Uri.parse(baseUrl), body: {
			'action': 'delete',
			'id': id,
		});

		return response.statusCode == 200;
	}
}
