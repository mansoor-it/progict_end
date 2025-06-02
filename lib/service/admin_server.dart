import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/admin_model.dart';

class AdminService {
	static final url = Uri.parse(ApiHelper.url('api_admin.php'));
	static const _add = 'add';
	static const _fetch = 'fetch';
	static const _update = 'update';
	static const _delete = 'delete';

	/// استرجاع الادمن بواسطة الإيميل
	static Future<Admin?> getAdminByEmail(String email) async {
		try {
			final response = await http.post(
				url,
				body: {
					'action': 'get_by_email',
					'email': email,
				},
			);
			print('getAdminByEmail: response code: ${response.statusCode}');
			print('getAdminByEmail: response body: ${response.body}');
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				if (data != null && data is Map<String, dynamic>) {
					return Admin.fromJson(data);
				}
			}
		} catch (e, stackTrace) {
			print('Exception in getAdminByEmail: $e');
			print('StackTrace: $stackTrace');
		}
		return null;
	}

	/// تسجيل دخول الادمن
	static Future<Admin?> loginAdmin(String email, String password) async {
		try {
			final response = await http.post(
				url,
				body: {
					'action': 'login',
					'email': email,
					'password': password,
				},
			);
			print('loginAdmin: response code: ${response.statusCode}');
			print('loginAdmin: response body: ${response.body}');
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				if (data != null && data is Map<String, dynamic>) {
					return Admin.fromJson(data);
				}
			}
		} catch (e, stackTrace) {
			print('Exception in loginAdmin: $e');
			print('StackTrace: $stackTrace');
		}
		return null;
	}

	/// استرجاع كل الادمنز
	static Future<List<Admin>> getAllAdmins() async {
		try {
			var map = {'action': _fetch};
			final response = await http.post(url, body: map);
			print('getAllAdmins: response code: ${response.statusCode}');
			print('getAllAdmins: response body: ${response.body}');
			if (response.statusCode == 200) {
				final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
				return parsed.map<Admin>((json) => Admin.fromJson(json)).toList();
			} else {
				return [];
			}
		} catch (e, stackTrace) {
			print('Exception in getAllAdmins: $e');
			print('StackTrace: $stackTrace');
			return [];
		}
	}

	/// إضافة ادمن جديد
	static Future<String> addAdmin(Admin admin) async {
		var map = admin.toJson();
		map['action'] = _add;
		try {
			final response = await http.post(url, body: map);
			print('addAdmin: response code: ${response.statusCode}');
			print('addAdmin: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in addAdmin: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	/// تحديث بيانات الادمن
	static Future<String> updateAdmin(Admin admin) async {
		var map = admin.toJson();
		map['action'] = _update;
		try {
			final response = await http.post(url, body: map);
			print('updateAdmin: response code: ${response.statusCode}');
			print('updateAdmin: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in updateAdmin: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	/// حذف الادمن
	static Future<String> deleteAdmin(String id) async {
		var map = {
			'action': _delete,
			'id': id,
		};
		try {
			final response = await http.post(url, body: map);
			print('deleteAdmin: response code: ${response.statusCode}');
			print('deleteAdmin: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in deleteAdmin: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}
}
