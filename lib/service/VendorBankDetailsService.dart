import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/vendors_model.dart';




class VendorService {
	// تأكد من تعديل رابط API إذا لزم الأمر (مثلاً استخدام ملف API خاص بالبائعين "api_vendor.php")
	static var url = Uri.parse('http://190.30.8.83/ecommerce/api_vendors_bank_details.php');

	static const _add = 'add';
	static const _fetch = 'fetch';
	static const _update = 'update';
	static const _delete = 'delete';

	static Future<List<Vendor>> getAllVendors() async {
		try {
			var map = {'action': _fetch};
			final response = await http.post(url, body: map);
			print('getAllVendors: response code: ${response.statusCode}');
			print('getAllVendors: response body: ${response.body}');
			if (response.statusCode == 200) {
				final parsed = json.decode(response.body)
						.cast<Map<String, dynamic>>();
				return parsed.map<Vendor>((json) => Vendor.fromJson(json)).toList();
			} else {
				return [];
			}
		} catch (e, stackTrace) {
			print('Exception in getAllVendors: $e');
			print('StackTrace: $stackTrace');
			return [];
		}
	}

	static Future<String> addVendor(Vendor vendor) async {
		var map = vendor.toJson();
		map['action'] = _add;
		try {
			final response = await http.post(url, body: map);
			print('addVendor: response code: ${response.statusCode}');
			print('addVendor: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in addVendor: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	static Future<String> updateVendor(Vendor vendor) async {
		var map = vendor.toJson();
		map['action'] = _update;
		try {
			final response = await http.post(url, body: map);
			print('updateVendor: response code: ${response.statusCode}');
			print('updateVendor: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in updateVendor: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	static Future<String> deleteVendor(String id) async {
		var map = {
			'action': _delete,
			'id': id,
		};
		try {
			final response = await http.post(url, body: map);
			print('deleteVendor: response code: ${response.statusCode}');
			print('deleteVendor: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in deleteVendor: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}
}
