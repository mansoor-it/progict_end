import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';
import '../model/vendors_model.dart';

class VendorService {
	// رابط API الأساسي
	static final url = Uri.parse(ApiHelper.url('api_allvendors.php'));

	static const _add = 'add';
	static const _fetch = 'fetch';
	static const _update = 'update';
	static const _delete = 'delete';

	// جلب جميع البائعين
	static Future<List<Vendor>> getAllVendors() async {
		try {
			var map = {'action': _fetch};
			final response = await http.post(url, body: map);
			print('getAllVendors: response code: ${response.statusCode}');
			print('getAllVendors: response body: ${response.body}');
			if (response.statusCode == 200) {
				final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
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

	// إضافة بائع جديد
	static Future<String> addVendor(Vendor vendor) async {
		var map = vendor.toJsonForRequest();
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

	// ✅ تحديث بيانات بائع (يستخدم toJsonForRequest لضمان إرسال الصورة بصيغة String)
	static Future<String> updateVendor(Vendor vendor) async {
		var map = vendor.toJsonForRequest();
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

	// حذف بائع
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

	// جلب بائع عن طريق الإيميل
	static Future<Vendor?> getVendorByEmail(String email) async {
		try {
			final response = await http.post(
				url,
				body: {
					'action': 'getVendorByEmail',
					'email': email,
				},
			);
			print('getVendorByEmail: ${response.body}');
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				if (data is Map<String, dynamic> && data.containsKey('message')) {
					print('Error from server: ${data['message']}');
					return null;
				}
				return Vendor.fromJson(data);
			} else {
				print('getVendorByEmail: response status not 200');
				return null;
			}
		} catch (e, stackTrace) {
			print('Exception in getVendorByEmail: $e');
			print('StackTrace: $stackTrace');
			return null;
		}
	}

	// تسجيل دخول البائع
	static Future<Vendor?> loginVendor(String email, String password) async {
		try {
			final response = await http.post(
				url,
				body: {
					'action': 'login',
					'email': email,
					'password': password,
				},
			);
			print('loginVendor: ${response.body}');
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				if (data is Map<String, dynamic> && data.containsKey('message')) {
					print('Error from server: ${data['message']}');
					return null;
				}
				return Vendor.fromJson(data);
			} else {
				return null;
			}
		} catch (e, stackTrace) {
			print('Exception in loginVendor: $e');
			print('StackTrace: $stackTrace');
			return null;
		}
	}

	// جلب المتاجر الخاصة ببائع معين
	static Future<List<dynamic>> fetchStoresByVendorId(String vendorId) async {
		final urlStores = Uri.parse(ApiHelper.url('stores')).replace(queryParameters: {
			'vendor_id': vendorId,
		});

		final response = await http.get(urlStores);

		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			return data['stores'];
		} else {
			throw Exception('Failed to load stores');
		}
	}
}
