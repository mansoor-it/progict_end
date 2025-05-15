import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/user_model.dart';

class UserService {
	//static var url = Uri.parse('http://190.30.24.218/ecommerce/api_user.php');
	static final url = Uri.parse(ApiHelper.url('api_user.php'));
	static const _add = 'add';
	static const _fetch = 'fetch';
	static const _update = 'update';
	static const _delete = 'delete';

	static Future<List<User>> getAllUsers() async {
		try {
			var map = {'action': _fetch};
			final response = await http.post(url, body: map);
			print('getAllUsers: response code: ${response.statusCode}');
			print('getAllUsers: response body: ${response.body}');
			if (response.statusCode == 200) {
				final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
				return parsed.map<User>((json) => User.fromJson(json)).toList();
			} else {
				return [];
			}
		} catch (e, stackTrace) {
			print('Exception in getAllUsers: $e');
			print('StackTrace: $stackTrace');
			return [];
		}
	}

	static Future<String> addUser(User user) async {
		var map = user.toJson();
		map['action'] = _add;
		try {
			final response = await http.post(url, body: map);
			print('addUser: response code: ${response.statusCode}');
			print('addUser: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in addUser: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	static Future<String> updateUser(User user) async {
		var map = user.toJson();
		map['action'] = _update;
		try {
			final response = await http.post(url, body: map);
			print('updateUser: response code: ${response.statusCode}');
			print('updateUser: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in updateUser: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	static Future<String> deleteUser(String id) async {
		var map = {
			'action': _delete,
			'id': id,
		};
		try {
			final response = await http.post(url, body: map);
			print('deleteUser: response code: ${response.statusCode}');
			print('deleteUser: response body: ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in deleteUser: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}
	static const _login = 'login';

	static Future<User?> loginUser(String email, String password) async {
		var map = {
			'action': _login,
			'email': email,
			'password': password,
		};
		try {
			final response = await http.post(url, body: map);
			print('loginUser: response code: ${response.statusCode}');
			print('loginUser: response body: ${response.body}');

			if (response.statusCode == 200) {
				final decoded = json.decode(response.body);
				if (decoded['success'] == true && decoded['user'] != null) {
					return User.fromJson(decoded['user']);
				}
			}
			return null;
		} catch (e, stackTrace) {
			print('Exception in loginUser: $e');
			print('StackTrace: $stackTrace');
			return null;
		}
	}

}
