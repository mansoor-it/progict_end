import 'package:flutter/material.dart';
class ApiHelper {
	static const String _baseUrl = "http://172.16.197.11/ecommerce/";

	/// تُرجع الرابط الكامل بناءً على اسم ملف PHP
	static String url(String fileName) {
		return '$_baseUrl$fileName';
	}
}
