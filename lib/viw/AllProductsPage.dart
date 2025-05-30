import 'package:flutter/material.dart';
import 'dart:convert';

import '../service/ProductDetailsPage_server.dart';
import '../service/server_cart.dart';
import 'ProductDetailsPage.dart';
import 'cart_screen.dart';

List<Map<String, dynamic>> cartItems = [];

class AllProductsPageNew extends StatefulWidget {
	const AllProductsPageNew({Key? key}) : super(key: key);

	@override
	_AllProductsPageNewState createState() => _AllProductsPageNewState();
}

class _AllProductsPageNewState extends State<AllProductsPageNew> {
	List<dynamic> products = [];
	List<dynamic> colors = [];
	List<dynamic> sizes = [];
	bool isLoading = true;

	final AllProductsController _controller = AllProductsController();
	final CartController _cartController = CartController();

	// 🔍 متغيرات البحث والفرز
	String _searchQuery = '';
	String _sortBy = 'الاسم تصاعدي';
	bool _isSearching = false;

	// 📋 قائمة المنتجات المؤقتة بعد الفلتر
	List<dynamic> get filteredProducts {
		List<dynamic> result = [...products];

		// 🔍 البحث
		if (_searchQuery.isNotEmpty) {
			result = result.where((product) =>
					product['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
		}

		// 🧮 الفرز
		switch (_sortBy) {
			case 'الاسم تنازلي':
				result.sort((a, b) => b['name'].compareTo(a['name']));
				break;
			case 'السعر من الأقل':
				result.sort((a, b) => double.parse(a['price']).compareTo(double.parse(b['price'])));
				break;
			case 'السعر من الأكثر':
				result.sort((a, b) => double.parse(b['price']).compareTo(double.parse(a['price'])));
				break;
			case 'الحجم':
				result.sort((a, b) {
					final aSize = sizes
							.where((s) => s['product_id'] == a['id'])
							.map((s) => s['name'])
							.firstOrNull ?? '';
					final bSize = sizes
							.where((s) => s['product_id'] == b['id'])
							.map((s) => s['name'])
							.firstOrNull ?? '';
					return aSize.compareTo(bSize);
				});
				break;
			case 'اللون':
				result.sort((a, b) {
					final aColor = colors
							.where((c) => c['product_id'] == a['id'])
							.map((c) => c['name'])
							.firstOrNull ?? '';
					final bColor = colors
							.where((c) => c['product_id'] == b['id'])
							.map((c) => c['name'])
							.firstOrNull ?? '';
					return aColor.compareTo(bColor);
				});
				break;
			case 'الاسم تصاعدي': // الافتراضي
			default:
				result.sort((a, b) => a['name'].compareTo(b['name']));
				break;
		}

		return result;
	}

	Future<void> fetchAllData() async {
		try {
			final data = await _controller.fetchAllDataWithoutStoreId();
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
	void initState() {
		super.initState();
		fetchAllData();
	}

	@override
	Widget build(BuildContext context) {
		return Directionality(
			textDirection: TextDirection.rtl,
			child: Scaffold(
				appBar: AppBar(
					title: _isSearching
							? TextField(
						autofocus: true,
						style: const TextStyle(color: Colors.white),
						decoration: const InputDecoration(
							hintText: "ابحث عن منتج...",
							hintStyle: TextStyle(color: Colors.white70),
							border: InputBorder.none,
							suffixIcon: Icon(Icons.search, color: Colors.white),
						),
						onChanged: (value) {
							setState(() {
								_searchQuery = value;
							});
						},
					)
							: const Text("كل المنتجات"),
					actions: [
						// زر البحث
						if (!_isSearching)
							IconButton(
								icon: const Icon(Icons.search),
								onPressed: () {
									setState(() {
										_isSearching = true;
									});
								},
							),
						// زر إلغاء البحث
						if (_isSearching)
							IconButton(
								icon: const Icon(Icons.close),
								onPressed: () {
									setState(() {
										_isSearching = false;
										_searchQuery = '';
									});
								},
							),

						// قائمة الفرز
						PopupMenuButton<String>(
							onSelected: (value) {
								setState(() {
									_sortBy = value;
								});
							},
							itemBuilder: (context) => [
								const PopupMenuItem(value: 'الاسم تصاعدي', child: Text('الاسم تصاعدي')),
								const PopupMenuItem(value: 'الاسم تنازلي', child: Text('الاسم تنازلي')),
								const PopupMenuItem(value: 'السعر من الأقل', child: Text('السعر من الأقل')),
								const PopupMenuItem(value: 'السعر من الأكثر', child: Text('السعر من الأكثر')),
								const PopupMenuItem(value: 'الحجم', child: Text('حسب الحجم')),
								const PopupMenuItem(value: 'اللون', child: Text('حسب اللون')),
							],
							icon: const Icon(Icons.sort),
						),

						IconButton(
							icon: const Icon(Icons.shopping_cart),
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => CartPage(userId: '1', cartItems: cartItems),
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
					itemCount: filteredProducts.length,
					itemBuilder: (context, index) {
						final product = filteredProducts[index];
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