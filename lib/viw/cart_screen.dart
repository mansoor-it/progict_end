import 'dart:convert';
import 'package:flutter/material.dart';
////////////////////////////////////////////////////
import '../model/model_cart.dart';
import '../service/server_cart.dart';

class CartPage extends StatefulWidget {
	final String userId;
	final List<Map<String, dynamic>>? cartItems;

	const CartPage({
		Key? key,
		required this.userId,
		this.cartItems,
	}) : super(key: key);

	@override
	_CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
	late CartController _controller;
	late Future<List<CartItemModel>> _cartFuture;

	@override
	void initState() {
		super.initState();
		_controller = CartController();
		if (widget.cartItems == null) {
			_cartFuture = _controller.fetchCartItems(widget.userId);
		}
	}

	void _refresh() {
		setState(() {
			if (widget.cartItems == null) {
				_cartFuture = _controller.fetchCartItems(widget.userId);
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
			body: widget.cartItems != null
					? _buildLocalCart(widget.cartItems!)
					: FutureBuilder<List<CartItemModel>>(
				future: _cartFuture,
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator());
					}
					if (snapshot.hasError) {
						return Center(child: Text('خطأ: ${snapshot.error}'));
					}
					final items = snapshot.data!;
					if (items.isEmpty) {
						return const Center(child: Text('السلة فارغة'));
					}

					double total = items.fold(
							0, (sum, item) => sum + double.parse(item.totalPrice));

					return _buildCartList(items, total);
				},
			),
		);
	}

	Widget _buildLocalCart(List<Map<String, dynamic>> cartItems) {
		if (cartItems.isEmpty) {
			return const Center(child: Text("السلة فارغة"));
		}

		double total = cartItems.fold(
				0.0,
						(sum, item) =>
				sum +
						(double.tryParse(item['price'].toString()) ?? 0.0) *
								(item['quantity'] ?? 1));

		return Column(
			children: [
				Expanded(
					child: ListView.builder(
						itemCount: cartItems.length,
						itemBuilder: (context, index) {
							final item = cartItems[index];
							return Card(
								margin:
								const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
								child: ListTile(
									leading: const Icon(Icons.shopping_bag),
									title: Text(item['name'] ?? ''),
									subtitle: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											if (item['color'] != null)
												Text('اللون: ${item['color']}'),
											if (item['size'] != null)
												Text('المقاس: ${item['size']}'),
											Text('الكمية: ${item['quantity']}'),
											Text('السعر: \$${item['price']}'),
											Text(
													'الإجمالي: \$${(double.tryParse(item['price'].toString()) ?? 0.0) * (item['quantity'] ?? 1)}'),
										],
									),
									trailing: IconButton(
										icon: const Icon(Icons.delete, color: Colors.red),
										onPressed: () {
											setState(() {
												cartItems.removeAt(index);
											});
										},
									),
								),
							);
						},
					),
				),
				Container(
					padding: const EdgeInsets.all(16),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text('الإجمالي: \$${total.toStringAsFixed(2)}',
									style: const TextStyle(
											fontSize: 18, fontWeight: FontWeight.bold)),
							ElevatedButton(
								onPressed: () {
									// يمكنك إضافة تأكيد السلة المحلية لاحقاً
								},
								child: const Text('تأكيد الطلب'),
							),
						],
					),
				),
			],
		);
	}

	Widget _buildCartList(List<CartItemModel> items, double total) {
		return Column(
			children: [
				Expanded(
					child: ListView.builder(
						itemCount: items.length,
						itemBuilder: (context, index) {
							final item = items[index];
							final bytes = item.productImage != null
									? base64Decode(item.productImage!)
									: null;
							return Card(
								margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
								child: ListTile(
									leading: bytes != null
											? Image.memory(bytes,
											width: 50, height: 50, fit: BoxFit.cover)
											: const Icon(Icons.image_not_supported),
									title: Text(item.productId),
									subtitle: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text('سعر الوحدة: \$${item.unitPrice}'),
											Text('الكمية: ${item.quantity}'),
											Text('الإجمالي: \$${item.totalPrice}'),
										],
									),
									trailing: IconButton(
										icon: const Icon(Icons.delete, color: Colors.red),
										onPressed: () async {
											bool ok = await _controller.deleteCartItem(item.id);
											if (ok) {
												ScaffoldMessenger.of(context).showSnackBar(
													const SnackBar(content: Text('تم حذف العنصر')),
												);
												_refresh();
											} else {
												ScaffoldMessenger.of(context).showSnackBar(
													const SnackBar(content: Text('فشل الحذف')),
												);
											}
										},
									),
								),
							);
						},
					),
				),
				Container(
					padding: const EdgeInsets.all(16),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text('الإجمالي: \$${total.toStringAsFixed(2)}',
									style: const TextStyle(
											fontSize: 18, fontWeight: FontWeight.bold)),
							ElevatedButton(
								onPressed: () async {
									bool success =
									await _controller.confirmOrder(widget.userId, items);
									if (success) {
										ScaffoldMessenger.of(context).showSnackBar(
											const SnackBar(content: Text("تم تأكيد الطلب بنجاح")),
										);
										_refresh();
									} else {
										ScaffoldMessenger.of(context).showSnackBar(
											const SnackBar(content: Text("فشل تأكيد الطلب")),
										);
									}
								},
								child: const Text('تأكيد الطلب'),
							),
						],
					),
				),
			],
		);
	}
}
