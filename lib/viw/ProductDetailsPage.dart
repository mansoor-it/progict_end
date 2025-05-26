import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/ProductDetailsPage_server.dart';
import '../service/server_cart.dart';
import 'cart_screen.dart';

List<Map<String, dynamic>> cartItems = []; // قائمة السلة

class AllProductsPage extends StatefulWidget {
	final String storeId;
	final String storeName;

	const AllProductsPage({
		Key? key,
		required this.storeId,
		required this.storeName,
	}) : super(key: key);

	@override
	_AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
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
			final data = await _controller.fetchAllData(widget.storeId);
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
					title: Text(widget.storeName),
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
									// أضف الآن storeId إلى الطلب
									final success =
									await _cartController.addCartItem(
										userId: '1',
										storeId: widget.storeId,    // ← storeId هنا
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
											// خزن أيضًا storeId محليًا
											cartItems.add({
												...itemMap,
												'store_id': widget.storeId,
											});
										}

										ScaffoldMessenger.of(context).showSnackBar(
											SnackBar(
												content: Text(
														"تمت إضافة ${itemMap['name']} من ${widget.storeName} إلى السلة"),
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

class ProductCard extends StatefulWidget {
	final dynamic product;
	final List<dynamic> productColors;
	final List<dynamic> productSizes;
	final Color Function(String) getColorFromName;
	final Future<void> Function(Map<String, dynamic>) onAddToCart;

	const ProductCard({
		Key? key,
		required this.product,
		required this.productColors,
		required this.productSizes,
		required this.getColorFromName,
		required this.onAddToCart,
	}) : super(key: key);

	@override
	_ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
	int quantity = 1;
	String? selectedColor;
	String? selectedSize;

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.all(8),
			elevation: 3,
			child: Padding(
				padding: const EdgeInsets.all(8.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						widget.product['image'] != null &&
								widget.product['image'].toString().isNotEmpty
								? ClipRRect(
							borderRadius: BorderRadius.circular(12),
							child: Image.memory(
								base64Decode(widget.product['image']),
								height: 200,
								width: double.infinity,
								fit: BoxFit.cover,
							),
						)
								: Container(
							height: 200,
							color: Colors.grey[300],
							child: const Center(child: Text("لا توجد صورة")),
						),
						const SizedBox(height: 8),
						Text(
							widget.product['name'] ?? "اسم المنتج",
							style:
							const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 4),
						Text(widget.product['description'] ?? "وصف المنتج"),
						const SizedBox(height: 4),
						Text(
							"السعر: ${widget.product['price']} \$",
							style: const TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.green),
						),
						const SizedBox(height: 8),

						// اختيار اللون
						if (widget.productColors.isNotEmpty) ...[
							const Text("اختر اللون:"),
							DropdownButton<String>(
								value: selectedColor,
								hint: const Text("اختر لونًا"),
								onChanged: (value) {
									setState(() {
										selectedColor = value;
									});
								},
								items: widget.productColors
										.map<DropdownMenuItem<String>>((colorItem) {
									return DropdownMenuItem<String>(
										value: colorItem['color_name'],
										child: Row(
											children: [
												CircleAvatar(
													backgroundColor:
													widget.getColorFromName(colorItem['color_name']),
													radius: 8,
												),
												const SizedBox(width: 8),
												Text(colorItem['color_name']),
											],
										),
									);
								}).toList(),
							),
						],

						// اختيار المقاس
						if (widget.productSizes.isNotEmpty) ...[
							const SizedBox(height: 8),
							const Text("اختر المقاس:"),
							DropdownButton<String>(
								value: selectedSize,
								hint: const Text("اختر مقاسًا"),
								onChanged: (value) {
									setState(() {
										selectedSize = value;
									});
								},
								items: widget.productSizes
										.map<DropdownMenuItem<String>>((sizeItem) {
									return DropdownMenuItem<String>(
										value: sizeItem['size'],
										child: Text(sizeItem['size']),
									);
								}).toList(),
							),
						],

						const SizedBox(height: 8),
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								// الكمية
								Row(
									children: [
										IconButton(
											icon: const Icon(Icons.remove),
											onPressed: quantity > 1
													? () {
												setState(() {
													quantity--;
												});
											}
													: null,
										),
										Text(quantity.toString()),
										IconButton(
											icon: const Icon(Icons.add),
											onPressed: () {
												setState(() {
													quantity++;
												});
											},
										),
									],
								),
								ElevatedButton(
									onPressed: () {
										if (widget.productColors.isNotEmpty &&
												selectedColor == null) {
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(content: Text("يرجى اختيار لون")),
											);
											return;
										}
										if (widget.productSizes.isNotEmpty &&
												selectedSize == null) {
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(content: Text("يرجى اختيار مقاس")),
											);
											return;
										}

										widget.onAddToCart({
											'id': widget.product['id'],
											'name': widget.product['name'],
											'price': widget.product['price'],
											'quantity': quantity,
											'color': selectedColor,
											'size': selectedSize,
											'image': widget.product['image'], // ✅ إضافة الصورة
										});
									},
									child: const Text("أضف إلى السلة"),
								),
							],
						),
					],
				),
			),
		);
	}
}
