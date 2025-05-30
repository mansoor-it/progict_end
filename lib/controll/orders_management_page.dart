import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

class OrdersManagementPage extends StatefulWidget {
	const OrdersManagementPage({Key? key}) : super(key: key);

	@override
	State<OrdersManagementPage> createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage> {
	final String apiUrl =  ApiHelper.url('order.php');
	final String orderItemsApiUrl =  ApiHelper.url('order.php');

	List<dynamic> orders = [];
	final _formKey = GlobalKey<FormState>();

	int? orderId;
	TextEditingController userIdController = TextEditingController();
	TextEditingController totalPriceController = TextEditingController();
	TextEditingController statusController = TextEditingController();

	@override
	void initState() {
		super.initState();
		fetchOrders();
	}

	Future<void> fetchOrders() async {
		try {
			final response = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (response.statusCode == 200) {
				setState(() {
					orders = json.decode(response.body);
				});
			}
		} catch (e) {
			print('Error fetching orders: $e');
		}
	}

	Future<void> fetchOrderItems(int orderId) async {
		try {
			final response = await http.get(Uri.parse('$orderItemsApiUrl?action=fetch_by_order&order_id=$orderId'));
			if (response.statusCode == 200) {
				final items = json.decode(response.body);
				showOrderItemsDialog(items);
			} else {
				throw Exception('Failed to load items');
			}
		} catch (e) {
			print('Error fetching order items: $e');
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تحميل العناصر')));
		}
	}

	void showOrderItemsDialog(List<dynamic> items) {
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: const Text('عناصر الطلب'),
				content: SizedBox(
					width: double.maxFinite,
					child: items.isEmpty
							? const Text('لا توجد عناصر لهذا الطلب.')
							: ListView.builder(
						shrinkWrap: true,
						itemCount: items.length,
						itemBuilder: (context, index) {
							final item = items[index];
							return ListTile(
								title: Text('المنتج: ${item['product_id']}'),
								subtitle: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text('الكمية: ${item['quantity']}'),
										Text('السعر: ${item['price']}'),
									],
								),
							);
						},
					),
				),
				actions: [
					TextButton(
						child: const Text('إغلاق'),
						onPressed: () => Navigator.of(context).pop(),
					),
				],
			),
		);
	}

	Future<void> saveOrder() async {
		if (!_formKey.currentState!.validate()) return;

		final isUpdate = orderId != null;
		final response = await http.post(Uri.parse(apiUrl), body: {
			'action': isUpdate ? 'update' : 'add',
			'id': orderId?.toString() ?? '',
			'user_id': userIdController.text,
			'total_price': totalPriceController.text,
			'status': statusController.text,
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
		clearForm();
		fetchOrders();
	}

	Future<void> deleteOrder(int id) async {
		final response = await http.post(Uri.parse(apiUrl), body: {
			'action': 'delete',
			'id': id.toString(),
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
		fetchOrders();
	}

	void fillForm(Map<String, dynamic> order) {
		setState(() {
			orderId = order['id'] is int ? order['id'] : int.parse(order['id'].toString());
			userIdController.text = order['user_id'].toString();
			totalPriceController.text = order['total_price'].toString();
			statusController.text = order['status'].toString();
		});
	}


	void clearForm() {
		setState(() {
			orderId = null;
			userIdController.clear();
			totalPriceController.clear();
			statusController.clear();
		});
	}

	Widget buildTextField(String label, TextEditingController controller, TextInputType type) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6.0),
			child: TextFormField(
				controller: controller,
				keyboardType: type,
				validator: (value) => value == null || value.isEmpty ? 'Required' : null,
				decoration: InputDecoration(
					labelText: label,
					border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
					filled: true,
					fillColor: Colors.grey[100],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة الطلبات'),
				centerTitle: true,
				backgroundColor: Colors.deepPurple,
			),
			body: Padding(
				padding: const EdgeInsets.all(12.0),
				child: Column(
					children: [
						Form(
							key: _formKey,
							child: Column(
								children: [
									buildTextField('رقم المستخدم', userIdController, TextInputType.number),
									buildTextField('السعر الكلي', totalPriceController, TextInputType.number),
									buildTextField('الحالة', statusController, TextInputType.text),
									const SizedBox(height: 10),
									Row(
										children: [
											ElevatedButton.icon(
												onPressed: saveOrder,
												icon: Icon(orderId == null ? Icons.add : Icons.save),
												label: Text(orderId == null ? 'إضافة طلب' : 'تحديث الطلب'),
												style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
											),
											const SizedBox(width: 10),
											if (orderId != null)
												OutlinedButton(
													onPressed: clearForm,
													child: const Text('إلغاء'),
												),
										],
									),
								],
							),
						),
						const Divider(height: 30),
						const Text('قائمة الطلبات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
						const SizedBox(height: 10),
						Expanded(
							child: ListView.builder(
								itemCount: orders.length,
								itemBuilder: (context, index) {
									final order = orders[index];
									return Card(
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
										margin: const EdgeInsets.symmetric(vertical: 6),
										child: ListTile(
											title: Text('طلب #${order['id']} - المستخدم: ${order['user_id']}'),
											subtitle: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text('السعر الكلي: ${order['total_price']}'),
													Text('الحالة: ${order['status']}'),
													Text('تاريخ الإنشاء: ${order['created_at']}'),
												],
											),
											trailing: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													IconButton(
														icon: const Icon(Icons.info_outline, color: Colors.orange),
														tooltip: 'عرض العناصر',
														onPressed: () => fetchOrderItems(order['id'] is int ? order['id'] : int.parse(order['id'].toString())),

													),
													IconButton(
														icon: const Icon(Icons.edit, color: Colors.blue),
														onPressed: () => fillForm(order),
													),
													IconButton(
														icon: const Icon(Icons.delete, color: Colors.red),
														onPressed: () => deleteOrder(int.parse(order['id'])),
													),
												],
											),
										),
									);
								},
							),
						)
					],
				),
			),
		);
	}
}
