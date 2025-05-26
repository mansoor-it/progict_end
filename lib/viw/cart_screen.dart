import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/model_cart.dart';
import '../service/server_cart.dart';
import 'PaymentPage.dart';

class CartPage extends StatefulWidget {
	final String userId;
	final List<Map<String, dynamic>>? cartItems;
	final String? orderId;

	const CartPage({
		Key? key,
		required this.userId,
		this.cartItems,
		this.orderId,
	}) : super(key: key);

	@override
	_CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
	late CartController _controller;
	late Future<List<CartItemModel>> _cartFuture;
	String? _generatedOrderId;

	@override
	void initState() {
		super.initState();
		_controller = CartController();

		if (widget.cartItems == null) {
			_cartFuture = _controller.fetchCartItems(widget.userId);
		}

		_generateOrderId();
	}

	void _generateOrderId() {
		_generatedOrderId = DateTime.now().millisecondsSinceEpoch.toString();
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
						0,
								(sum, item) => sum + double.parse(item.totalPrice),
					);

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
							(item['quantity'] ?? 1),
		);

		return Column(
			children: [
				Expanded(
					child: ListView.builder(
						itemCount: cartItems.length,
						itemBuilder: (context, index) {
							final item = cartItems[index];

							Uint8List? imageBytes =
							item['image'] != null ? base64Decode(item['image']) : null;

							return Card(
								margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
								child: ListTile(
									leading: imageBytes != null
											? Image.memory(
										imageBytes,
										width: 50,
										height: 50,
										fit: BoxFit.cover,
									)
											: const Icon(Icons.image_not_supported, size: 50),
									title: Text(item['name'] ?? ''),
									subtitle: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											if (item['color'] != null) Text('اللون: ${item['color']}'),
											if (item['size'] != null) Text('المقاس: ${item['size']}'),
											Text('الكمية: ${item['quantity']}'),
											Text('السعر: \$${item['price']}'),
											Text('الإجمالي: \$${
													(double.tryParse(item['price'].toString()) ?? 0.0) *
															(item['quantity'] ?? 1)
											}'),
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
				_buildTotalSection(total),
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
											? Image.memory(bytes, width: 50, height: 50, fit: BoxFit.cover)
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
						onPressed: () => _navigateToPayment(context, total),
						child: const Text('تأكيد الطلب والدفع'),
					),
				],
			),
		);
	}

	void _navigateToPayment(BuildContext context, double total) async {
		List<CartItemModel> items = [];

		if (widget.cartItems == null) {
			final snapshot = await _cartFuture.whenComplete(() {});
			items = snapshot;
		} else {
			items = widget.cartItems!.map((item) {
				final price = item['price'];
				final quantity = item['quantity'];

				return CartItemModel(
					id: '',
					productId: item['id'].toString(),
					userId: widget.userId,
					unitPrice: price.toString(),
					quantity: quantity.toString(),
					totalPrice: '\$${(double.tryParse(price.toString()) ?? 0.0) * (int.tryParse(quantity.toString()) ?? 1)}',
					productImage: null,
					createdAt: DateTime.now().toString(),
					updatedAt: DateTime.now().toString(),
				);
			}).toList();
		}

		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => PaymentPage(
					orderId: _generatedOrderId!,
					userId: widget.userId,
					totalAmount: total,
					cartItems: items,
					onPaymentSuccess: (payment) {
						ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(content: Text('تم الدفع بنجاح')),
						);
						Navigator.pop(context); // العودة بعد الدفع
					},
				),
			),
		);
	}


}
