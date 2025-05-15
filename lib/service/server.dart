import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/image.dart';

class Services {
	static var url = Uri.parse('http://192.168.43.129/ecommerce/api_img.php');

	// تغيرت أسماء الأفعال لتتوافق مع صفحة PHP الجديدة
	static const _ADD_IMAGE_ACTION = 'add';
	static const _GET_ALL_IMAGES_ACTION = 'fetch';
	static const _UPDATE_IMAGE_ACTION = 'update';
	static const _DELETE_IMAGE_ACTION = 'delete';

	// دالة إضافة الصورة
	static Future<String> addImage(String imageString) async {
		try {
			var map = {
				'action': _ADD_IMAGE_ACTION,
				'image_code': imageString,
			};
			final response = await http.post(url, body: map);
			return response.body;
		} catch (e) {
			return 'error';
		}
	}

	// دالة استرجاع جميع الصور
	static Future<List<Images>> getAllPosts() async {
		try {
			var map = {'action': _GET_ALL_IMAGES_ACTION};
			final response = await http.post(url, body: map);
			if (response.statusCode == 200) {
				return parseResponse(response.body);
			} else {
				return [];
			}
		} catch (e) {
			return [];
		}
	}

	// دالة تعديل الصورة
	static Future<String> updateImage(String id, String newImageString) async {
		try {
			var map = {
				'action': _UPDATE_IMAGE_ACTION,
				'id': id,
				'new_image_code': newImageString,
			};
			final response = await http.post(url, body: map);
			return response.body;
		} catch (e) {
			return 'error';
		}
	}

	// دالة حذف الصورة
	static Future<String> deleteImage(String id) async {
		try {
			var map = {
				'action': _DELETE_IMAGE_ACTION,
				'id': id,
			};
			final response = await http.post(url, body: map);
			return response.body;
		} catch (e) {
			return 'error';
		}
	}

	// تحويل الاستجابة النصية (JSON) إلى قائمة من عناصر الصور
	static List<Images> parseResponse(String responseBody) {
		final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
		return parsed.map<Images>((json) => Images.fromJson(json)).toList();
	}
}
