import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/banners_model.dart';

class BannerService {
	// تأكد من أن رابط السيرفر صحيح ويتوافق مع ملف PHP الخاص بالبـنـرات
	//static const String apiUrl = 'http://190.30.24.218/ecommerce/apibanners.php';
	static final apiUrl = ApiHelper.url('apibanners.php');
	static const String _add = 'add';
	static const String _fetch = 'fetch';
	static const String _update = 'update';
	static const String _delete = 'delete';

	// Fetch all banners
	static Future<List<BannerModel>> getAllBanners() async {
		try {
			var map = {'action': _fetch};
			final response = await http.post(Uri.parse(apiUrl), body: map);

			print('getAllBanners: response code: ${response.statusCode}');
			print('getAllBanners: response body: ${response.body}');

			if (response.statusCode == 200) {
				// Parse the JSON response and get the 'data' part which is a list of banners
				final decodedResponse = json.decode(response.body);

				// Check if the 'data' key exists in the decoded response
				if (decodedResponse['data'] != null) {
					final bannerData = decodedResponse['data'] as List;

					// Map the list of JSON objects to a list of BannerModel objects
					return bannerData.map((json) => BannerModel.fromJson(json)).toList();
				} else {
					// If there's no data, return an empty list
					return [];
				}
			} else {
				// Return an empty list if the response status code is not 200
				return [];
			}
		} catch (e, stackTrace) {
			print('Exception in getAllBanners: $e');
			print('StackTrace: $stackTrace');
			return [];
		}
	}

	// Add a new banner
	static Future<String> addBanner(BannerModel banner) async {
		var map = banner.toJson();
		map['action'] = _add;

		try {
			final response = await http.post(Uri.parse(apiUrl), body: map);
			print('addBanner: response code: ${response.statusCode}');
			print('addBanner: response body: ${response.body}');

			if (response.statusCode == 200) {
				return 'Banner added successfully';
			} else {
				return 'Failed to add banner: ${response.body}';
			}
		} catch (e, stackTrace) {
			print('Exception in addBanner: $e');
			print('StackTrace: $stackTrace');
			return 'Error occurred while adding banner';
		}
	}

	// Update an existing banner
	static Future<String> updateBanner(BannerModel banner) async {
		var map = banner.toJson();
		map['action'] = _update;

		try {
			final response = await http.post(Uri.parse(apiUrl), body: map);
			print('updateBanner: response code: ${response.statusCode}');
			print('updateBanner: response body: ${response.body}');

			if (response.statusCode == 200) {
				return 'Banner updated successfully';
			} else {
				return 'Failed to update banner: ${response.body}';
			}
		} catch (e, stackTrace) {
			print('Exception in updateBanner: $e');
			print('StackTrace: $stackTrace');
			return 'Error occurred while updating banner';
		}
	}

	// Delete a banner
	static Future<String> deleteBanner(String id) async {
		var map = {
			'action': _delete,
			'id': id,
		};

		try {
			final response = await http.post(Uri.parse(apiUrl), body: map);
			print('deleteBanner: response code: ${response.statusCode}');
			print('deleteBanner: response body: ${response.body}');

			if (response.statusCode == 200) {
				return 'Banner deleted successfully';
			} else {
				return 'Failed to delete banner: ${response.body}';
			}
		} catch (e, stackTrace) {
			print('Exception in deleteBanner: $e');
			print('StackTrace: $stackTrace');
			return 'Error occurred while deleting banner';
		}
	}
}
