import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/model_cart.dart'; // تأكد من استيراد النموذج المحدث
import '../service/server_cart.dart';
import 'PaymentPage.dart';

class CartPage extends StatefulWidget {
	final String userId;
	// استخدام قائمة من الخرائط للسلة المحلية لتسهيل إضافة الأسماء
	final List<Map<String, dynamic>>? cartItems;
	final String? orderId;

	const CartPage({
		Key? key,
		required this.userId,
		this.cartItems, // استقبال السلة المحلية
		this.orderId,
	}) : super(key: key);

	@override
	_CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
	late CartController _controller;
	// استخدام Future<List<Map<String, dynamic>>> لجلب البيانات من الخادم
	late Future<List<Map<String, dynamic>>> _cartFuture;
	String? _generatedOrderId;
	// قائمة لعرض العناصر سواء كانت محلية أو من الخادم
	List<Map<String, dynamic>> displayItems = [];

	@override
	void initState() {
		super.initState();
		_controller = CartController();

		if (widget.cartItems != null) {
			// إذا كانت السلة محلية، استخدمها مباشرة
			displayItems = widget.cartItems!;
			_cartFuture = Future.value(widget.cartItems!); // إنشاء Future وهمي
		} else {
			// إذا لم تكن السلة محلية، اجلبها من الخادم
			_cartFuture = _fetchAndMapCartItems(widget.userId);
		}

		_generateOrderId();
	}

	// دالة لجلب البيانات من الخادم وتحويلها إلى List<Map<String, dynamic>>
	Future<List<Map<String, dynamic>>> _fetchAndMapCartItems(String userId) async {
		try {
			// استدعاء الدالة لجلب العناصر
			final List<CartItemModel> items = await _controller.fetchCartItems(userId);

			// تحويل العناصر إلى قائمة من الخرائط
			final List<Map<String, dynamic>> mappedItems = items.map((item) => item.toJson()).toList();

			setState(() {
				displayItems = mappedItems; // تعيين العناصر المعالجة
			});

			return mappedItems; // إرجاع القائمة المعالجة
		} catch (e) {
			print("Error fetching cart items: $e");
			// يمكنك عرض رسالة خطأ هنا
			return []; // إرجاع قائمة فارغة في حالة الخطأ
		}
	}

	void _generateOrderId() {
		_generatedOrderId = DateTime.now().millisecondsSinceEpoch.toString();
	}

