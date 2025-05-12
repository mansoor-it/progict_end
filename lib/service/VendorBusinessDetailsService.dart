import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/VendorBusinessDetails_model.dart';

class VendorBusinessDetailsService {
	static var url = Uri.parse('http://190.30.8.83/ecommerce/api_allvendors.php');

	static const _add = 'add';
	static const _fetch = 'fetch';
	static const _update = 'update';
	static const _delete = 'delete';

	static Future<List<VendorBusinessDetails>> getAllBusinessDetails() async {
		try {
			var map = {'action': _fetch};
			final response = await http.post(url, body: map);
			print('getAllBusinessDetails: ${response.statusCode} ${response.body}');
			if (response.statusCode == 200) {
				final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
				return parsed.map<VendorBusinessDetails>((json) => VendorBusinessDetails.fromJson(json)).toList();
			} else {
				return [];
			}
		} catch (e, stackTrace) {
			print('Exception in getAllBusinessDetails: $e');
			print('StackTrace: $stackTrace');
			return [];
		}
	}

	static Future<String> addBusinessDetails(VendorBusinessDetails businessDetails) async {
		var map = businessDetails.toJsonForRequest();
		map['action'] = _add;
		try {
			final response = await http.post(url, body: map);
			print('addBusinessDetails: ${response.statusCode} ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in addBusinessDetails: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	static Future<String> updateBusinessDetails(VendorBusinessDetails businessDetails) async {
		var map = businessDetails.toJsonForRequest();
		map['action'] = _update;
		try {
			final response = await http.post(url, body: map);
			print('updateBusinessDetails: ${response.statusCode} ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in updateBusinessDetails: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}

	static Future<String> deleteBusinessDetails(String vendorId) async {
		var map = {
			'action': _delete,
			'vendor_id': vendorId,
		};
		try {
			final response = await http.post(url, body: map);
			print('deleteBusinessDetails: ${response.statusCode} ${response.body}');
			return response.body;
		} catch (e, stackTrace) {
			print('Exception in deleteBusinessDetails: $e');
			print('StackTrace: $stackTrace');
			return 'error';
		}
	}
}
