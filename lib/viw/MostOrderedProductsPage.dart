import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

class MostOrderedProductsPage extends StatefulWidget {
	const MostOrderedProductsPage({super.key});

	@override
	State<MostOrderedProductsPage> createState() => _MostOrderedProductsPageState();
}

class _MostOrderedProductsPageState extends State<MostOrderedProductsPage> {
	List<dynamic> products = [];
	bool isLoading = true;
	String? errorMessage;

	@override
	void initState() {
		super.initState();
		fetchMostOrderedProducts();
	}

	Future<void> fetchMostOrderedProducts() async {
		setState(() {
			isLoading = true;
			errorMessage = null;
		});

		try {
			//const String url = '"http://172.25.30.9/ecommerce/get_most_ordered_products.php';
			final url = Uri.parse(ApiHelper.url('get_most_ordered_products.php'));
			final response = await http.get(url);

			if (response.statusCode == 200) {
				final data = jsonDecode(response.body);
				if (data['status'] == 'success') {
					setState(() {
						products = data['products'];
						isLoading = false;
					});
				} else {
					setState(() {
						errorMessage = 'فشل في تحميل المنتجات: ${data['message'] ?? 'خطأ غير معروف'}';
						isLoading = false;
					});
				}
			} else {
				setState(() {
					errorMessage = 'خطأ في الاتصال بالسيرفر: رمز الحالة ${response.statusCode}';
					isLoading = false;
				});
			}
		} catch (e) {
			setState(() {
				errorMessage = 'حدث خطأ غير متوقع. الرجاء المحاولة لاحقًا.';
				isLoading = false;
			});
		}
	}

	// دالة للحصول على كلمة مفتاحية من اسم المنتج (أول كلمة فقط هنا)
	String getKeyword(String productName) {
		final words = productName.split(' ');
		return words.isNotEmpty ? words[0].toLowerCase() : '';
	}

	// البحث عن منتجات مشابهة بناءً على الكلمة المفتاحية
	List<Map<String, dynamic>> getSimilarProducts(String keyword, String currentProductId) {
		return products.where((product) {
			final name = (product['product_name'] ?? '').toString().toLowerCase();
			final id = product['id'].toString();
			return name.contains(keyword) && id != currentProductId; // نستبعد نفس المنتج
		}).cast<Map<String, dynamic>>().toList();
	}

	void showSimilarProductsDialog(BuildContext context, String productName, String productId) {
		final keyword = getKeyword(productName);
		final similarProducts = getSimilarProducts(keyword, productId);

		showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: Text('منتجات مشابهة لـ "$keyword"'),
					content: similarProducts.isEmpty
							? const Text('لا توجد منتجات مشابهة.')
							: SizedBox(
						width: double.maxFinite,
						height: 300,
						child: ListView.builder(
							itemCount: similarProducts.length,
							itemBuilder: (context, index) {
								final product = similarProducts[index];
								return ListTile(
									leading: product['image'] != null && product['image'].toString().isNotEmpty
											? Image.memory(
										base64Decode(product['image']),
										width: 40,
										height: 40,
										fit: BoxFit.cover,
									)
											: const Icon(Icons.image_not_supported),
									title: Text(product['product_name'] ?? ''),
									subtitle: Text('السعر: ${product['price']}'),
								);
							},
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(),
							child: const Text('إغلاق'),
						),
					],
				);
			},
		);
	}

	Widget buildProductItem(Map<String, dynamic> product) {
		return Card(
			margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
			elevation: 3,
			child: ListTile(
				leading: product['image'] != null && product['image'].toString().isNotEmpty
						? Image.memory(
					base64Decode(product['image']),
					width: 50,
					height: 50,
					fit: BoxFit.cover,
				)
						: const Icon(Icons.image_not_supported),
				title: Text(product['product_name'] ?? ''),
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text('السعر: ${product['price']}'),
						Text('الكمية المطلوبة: ${product['total_ordered']}'),
						Text('الحالة: ${product['status']}'),
						const SizedBox(height: 6),
						ElevatedButton(
							onPressed: () => showSimilarProductsDialog(context, product['product_name'] ?? '', product['id'].toString()),
							child: const Text('منتجات مشابهة'),
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('المنتجات الأكثر طلبًا'),
			),
			body: isLoading
					? const Center(child: CircularProgressIndicator())
					: errorMessage != null
					? Center(
				child: Text(
					errorMessage!,
					style: const TextStyle(color: Colors.red, fontSize: 16),
				),
			)
					: products.isEmpty
					? const Center(child: Text('لا توجد منتجات متاحة.'))
					: ListView.builder(
				itemCount: products.length,
				itemBuilder: (context, index) => buildProductItem(products[index]),
			),
		);
	}
}
