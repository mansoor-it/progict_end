import 'package:flutter/material.dart';
import 'dart:convert';

import '../service/ProductDetailsPage_server.dart';
import '../service/server_cart.dart';
import 'ProductDetailsPage.dart';
import 'cart_screen.dart';

List<Map<String, dynamic>> cartItems = [];

class AllProductsPageNew extends StatefulWidget { // ✅ تغيير اسم الكلاس فقط
	const AllProductsPageNew({Key? key}) : super(key: key);

	@override
	_AllProductsPageNewState createState() => _AllProductsPageNewState(); // ✅ تغيير هنا أيضًا
}

class _AllProductsPageNewState extends State<AllProductsPageNew> {
	List<dynamic> products = [];
	List<dynamic> colors = [];
	List<dynamic> sizes = [];
	bool isLoading = true;

	final AllProductsController _controller = AllProductsController();
	final CartController _cartController = CartController();

	@override
	void initState() {
		super.initState();
		fetchAllData();
	}
	Future<void> fetchAllData() async {
		try {
			final data = await _controller.fetchAllDataWithoutStoreId(); // ✅ استدعاء الدالة الجديدة
			setState(() {
				products = data['products'];
				colors = data['colors'];
				sizes = data['sizes'];
				isLoading = data['isLoading'];
			});
		} catch (e) {
			print("Error: $e");
			setState(() {
				isLoading = false;
			});
		}
	}

	Color getColorFromName(String colorName) {
		return _controller.getColorFromName(colorName);
	}

	@override
	Widget build(BuildContext context) {
		return Directionality(
			textDirection: TextDirection.rtl,
			child: Scaffold(
				appBar: AppBar(
					title: const Text("كل المنتجات"),
					actions: [
						IconButton(
							icon: const Icon(Icons.shopping_cart),
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) =>
												CartPage(userId: '1', cartItems: cartItems),
									),
								);
							},
						),
					],
				),
				body: isLoading
						? const Center(child: CircularProgressIndicator())
						: products.isEmpty
						? const Center(child: Text("لا توجد منتجات"))
						: ListView.builder(
					itemCount: products.length,
					itemBuilder: (context, index) {
						final product = products[index];
						final productColors = colors
								.where((c) =>
						c['product_id'].toString() ==
								product['id'].toString())
								.toList();
						final productSizes = sizes
								.where((s) =>
						s['product_id'].toString() ==
								product['id'].toString())
								.toList();

						return ProductCard(
							product: product,
							productColors: productColors,
							productSizes: productSizes,
							getColorFromName: getColorFromName,
							onAddToCart: (itemMap) async {
								try {
									final success = await _cartController.addCartItem(
										userId: '1',
										storeId: itemMap['store_id'] ?? '0',
										productId: itemMap['id'].toString(),
										quantity: itemMap['quantity'].toString(),
										unitPrice: itemMap['price'].toString(),
									);

									if (success) {
										final existingIndex = cartItems.indexWhere(
													(cartItem) =>
											cartItem['id'] == itemMap['id'] &&
													cartItem['color'] == itemMap['color'] &&
													cartItem['size'] == itemMap['size'],
										);
										if (existingIndex != -1) {
											cartItems[existingIndex]['quantity'] +=
											itemMap['quantity'];
										} else {
											cartItems.add({
												...itemMap,
												'store_id': itemMap['store_id'] ?? '0',
											});
										}

										ScaffoldMessenger.of(context).showSnackBar(
											SnackBar(
												content: Text(
														"تمت إضافة ${itemMap['name']} إلى السلة"),
											),
										);
									} else {
										ScaffoldMessenger.of(context).showSnackBar(
											const SnackBar(
												content: Text(
														"حدث خطأ أثناء إضافة المنتج إلى السلة"),
											),
										);
									}
								} catch (e) {
									ScaffoldMessenger.of(context).showSnackBar(
										SnackBar(content: Text(e.toString())),
									);
								}
							},
						);
					},
				),
			),
		);
	}
}
