import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

// const String apiBaseUrl = "http://190.30.24.218/ecommerce/u.php";
final String apiBaseUrl = ApiHelper.url('u.php');

class AllProductsController {
	Future<Map<String, dynamic>> fetchAllData(String storeId) async {
		List<dynamic> products = [];
		List<dynamic> colors = [];
		List<dynamic> sizes = [];
		bool isLoading = true;

		try {
			final productResponse = await http.get(Uri.parse(
					"$apiBaseUrl?entity=product&action=fetch&store_id=$storeId"));
			final colorResponse =
			await http.get(Uri.parse("$apiBaseUrl?entity=color&action=fetch"));
			final sizeResponse =
			await http.get(Uri.parse("$apiBaseUrl?entity=size&action=fetch"));

			if (productResponse.statusCode == 200 &&
					colorResponse.statusCode == 200 &&
					sizeResponse.statusCode == 200) {
				products = (json.decode(productResponse.body) as List)
						.where((product) =>
				product['store_id'].toString() == storeId)
						.toList();
				colors = json.decode(colorResponse.body);
				sizes = json.decode(sizeResponse.body);
				isLoading = false;
			} else {
				throw Exception("خطأ في جلب البيانات من الخادم");
			}
		} catch (e) {
			print("Error: $e");
			isLoading = false;
		}
		return {
			'products': products,
			'colors': colors,
			'sizes': sizes,
			'isLoading': isLoading,
		};
	}

	/// ✅ دالة جديدة لجلب جميع المنتجات بدون استخدام store_id
	Future<Map<String, dynamic>> fetchAllDataWithoutStoreId() async {
		List<dynamic> products = [];
		List<dynamic> colors = [];
		List<dynamic> sizes = [];
		bool isLoading = true;

		try {
			final productResponse = await http.get(
				Uri.parse("$apiBaseUrl?entity=product&action=fetch"),
			);
			final colorResponse = await http.get(
				Uri.parse("$apiBaseUrl?entity=color&action=fetch"),
			);
			final sizeResponse = await http.get(
				Uri.parse("$apiBaseUrl?entity=size&action=fetch"),
			);

			if (productResponse.statusCode == 200 &&
					colorResponse.statusCode == 200 &&
					sizeResponse.statusCode == 200) {
				products = json.decode(productResponse.body);
				colors = json.decode(colorResponse.body);
				sizes = json.decode(sizeResponse.body);
				isLoading = false;
			} else {
				throw Exception("خطأ في جلب البيانات من الخادم");
			}
		} catch (e) {
			print("Error: $e");
			isLoading = false;
		}

		return {
			'products': products,
			'colors': colors,
			'sizes': sizes,
			'isLoading': isLoading,
		};
	}

