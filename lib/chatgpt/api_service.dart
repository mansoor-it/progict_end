// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
	// عدل هذا العنوان ليطابق عنوان خادم Flask لديك
	static const String _baseUrl = 'http://190.30.0.68:5000';

	/// ترسل استعلام المستخدم إلى نقطة النهاية `/chat_query` وتعيد نص الرد.
	static Future<String> sendChatQuery(String userQuery) async {
		final uri = Uri.parse('$_baseUrl/chat_query');

		try {
			final response = await http.post(
				uri,
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'user_query': userQuery}),
			);

			if (response.statusCode == 200) {
				final Map<String, dynamic> decoded = jsonDecode(response.body);
				// نأخذ قيمة الحقل "reply" من الـ JSON الذي يعيده الخادم
				return decoded['reply'] as String? ?? 'لا يوجد رد.';
			} else {
				return 'خطأ في الطلب: رمز الحالة ${response.statusCode}';
			}
		} catch (e) {
			return 'حدث خطأ أثناء الاتصال بالخادم: $e';
		}
	}
}
