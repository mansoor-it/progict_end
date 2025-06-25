import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiService {
	static const String _baseUrl = 'http://127.0.0.1:5000';

	static Future<String> sendChatQuery(String userQuery) async {
		final uri = Uri.parse('$_baseUrl/chat_query');

		try {
			final response = await http.post(
				uri,
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'user_query': userQuery}),
			).timeout(const Duration(seconds: 30));

			if (response.statusCode == 200) {
				final Map<String, dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
				return decoded['reply'] as String? ?? 'لا يوجد رد.';
			} else {
				return 'خطأ في الخادم (${response.statusCode})\n${response.body}';
			}
		} on TimeoutException {
			return 'انتهى وقت الانتظار، يرجى المحاولة لاحقاً';
		} on http.ClientException catch (e) {
			return 'خطأ في الاتصال: ${e.message}';
		} catch (e) {
			return 'حدث خطأ غير متوقع: $e';
		}
	}
}