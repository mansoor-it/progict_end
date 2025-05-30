import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

class OrdersAndDetailsManagementPage extends StatefulWidget {
	const OrdersAndDetailsManagementPage({Key? key}) : super(key: key);

	@override
	State<OrdersAndDetailsManagementPage> createState() => _OrdersAndDetailsManagementPageState();
}

class _OrdersAndDetailsManagementPageState extends State<OrdersAndDetailsManagementPage> {
	// API URLs
	final String ordersApiUrl =  ApiHelper.url('order.php');
	final String orderDetailsApiUrl = ApiHelper.url('order_items.php');

	// بيانات الطلبات
	List<dynamic> orders = [];
	int? selectedOrderId; // الطلب المحدد لعرض تفاصيله

	// بيانات تفاصيل الطلب المحدد
	List<OrderDetail> orderDetails = [];

	// فورم الطلبات
	final _formKey = GlobalKey<FormState>();
	int? orderId;
	TextEditingController userIdController = TextEditingController();
	TextEditingController totalPriceController = TextEditingController();
	TextEditingController statusController = TextEditingController();

	// فورم تفاصيل الطلبات (لإضافة/تعديل)
	final _detailFormKey = GlobalKey<FormState>();
	TextEditingController detailIdController = TextEditingController();
	TextEditingController detailOrderIdController = TextEditingController();
	TextEditingController detailProductIdController = TextEditingController();
	TextEditingController detailQuantityController = TextEditingController();
	TextEditingController detailPriceController = TextEditingController();
	TextEditingController detailColorController = TextEditingController();
	TextEditingController detailSizeController = TextEditingController();

	@override
	void initState() {
		super.initState();
		fetchOrders();
	}

	// جلب الطلبات
	Future<void> fetchOrders() async {
		try {
			final response = await http.get(Uri.parse('$ordersApiUrl?action=fetch'));
			if (response.statusCode == 200) {
				setState(() {
					orders = json.decode(response.body);
				});
			}
		} catch (e) {
			print('Error fetching orders: $e');
		}
	}

	// جلب تفاصيل الطلب بناء على الطلب المحدد - التعديل هنا
	Future<void> fetchOrderDetails(int orderId) async {
		try {
			final response = await http.get(Uri.parse('$orderDetailsApiUrl?action=fetch_by_order&order_id=$orderId'));
			if (response.statusCode == 200) {
				final body = jsonDecode(response.body);

				// التحقق من هيكل الاستجابة
				print('API Response: $body'); // لأغراض التصحيح

				// التعديل الرئيسي: استخراج المنتجات من الحقل الصحيح
				if (body is Map<String, dynamic> && body.containsKey('data')) {
					// إذا كانت البيانات في حقل 'data'
					final data = body['data'];
					if (data is List) {
						setState(() {
							orderDetails = data.map<OrderDetail>((e) => OrderDetail.fromJson(e)).toList();
						});
					} else {
						setState(() {
							orderDetails = [];
						});
					}
				}
				else if (body is List) {
					// إذا كانت الاستجابة قائمة مباشرة
					setState(() {
						orderDetails = body.map<OrderDetail>((e) => OrderDetail.fromJson(e)).toList();
					});
				}
				else {
					setState(() {
						orderDetails = [];
					});
					print('Unexpected API response structure');
				}
			}
		} catch (e) {
			print('Error fetching order details: $e');
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تحميل تفاصيل الطلب')));
		}
	}

