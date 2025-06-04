// payment_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';
import '../model/model_cart.dart'; // نموذج السلة المحدث
import 'f/InvoicePage.dart';
     // صفحة الفاتورة الجديدة

class PaymentPage extends StatefulWidget {
	final String userId;
	final double totalAmount;
	final List<CartItemModel> cartItems; // استقبال قائمة البنود
	final Function(String?) onPaymentSuccess; // استدعاء عند نجاح الدفع
	final VoidCallback onClearCart; // دالة لإفراغ السلة
	final String orderId; // معرف الطلب

	const PaymentPage({
		Key? key,
		required this.userId,
		required this.totalAmount,
		required this.cartItems,
		required this.onPaymentSuccess,
		required this.onClearCart,
		required this.orderId,
	}) : super(key: key);

	@override
	_PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
	final String apiUrl = ApiHelper.url('y.php');

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
		recipientNameController = TextEditingController();
		addressLine1Controller = TextEditingController();
		addressLine2Controller = TextEditingController();
		cityController = TextEditingController();
		postalCodeController = TextEditingController();
		countryController = TextEditingController(text: 'اليمن');
		phoneController = TextEditingController();
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
		if (selectedPaymentMethod == null) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('يرجى اختيار طريقة الدفع أولاً')),
			);
			return;
		}

		if (mounted) {
			setState(() => isLoading = true);
		}

		final items = widget.cartItems.map((item) {
			return {
				"product_id": item.productId,
				"quantity": int.tryParse(item.quantity) ?? 1,
				"price": double.tryParse(item.unitPrice) ?? 0.0,
				"color_id": item.colorId,
				"color_name": item.colorName,
				"size_id": item.sizeId,
				"size_name": item.sizeName,
			};
		}).toList();

		final orderData = {
			"user_id": widget.userId,
			"order_id": widget.orderId,
			"total_price": widget.totalAmount.toStringAsFixed(2),
			"items": items,
			"payment": {
				"amount": widget.totalAmount.toStringAsFixed(2),
				"method": selectedPaymentMethod,
				"status": "completed"
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
					String finalOrderId = responseData['order_id']?.toString() ?? widget.orderId;
					widget.onPaymentSuccess(finalOrderId);

					// الذهاب إلى صفحة الفاتورة مع تمرير البيانات
					if (!mounted) return;
					Navigator.of(context).pushReplacement(
						MaterialPageRoute(
							builder: (_) => InvoicePage(
								orderId: finalOrderId,
								userId: widget.userId,
								cartItems: widget.cartItems,
								totalAmount: widget.totalAmount,
								recipientName: recipientNameController.text,
								addressLine1: addressLine1Controller.text,
								addressLine2: addressLine2Controller.text,
								city: cityController.text,
								postalCode: postalCodeController.text,
								country: countryController.text,
								phone: phoneController.text,
							),
						),
					).then((_) {
						// بعد العودة من صفحة الفاتورة، أفرغ السلة
						widget.onClearCart();
					});
				} else {
					if (!mounted) return;
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(content: Text("فشل إنشاء الطلب: ${responseData['message']}")),
					);
				}
			} else {
				if (!mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text("خطأ في الاتصال بالخادم: ${response.statusCode}")),
				);
			}
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text("حدث خطأ أثناء إرسال الطلب: $e")),
			);
		}

		if (mounted) {
			setState(() => isLoading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('الدفع والشحن'),
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: ListView(
					children: [
						// ملخص الطلب
						Text('ملخص الطلب', style: Theme.of(context).textTheme.titleLarge),
						const SizedBox(height: 8),
						...widget.cartItems.map((item) {
							final qty = int.tryParse(item.quantity) ?? 1;
							final pricePer = double.tryParse(item.unitPrice) ?? 0.0;
							final totalForItem = qty * pricePer;
							return ListTile(
								title: Text(item.productName ?? 'منتج'),
								subtitle: Text(
									'الكمية: $qty' +
											(item.colorName != null ? ' - اللون: ${item.colorName}' : '') +
											(item.sizeName != null ? ' - المقاس: ${item.sizeName}' : ''),
								),
								trailing: Text('\$${totalForItem.toStringAsFixed(2)}'),
							);
						}).toList(),
						const Divider(),
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 8.0),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Text('المبلغ الإجمالي:', style: Theme.of(context).textTheme.titleMedium),
									Text('\$${widget.totalAmount.toStringAsFixed(2)}',
											style: Theme.of(context)
													.textTheme
													.titleMedium
													?.copyWith(fontWeight: FontWeight.bold)),
								],
							),
						),
						const Divider(),

						const SizedBox(height: 16),
						Text('معلومات الشحن', style: Theme.of(context).textTheme.titleLarge),
						const SizedBox(height: 8),
						TextField(
							controller: recipientNameController,
							decoration: const InputDecoration(labelText: 'اسم المستلم', border: OutlineInputBorder()),
						),
						const SizedBox(height: 8),
						TextField(
							controller: addressLine1Controller,
							decoration: const InputDecoration(labelText: 'العنوان الأول', border: OutlineInputBorder()),
						),
						const SizedBox(height: 8),
						TextField(
							controller: addressLine2Controller,
							decoration: const InputDecoration(labelText: 'العنوان الثاني (اختياري)', border: OutlineInputBorder()),
						),
						const SizedBox(height: 8),
						TextField(
							controller: cityController,
							decoration: const InputDecoration(labelText: 'المدينة', border: OutlineInputBorder()),
						),
						const SizedBox(height: 8),
						TextField(
							controller: postalCodeController,
							decoration: const InputDecoration(labelText: 'الرمز البريدي', border: OutlineInputBorder()),
						),
						const SizedBox(height: 8),
						TextField(
							controller: countryController,
							enabled: false,
							decoration: const InputDecoration(labelText: 'البلد', border: OutlineInputBorder()),
						),
						const SizedBox(height: 8),
						TextField(
							controller: phoneController,
							keyboardType: TextInputType.phone,
							decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
						),

						const SizedBox(height: 16),
						Text('طريقة الدفع', style: Theme.of(context).textTheme.titleLarge),
						const SizedBox(height: 8),
						DropdownButtonFormField<String>(
							value: selectedPaymentMethod,
							hint: const Text('اختر طريقة الدفع'),
							items: const [
								DropdownMenuItem(value: "credit_card", child: Text("بطاقة ائتمانية")),
								DropdownMenuItem(value: "paypal", child: Text("PayPal")),
								DropdownMenuItem(value: "cash_on_delivery", child: Text("الدفع عند الاستلام")),
							],
							onChanged: (value) {
								setState(() => selectedPaymentMethod = value);
							},
							decoration: const InputDecoration(labelText: 'طريقة الدفع', border: OutlineInputBorder()),
						),

						const SizedBox(height: 30),
						ElevatedButton(
							onPressed: isLoading ? null : submitOrder,
							style: ElevatedButton.styleFrom(
								padding: const EdgeInsets.symmetric(vertical: 16),
								textStyle: const TextStyle(fontSize: 18),
							),
							child: isLoading
									? const SizedBox(
								width: 24,
								height: 24,
								child: CircularProgressIndicator(color: Colors.white),
							)
									: const Text('إتمام الطلب والدفع'),
						)
					],
				),
			),
		);
	}
}
