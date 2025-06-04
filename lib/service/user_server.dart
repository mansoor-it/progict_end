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

	static Future<bool> registerUser(User user) async {
		var map = user.toJson();
		map['action'] = _add; // أكشن الإضافة عند التسجيل
		try {
			final response = await http.post(url, body: map);
			print('registerUser: response code: ${response.statusCode}');
			print('registerUser: response body: ${response.body}');

			if (response.statusCode == 200) {
				final decoded = json.decode(response.body);
				// التأكد من وجود المفتاح 'success' وقيمته true
				final bool success = decoded['success'] ?? false;
				return success;
			}
			return false;
		} catch (e, stackTrace) {
			print('Exception in registerUser: $e');
			print('StackTrace: $stackTrace');
			return false;
		}
	}
	static Future<User?> getUserByEmail(String email) async {
		final users = await getAllUsers();
		try {
			return users.firstWhere((user) => user.email.toLowerCase() == email.toLowerCase());
		} catch (e) {
			return null; // لم يتم العثور على المستخدم
		}
	}
	// --- دالة جديدة لجلب بيانات المستخدم بواسطة ID ---
	static Future<User?> fetchUserDataById(String userId) async {
		final url = Uri.parse('${ApiHelper.url('api_user.php')}/$userId');
		try {
			final response = await http.get(url, headers: {
				'Content-Type': 'application/json; charset=UTF-8',
				'Accept': 'application/json',
			});

			print('Response code: ${response.statusCode}');
			print('Response body: ${response.body}');

			if (response.statusCode == 200) {
				final responseBody = utf8.decode(response.bodyBytes);
				final List<dynamic> data = jsonDecode(responseBody); // استخدم List بدلاً من Map

				// طباعة البيانات المسترجعة
				print('Fetched data: $data');

				// البحث عن المستخدم في القائمة
				final user = data.firstWhere((user) => user['id'].toString() == userId, orElse: () => null);
				if (user != null) {
					return User.fromJson(user);
				} else {
					print('User not found in response');
					return null;
				}
			} else {
				print('Failed to load user data. Status code: ${response.statusCode}');
				return null;
			}
		} catch (e) {
			print('Error fetching user data by ID: $e');
			return null;
		}
	}
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
// داخل كلاس UserService:
	static Future<User?> getUserById(String userId) async {
		try {
			// نجلب جميع المستخدمين من السيرفر
			var map = {'action': _fetch};
			final response = await http.post(url, body: map);
			print('getUserById: response code: ${response.statusCode}');
			print('getUserById: response body: ${response.body}');

			if (response.statusCode == 200) {
				// نفترض أن الـ API يعيد قائمة JSON من المستخدمين
				final List parsed = json.decode(response.body);
				// نحول كل JSON إلى كائن User
				final users = parsed.map<User>((json) => User.fromJson(json)).toList();

				// نبحث عن المستخدم الذي يطابق معرفه
				try {
					return users.firstWhere((user) => user.id.toString() == userId);
				} catch (e) {
					print('User not found for ID: $userId');
					return null;
				}
			} else {
				print('Failed to fetch users. Status code: ${response.statusCode}');
				return null;
			}
		} catch (e, stackTrace) {
			print('Exception in getUserById: $e');
			print('StackTrace: $stackTrace');
			return null;
		}
	}

}
