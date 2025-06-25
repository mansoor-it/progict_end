import 'package:flutter/material.dart';
class ApiHelper {
	static const String _baseUrl = "http://192.168.7.140/ecommerce/";

	/// تُرجع الرابط الكامل بناءً على اسم ملف PHP
	static String url(String fileName) {
		return '$_baseUrl$fileName';
	}
}
