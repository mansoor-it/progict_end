import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/model_cart.dart'; // نموذج السلة

class PaymentPage extends StatefulWidget {
	final String userId;
	final double totalAmount;
	final List<CartItemModel> cartItems;
	final Function(String?) onPaymentSuccess; // ← تم تغييرها لتتقبل null

	const PaymentPage({
		Key? key,
		required this.userId,
		required this.totalAmount,
		required this.cartItems,
		required this.onPaymentSuccess, required String orderId,
	}) : super(key: key);

	@override
	_PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
	final String apiUrl = 'http://192.168.43.129/ecommerce/y.php';

	String? selectedPaymentMethod;

	late TextEditingController recipientNameController;
	late TextEditingController addressLine1Controller;
	late TextEditingController addressLine2Controller;
	late TextEditingController cityController;
	late TextEditingController postalCodeController;
	late TextEditingController countryController;
	late TextEditingController phoneController;

	bool isLoading = false;

	@override
	void initState() {
		super.initState();

		recipientNameController = TextEditingController(text: '');
		addressLine1Controller = TextEditingController(text: '');
		addressLine2Controller = TextEditingController(text: '');
		cityController = TextEditingController(text: '');
		postalCodeController = TextEditingController(text: '');
		countryController = TextEditingController(text: 'السعودية');
		phoneController = TextEditingController(text: '');
	}

	@override
	void dispose() {
		recipientNameController.dispose();
		addressLine1Controller.dispose();
		addressLine2Controller.dispose();
		cityController.dispose();
		postalCodeController.dispose();
		countryController.dispose();
		phoneController.dispose();
		super.dispose();
	}

	Future<void> submitOrder() async {
		setState(() {
			isLoading = true;
		});

		final items = widget.cartItems.map((item) {
			return {
				"product_id": item.productId,
				"quantity": int.tryParse(item.quantity) ?? 1,
				"price": double.tryParse(item.unitPrice) ?? 0.0,
			};
		}).toList();

		final orderData = {
			"user_id": widget.userId,
			"total_price": widget.totalAmount.toStringAsFixed(2),
			"items": items,
			"payment": {
				"amount": widget.totalAmount.toStringAsFixed(2),
				"method": selectedPaymentMethod ?? "credit_card",
				"status": "pending"
			},
			"shipping": {
				"recipient_name": recipientNameController.text,
				"address_line1": addressLine1Controller.text,
				"address_line2": addressLine2Controller.text,
				"city": cityController.text,
				"postal_code": postalCodeController.text,
				"country": countryController.text,
				"phone": phoneController.text,
				"notes": ""
			}
		};

		try {
			final response = await http.post(
				Uri.parse(apiUrl),
				headers: {'Content-Type': 'application/json'},
				body: json.encode(orderData),
			);

			if (response.statusCode == 200) {
				final responseData = json.decode(response.body);
				if (responseData['success']) {
					String? newOrderId = responseData['order_id'].toString(); // ← تم استلام الـ order_id من السيرفر
					widget.onPaymentSuccess(newOrderId); // ← إرسال القيمة للمستخدم
				} else {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(content: Text("فشل الطلب: ${responseData['message']}")),
					);
				}
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
							content: Text("خطأ في الاتصال: ${response.statusCode}")),
				);
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text("حدث خطأ أثناء إرسال الطلب: $e")),
			);
		}

		setState(() {
			isLoading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('معلومات الدفع والشحن'),
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: ListView(
					children: [
						Text(
							'تقديم طلب جديد',
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
						),
						SizedBox(height: 16),

						TextField(
							controller: recipientNameController,
							decoration: InputDecoration(labelText: 'اسم المستلم'),
						),

						TextField(
							controller: addressLine1Controller,
							decoration: InputDecoration(labelText: 'العنوان الأول'),
						),

						TextField(
							controller: addressLine2Controller,
							decoration:
							InputDecoration(labelText: 'العنوان الثاني (اختياري)'),
						),

						TextField(
							controller: cityController,
							decoration: InputDecoration(labelText: 'المدينة'),
						),

						TextField(
							controller: postalCodeController,
							decoration: InputDecoration(labelText: 'الرمز البريدي'),
						),

						TextField(
							controller: countryController,
							enabled: false,
							decoration: InputDecoration(labelText: 'البلد'),
						),

						TextField(
							controller: phoneController,
							keyboardType: TextInputType.phone,
							decoration: InputDecoration(labelText: 'رقم الهاتف'),
						),

						SizedBox(height: 16),

						DropdownButtonFormField<String>(
							value: selectedPaymentMethod ?? "credit_card",
							items: [
								DropdownMenuItem(value: "credit_card", child: Text("بطاقة ائتمانية")),
								DropdownMenuItem(value: "paypal", child: Text("PayPal")),
								DropdownMenuItem(value: "cash_on_delivery", child: Text("الدفع عند الاستلام")),
							],
							onChanged: (value) {
								setState(() {
									selectedPaymentMethod = value!;
								});
							},
							decoration: InputDecoration(labelText: 'طريقة الدفع'),
						),

						SizedBox(height: 30),

						ElevatedButton(
							onPressed: isLoading ? null : submitOrder,
							child: isLoading
									? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
									: Text('إرسال الطلب'),
						)
					],
				),
			),
		);
	}
}