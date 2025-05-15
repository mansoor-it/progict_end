import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/admin_model.dart';

class AdminService {
	//static var url = Uri.parse('http://192.168.43.129/ecommerce/api_admin.php');
	static final url = Uri.parse(ApiHelper.url('api_admin.php'));
	static const _add = 'add';
	static const _fetch = 'fetch';
	static const _update = 'update';
	static const _delete = 'delete';

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
