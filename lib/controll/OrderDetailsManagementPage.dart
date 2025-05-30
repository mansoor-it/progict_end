import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

class OrderDetail {
	final String id;
	final String orderId;
	final String productId;
	final String quantity;
	final String price;
	final String? color;
	final String? size;
	final String? createdAt;
	final String? updatedAt;

	OrderDetail({
		required this.id,
		required this.orderId,
		required this.productId,
		required this.quantity,
		required this.price,
		this.color,
		this.size,
		this.createdAt,
		this.updatedAt,
	});

	factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
		id: json['id'].toString(),
		orderId: json['order_id'].toString(),
		productId: json['product_id'].toString(),
		quantity: json['quantity'].toString(),
		price: json['price'].toString(),
		color: json['color'],
		size: json['size'],
		createdAt: json['created_at'],
		updatedAt: json['updated_at'],
	);

	Map<String, dynamic> toJson() => {
		'id': id,
		'order_id': orderId,
		'product_id': productId,
		'quantity': quantity,
		'price': price,
		'color': color,
		'size': size,
		'created_at': createdAt,
		'updated_at': updatedAt,
	};
}

class OrderDetailManagementPage extends StatefulWidget {
	const OrderDetailManagementPage({Key? key}) : super(key: key);

	@override
	State<OrderDetailManagementPage> createState() =>
			_OrderDetailManagementPageState();
}

class _OrderDetailManagementPageState
		extends State<OrderDetailManagementPage> {
	List<OrderDetail> orderDetails = [];
	final String apiUrl = ApiHelper.url('order_items.php');
	final TextEditingController searchController = TextEditingController();

	@override
	void initState() {
		super.initState();
		fetchOrderDetails();
	}

	Future<void> fetchOrderDetails() async {
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final body = jsonDecode(response.body);

				if (body is List) {
					setState(() {
						orderDetails = body.map((e) => OrderDetail.fromJson(e)).toList();
					});
				} else if (body is Map && body.containsKey('error')) {
					print("Server error: ${body['error']}");
				} else {
					print("Unexpected response format: $body");
				}
			} else {
				print("Failed to load data, status code: ${response.statusCode}");
			}
		} catch (e) {
			print("Error fetching order details: $e");
		}
	}

	Future<void> showForm({OrderDetail? detail}) async {
		final idController = TextEditingController(text: detail?.id);
		final orderIdController = TextEditingController(text: detail?.orderId);
		final productIdController = TextEditingController(text: detail?.productId);
		final quantityController = TextEditingController(text: detail?.quantity);
		final priceController = TextEditingController(text: detail?.price);
		final colorController = TextEditingController(text: detail?.color);
		final sizeController = TextEditingController(text: detail?.size);

		await showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: Text(
					detail == null ? 'إضافة تفاصيل الطلب' : 'تعديل تفاصيل الطلب',
					style: const TextStyle(fontWeight: FontWeight.bold),
				),
				content: SingleChildScrollView(
					child: Column(
						children: [
							TextField(
								controller: orderIdController,
								decoration: InputDecoration(labelText: 'رقم الطلب'),
							),
							TextField(
								controller: productIdController,
								decoration: InputDecoration(labelText: 'رقم المنتج'),
							),
							TextField(
								controller: quantityController,
								keyboardType: TextInputType.number,
								decoration: InputDecoration(labelText: 'الكمية'),
							),
							TextField(
								controller: priceController,
								keyboardType: TextInputType.numberWithOptions(decimal: true),
								decoration: InputDecoration(labelText: 'السعر'),
							),
							TextField(
								controller: colorController,
								decoration: InputDecoration(labelText: 'اللون'),
							),
							TextField(
								controller: sizeController,
								decoration: InputDecoration(labelText: 'الحجم'),
							),
						],
					),
				),
				actions: [
					ElevatedButton.icon(
						onPressed: () async {
							final body = {
								'action': detail == null ? 'add' : 'update',
								'id': detail?.id ?? '',
								'order_id': orderIdController.text,
								'product_id': productIdController.text,
								'quantity': quantityController.text,
								'price': priceController.text,
								'color': colorController.text,
								'size': sizeController.text,
							};
							await http.post(Uri.parse(apiUrl), body: body);
							Navigator.pop(ctx);
							fetchOrderDetails();
						},
						icon: const Icon(Icons.save),
						label: const Text('حفظ'),
					),
					TextButton(
						onPressed: () => Navigator.pop(ctx),
						child: const Text('إلغاء'),
					)
				],
			),
		);
	}

	Future<void> deleteDetail(String id) async {
		await http.post(Uri.parse(apiUrl), body: {'action': 'delete', 'id': id});
		fetchOrderDetails();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة تفاصيل الطلب'),
				centerTitle: true,
				backgroundColor: Colors.deepPurple,
			),
			body: Padding(
				padding: const EdgeInsets.all(12.0),
				child: Column(
					children: [
						// حقل البحث
						TextField(
							controller: searchController,
							decoration: InputDecoration(
								hintText: 'بحث حسب رقم الطلب...',
								prefixIcon: const Icon(Icons.search),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(10),
								),
							),
							onChanged: (value) {
								setState(() {
									final keyword = value.toLowerCase();
									orderDetails = orderDetails
											.where((item) => item.orderId.toLowerCase().contains(keyword))
											.toList();
								});
							},
						),
						const SizedBox(height: 16),

						// قائمة البيانات
						Expanded(
							child: orderDetails.isEmpty
									? const Center(
								child: Text(
									'لا توجد بيانات للعرض.',
									style: TextStyle(fontSize: 18, color: Colors.grey),
								),
							)
									: ListView.builder(
								itemCount: orderDetails.length,
								itemBuilder: (ctx, i) {
									final item = orderDetails[i];
									return Card(
										elevation: 4,
										margin:
										const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
										child: ListTile(
											title: Text(
												'طلب #${item.orderId} - منتج #${item.productId}',
												style: const TextStyle(fontWeight: FontWeight.bold),
											),
											subtitle: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													const SizedBox(height: 4),
													Text('الكمية: ${item.quantity}'),
													Text('السعر: \$${item.price}'),
													Text('اللون: ${item.color ?? 'غير محدد'}'),
													Text('الحجم: ${item.size ?? 'غير محدد'}'),
												],
											),
											trailing: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													IconButton(
														icon: const Icon(Icons.edit, color: Colors.blue),
														onPressed: () => showForm(detail: item),
													),
													IconButton(
														icon: const Icon(Icons.delete, color: Colors.red),
														onPressed: () => deleteDetail(item.id),
													),
												],
											),
										),
									);
								},
							),
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton(
				backgroundColor: Colors.deepPurple,
				onPressed: () => showForm(),
				child: const Icon(Icons.add),
			),
		);
	}
}