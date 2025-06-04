// invoice_page.dart

import 'package:flutter/material.dart';
import '../model/model_cart.dart'; // نموذج البنود

class InvoicePage extends StatelessWidget {
	final String orderId;
	final String userId;
	final List<CartItemModel> cartItems;
	final double totalAmount;
	final String recipientName;
	final String addressLine1;
	final String addressLine2;
	final String city;
	final String postalCode;
	final String country;
	final String phone;

	const InvoicePage({
		Key? key,
		required this.orderId,
		required this.userId,
		required this.cartItems,
		required this.totalAmount,
		required this.recipientName,
		required this.addressLine1,
		required this.addressLine2,
		required this.city,
		required this.postalCode,
		required this.country,
		required this.phone,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('فاتورة الطلب'),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () {
						Navigator.of(context).pop();
					},
				),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// عنوان الفاتورة
						Center(
							child: Text(
								'فاتورة رقم: $orderId',
								style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
							),
						),
						const SizedBox(height: 12),

						// معلومات المستخدم والتاريخ
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text('معرف المستخدم: $userId', style: const TextStyle(fontSize: 14)),
								Text(
									'التاريخ: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
									style: const TextStyle(fontSize: 14),
								),
							],
						),
						const Divider(thickness: 1.2),

						// جدول البنود
						const Text('تفاصيل البنود:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
						const SizedBox(height: 8),
						Table(
							border: TableBorder.all(color: Colors.grey.shade300),
							columnWidths: const {
								0: FlexColumnWidth(4),
								1: FlexColumnWidth(1),
								2: FlexColumnWidth(2),
								3: FlexColumnWidth(2),
							},
							children: [
								TableRow(
									decoration: BoxDecoration(color: Colors.grey[200]),
									children: const [
										Padding(
											padding: EdgeInsets.all(8.0),
											child: Text('المنتج', style: TextStyle(fontWeight: FontWeight.bold)),
										),
										Padding(
											padding: EdgeInsets.all(8.0),
											child: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold)),
										),
										Padding(
											padding: EdgeInsets.all(8.0),
											child: Text('سعر القطعة', style: TextStyle(fontWeight: FontWeight.bold)),
										),
										Padding(
											padding: EdgeInsets.all(8.0),
											child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
										),
									],
								),
								...cartItems.map((item) {
									final qty = int.tryParse(item.quantity) ?? 1;
									final pricePer = double.tryParse(item.unitPrice) ?? 0.0;
									final totalForItem = qty * pricePer;
									final name = item.productName ?? 'منتج';
									final displayName = name +
											(item.colorName != null ? "\n(لون: ${item.colorName})" : '') +
											(item.sizeName != null ? "\n(مقاس: ${item.sizeName})" : '');

									return TableRow(
										children: [
											Padding(
												padding: const EdgeInsets.all(8.0),
												child: Text(displayName),
											),
											Padding(
												padding: const EdgeInsets.all(8.0),
												child: Text('$qty', textAlign: TextAlign.center),
											),
											Padding(
												padding: const EdgeInsets.all(8.0),
												child: Text('${pricePer.toStringAsFixed(2)}\$',
														textAlign: TextAlign.center),
											),
											Padding(
												padding: const EdgeInsets.all(8.0),
												child: Text('${totalForItem.toStringAsFixed(2)}\$',
														textAlign: TextAlign.center),
											),
										],
									);
								}).toList(),
							],
						),
						const SizedBox(height: 12),

						// المجموع الكلي
						Align(
							alignment: Alignment.centerRight,
							child: Text(
								'المجموع الكلي: ${totalAmount.toStringAsFixed(2)}\$',
								style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
							),
						),
						const SizedBox(height: 16),

						// عنوان معلومات الشحن
						const Text('معلومات الشحن:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
						const SizedBox(height: 8),
						Text('اسم المستلم: $recipientName', style: const TextStyle(fontSize: 14)),
						const SizedBox(height: 4),
						Text('العنوان: $addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}',
								style: const TextStyle(fontSize: 14)),
						const SizedBox(height: 4),
						Text('المدينة: $city', style: const TextStyle(fontSize: 14)),
						const SizedBox(height: 4),
						Text('الرمز البريدي: $postalCode', style: const TextStyle(fontSize: 14)),
						const SizedBox(height: 4),
						Text('البلد: $country', style: const TextStyle(fontSize: 14)),
						const SizedBox(height: 4),
						Text('رقم الهاتف: $phone', style: const TextStyle(fontSize: 14)),
						const SizedBox(height: 16),
					],
				),
			),
		);
	}
}
