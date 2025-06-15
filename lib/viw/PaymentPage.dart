// payment_page.dart - الإصدار النهائي المحسن

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // إضافة مكتبة الأيقونات

import '../ApiConfig.dart';
import '../model/model_cart.dart'; // نموذج السلة المحدث
import 'f/InvoicePage.dart'; // صفحة الفاتورة الجديدة

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

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
	final String apiUrl = ApiHelper.url('y.php');

	String? selectedPaymentMethod;

	// إضافة متحكم للرسوم المتحركة
	late AnimationController _animationController;
	late Animation<double> _animation;

	late TextEditingController recipientNameController;
	late TextEditingController addressLine1Controller;
	late TextEditingController addressLine2Controller;
	late TextEditingController cityController;
	late TextEditingController postalCodeController;
	late TextEditingController countryController;
	late TextEditingController phoneController;

	// إضافة متحكمات لبيانات البطاقة الائتمانية
	late TextEditingController cardNumberController;
	late TextEditingController cardHolderController;
	late TextEditingController expiryDateController;
	late TextEditingController cvvController;

	bool isLoading = false;

	// تعريف ألوان التطبيق
	final Color primaryColor = const Color(0xFF3F51B5);
	final Color accentColor = const Color(0xFFFF9800);
	final Color backgroundColor = const Color(0xFFF5F5F5);
	final Color cardColor = Colors.white;
	final Color textColor = const Color(0xFF333333);

	@override
	void initState() {
		super.initState();

		// تهيئة متحكم الرسوم المتحركة
		_animationController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 300),
		);
		_animation = CurvedAnimation(
			parent: _animationController,
			curve: Curves.easeInOut,
		);

		// تهيئة متحكمات النصوص
		recipientNameController = TextEditingController();
		addressLine1Controller = TextEditingController();
		addressLine2Controller = TextEditingController();
		cityController = TextEditingController();
		postalCodeController = TextEditingController();
		countryController = TextEditingController(text: 'اليمن');
		phoneController = TextEditingController();

		// تهيئة متحكمات بيانات البطاقة
		cardNumberController = TextEditingController();
		cardHolderController = TextEditingController();
		expiryDateController = TextEditingController();
		cvvController = TextEditingController();
	}

	@override
	void dispose() {
		// التخلص من متحكمات النصوص
		recipientNameController.dispose();
		addressLine1Controller.dispose();
		addressLine2Controller.dispose();
		cityController.dispose();
		postalCodeController.dispose();
		countryController.dispose();
		phoneController.dispose();

		// التخلص من متحكمات بيانات البطاقة
		cardNumberController.dispose();
		cardHolderController.dispose();
		expiryDateController.dispose();
		cvvController.dispose();

		// التخلص من متحكم الرسوم المتحركة
		_animationController.dispose();

		super.dispose();
	}

	// دالة لعرض أيقونة طريقة الدفع
	Widget _getPaymentMethodIcon(String? method) {
		switch (method) {
			case 'cremii':
				return const FaIcon(FontAwesomeIcons.buildingColumns, color: Color(0xFF1976D2));
			case 'raseed_fawri':
				return const FaIcon(FontAwesomeIcons.moneyBillTransfer, color: Color(0xFF43A047));
			case 'credit_card':
				return const FaIcon(FontAwesomeIcons.creditCard, color: Color(0xFF7B1FA2));
			case 'cash_on_delivery':
				return const FaIcon(FontAwesomeIcons.handHoldingDollar, color: Color(0xFFEF6C00));
			default:
				return const FaIcon(FontAwesomeIcons.wallet, color: Colors.grey);
		}
	}

	// دالة لعرض تفاصيل طريقة الدفع المختارة
	Widget _buildPaymentMethodDetails() {
		if (selectedPaymentMethod == null) {
			return const SizedBox.shrink();
		}

		return AnimatedBuilder(
			animation: _animation,
			builder: (context, child) {
				return FadeTransition(
					opacity: _animation,
					child: SizeTransition(
						sizeFactor: _animation,
						child: child,
					),
				);
			},
			child: Container(
				margin: const EdgeInsets.only(top: 16),
				padding: const EdgeInsets.all(16),
				decoration: BoxDecoration(
					color: cardColor,
					borderRadius: BorderRadius.circular(8),
					boxShadow: [
						BoxShadow(
							color: Colors.black.withOpacity(0.1),
							blurRadius: 8,
							offset: const Offset(0, 2),
						),
					],
				),
				child: _buildPaymentMethodContent(),
			),
		);
	}

	// دالة لعرض محتوى تفاصيل طريقة الدفع
	Widget _buildPaymentMethodContent() {
		switch (selectedPaymentMethod) {
			case 'cremii':
				return Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								const FaIcon(FontAwesomeIcons.buildingColumns, color: Color(0xFF1976D2)),
								const SizedBox(width: 8),
								Text(
									'تفاصيل الحساب البنكي',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.bold,
										color: const Color(0xFF1976D2),
									),
								),
							],
						),
						const Divider(),
						const SizedBox(height: 8),
						_buildInfoRow('اسم الحساب:', 'منصور'),
						const SizedBox(height: 8),
						_buildInfoRow('رقم الحساب:', '122222'),
						const SizedBox(height: 16),
						const Text(
							'يرجى تحويل المبلغ المطلوب إلى الحساب المذكور أعلاه وإكمال الطلب.',
							style: TextStyle(fontSize: 14),
						),
					],
				);

			case 'raseed_fawri':
				return Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								const FaIcon(FontAwesomeIcons.moneyBillTransfer, color: Color(0xFF43A047)),
								const SizedBox(width: 8),
								Text(
									'تفاصيل الرصيد الفوري',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.bold,
										color: const Color(0xFF43A047),
									),
								),
							],
						),
						const Divider(),
						const SizedBox(height: 8),
						_buildInfoRow('رقم التحويل:', '7333494291'),
						const SizedBox(height: 16),
						Container(
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: const Color(0xFFE8F5E9),
								borderRadius: BorderRadius.circular(8),
							),
							child: const Row(
								children: [
									Icon(Icons.info_outline, color: Color(0xFF43A047)),
									SizedBox(width: 8),
									Expanded(
										child: Text(
											'قم بتحويل المبلغ المطلوب عبر هذا الرقم ثم أكمل الطلب.',
											style: TextStyle(fontSize: 14),
										),
									),
								],
							),
						),
					],
				);

			case 'credit_card':
				return Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								const FaIcon(FontAwesomeIcons.creditCard, color: Color(0xFF7B1FA2)),
								const SizedBox(width: 8),
								Text(
									'بيانات البطاقة الائتمانية',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.bold,
										color: const Color(0xFF7B1FA2),
									),
								),
							],
						),
						const Divider(),
						const SizedBox(height: 8),
						TextField(
							controller: cardNumberController,
							decoration: InputDecoration(
								labelText: 'رقم البطاقة',
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(8),
								),
								prefixIcon: const Icon(Icons.credit_card),
							),
							keyboardType: TextInputType.number,
						),
						const SizedBox(height: 12),
						TextField(
							controller: cardHolderController,
							decoration: InputDecoration(
								labelText: 'اسم حامل البطاقة',
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(8),
								),
								prefixIcon: const Icon(Icons.person),
							),
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(
									child: TextField(
										controller: expiryDateController,
										decoration: InputDecoration(
											labelText: 'تاريخ الانتهاء (MM/YY)',
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(8),
											),
											prefixIcon: const Icon(Icons.date_range),
										),
										keyboardType: TextInputType.datetime,
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: TextField(
										controller: cvvController,
										decoration: InputDecoration(
											labelText: 'رمز الأمان (CVV)',
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(8),
											),
											prefixIcon: const Icon(Icons.security),
										),
										keyboardType: TextInputType.number,
										obscureText: true,
										maxLength: 3,
										buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
									),
								),
							],
						),
						const SizedBox(height: 16),
						Row(
							children: [
								const FaIcon(FontAwesomeIcons.lock, size: 14, color: Colors.grey),
								const SizedBox(width: 8),
								const Expanded(
									child: Text(
										'جميع المعاملات مشفرة وآمنة',
										style: TextStyle(fontSize: 12, color: Colors.grey),
									),
								),
							],
						),
					],
				);

			case 'cash_on_delivery':
				return Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								const FaIcon(FontAwesomeIcons.handHoldingDollar, color: Color(0xFFEF6C00)),
								const SizedBox(width: 8),
								Text(
									'الدفع عند الاستلام',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.bold,
										color: const Color(0xFFEF6C00),
									),
								),
							],
						),
						const Divider(),
						const SizedBox(height: 8),
						Container(
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: const Color(0xFFFFF3E0),
								borderRadius: BorderRadius.circular(8),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const Row(
										children: [
											Icon(Icons.info_outline, color: Color(0xFFEF6C00)),
											SizedBox(width: 8),
											Expanded(
												child: Text(
													'سيتم الدفع نقداً عند استلام الطلب.',
													style: TextStyle(fontSize: 14),
												),
											),
										],
									),
									const SizedBox(height: 8),
									_buildInfoRow('كود التأكيد:', 'COD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}'),
									const SizedBox(height: 8),
									const Text(
										'يرجى الاحتفاظ بكود التأكيد لتقديمه عند الاستلام.',
										style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
									),
								],
							),
						),
					],
				);

			default:
				return const SizedBox.shrink();
		}
	}

	// دالة مساعدة لعرض صف معلومات
	Widget _buildInfoRow(String label, String value) {
		return Row(
			children: [
				Text(
					label,
					style: const TextStyle(
						fontWeight: FontWeight.bold,
						fontSize: 14,
					),
				),
				const SizedBox(width: 8),
				Text(
					value,
					style: const TextStyle(fontSize: 14),
				),
			],
		);
	}

	// دالة لعرض بطاقة منتج في ملخص الطلب
	Widget _buildProductCard(CartItemModel item) {
		final qty = int.tryParse(item.quantity) ?? 1;
		final pricePer = double.tryParse(item.unitPrice) ?? 0.0;
		final totalForItem = qty * pricePer;

		return Card(
			elevation: 2,
			margin: const EdgeInsets.symmetric(vertical: 6),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(8),
			),
			child: Padding(
				padding: const EdgeInsets.all(12),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// صورة المنتج (يمكن استبدالها بصورة فعلية)
						Container(
							width: 60,
							height: 60,
							decoration: BoxDecoration(
								color: Colors.grey.shade200,
								borderRadius: BorderRadius.circular(6),
							),
							child: const Center(
								child: Icon(Icons.shopping_bag, color: Colors.grey),
							),
						),
						const SizedBox(width: 12),
						// تفاصيل المنتج
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										item.productName ?? 'منتج',
										style: const TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 16,
										),
									),
									const SizedBox(height: 4),
									Text(
										'الكمية: $qty',
										style: TextStyle(
											fontSize: 14,
											color: Colors.grey.shade700,
										),
									),
									if (item.colorName != null)
										Text(
											'اللون: ${item.colorName}',
											style: TextStyle(
												fontSize: 14,
												color: Colors.grey.shade700,
											),
										),
									if (item.sizeName != null)
										Text(
											'المقاس: ${item.sizeName}',
											style: TextStyle(
												fontSize: 14,
												color: Colors.grey.shade700,
											),
										),
								],
							),
						),
						// سعر المنتج
						Text(
							'\$${totalForItem.toStringAsFixed(2)}',
							style: TextStyle(
								fontWeight: FontWeight.bold,
								fontSize: 16,
								color: primaryColor,
							),
						),
					],
				),
			),
		);
	}

	// دالة لعرض قسم بعنوان
	Widget _buildSectionTitle(String title, IconData icon) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 16),
			child: Row(
				children: [
					Icon(icon, color: primaryColor),
					const SizedBox(width: 8),
					Text(
						title,
						style: Theme.of(context).textTheme.titleLarge?.copyWith(
							fontWeight: FontWeight.bold,
							color: primaryColor,
						),
					),
				],
			),
		);
	}

	// دالة لعرض حقل إدخال
	Widget _buildTextField({
		required TextEditingController controller,
		required String label,
		required IconData icon,
		bool enabled = true,
		TextInputType keyboardType = TextInputType.text,
	}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 12),
			child: TextField(
				controller: controller,
				enabled: enabled,
				keyboardType: keyboardType,
				decoration: InputDecoration(
					labelText: label,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
					),
					prefixIcon: Icon(icon),
					filled: true,
					fillColor: enabled ? Colors.white : Colors.grey.shade100,
				),
			),
		);
	}

	Future<void> submitOrder() async {
		if (selectedPaymentMethod == null) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('يرجى اختيار طريقة الدفع أولاً'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		// التحقق من صحة بيانات الشحن
		if (recipientNameController.text.isEmpty ||
				addressLine1Controller.text.isEmpty ||
				cityController.text.isEmpty ||
				phoneController.text.isEmpty) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('يرجى إكمال جميع بيانات الشحن المطلوبة'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		// التحقق من صحة بيانات البطاقة إذا تم اختيار الدفع بالبطاقة
		if (selectedPaymentMethod == 'credit_card') {
			if (cardNumberController.text.isEmpty ||
					cardHolderController.text.isEmpty ||
					expiryDateController.text.isEmpty ||
					cvvController.text.isEmpty) {
				if (!mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('يرجى إكمال جميع بيانات البطاقة الائتمانية'),
						backgroundColor: Colors.red,
					),
				);
				return;
			}
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
						SnackBar(
							content: Text("فشل إنشاء الطلب: ${responseData['message']}"),
							backgroundColor: Colors.red,
						),
					);
				}
			} else {
				if (!mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("خطأ في الاتصال بالخادم: ${response.statusCode}"),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text("حدث خطأ أثناء إرسال الطلب: $e"),
					backgroundColor: Colors.red,
				),
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
				backgroundColor: primaryColor,
				foregroundColor: Colors.white,
				elevation: 2,
			),
			backgroundColor: backgroundColor,
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: ListView(
						children: [
							// ملخص الطلب
							_buildSectionTitle('ملخص الطلب', Icons.shopping_cart),
							...widget.cartItems.map((item) => _buildProductCard(item)).toList(),

							// المبلغ الإجمالي
							Container(
								margin: const EdgeInsets.symmetric(vertical: 16),
								padding: const EdgeInsets.all(16),
								decoration: BoxDecoration(
									color: primaryColor.withOpacity(0.1),
									borderRadius: BorderRadius.circular(8),
								),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text(
											'المبلغ الإجمالي:',
											style: Theme.of(context).textTheme.titleMedium?.copyWith(
												fontWeight: FontWeight.bold,
											),
										),
										Text(
											'\$${widget.totalAmount.toStringAsFixed(2)}',
											style: Theme.of(context).textTheme.titleMedium?.copyWith(
												fontWeight: FontWeight.bold,
												color: primaryColor,
											),
										),
									],
								),
							),

							// معلومات الشحن
							_buildSectionTitle('معلومات الشحن', Icons.local_shipping),
							Card(
								elevation: 2,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										children: [
											_buildTextField(
												controller: recipientNameController,
												label: 'اسم المستلم',
												icon: Icons.person,
											),
											_buildTextField(
												controller: addressLine1Controller,
												label: 'العنوان الأول',
												icon: Icons.home,
											),
											_buildTextField(
												controller: addressLine2Controller,
												label: 'العنوان الثاني (اختياري)',
												icon: Icons.location_on,
											),
											_buildTextField(
												controller: cityController,
												label: 'المدينة',
												icon: Icons.location_city,
											),
											_buildTextField(
												controller: postalCodeController,
												label: 'الرمز البريدي',
												icon: Icons.markunread_mailbox,
											),
											_buildTextField(
												controller: countryController,
												label: 'البلد',
												icon: Icons.flag,
												enabled: false,
											),
											_buildTextField(
												controller: phoneController,
												label: 'رقم الهاتف',
												icon: Icons.phone,
												keyboardType: TextInputType.phone,
											),
										],
									),
								),
							),

							// طريقة الدفع
							_buildSectionTitle('طريقة الدفع', Icons.payment),
							Card(
								elevation: 2,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											// خيارات طرق الدفع
											_buildPaymentMethodOption(
												'cremii',
												'كريمي (حساب بنكي)',
												FontAwesomeIcons.buildingColumns,
												const Color(0xFF1976D2),
											),
											const SizedBox(height: 8),
											_buildPaymentMethodOption(
												'raseed_fawri',
												'رصيد فوري',
												FontAwesomeIcons.moneyBillTransfer,
												const Color(0xFF43A047),
											),
											const SizedBox(height: 8),
											_buildPaymentMethodOption(
												'credit_card',
												'بطاقة ائتمانية',
												FontAwesomeIcons.creditCard,
												const Color(0xFF7B1FA2),
											),
											const SizedBox(height: 8),
											_buildPaymentMethodOption(
												'cash_on_delivery',
												'الدفع عند الاستلام',
												FontAwesomeIcons.handHoldingDollar,
												const Color(0xFFEF6C00),
											),

											// تفاصيل طريقة الدفع المختارة
											_buildPaymentMethodDetails(),
										],
									),
								),
							),

							// زر إتمام الطلب
							const SizedBox(height: 30),
							ElevatedButton(
								onPressed: isLoading ? null : submitOrder,
								style: ElevatedButton.styleFrom(
									backgroundColor: accentColor,
									foregroundColor: Colors.white,
									padding: const EdgeInsets.symmetric(vertical: 16),
									textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(12),
									),
									elevation: 3,
								),
								child: isLoading
										? const SizedBox(
									width: 24,
									height: 24,
									child: CircularProgressIndicator(color: Colors.white),
								)
										: const Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(Icons.check_circle),
										SizedBox(width: 8),
										Text('إتمام الطلب والدفع'),
									],
								),
							),
							const SizedBox(height: 30),
						],
					),
				),
			),
		);
	}

	// دالة لعرض خيار طريقة دفع
	Widget _buildPaymentMethodOption(String value, String title, IconData icon, Color color) {
		final isSelected = selectedPaymentMethod == value;

		return InkWell(
			onTap: () {
				setState(() {
					selectedPaymentMethod = value;
					// تشغيل الرسوم المتحركة عند اختيار طريقة دفع
					_animationController.reset();
					_animationController.forward();
				});
			},
			borderRadius: BorderRadius.circular(8),
			child: Container(
				padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
				decoration: BoxDecoration(
					color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
					borderRadius: BorderRadius.circular(8),
					border: Border.all(
						color: isSelected ? color : Colors.grey.shade300,
						width: isSelected ? 2 : 1,
					),
				),
				child: Row(
					children: [
						FaIcon(icon, color: color),
						const SizedBox(width: 12),
						Expanded(
							child: Text(
								title,
								style: TextStyle(
									fontSize: 16,
									fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
								),
							),
						),
						if (isSelected)
							Icon(Icons.check_circle, color: color),
					],
				),
			),
		);
	}
}