	// حفظ الطلب (إضافة أو تعديل)
	Future<void> saveOrder() async {
		if (!_formKey.currentState!.validate()) return;

		final isUpdate = orderId != null;
		final response = await http.post(Uri.parse(ordersApiUrl), body: {
			'action': isUpdate ? 'update' : 'add',
			'id': orderId?.toString() ?? '',
			'user_id': userIdController.text,
			'total_price': totalPriceController.text,
			'status': statusController.text,
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? '')));
		clearOrderForm();
		fetchOrders();
	}

	// حذف الطلب
	Future<void> deleteOrder(int id) async {
		final response = await http.post(Uri.parse(ordersApiUrl), body: {
			'action': 'delete',
			'id': id.toString(),
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? '')));
		if (selectedOrderId == id) {
			selectedOrderId = null;
			orderDetails.clear();
		}
		fetchOrders();
	}

	// تعبئة بيانات الطلب في الفورم
	void fillOrderForm(Map<String, dynamic> order) {
		setState(() {
			orderId = order['id'] is int ? order['id'] : int.parse(order['id'].toString());
			userIdController.text = order['user_id'].toString();
			totalPriceController.text = order['total_price'].toString();
			statusController.text = order['status'].toString();
		});
	}

	void clearOrderForm() {
		setState(() {
			orderId = null;
			userIdController.clear();
			totalPriceController.clear();
			statusController.clear();
		});
	}

	// حفظ أو تحديث تفاصيل الطلب
	Future<void> saveOrderDetail() async {
		if (!_detailFormKey.currentState!.validate()) return;

		final isUpdate = detailIdController.text.isNotEmpty;

		final response = await http.post(Uri.parse(orderDetailsApiUrl), body: {
			'action': isUpdate ? 'update' : 'add',
			'id': detailIdController.text,
			'order_id': detailOrderIdController.text,
			'product_id': detailProductIdController.text,
			'quantity': detailQuantityController.text,
			'price': detailPriceController.text,
			'color': detailColorController.text,
			'size': detailSizeController.text,
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? '')));
		Navigator.of(context).pop();
		if (selectedOrderId != null) {
			fetchOrderDetails(selectedOrderId!);
		}
	}

	// حذف تفاصيل الطلب
	Future<void> deleteOrderDetail(String id) async {
		await http.post(Uri.parse(orderDetailsApiUrl), body: {'action': 'delete', 'id': id});
		if (selectedOrderId != null) {
			fetchOrderDetails(selectedOrderId!);
		}
	}

	// فتح نافذة الفورم لإضافة/تعديل تفاصيل الطلب
	Future<void> showDetailForm({OrderDetail? detail}) async {
		if (detail != null) {
			detailIdController.text = detail.id;
			detailOrderIdController.text = detail.orderId;
			detailProductIdController.text = detail.productId;
			detailQuantityController.text = detail.quantity;
			detailPriceController.text = detail.price;
			detailColorController.text = detail.color ?? '';
			detailSizeController.text = detail.size ?? '';
		} else {
			detailIdController.clear();
			detailOrderIdController.text = selectedOrderId?.toString() ?? '';
			detailProductIdController.clear();
			detailQuantityController.clear();
			detailPriceController.clear();
			detailColorController.clear();
			detailSizeController.clear();
		}

		await showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: Text(detail == null ? 'إضافة تفاصيل الطلب' : 'تعديل تفاصيل الطلب'),
				content: Form(
					key: _detailFormKey,
					child: SingleChildScrollView(
						child: Column(
							children: [
								TextFormField(
									controller: detailOrderIdController,
									decoration: const InputDecoration(labelText: 'رقم الطلب'),
									readOnly: true,
								),
								TextFormField(
									controller: detailProductIdController,
									decoration: const InputDecoration(labelText: 'رقم المنتج'),
									validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
								),
								TextFormField(
									controller: detailQuantityController,
									decoration: const InputDecoration(labelText: 'الكمية'),
									keyboardType: TextInputType.number,
									validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
								),
								TextFormField(
									controller: detailPriceController,
									decoration: const InputDecoration(labelText: 'السعر'),
									keyboardType: TextInputType.number,
									validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
								),
								TextFormField(
									controller: detailColorController,
									decoration: const InputDecoration(labelText: 'اللون'),
								),
								TextFormField(
									controller: detailSizeController,
									decoration: const InputDecoration(labelText: 'المقاس'),
								),
							],
						),
					),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(ctx).pop(),
						child: const Text('إلغاء'),
					),
					ElevatedButton(
						onPressed: saveOrderDetail,
						child: const Text('حفظ'),
					),
				],
			),
		);
	}

	// دالة لعرض تفاصيل المنتجات في نافذة منبثقة
	void showProductsDialog() {
		showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: Text('منتجات الطلب رقم $selectedOrderId'),
				content: Container(
					width: double.maxFinite,
					child: ListView.builder(
						shrinkWrap: true,
						itemCount: orderDetails.length,
						itemBuilder: (context, index) {
							final detail = orderDetails[index];
							return Card(
								child: ListTile(
									title: Text('المنتج: ${detail.productId}'),
									subtitle: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text('الكمية: ${detail.quantity}'),
											Text('السعر: ${detail.price}'),
											if (detail.color != null && detail.color!.isNotEmpty)
												Text('اللون: ${detail.color}'),
											if (detail.size != null && detail.size!.isNotEmpty)
												Text('المقاس: ${detail.size}'),
										],
									),
								),
							);
						},
					),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(ctx).pop(),
						child: const Text('إغلاق'),
					)
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('إدارة الطلبات وتفاصيلها')),
			body: Padding(
				padding: const EdgeInsets.all(10),
				child: Column(
					children: [
						// فورم الطلبات
						Form(
							key: _formKey,
							child: Column(
								children: [
									TextFormField(
										controller: userIdController,
										decoration: const InputDecoration(labelText: 'رقم المستخدم'),
										validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
									),
									TextFormField(
										controller: totalPriceController,
										decoration: const InputDecoration(labelText: 'السعر الكلي'),
										keyboardType: TextInputType.number,
										validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
									),
									TextFormField(
										controller: statusController,
										decoration: const InputDecoration(labelText: 'الحالة'),
										validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
									),
									Row(
										children: [
											ElevatedButton(
												onPressed: saveOrder,
												child: Text(orderId == null ? 'إضافة طلب' : 'تحديث الطلب'),
											),
											const SizedBox(width: 10),
											if (orderId != null)
												ElevatedButton(
													onPressed: clearOrderForm,
													child: const Text('إلغاء'),
													style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
												)
										],
									),
								],
							),
						),

						const SizedBox(height: 20),

						// قائمة الطلبات
						Expanded(
							child: Row(
								children: [
									// قائمة الطلبات
									Expanded(
										child: Column(
											children: [
												const Text('قائمة الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
												Expanded(
													child: ListView.builder(
														itemCount: orders.length,
														itemBuilder: (context, index) {
															final order = orders[index];
															final isSelected = selectedOrderId == order['id'];
															return Card(
																color: isSelected ? Colors.blue.shade100 : null,
																child: ListTile(
																	title: Text('طلب رقم: ${order['id']}'),
																	subtitle: Text('المستخدم: ${order['user_id']} - السعر: ${order['total_price']} - الحالة: ${order['status']}'),
																	onTap: () {
																		setState(() {
																			selectedOrderId = order['id'];
																			fillOrderForm(order);
																			fetchOrderDetails(selectedOrderId!);
																		});
																	},
																	trailing: Row(
																		mainAxisSize: MainAxisSize.min,
																		children: [
																			IconButton(
																				icon: const Icon(Icons.edit),
																				onPressed: () {
																					fillOrderForm(order);
																				},
																			),
																			IconButton(
																				icon: const Icon(Icons.delete),
																				onPressed: () => deleteOrder(order['id']),
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

									const VerticalDivider(),

									// تفاصيل الطلب المحدد
									Expanded(
										child: selectedOrderId == null
												? const Center(child: Text('اختر طلبًا لعرض تفاصيله'))
												: Column(
											children: [
												Text('تفاصيل الطلب رقم $selectedOrderId', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
												// استخدام Wrap بدلاً من Row لتجنب تجاوز العرض
												Wrap(
													alignment: WrapAlignment.center,
													spacing: 10,
													runSpacing: 10,
													children: [
														ElevatedButton.icon(
															icon: const Icon(Icons.add),
															label: const Text('إضافة تفاصيل'),
															onPressed: () {
																showDetailForm();
															},
														),
														// الزر الجديد لعرض المنتجات
														ElevatedButton.icon(
															icon: const Icon(Icons.list),
															label: const Text('عرض المنتجات'),
															onPressed: () {
																if (orderDetails.isNotEmpty) {
																	showProductsDialog();
																} else {
																	ScaffoldMessenger.of(context).showSnackBar(
																			const SnackBar(content: Text('لا توجد منتجات لهذا الطلب'))
																	);
																}
															},
														),
													],
												),
												Expanded(
													child: ListView.builder(
														itemCount: orderDetails.length,
														itemBuilder: (context, index) {
															final detail = orderDetails[index];
															return Card(
																child: ListTile(
																	title: Text('منتج: ${detail.productId}, كمية: ${detail.quantity}, سعر: ${detail.price}'),
																	subtitle: Text('لون: ${detail.color ?? '-'}, مقاس: ${detail.size ?? '-'}'),
																	trailing: Row(
																		mainAxisSize: MainAxisSize.min,
																		children: [
																			IconButton(
																				icon: const Icon(Icons.edit),
																				onPressed: () => showDetailForm(detail: detail),
																			),
																			IconButton(
																				icon: const Icon(Icons.delete),
																				onPressed: () => deleteOrderDetail(detail.id),
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
								],
							),
						),
					],
				),
			),
		);
	}
}

// نموذج تفاصيل الطلب
class OrderDetail {
	final String id;
	final String orderId;
	final String productId;
	final String quantity;
	final String price;
	final String? color;
	final String? size;

	OrderDetail({
		required this.id,
		required this.orderId,
		required this.productId,
		required this.quantity,
		required this.price,
		this.color,
		this.size,
	});

	factory OrderDetail.fromJson(Map<String, dynamic> json) {
		return OrderDetail(
			id: json['id'].toString(),
			orderId: json['order_id'].toString(),
			productId: json['product_id'].toString(),
			quantity: json['quantity'].toString(),
			price: json['price'].toString(),
			color: json['color'],
			size: json['size'],
		);
	}
}