	// دالة لتحويل اسم اللون إلى كائن Color
	Color getColorFromName(String colorName) {
		switch (colorName.toLowerCase()) {
			case 'red':
			case 'أحمر':
			case 'احمر':
				return Colors.red;
			case 'blue':
			case 'أزرق':
			case 'ازرق':
				return Colors.blue;
			case 'green':
			case 'أخضر':
			case 'اخضر':
				return Colors.green;
			case 'black':
			case 'اسود':
			case 'أسود':
				return Colors.black;
			case 'white':
			case 'أبيض':
			case 'ابيض':
				return Colors.white;

		// ألوان إضافية شائعة
			case 'yellow':
			case 'أصفر':
			case 'اصفر':
				return Colors.yellow;
			case 'orange':
			case 'برتقالي':
				return Colors.orange;
			case 'purple':
			case 'بنفسجي':
				return Colors.purple;
			case 'pink':
			case 'وردي':
				return Colors.pink;
			case 'brown':
			case 'بني':
				return Colors.brown;
			case 'grey':
			case 'gray':
			case 'رمادي':
				return Colors.grey;

		// ألوان متقدمة
			case 'golden':
			case 'gold':
			case 'ذهبي':
				return const Color(0xFFFFD700); // ذهبي ملكي
			case 'silver':
			case 'فضي':
				return const Color(0xFFC0C0C0);
			case 'navy':
			case 'كحلي':
				return Colors.indigo[900]!;
			case 'maroon':
			case 'عنابي':
				return const Color(0xFF800000);
			case 'olive':
			case 'زيتوني':
				return const Color(0xFF808000);
			case 'lime':
			case 'ليموني':
				return Colors.lime;
			case 'cyan':
			case 'سماوي':
				return Colors.cyan;
			case 'teal':
			case 'أزرق مخضر':
			case 'ازرق مخضر':
				return Colors.teal;
			case 'indigo':
			case 'نيلي':
				return Colors.indigo;
			case 'violet':
			case 'بنفسجي فاتح':
				return const Color(0xFF8A2BE2);
			case 'turquoise':
			case 'فيروزي':
				return const Color(0xFF40E0D0);
			case 'coral':
			case 'مرجاني':
				return const Color(0xFFFF7F50);
			case 'salmon':
			case 'سلموني':
				return const Color(0xFFFA8072);
			case 'khaki':
			case 'كاكي':
				return const Color(0xFFF0E68C);
			case 'beige':
			case 'بيج':
				return const Color(0xFFF5F5DC);
			case 'ivory':
			case 'عاجي':
				return const Color(0xFFFFFFF0);
			case 'crimson':
			case 'قرمزي':
				return const Color(0xFFDC143C);
			case 'scarlet':
			case 'قرمزي فاتح':
				return const Color(0xFFFF2400);

		// درجات الأزرق
			case 'light blue':
			case 'ازرق فاتح':
				return Colors.lightBlue;
			case 'dark blue':
			case 'ازرق غامق':
				return Colors.blue[900]!;
			case 'sky blue':
			case 'ازرق سماوي':
				return const Color(0xFF87CEEB);
			case 'royal blue':
			case 'ازرق ملكي':
				return const Color(0xFF4169E1);
			case 'midnight blue':
			case 'ازرق ليلي':
				return const Color(0xFF191970);
			case 'steel blue':
			case 'ازرق فولاذي':
				return const Color(0xFF4682B4);
			case 'powder blue':
			case 'ازرق بودرة':
				return const Color(0xFFB0E0E6);
			case 'cornflower blue':
			case 'ازرق ذرة':
				return const Color(0xFF6495ED);

		// درجات الأخضر
			case 'light green':
			case 'اخضر فاتح':
				return Colors.lightGreen;
			case 'dark green':
			case 'اخضر غامق':
				return Colors.green[900]!;
			case 'forest green':
			case 'اخضر غابات':
				return const Color(0xFF228B22);
			case 'emerald':
			case 'زمردي':
				return const Color(0xFF50C878);
			case 'chartreuse':
			case 'اخضر فسفوري':
				return const Color(0xFF7FFF00);
			case 'sea green':
			case 'اخضر بحري':
				return const Color(0xFF2E8B57);
			case 'lime green':
			case 'اخضر ليموني':
				return Colors.limeAccent[400]!;

		// درجات الأحمر
			case 'light red':
			case 'احمر فاتح':
				return Colors.red[300]!;
			case 'dark red':
			case 'احمر غامق':
				return Colors.red[900]!;
			case 'firebrick':
			case 'طوبي':
				return const Color(0xFFB22222);
			case 'indian red':
			case 'احمر هندي':
				return const Color(0xFFCD5C5C);
			case 'burgundy':
			case 'برغندي':
				return const Color(0xFF800020); // أحمر داكن مائل للبنفسجي
			case 'ruby':
			case 'ياقوتي':
				return const Color(0xFFE0115F); // أحمر عميق

		// درجات الأصفر
			case 'light yellow':
			case 'اصفر فاتح':
				return Colors.yellow[200]!;
			case 'goldenrod':
			case 'ذهبي داكن':
				return const Color(0xFFDAA520);
			case 'lemon chiffon':
			case 'اصفر ليموني فاتح':
				return const Color(0xFFFFFACD);
			case 'mustard':
			case 'خردلي':
				return const Color(0xFFFFDB58); // أصفر بني

		// درجات البرتقالي
			case 'dark orange':
			case 'برتقالي غامق':
				return Colors.deepOrange;
			case 'tangerine':
			case 'يوسفي':
				return const Color(0xFFF28500);
			case 'burnt orange':
			case 'برتقالي محروق':
				return const Color(0xFFCC5500);

		// درجات البنفسجي
			case 'lavender':
			case 'لافندر':
				return const Color(0xFFE6E6FA);
			case 'plum':
			case 'برقوقي':
				return const Color(0xFFDDA0DD);
			case 'magenta':
			case 'ارجواني':
				return Colors.pink[400]!; // أو const Color(0xFFFF00FF);
			case 'amethyst':
			case 'جمشت':
				return const Color(0xFF9966CC); // بنفسجي زاهي

		// درجات الوردي
			case 'hot pink':
			case 'وردي فاقع':
				return const Color(0xFFFF69B4);
			case 'deep pink':
			case 'وردي غامق':
				return Colors.pink[800]!;
			case 'rose':
			case 'وردي محمر':
				return const Color(0xFFFF007F);
			case 'fuchsia':
			case 'فوشيا':
				return const Color(0xFFFF00FF); // وردي أرجواني

		// درجات البني
			case 'saddle brown':
			case 'بني محمر':
				return const Color(0xFF8B4513);
			case 'peru':
			case 'بني رملي':
				return const Color(0xFFCD853F);
			case 'chocolate':
			case 'شوكولاتة':
				return const Color(0xFFD2691E);
			case 'mocha':
			case 'موكا':
				return const Color(0xFF785B31); // بني متوسط

		// درجات الرمادي
			case 'light grey':
			case 'light gray':
			case 'رمادي فاتح':
				return Colors.grey[300]!;
			case 'dark grey':
			case 'dark gray':
			case 'رمادي غامق':
				return Colors.grey[700]!;
			case 'slate grey':
			case 'slate gray':
			case 'رمادي أردوازي':
				return const Color(0xFF708090);
			case 'charcoal':
			case 'فحمي':
				return const Color(0xFF36454F); // رمادي داكن جداً

		// ألوان أخرى مثيرة للاهتمام
			case 'mint green':
			case 'اخضر نعناعي':
				return const Color(0xFF98FB98);
			case 'peach':
			case 'خوخي':
				return const Color(0xFFFFE5B4);
			case 'periwinkle':
			case 'بنفسجي مزرق':
				return const Color(0xFFCCCCFF);
			case 'tan':
			case 'اسمر':
				return const Color(0xFFD2B48C);
			case 'wheat':
			case 'قمحي':
				return const Color(0xFFF5DEB3);
			case 'apricot':
			case 'مشمشي':
				return const Color(0xFFFBCEB1);
			case 'lavender blush':
			case 'زهري لافندر':
				return const Color(0xFFFFF0F5);
			case 'linen':
			case 'كتاني':
				return const Color(0xFFFAF0E6);
			case 'cornsilk':
			case 'حرير الذرة':
				return const Color(0xFFFFF8DC); // أبيض مصفر
			case 'honeydew':
			case 'شمامي':
				return const Color(0xFFF0FFF0); // أخضر فاتح جداً
			case 'azure':
			case 'ازرق سماوي عميق':
				return const Color(0xFF007FFF); // أزرق سماوي عميق
			case 'sepia':
			case 'بني داكن':
				return const Color(0xFF704214); // بني محمر داكن
			case 'celeste':
			case 'سماوي فاتح':
				return const Color(0xFFB2FFFF); // أزرق فاتح جداً (سمائي)
			case 'rust':
			case 'صدا':
				return const Color(0xFFB7410E); // برتقالي مائل للبني

			default:
				return Colors.black;
		}
	}
}
