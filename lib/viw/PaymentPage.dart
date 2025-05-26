import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/model_cart.dart';
import '../model/orders_payments_model.dart';
import '../service/orders_payments_server.dart';

class PaymentPage extends StatefulWidget {
	final String orderId;
	final String userId;
	final double totalAmount;
	final List<CartItemModel> cartItems;
	final Function(String) onPaymentSuccess;

	const PaymentPage({
		Key? key,
		required this.orderId,
		required this.userId,
		required this.totalAmount,
		required this.cartItems,
		required this.onPaymentSuccess,
	}) : super(key: key);

	@override
	_PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
	String _selectedPaymentMethod = 'credit_card';
	final _accountName = 'منصور'; // اسم صاحب الحساب للتحويل البنكي

	Future<void> _processPayment() async {
		try {
			// إنشاء الطلب
			final order = Order.create(
				id: widget.orderId,
				userId: widget.userId,
				totalPrice: widget.totalAmount.toString(),
				status: "pending",
			);

			final orderResult = await OrderPaymentService.addOrder(order);
			final orderJson = json.decode(orderResult);
			if (orderJson['success'] != true) throw Exception("فشل في إنشاء الطلب");

			// إضافة تفاصيل المنتجات
			for (var item in widget.cartItems) {
				final orderItem = OrderItem.create(
					id: "${DateTime.now().millisecondsSinceEpoch}${item.productId}",
					orderId: widget.orderId,
					productId: item.productId,
					productName: item.productId,
					productImage: "",
					quantity: item.quantity.toString(),
					price: double.parse(item.unitPrice).toString(),
				);

				final itemResult = await OrderPaymentService.addOrderItem(orderItem);
				final itemJson = json.decode(itemResult);
				if (itemJson['success'] != true) throw Exception("فشل في إضافة تفاصيل الطلب");
			}

			// تسجيل الدفع
			final payment = Payment.create(
				id: DateTime.now().toString(),
				orderId: widget.orderId,
				userId: widget.userId,
				amount: widget.totalAmount.toString(),
				paymentMethod: _selectedPaymentMethod,
				status: "paid",
			);

			final paymentResult = await OrderPaymentService.addPayment(payment);
			final paymentJson = json.decode(paymentResult);
			if (paymentJson['success'] != true) throw Exception("فشل في تسجيل الدفع");

			widget.onPaymentSuccess(widget.orderId);
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('تم الدفع بنجاح')),
			);
			Navigator.pop(context);
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('حدث خطأ: $e')),
			);
		}
	}

	Widget _buildPaymentMethodSelector() {
		return Column(
			children: [
				RadioListTile<String>(
					title: const Text('بطاقة إئتمان'),
					value: 'credit_card',
					groupValue: _selectedPaymentMethod,
					onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
				),
				RadioListTile<String>(
					title: const Text('الدفع عند الاستلام'),
					value: 'cash_on_delivery',
					groupValue: _selectedPaymentMethod,
					onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
				),
				RadioListTile<String>(
					title: const Text('تحويل بنكي'),
					value: 'bank_transfer',
					groupValue: _selectedPaymentMethod,
					onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
				),
				if (_selectedPaymentMethod == 'bank_transfer')
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
						child: Column(
							children: [
								const Text('الرجاء التحويل إلى الحساب البنكي التالي:'),
								Text(_accountName, style: const TextStyle(fontWeight: FontWeight.bold)),
								const Text('IBAN: SA00 0000 0000 0000 0000 0000'),
							],
						),
					),
			],
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('طرق الدفع')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Card(
							child: Padding(
								padding: const EdgeInsets.all(12.0),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text('رقم الطلب: ${widget.orderId}'),
										Text('المبلغ الإجمالي: \$${widget.totalAmount.toStringAsFixed(2)}'),
									],
								),
							),
						),
						const SizedBox(height: 20),
						const Text('اختر طريقة الدفع:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
						_buildPaymentMethodSelector(),
						const SizedBox(height: 20),
						Expanded(
							child: ListView.builder(
								itemCount: widget.cartItems.length,
								itemBuilder: (context, index) {
									final item = widget.cartItems[index];
									return ListTile(
										title: Text('منتج: ${item.productId}'),
										subtitle: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text('الكمية: ${item.quantity}'),
												Text('السعر: ${item.unitPrice}'),
											],
										),
									);
								},
							),
						),
						SizedBox(
							width: double.infinity,
							child: ElevatedButton(
								style: ElevatedButton.styleFrom(
									padding: const EdgeInsets.symmetric(vertical: 15),
								),
								onPressed: _processPayment,
								child: const Text('تأكيد الدفع', style: TextStyle(fontSize: 18)),
							),
						),
					],
				),
			),
		);
	}
}