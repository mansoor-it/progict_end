// invoice_page.dart

import 'package:flutter/material.dart';
import '../../chatgpt/chat_page.dart';
import '../../model/model_cart.dart'; // نموذج البنود
import 'package:flutter/services.dart'; // لإضافة تأثيرات اهتزاز
import 'package:intl/intl.dart'; // لتنسيق التاريخ والأرقام

class InvoicePage extends StatefulWidget {
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
	State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> with SingleTickerProviderStateMixin {
	late AnimationController _animationController;
	late Animation<double> _fadeAnimation;
	bool _showHelp = false;

	@override
	void initState() {
		super.initState();
		// إعداد الرسوم المتحركة
		_animationController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 800),
		);
		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
		);
		_animationController.forward();
	}

	@override
	void dispose() {
		_animationController.dispose();
		super.dispose();
	}

	// دالة لتنسيق التاريخ
	String _formatDate() {
		final now = DateTime.now();
		return DateFormat('yyyy-MM-dd').format(now);
	}

	// دالة لتنسيق الأرقام
	String _formatCurrency(double amount) {
		return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
	}

	// دالة لعرض رسالة مساعدة
	void _toggleHelp() {
		setState(() {
			_showHelp = !_showHelp;
		});
		// إضافة تأثير اهتزاز عند الضغط
		HapticFeedback.mediumImpact();
	}

	// دالة للانتقال إلى صفحة المحادثة
	void _navigateToChatPage() {
		HapticFeedback.lightImpact();
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => ChatPage(),
			),
		);
		// افتراض وجود مسار للانتقال إلى صفحة المحادثة
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final isDarkMode = theme.brightness == Brightness.dark;
		final primaryColor = theme.colorScheme.primary;
		final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
		final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
		final textColor = isDarkMode ? Colors.white : Colors.black87;
		final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

		return Scaffold(
			backgroundColor: backgroundColor,
			appBar: AppBar(
				title: const Text('فاتورة الطلب'),
				centerTitle: true,
				elevation: 0,
				backgroundColor: primaryColor,
				foregroundColor: Colors.white,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () {
						Navigator.of(context).pop();
					},
					tooltip: 'العودة',
				),
				actions: [
					// زر المساعدة
					IconButton(
						icon: const Icon(Icons.help_outline),
						onPressed: _toggleHelp,
						tooltip: 'مساعدة',
					),
					// زر الاستفسار للانتقال إلى صفحة المحادثة
					IconButton(
						icon: const Icon(Icons.chat_bubble_outline),
						onPressed: _navigateToChatPage,
						tooltip: 'استفسار عن الطلب',
					),
				],
			),
			body: Stack(
				children: [
					// المحتوى الرئيسي
					FadeTransition(
						opacity: _fadeAnimation,
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(16.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// بطاقة عنوان الفاتورة
									Card(
										elevation: 4,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(15),
											side: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
										),
										color: cardColor,
										child: Padding(
											padding: const EdgeInsets.all(16.0),
											child: Column(
												children: [
													Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															Icon(Icons.receipt_long, color: primaryColor, size: 28),
															const SizedBox(width: 8),
															Text(
																'فاتورة رقم: ${widget.orderId}',
																style: TextStyle(
																	fontSize: 24,
																	fontWeight: FontWeight.bold,
																	color: textColor,
																),
															),
														],
													),
													const SizedBox(height: 12),
													// معلومات المستخدم والتاريخ
													Row(
														mainAxisAlignment: MainAxisAlignment.spaceBetween,
														children: [
															Row(
																children: [
																	Icon(Icons.person, color: subtitleColor, size: 16),
																	const SizedBox(width: 4),
																	Text(
																		'معرف المستخدم: ${widget.userId}',
																		style: TextStyle(fontSize: 14, color: subtitleColor),
																	),
																],
															),
															Row(
																children: [
																	Icon(Icons.calendar_today, color: subtitleColor, size: 16),
																	const SizedBox(width: 4),
																	Text(
																		'التاريخ: ${_formatDate()}',
																		style: TextStyle(fontSize: 14, color: subtitleColor),
																	),
																],
															),
														],
													),
												],
											),
										),
									),
									const SizedBox(height: 16),

									// بطاقة تفاصيل البنود
									Card(
										elevation: 4,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(15),
										),
										color: cardColor,
										child: Padding(
											padding: const EdgeInsets.all(16.0),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Row(
														children: [
															Icon(Icons.shopping_cart, color: primaryColor),
															const SizedBox(width: 8),
															Text(
																'تفاصيل البنود:',
																style: TextStyle(
																	fontSize: 18,
																	fontWeight: FontWeight.bold,
																	color: textColor,
																),
															),
														],
													),
													const SizedBox(height: 12),
													// جدول البنود بتصميم محسن
													Container(
														decoration: BoxDecoration(
															border: Border.all(color: Colors.grey.shade300),
															borderRadius: BorderRadius.circular(8),
														),
														child: ClipRRect(
															borderRadius: BorderRadius.circular(8),
															child: Table(
																border: TableBorder.all(color: Colors.grey.shade300),
																columnWidths: const {
																	0: FlexColumnWidth(4),
																	1: FlexColumnWidth(1),
																	2: FlexColumnWidth(2),
																	3: FlexColumnWidth(2),
																},
																children: [
																	TableRow(
																		decoration: BoxDecoration(
																			color: primaryColor.withOpacity(0.2),
																		),
																		children: [
																			Padding(
																				padding: const EdgeInsets.all(10.0),
																				child: Text(
																					'المنتج',
																					style: TextStyle(
																						fontWeight: FontWeight.bold,
																						color: textColor,
																					),
																				),
																			),
																			Padding(
																				padding: const EdgeInsets.all(10.0),
																				child: Text(
																					'الكمية',
																					style: TextStyle(
																						fontWeight: FontWeight.bold,
																						color: textColor,
																					),
																					textAlign: TextAlign.center,
																				),
																			),
																			Padding(
																				padding: const EdgeInsets.all(10.0),
																				child: Text(
																					'سعر القطعة',
																					style: TextStyle(
																						fontWeight: FontWeight.bold,
																						color: textColor,
																					),
																					textAlign: TextAlign.center,
																				),
																			),
																			Padding(
																				padding: const EdgeInsets.all(10.0),
																				child: Text(
																					'الإجمالي',
																					style: TextStyle(
																						fontWeight: FontWeight.bold,
																						color: textColor,
																					),
																					textAlign: TextAlign.center,
																				),
																			),
																		],
																	),
																	...widget.cartItems.map((item) {
																		final qty = int.tryParse(item.quantity) ?? 1;
																		final pricePer = double.tryParse(item.unitPrice) ?? 0.0;
																		final totalForItem = qty * pricePer;
																		final name = item.productName ?? 'منتج';
																		final displayName = name +
																				(item.colorName != null ? "\n(لون: ${item.colorName})" : '') +
																				(item.sizeName != null ? "\n(مقاس: ${item.sizeName})" : '');

																		return TableRow(
																			decoration: BoxDecoration(
																				color: widget.cartItems.indexOf(item) % 2 == 0
																						? Colors.transparent
																						: (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
																			),
																			children: [
																				Padding(
																					padding: const EdgeInsets.all(10.0),
																					child: Text(
																						displayName,
																						style: TextStyle(color: textColor),
																					),
																				),
																				Padding(
																					padding: const EdgeInsets.all(10.0),
																					child: Text(
																						'$qty',
																						textAlign: TextAlign.center,
																						style: TextStyle(color: textColor),
																					),
																				),
																				Padding(
																					padding: const EdgeInsets.all(10.0),
																					child: Text(
																						_formatCurrency(pricePer),
																						textAlign: TextAlign.center,
																						style: TextStyle(color: textColor),
																					),
																				),
																				Padding(
																					padding: const EdgeInsets.all(10.0),
																					child: Text(
																						_formatCurrency(totalForItem),
																						textAlign: TextAlign.center,
																						style: TextStyle(
																							color: primaryColor,
																							fontWeight: FontWeight.bold,
																						),
																					),
																				),
																			],
																		);
																	}).toList(),
																],
															),
														),
													),
													const SizedBox(height: 16),

													// المجموع الكلي بتصميم محسن
													Container(
														padding: const EdgeInsets.all(12),
														decoration: BoxDecoration(
															color: primaryColor.withOpacity(0.1),
															borderRadius: BorderRadius.circular(8),
															border: Border.all(color: primaryColor.withOpacity(0.3)),
														),
														child: Row(
															mainAxisAlignment: MainAxisAlignment.spaceBetween,
															children: [
																Text(
																	'المجموع الكلي:',
																	style: TextStyle(
																		fontSize: 18,
																		fontWeight: FontWeight.bold,
																		color: textColor,
																	),
																),
																Text(
																	_formatCurrency(widget.totalAmount),
																	style: TextStyle(
																		fontSize: 18,
																		fontWeight: FontWeight.bold,
																		color: primaryColor,
																	),
																),
															],
														),
													),
												],
											),
										),
									),
									const SizedBox(height: 16),

									// بطاقة معلومات الشحن
									Card(
										elevation: 4,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(15),
										),
										color: cardColor,
										child: Padding(
											padding: const EdgeInsets.all(16.0),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Row(
														children: [
															Icon(Icons.local_shipping, color: primaryColor),
															const SizedBox(width: 8),
															Text(
																'معلومات الشحن:',
																style: TextStyle(
																	fontSize: 18,
																	fontWeight: FontWeight.bold,
																	color: textColor,
																),
															),
														],
													),
													const SizedBox(height: 12),
													// معلومات الشحن بتصميم محسن
													Container(
														padding: const EdgeInsets.all(12),
														decoration: BoxDecoration(
															borderRadius: BorderRadius.circular(8),
															border: Border.all(color: Colors.grey.shade300),
														),
														child: Column(
															children: [
																_buildShippingInfoRow(Icons.person, 'اسم المستلم:', widget.recipientName, textColor),
																const Divider(height: 16),
																_buildShippingInfoRow(
																	Icons.home,
																	'العنوان:',
																	'${widget.addressLine1}${widget.addressLine2.isNotEmpty ? '، ${widget.addressLine2}' : ''}',
																	textColor,
																),
																const Divider(height: 16),
																_buildShippingInfoRow(Icons.location_city, 'المدينة:', widget.city, textColor),
																const Divider(height: 16),
																_buildShippingInfoRow(Icons.markunread_mailbox, 'الرمز البريدي:', widget.postalCode, textColor),
																const Divider(height: 16),
																_buildShippingInfoRow(Icons.flag, 'البلد:', widget.country, textColor),
																const Divider(height: 16),
																_buildShippingInfoRow(Icons.phone, 'رقم الهاتف:', widget.phone, textColor),
															],
														),
													),
												],
											),
										),
									),
									const SizedBox(height: 24),

									// أزرار الإجراءات
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceEvenly,
										children: [
											_buildActionButton(
												context,
												icon: Icons.print,
												label: 'طباعة',
												color: Colors.blue,
												onPressed: () {
													HapticFeedback.mediumImpact();
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('جاري إرسال الفاتورة للطباعة...')),
													);
												},
											),
											_buildActionButton(
												context,
												icon: Icons.share,
												label: 'مشاركة',
												color: Colors.green,
												onPressed: () {
													HapticFeedback.mediumImpact();
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('جاري فتح خيارات المشاركة...')),
													);
												},
											),
											_buildActionButton(
												context,
												icon: Icons.download,
												label: 'تحميل',
												color: Colors.orange,
												onPressed: () {
													HapticFeedback.mediumImpact();
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('جاري تحميل الفاتورة كملف PDF...')),
													);
												},
											),
										],
									),
								],
							),
						),
					),

					// نافذة المساعدة
					if (_showHelp)
						Positioned.fill(
							child: GestureDetector(
								onTap: _toggleHelp,
								child: Container(
									color: Colors.black54,
									child: Center(
										child: Container(
											margin: const EdgeInsets.all(32),
											padding: const EdgeInsets.all(24),
											decoration: BoxDecoration(
												color: cardColor,
												borderRadius: BorderRadius.circular(16),
												boxShadow: [
													BoxShadow(
														color: Colors.black26,
														blurRadius: 10,
														offset: const Offset(0, 5),
													),
												],
											),
											child: Column(
												mainAxisSize: MainAxisSize.min,
												children: [
													Row(
														mainAxisAlignment: MainAxisAlignment.spaceBetween,
														children: [
															Text(
																'مساعدة',
																style: TextStyle(
																	fontSize: 22,
																	fontWeight: FontWeight.bold,
																	color: textColor,
																),
															),
															IconButton(
																icon: const Icon(Icons.close),
																onPressed: _toggleHelp,
																color: textColor,
															),
														],
													),
													const Divider(),
													const SizedBox(height: 8),
													_buildHelpItem(
														icon: Icons.receipt_long,
														title: 'تفاصيل الفاتورة',
														description: 'تعرض هذه الصفحة تفاصيل طلبك الكاملة مع المنتجات والأسعار ومعلومات الشحن.',
														textColor: textColor,
														iconColor: primaryColor,
													),
													const SizedBox(height: 16),
													_buildHelpItem(
														icon: Icons.print,
														title: 'طباعة الفاتورة',
														description: 'يمكنك طباعة الفاتورة بالضغط على زر الطباعة في أسفل الصفحة.',
														textColor: textColor,
														iconColor: Colors.blue,
													),
													const SizedBox(height: 16),
													_buildHelpItem(
														icon: Icons.chat_bubble_outline,
														title: 'استفسار عن الطلب',
														description: 'للاستفسار عن طلبك، اضغط على أيقونة المحادثة في الأعلى للتواصل مع خدمة العملاء.',
														textColor: textColor,
														iconColor: Colors.green,
													),
													const SizedBox(height: 16),
													ElevatedButton(
														onPressed: _toggleHelp,
														style: ElevatedButton.styleFrom(
															backgroundColor: primaryColor,
															foregroundColor: Colors.white,
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(8),
															),
															padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
														),
														child: const Text('فهمت'),
													),
												],
											),
										),
									),
								),
							),
						),
				],
			),
			// زر عائم للاستفسار
			floatingActionButton: FloatingActionButton(
				onPressed: _navigateToChatPage,
				backgroundColor: primaryColor,
				tooltip: 'استفسار عن الطلب',
				child: const Icon(Icons.chat),
			),
		);
	}

	// دالة لبناء صف معلومات الشحن
	Widget _buildShippingInfoRow(IconData icon, String label, String value, Color textColor) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Icon(icon, size: 18, color: Colors.grey),
				const SizedBox(width: 8),
				Text(
					label,
					style: TextStyle(
						fontWeight: FontWeight.bold,
						color: textColor,
					),
				),
				const SizedBox(width: 4),
				Expanded(
					child: Text(
						value,
						style: TextStyle(color: textColor),
						textAlign: TextAlign.start,
					),
				),
			],
		);
	}

	// دالة لبناء زر إجراء
	Widget _buildActionButton(
			BuildContext context, {
				required IconData icon,
				required String label,
				required Color color,
				required VoidCallback onPressed,
			}) {
		return ElevatedButton.icon(
			onPressed: onPressed,
			icon: Icon(icon),
			label: Text(label),
			style: ElevatedButton.styleFrom(
				backgroundColor: color,
				foregroundColor: Colors.white,
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(8),
				),
			),
		);
	}

	// دالة لبناء عنصر مساعدة
	Widget _buildHelpItem({
		required IconData icon,
		required String title,
		required String description,
		required Color textColor,
		required Color iconColor,
	}) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Container(
					padding: const EdgeInsets.all(8),
					decoration: BoxDecoration(
						color: iconColor.withOpacity(0.1),
						borderRadius: BorderRadius.circular(8),
					),
					child: Icon(icon, color: iconColor),
				),
				const SizedBox(width: 12),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								title,
								style: TextStyle(
									fontWeight: FontWeight.bold,
									fontSize: 16,
									color: textColor,
								),
							),
							const SizedBox(height: 4),
							Text(
								description,
								style: TextStyle(
									color: textColor.withOpacity(0.8),
									fontSize: 14,
								),
							),
						],
					),
				),
			],
		);
	}
}
