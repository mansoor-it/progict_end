import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/ProductDetailsPage_server.dart'; // تأكد من صحة المسار
import '../service/server_cart.dart'; // تأكد من صحة المسار
import 'cart_screen.dart'; // تأكد من صحة المسار
import '../model/user_model.dart'; // <-- إضافة استيراد لنموذج المستخدم
import '../model/model_cart.dart'; // <-- استيراد نموذج السلة

// ملاحظة: يفضل إدارة حالة السلة بشكل أفضل (مثل استخدام Provider أو Riverpod)
// بدلاً من قائمة عامة مثل هذه.
List<Map<String, dynamic>> cartItems = [];

class AllProductsPage extends StatefulWidget {
	final String storeId;
	final String storeName;
	final User user; // <-- إضافة متغير لاستقبال المستخدم

	const AllProductsPage({
		Key? key,
		required this.storeId,
		required this.storeName,
		required this.user, // <-- جعله مطلوبًا في المنشئ
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
			if (mounted) {
				setState(() {
					products = data['products'] ?? [];
					colors = data['colors'] ?? [];
					sizes = data['sizes'] ?? [];
					isLoading = false;
				});
			}
		} catch (e) {
			print("Error fetching products data: $e");
			if (mounted) {
				setState(() {
					isLoading = false;
				});
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('حدث خطأ أثناء جلب المنتجات')),
				);
			}
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
					backgroundColor: Colors.brown,
					foregroundColor: Colors.white,
					actions: [
						IconButton(
							icon: Badge(
								label: Text(cartItems.length.toString()),
								isLabelVisible: cartItems.isNotEmpty,
								child: const Icon(Icons.shopping_cart_outlined),
							),
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => CartPage(
											userId: widget.user.id, // استخدام معرف المستخدم الفعلي
											cartItems: cartItems, // تمرير القائمة المحلية
										),
									),
								);
							},
						),
					],
				),
				body: isLoading
						? const Center(child: CircularProgressIndicator(color: Colors.brown))
						: products.isEmpty
						? const Center(child: Text("لا توجد منتجات متاحة حاليًا في هذا المتجر."))
						: ListView.builder(
					padding: const EdgeInsets.all(8.0),
					itemCount: products.length,
					itemBuilder: (context, index) {
						final product = products[index];
						if (product == null || product['id'] == null) {
							return const SizedBox.shrink();
						}

						final productIdStr = product['id'].toString();
						final productColors = colors
								.where((c) => c != null && c['product_id']?.toString() == productIdStr)
								.toList();
						final productSizes = sizes
								.where((s) => s != null && s['product_id']?.toString() == productIdStr)
								.toList();

						return ProductCard(
							product: product,
							productColors: productColors,
							productSizes: productSizes,
							getColorFromName: getColorFromName,
							onAddToCart: (itemMap) async {
								try {
									// --- تعديل هنا: تمرير اسم اللون والمقاس أيضاً إلى الخادم ---
									final success =
									await _cartController.addCartItem(
										userId: widget.user.id,
										storeId: widget.storeId,
										productId: itemMap['id'].toString(),
										quantity: itemMap['quantity'].toString(),
										unitPrice: itemMap['price'].toString(),
										productColorId: itemMap['color_id']?.toString(),
										productSizeId: itemMap['size_id']?.toString(),
										productImage: itemMap['image']?.toString(),
										// إضافة أسماء اللون والمقاس (إذا كان الخادم يدعم استقبالها)
										// productColorName: itemMap['color_name']?.toString(),
										// productSizeName: itemMap['size_name']?.toString(),
									);
									// ------------------------------------------------------

									if (success) {
										// --- تعديل هنا: تحديث قائمة السلة المحلية بالأسماء ---
										final existingIndex = cartItems.indexWhere(
														(cartItem) =>
												cartItem['id'] == itemMap['id'] &&
														cartItem['color_id'] == itemMap['color_id'] &&
														cartItem['size_id'] == itemMap['size_id'] &&
														cartItem['store_id'] == widget.storeId
										);
										if (existingIndex != -1) {
											setState(() {
												cartItems[existingIndex]['quantity'] +=
												itemMap['quantity'];
												// تحديث السعر الإجمالي إذا لزم الأمر
											});
										} else {
											setState(() {
												// إضافة العنصر الجديد مع اسم اللون والمقاس
												cartItems.add({
													...itemMap, // يتضمن الآن color_name و size_name من ProductCard
													'store_id': widget.storeId,
												});
											});
										}
										// ------------------------------------------------------

										if (mounted) {
											ScaffoldMessenger.of(context).showSnackBar(
												SnackBar(
													content: Text(
															"تمت إضافة ${itemMap['name']} إلى السلة"),
													backgroundColor: Colors.green,
												),
											);
										}
									} else {
										if (mounted) {
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(
													content: Text(
															"فشل إضافة المنتج إلى السلة. حاول مرة أخرى."),
													backgroundColor: Colors.red,
												),
											);
										}
									}
								} catch (e) {
									print("Error adding item to cart: $e");
									if (mounted) {
										ScaffoldMessenger.of(context).showSnackBar(
											SnackBar(
												content: Text("حدث خطأ: ${e.toString()}"),
												backgroundColor: Colors.red,
											),
										);
									}
								}
							},
						);
					},
				),
			),
		);
	}
}