	void _refresh() {
		setState(() {
			if (widget.cartItems == null) {
				// إعادة جلب البيانات من الخادم عند التحديث
				_cartFuture = _fetchAndMapCartItems(widget.userId);
			} else {
				// لا حاجة لإعادة الجلب إذا كانت السلة محلية
				// قد تحتاج لتحديث displayItems إذا كان هناك تغيير محلي
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('سلة المشتريات'),
				actions: [
					IconButton(
						icon: const Icon(Icons.refresh),
						onPressed: _refresh,
					),
				],
			),
			body: FutureBuilder<List<Map<String, dynamic>>>(
				future: _cartFuture, // استخدام Future الموحد
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator());
					}

					if (snapshot.hasError) {
						return Center(child: Text('خطأ في جلب بيانات السلة: ${snapshot.error}'));
					}

					if (displayItems.isEmpty) {
						return const Center(child: Text('السلة فارغة'));
					}

					// حساب الإجمالي بناءً على displayItems
					double total = displayItems.fold(
						0.0,
								(sum, item) =>
						sum +
								(double.tryParse(item['unit_price']?.toString() ?? item['price']?.toString() ?? '0.0') ?? 0.0) *
										(int.tryParse(item['quantity']?.toString() ?? '1') ?? 1),
					);

					return _buildCartList(displayItems, total);
				},
			),
		);
	}

	// تعديل _buildCartList لتعمل مع List<Map<String, dynamic>>
	Widget _buildCartList(List<Map<String, dynamic>> items, double total) {
		return Column(
			children: [
				Expanded(
					child: ListView.builder(
						itemCount: items.length,
						itemBuilder: (context, index) {
							final item = items[index];
							// محاولة الحصول على الصورة من الحقول المحتملة
							final imageBase64 = item['product_image']?.toString() ?? item['image']?.toString();
							Uint8List? imageBytes;
							if (imageBase64 != null && imageBase64.isNotEmpty) {
								try {
									imageBytes = base64Decode(imageBase64);
								} catch (e) {
									print("Error decoding cart item image: $e");
								}
							}

							// محاولة الحصول على اسم المنتج
							final productName = item['product_name']?.toString() ?? item['name']?.toString() ?? 'منتج غير معروف';
							// الحصول على اللون والمقاس (الأسماء)
							final colorName = item['color_name']?.toString();
							final sizeName = item['size_name']?.toString();
							final quantity = item['quantity']?.toString() ?? '1';
							final unitPrice = double.tryParse(item['unit_price']?.toString() ?? item['price']?.toString() ?? '0.0') ?? 0.0;
							final itemTotal = unitPrice * (int.tryParse(quantity) ?? 1);

							return Card(
								margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
								child: ListTile(
									leading: imageBytes != null
											? Image.memory(imageBytes, width: 50, height: 50, fit: BoxFit.cover)
											: const Icon(Icons.image_not_supported, size: 50),
									title: Text(productName),
									subtitle: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											// عرض اسم اللون والمقاس إذا كانا موجودين
											if (colorName != null && colorName.isNotEmpty) Text('اللون: $colorName'),
											if (sizeName != null && sizeName.isNotEmpty) Text('المقاس: $sizeName'),
											Text('الكمية: $quantity'),
											Text('سعر الوحدة: \$${unitPrice.toStringAsFixed(2)}'),
											Text('الإجمالي: \$${itemTotal.toStringAsFixed(2)}'),
										],
									),
									trailing: IconButton(
										icon: const Icon(Icons.delete, color: Colors.red),
										onPressed: () async {
											// تحديد إذا كان الحذف محلياً أو من الخادم
											if (widget.cartItems != null) {
												// حذف محلي
												setState(() {
													displayItems.removeAt(index);
												});
												ScaffoldMessenger.of(context).showSnackBar(
													const SnackBar(content: Text('تم حذف العنصر من السلة المحلية')),
												);
											} else {
												// حذف من الخادم
												final itemId = item['id']?.toString();
												if (itemId != null) {
													bool ok = await _controller.deleteCartItem(itemId);
													if (ok) {
														ScaffoldMessenger.of(context).showSnackBar(
															const SnackBar(content: Text('تم حذف العنصر')),
														);
														_refresh(); // إعادة جلب البيانات بعد الحذف
													} else {
														ScaffoldMessenger.of(context).showSnackBar(
															const SnackBar(content: Text('فشل الحذف من الخادم')),
														);
													}
												} else {
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('معرف العنصر غير موجود للحذف')),
													);
												}
											}
										},
									),
								),
							);
						},
					),
				),
				_buildTotalSection(total),
			],
		);
	}

	Widget _buildTotalSection(double total) {
		return Container(
			padding: const EdgeInsets.all(16),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Text(
						'الإجمالي: \$${total.toStringAsFixed(2)}',
						style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
					),
					ElevatedButton(
						// التأكد من أن السلة ليست فارغة قبل السماح بالدفع
						onPressed: displayItems.isNotEmpty ? () => _navigateToPayment(context, total) : null,
						child: const Text('تأكيد الطلب والدفع'),
					),
				],
			),
		);
	}

	// تعديل _navigateToPayment لتعمل مع List<Map<String, dynamic>>
	void _navigateToPayment(BuildContext context, double total) {
		// تحويل displayItems (وهي List<Map<String, dynamic>>) إلى List<CartItemModel>
		// مع التأكد من تضمين أسماء اللون والمقاس
		final List<CartItemModel> itemsToPass = displayItems.map((item) {
			final unitPrice = double.tryParse(item['unit_price']?.toString() ?? item['price']?.toString() ?? '0.0') ?? 0.0;
			final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
			final itemTotal = unitPrice * quantity;

			return CartItemModel(
				id: item['id']?.toString() ?? '', // استخدام معرف السلة إذا كان متاحاً
				productId: item['product_id']?.toString() ?? item['id']?.toString() ?? '', // استخدام معرف المنتج
				userId: widget.userId,
				unitPrice: unitPrice.toStringAsFixed(2),
				quantity: quantity.toString(),
				totalPrice: itemTotal.toStringAsFixed(2),
				productImage: item['product_image']?.toString() ?? item['image']?.toString(),
				createdAt: item['created_at']?.toString() ?? DateTime.now().toString(),
				updatedAt: item['updated_at']?.toString() ?? DateTime.now().toString(),
				// --- تضمين الأسماء والمعرفات ---
				colorId: item['product_color_id']?.toString() ?? item['color_id']?.toString(),
				colorName: item['color_name']?.toString(), // <-- اسم اللون
				sizeId: item['product_size_id']?.toString() ?? item['size_id']?.toString(),
				sizeName: item['size_name']?.toString(),   // <-- اسم المقاس
				// --- إضافة اسم المنتج إذا كان متاحاً ---
				productName: item['product_name']?.toString() ?? item['name']?.toString(),
			);
		}).toList();

		if (itemsToPass.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('السلة فارغة، لا يمكن المتابعة للدفع')),
			);
			return;
		}

		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => PaymentPage(
					orderId: _generatedOrderId!, // استخدام المعرف المولّد
					userId: widget.userId,
					totalAmount: total,
					cartItems: itemsToPass, // تمرير القائمة المحولة
					onPaymentSuccess: (payment) {
						ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(content: Text('تم الدفع بنجاح')),
						);
						// (اختياري) يمكنك مسح السلة المحلية هنا إذا كانت مستخدمة
						if (widget.cartItems != null) {
							setState(() {
								widget.cartItems!.clear();
								displayItems.clear();
							});
						}
						Navigator.pop(context); // العودة بعد الدفع
					}, onClearCart: () {  },
				),
			),
		);
	}
}

