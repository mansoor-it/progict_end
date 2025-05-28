import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

// const String apiBaseUrl = "http://190.30.24.218/ecommerce/u.php";
final String apiBaseUrl = ApiHelper.url('u.php');

class AllProductsController {
	Future<Map<String, dynamic>> fetchAllData(String storeId) async {
		List<dynamic> products = [];
		List<dynamic> colors = [];
		List<dynamic> sizes = [];
		bool isLoading = true;

		try {
			final productResponse = await http.get(Uri.parse(
					"$apiBaseUrl?entity=product&action=fetch&store_id=$storeId"));
			final colorResponse =
			await http.get(Uri.parse("$apiBaseUrl?entity=color&action=fetch"));
			final sizeResponse =
			await http.get(Uri.parse("$apiBaseUrl?entity=size&action=fetch"));

			if (productResponse.statusCode == 200 &&
					colorResponse.statusCode == 200 &&
					sizeResponse.statusCode == 200) {
				products = (json.decode(productResponse.body) as List)
						.where((product) =>
				product['store_id'].toString() == storeId)
						.toList();
				colors = json.decode(colorResponse.body);
				sizes = json.decode(sizeResponse.body);
				isLoading = false;
			} else {
				throw Exception("خطأ في جلب البيانات من الخادم");
			}
		} catch (e) {
			print("Error: $e");
			isLoading = false;
		}
		return {
			'products': products,
			'colors': colors,
			'sizes': sizes,
			'isLoading': isLoading,
		};
	}

	/// ✅ دالة جديدة لجلب جميع المنتجات بدون استخدام store_id
	Future<Map<String, dynamic>> fetchAllDataWithoutStoreId() async {
		List<dynamic> products = [];
		List<dynamic> colors = [];
		List<dynamic> sizes = [];
		bool isLoading = true;

		try {
			final productResponse = await http.get(
				Uri.parse("$apiBaseUrl?entity=product&action=fetch"),
			);
			final colorResponse = await http.get(
				Uri.parse("$apiBaseUrl?entity=color&action=fetch"),
			);
			final sizeResponse = await http.get(
				Uri.parse("$apiBaseUrl?entity=size&action=fetch"),
			);

			if (productResponse.statusCode == 200 &&
					colorResponse.statusCode == 200 &&
					sizeResponse.statusCode == 200) {
				products = json.decode(productResponse.body);
				colors = json.decode(colorResponse.body);
				sizes = json.decode(sizeResponse.body);
				isLoading = false;
			} else {
				throw Exception("خطأ في جلب البيانات من الخادم");
			}
		} catch (e) {
			print("Error: $e");
			isLoading = false;
		}

		return {
			'products': products,
			'colors': colors,
			'sizes': sizes,
			'isLoading': isLoading,
		};
	}

	// دالة لتحويل اسم اللون إلى كائن Color
	Color getColorFromName(String colorName) {
		switch (colorName.toLowerCase()) {
			case 'red':
				return Colors.red;
			case 'blue':
				return Colors.blue;
			case 'green':
				return Colors.green;
			case 'black':
				return Colors.black;
			case 'white':
				return Colors.white;
			default:
				return Colors.grey;
		}
	}
}