// --- ProductCard Widget (مع تعديلات لتمرير ID واسم اللون والمقاس) ---
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
	String? selectedColorId;
	String? selectedColorName; // <-- تخزين اسم اللون
	String? selectedSizeId;
	String? selectedSizeName; // <-- تخزين اسم المقاس

	Widget _buildProductImage() {
		final imageBase64 = widget.product['image']?.toString();
		if (imageBase64 != null && imageBase64.isNotEmpty) {
			try {
				return ClipRRect(
					borderRadius: BorderRadius.circular(12),
					child: Image.memory(
						base64Decode(imageBase64),
						height: 200,
						width: double.infinity,
						fit: BoxFit.cover,
						errorBuilder: (context, error, stackTrace) {
							return _buildPlaceholderImage("خطأ في تحميل الصورة");
						},
					),
				);
			} catch (e) {
				print("Error decoding image: $e");
				return _buildPlaceholderImage("صورة غير صالحة");
			}
		} else {
			return _buildPlaceholderImage("لا توجد صورة");
		}
	}

	Widget _buildPlaceholderImage(String message) {
		return Container(
			height: 200,
			width: double.infinity,
			decoration: BoxDecoration(
				color: Colors.grey[200],
				borderRadius: BorderRadius.circular(12),
			),
			child: Center(
				child: Text(message, style: TextStyle(color: Colors.grey[600])),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final price = widget.product['price']?.toString() ?? '0.0';

		return Card(
			margin: const EdgeInsets.symmetric(vertical: 8.0),
			elevation: 2,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			clipBehavior: Clip.antiAlias,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					_buildProductImage(),
					Padding(
						padding: const EdgeInsets.all(12.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									widget.product['name'] ?? "اسم المنتج غير متوفر",
									style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
								),
								const SizedBox(height: 4),
								Text(
									widget.product['description'] ?? "لا يوجد وصف",
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
								),
								const SizedBox(height: 8),
								Text(
									"السعر: $price \$",
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.bold,
										color: Colors.green[700],
									),
								),
								const SizedBox(height: 12),

								// اختيار اللون والمقاس
								Row(
									children: [
										if (widget.productColors.isNotEmpty) ...[
											Expanded(
												child: DropdownButtonFormField<String>(
													value: selectedColorId,
													hint: const Text("اللون"),
													decoration: InputDecoration(
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
														contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
													),
													onChanged: (value) {
														setState(() {
															selectedColorId = value;
															// البحث عن اسم اللون المطابق للمعرف المحدد
															final selectedColorItem = widget.productColors.firstWhere(
																		(c) => c['id']?.toString() == value,
																orElse: () => null,
															);
															selectedColorName = selectedColorItem?['color_name']?.toString();
														});
													},
													items: widget.productColors
															.map<DropdownMenuItem<String>>((colorItem) {
														final colorName = colorItem['color_name']?.toString() ?? '';
														final colorId = colorItem['id']?.toString();
														return DropdownMenuItem<String>(
															value: colorId,
															child: Row(
																children: [
																	CircleAvatar(
																		backgroundColor: widget.getColorFromName(colorName),
																		radius: 8,
																	),
																	const SizedBox(width: 8),
																	Text(colorName),
																],
															),
														);
													}).toList(),
												),
											),
											const SizedBox(width: 8),
										],
										if (widget.productSizes.isNotEmpty) ...[
											Expanded(
												child: DropdownButtonFormField<String>(
													value: selectedSizeId,
													hint: const Text("المقاس"),
													decoration: InputDecoration(
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
														contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
													),
													onChanged: (value) {
														setState(() {
															selectedSizeId = value;
															// البحث عن اسم المقاس المطابق للمعرف المحدد
															final selectedSizeItem = widget.productSizes.firstWhere(
																		(s) => s['id']?.toString() == value,
																orElse: () => null,
															);
															selectedSizeName = selectedSizeItem?['size']?.toString();
														});
													},
													items: widget.productSizes
															.map<DropdownMenuItem<String>>((sizeItem) {
														final sizeValue = sizeItem['size']?.toString() ?? '';
														final sizeId = sizeItem['id']?.toString();
														return DropdownMenuItem<String>(
															value: sizeId,
															child: Text(sizeValue),
														);
													}).toList(),
												),
											),
										],
									],
								),

								const SizedBox(height: 12),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Row(
											children: [
												IconButton(
													icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
													onPressed: quantity > 1
															? () => setState(() => quantity--)
															: null,
												),
												Padding(
													padding: const EdgeInsets.symmetric(horizontal: 8.0),
													child: Text(quantity.toString(), style: Theme.of(context).textTheme.titleMedium),
												),
												IconButton(
													icon: const Icon(Icons.add_circle_outline, color: Colors.green),
													onPressed: () => setState(() => quantity++),
												),
											],
										),
										ElevatedButton.icon(
											onPressed: () {
												if (widget.productColors.isNotEmpty && selectedColorId == null) {
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text("يرجى اختيار اللون أولاً")),
													);
													return;
												}
												if (widget.productSizes.isNotEmpty && selectedSizeId == null) {
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text("يرجى اختيار المقاس أولاً")),
													);
													return;
												}

												// --- تعديل هنا: تمرير معرف واسم اللون والمقاس ---
												widget.onAddToCart({
													'id': widget.product['id'],
													'name': widget.product['name'] ?? 'منتج',
													'price': double.tryParse(price) ?? 0.0,
													'quantity': quantity,
													'color_id': selectedColorId,
													'color_name': selectedColorName, // <-- تمرير اسم اللون المحدد
													'size_id': selectedSizeId,
													'size_name': selectedSizeName,   // <-- تمرير اسم المقاس المحدد
													'image': widget.product['image'],
												});
												// --------------------------------------------------
											},
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.brown,
												foregroundColor: Colors.white,
												padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
											),
											icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
											label: const Text("إضافة للسلة"),
										),
									],
								),
							],
						),
					),
				],
			),
		);
	}
}

