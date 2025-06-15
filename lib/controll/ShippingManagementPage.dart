import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';

// Copied from user_management_page.dart
class AppColors {
	// نظام ألوان متدرج وأنيق
	static const Color primary = Color(0xFF1565C0); // أزرق داكن احترافي
	static const Color primaryLight = Color(0xFF42A5F5); // أزرق فاتح
	static const Color primaryDark = Color(0xFF0D47A1); // أزرق أغمق
	static const Color secondary = Color(0xFFE3F2FD); // أزرق فاتح جداً للخلفيات
	static const Color accent = Color(0xFF00BCD4); // سماوي للعناصر التفاعلية
	static const Color background = Color(0xFFFAFAFA); // خلفية رمادية فاتحة جداً
	static const Color surface = Color(0xFFFFFFFF); // أبيض للبطاقات والأسطح
	static const Color cardBackground = Color(0xFFFFFFFF); // أبيض للبطاقات
	static const Color textPrimary = Color(0xFF212121); // أسود داكن للنصوص الرئيسية
	static const Color textSecondary = Color(0xFF757575); // رمادي متوسط للنصوص الثانوية
	static const Color textHint = Color(0xFFBDBDBD); // رمادي فاتح للنصوص التوضيحية
	static const Color success = Color(0xFF4CAF50); // أخضر للنجاح
	static const Color warning = Color(0xFFFF9800); // برتقالي للتحذير
	static const Color error = Color(0xFFF44336); // أحمر للخطأ
	static const Color divider = Color(0xFFE0E0E0); // رمادي فاتح للفواصل
	static const Color iconColor = Color(0xFF1565C0); // لون الأيقونات أزرق داكن
	static const Color shimmerBase = Color(0xFFE0E0E0); // لون أساسي لتأثير التحميل
	static const Color shimmerHighlight = Color(0xFFF5F5F5); // لون تمييز لتأثير التحميل

	// ألوان إضافية للتدرجات والظلال
	static const Color gradientStart = Color(0xFF1976D2);
	static const Color gradientEnd = Color(0xFF42A5F5);
	static const Color shadowColor = Color(0x1A000000); // ظل خفيف
}

// Copied from user_management_page.dart
class AppTextStyles {
	static const String fontFamily = 'Roboto'; // استخدام خط احترافي

	static const TextStyle displayLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 32,
		fontWeight: FontWeight.bold,
		color: AppColors.textPrimary,
		letterSpacing: 0.5,
		height: 1.2,
	);

	static const TextStyle displayMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 28,
		fontWeight: FontWeight.bold,
		color: AppColors.textPrimary,
		letterSpacing: 0.25,
		height: 1.2,
	);

	static const TextStyle headlineLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 24,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
		letterSpacing: 0.15,
		height: 1.3,
	);

	static const TextStyle headlineMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 20,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
		letterSpacing: 0.15,
		height: 1.3,
	);

	static const TextStyle titleLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 18,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
		letterSpacing: 0.1,
		height: 1.4,
	);

	static const TextStyle titleMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 16,
		fontWeight: FontWeight.w500,
		color: AppColors.textPrimary,
		letterSpacing: 0.1,
		height: 1.4,
	);

	static const TextStyle bodyLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 16,
		fontWeight: FontWeight.normal,
		color: AppColors.textPrimary,
		letterSpacing: 0.5,
		height: 1.5,
	);

	static const TextStyle bodyMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 14,
		fontWeight: FontWeight.normal,
		color: AppColors.textPrimary,
		letterSpacing: 0.25,
		height: 1.4,
	);

	static const TextStyle bodySmall = TextStyle(
		fontFamily: fontFamily,
		fontSize: 12,
		fontWeight: FontWeight.normal,
		color: AppColors.textSecondary,
		letterSpacing: 0.4,
		height: 1.3,
	);

	static const TextStyle labelLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 14,
		fontWeight: FontWeight.w600,
		color: Colors.white,
		letterSpacing: 0.8,
		height: 1.2,
	);

	static const TextStyle labelMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 12,
		fontWeight: FontWeight.w500,
		color: AppColors.textSecondary,
		letterSpacing: 0.5,
		height: 1.2,
	);
}

// Copied from user_management_page.dart
class AppShadows {
	static const List<BoxShadow> light = [
		BoxShadow(
			color: AppColors.shadowColor,
			offset: Offset(0, 1),
			blurRadius: 3,
			spreadRadius: 0,
		),
	];

	static const List<BoxShadow> medium = [
		BoxShadow(
			color: AppColors.shadowColor,
			offset: Offset(0, 2),
			blurRadius: 6,
			spreadRadius: 0,
		),
	];

	static const List<BoxShadow> heavy = [
		BoxShadow(
			color: AppColors.shadowColor,
			offset: Offset(0, 4),
			blurRadius: 12,
			spreadRadius: 0,
		),
	];
}

class ShippingDetail {
	final String id;
	final String orderId;
	final String recipientName;
	final String addressLine1;
	final String? addressLine2;
	final String city;
	final String state;
	final String postalCode;
	final String country;
	final String phone;
	final String? notes;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	ShippingDetail({
		required this.id,
		required this.orderId,
		required this.recipientName,
		required this.addressLine1,
		this.addressLine2,
		required this.city,
		required this.state,
		required this.postalCode,
		required this.country,
		required this.phone,
		this.notes,
		required this.status,
		this.createdAt,
		this.updatedAt,
	});

	factory ShippingDetail.fromJson(Map<String, dynamic> json) {
		return ShippingDetail(
			id: json['id'].toString(),
			orderId: json['order_id'].toString(),
			recipientName: json['recipient_name'] ?? '',
			addressLine1: json['address_line1'] ?? '',
			addressLine2: json['address_line2'],
			city: json['city'] ?? '',
			state: json['state'] ?? '',
			postalCode: json['postal_code'] ?? '',
			country: json['country'] ?? '',
			phone: json['phone'] ?? '',
			notes: json['notes'],
			status: json['status'] ?? '',
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'order_id': orderId,
			'recipient_name': recipientName,
			'address_line1': addressLine1,
			'address_line2': addressLine2 ?? '',
			'city': city,
			'state': state,
			'postal_code': postalCode,
			'country': country,
			'phone': phone,
			'notes': notes ?? '',
			'status': status,
		};
	}
}

class ShippingDetailsPage extends StatefulWidget {
	@override
	_ShippingDetailsPageState createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
	List<ShippingDetail> _shippingList = [];
	final String apiUrl = ApiHelper.url('shippings_api.php');

	@override
	void initState() {
		super.initState();
		fetchShippingDetails();
	}

	Future<void> fetchShippingDetails() async {
		final response = await http.get(Uri.parse('$apiUrl?action=fetch'));
		if (response.statusCode == 200) {
			final List<dynamic> data = json.decode(response.body);
			setState(() {
				_shippingList = data.map((e) => ShippingDetail.fromJson(e)).toList();
			});
			print('تم جلب بيانات الشحن بنجاح');
		} else {
			print('فشل في تحميل بيانات الشحن');
			_showSnackbar('فشل في تحميل البيانات', isError: true);
		}
	}

	Future<void> deleteShipping(String id) async {
		final response = await http.post(Uri.parse(apiUrl), body: {
			'action': 'delete',
			'id': id,
		});

		if (response.statusCode == 200) {
			fetchShippingDetails();
			print('تم حذف الشحنة');
			_showSnackbar('تم الحذف بنجاح');
		} else {
			print('فشل في حذف الشحنة');
			_showSnackbar('فشل في الحذف', isError: true);
		}
	}

	void _showSnackbar(String message, {bool isError = false}) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Row(
					children: [
						Icon(
							isError ? Icons.error_outline : Icons.check_circle_outline,
							color: Colors.white,
							size: 20,
						),
						const SizedBox(width: 12),
						Expanded(
							child: Text(
								message,
								style: const TextStyle(color: Colors.white, fontSize: 14),
							),
						),
					],
				),
				backgroundColor: isError ? AppColors.error : AppColors.success,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
				margin: const EdgeInsets.all(16),
				elevation: 6,
				action: SnackBarAction(
					label: 'إغلاق',
					textColor: Colors.white70,
					onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
				),
			),
		);
	}

	void showForm({ShippingDetail? detail}) {
		final formKey = GlobalKey<FormState>();
		final Map<String, TextEditingController> controllers = {
			'order_id': TextEditingController(text: detail?.orderId ?? ''),
			'recipient_name': TextEditingController(text: detail?.recipientName ?? ''),
			'address_line1': TextEditingController(text: detail?.addressLine1 ?? ''),
			'address_line2': TextEditingController(text: detail?.addressLine2 ?? ''),
			'city': TextEditingController(text: detail?.city ?? ''),
			'state': TextEditingController(text: detail?.state ?? ''),
			'postal_code': TextEditingController(text: detail?.postalCode ?? ''),
			'country': TextEditingController(text: detail?.country ?? ''),
			'phone': TextEditingController(text: detail?.phone ?? ''),
			'notes': TextEditingController(text: detail?.notes ?? ''),
			'status': TextEditingController(text: detail?.status ?? ''),
		};

		final Map<String, String> arabicLabels = {
			'order_id': 'رقم الطلب',
			'recipient_name': 'اسم المستلم',
			'address_line1': 'العنوان الرئيسي',
			'address_line2': 'العنوان الثانوي (اختياري)',
			'city': 'المدينة',
			'state': 'المحافظة',
			'postal_code': 'الرمز البريدي',
			'country': 'الدولة',
			'phone': 'رقم الهاتف',
			'notes': 'ملاحظات (اختياري)',
			'status': 'حالة الشحنة',
		};

		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (context) => StatefulBuilder(
				builder: (context, setStateDialog) {
					return Dialog(
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
						elevation: 16,
						child: Container(
							constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									// Header مع تدرج لوني
									Container(
										padding: const EdgeInsets.all(24),
										decoration: BoxDecoration(
											gradient: LinearGradient(
												colors: [AppColors.gradientStart, AppColors.gradientEnd],
												begin: Alignment.topLeft,
												end: Alignment.bottomRight,
											),
											borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
										),
										child: Row(
											children: [
												Icon(
													detail == null ? Icons.local_shipping_outlined : Icons.edit,
													color: Colors.white,
													size: 28,
												),
												const SizedBox(width: 12),
												Expanded(
													child: Text(
														detail == null ? 'إضافة شحنة جديدة' : 'تعديل بيانات الشحنة',
														style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
													),
												),
												IconButton(
													icon: const Icon(Icons.close, color: Colors.white),
													onPressed: () => Navigator.pop(context),
												),
											],
										),
									),
									// Content
									Expanded(
										child: Form(
											key: formKey,
											child: SingleChildScrollView(
												padding: const EdgeInsets.all(24),
												child: Column(
													children: controllers.entries.map((entry) {
														// Special handling for status dropdown
														if (entry.key == 'status') {
															return Padding(
																padding: const EdgeInsets.only(bottom: 16),
																child: Container(
																	decoration: BoxDecoration(
																		borderRadius: BorderRadius.circular(12),
																		border: Border.all(color: AppColors.divider),
																	),
																	child: DropdownButtonFormField<String>(
																		value: detail?.status ?? 'pending',
																		decoration: InputDecoration(
																			labelText: arabicLabels[entry.key],
																			prefixIcon: Icon(Icons.delivery_dining, color: AppColors.iconColor),
																			border: InputBorder.none,
																			contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
																		),
																		items: const [
																			DropdownMenuItem(value: 'pending', child: Text('معلقة')),
																			DropdownMenuItem(value: 'shipped', child: Text('تم الشحن')),
																			DropdownMenuItem(value: 'delivered', child: Text('تم التسليم')),
																			DropdownMenuItem(value: 'cancelled', child: Text('ملغاة')),
																		],
																		onChanged: (value) => controllers['status']?.text = value!,
																	),
																),
															);
														}
														return Padding(
															padding: const EdgeInsets.only(bottom: 16),
															child: TextFormField(
																controller: entry.value,
																decoration: InputDecoration(
																	labelText: arabicLabels[entry.key],
																	labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
																	prefixIcon: Icon(_getIconForField(entry.key), color: AppColors.iconColor),
																	border: OutlineInputBorder(
																		borderRadius: BorderRadius.circular(12),
																		borderSide: BorderSide(color: AppColors.divider),
																	),
																	focusedBorder: OutlineInputBorder(
																		borderRadius: BorderRadius.circular(12),
																		borderSide: BorderSide(color: AppColors.primary, width: 2),
																	),
																	filled: true,
																	fillColor: AppColors.surface,
																	contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
																),
																style: AppTextStyles.bodyLarge,
																validator: (val) =>
																(entry.key != 'address_line2' && entry.key != 'notes' && (val == null || val.isEmpty))
																		? 'هذا الحقل مطلوب' : null,
															),
														);
													}).toList(),
												),
											),
										),
									),
									// Footer مع الأزرار
									Container(
										padding: const EdgeInsets.all(24),
										decoration: BoxDecoration(
											color: AppColors.background,
											borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
										),
										child: Row(
											mainAxisAlignment: MainAxisAlignment.end,
											children: [
												TextButton(
													onPressed: () => Navigator.pop(context),
													child: Text(
														'إلغاء',
														style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
													),
												),
												const SizedBox(width: 16),
												ElevatedButton(
													onPressed: () async {
														if (!formKey.currentState!.validate()) return;

														final map = {
															'action': detail == null ? 'add' : 'update',
															if (detail != null) 'id': detail.id,
														};
														controllers.forEach((key, value) {
															map[key] = value.text;
														});

														final response = await http.post(Uri.parse(apiUrl), body: map);

														Navigator.pop(context);

														if (response.statusCode == 200) {
															print(detail == null ? 'تمت الإضافة' : 'تم التحديث');
															_showSnackbar(detail == null
																	? 'تمت إضافة الشحنة بنجاح'
																	: 'تم تحديث بيانات الشحنة بنجاح');
															fetchShippingDetails();
														} else {
															print('فشل العملية');
															_showSnackbar('حدث خطأ أثناء حفظ البيانات', isError: true);
														}
													},
													style: ElevatedButton.styleFrom(
														backgroundColor: AppColors.primary,
														padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
														shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(10)),
														elevation: 4,
													),
													child: Text(
														'حفظ',
														style: AppTextStyles.labelLarge,
													),
												),
											],
										),
									),
								],
							),
						),
					);
				},
			),
		);
	}

	IconData _getIconForField(String fieldKey) {
		switch (fieldKey) {
			case 'order_id':
				return Icons.receipt_outlined;
			case 'recipient_name':
				return Icons.person_outline;
			case 'address_line1':
				return Icons.location_on_outlined;
			case 'address_line2':
				return Icons.location_on_outlined;
			case 'city':
				return Icons.location_city_outlined;
			case 'state':
				return Icons.map_outlined;
			case 'postal_code':
				return Icons.local_post_office_outlined;
			case 'country':
				return Icons.public_outlined;
			case 'phone':
				return Icons.phone_outlined;
			case 'notes':
				return Icons.notes_outlined;
			default:
				return Icons.info_outline;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: AppColors.primaryDark,
				title: Text(
					'إدارة بيانات الشحن',
					style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
				),
				centerTitle: true,
				iconTheme: const IconThemeData(color: Colors.white),
				elevation: 4,
			),
			body: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [AppColors.background, AppColors.surface],
					),
				),
				child: RefreshIndicator(
					onRefresh: fetchShippingDetails,
					color: AppColors.primary,
					child: _shippingList.isEmpty
							? Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(Icons.local_shipping, size: 80, color: AppColors.primaryLight),
								const SizedBox(height: 20),
								Text(
									'لا توجد بيانات شحن متاحة',
									style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary),
								),
							],
						),
					)
							: ListView.builder(
						padding: const EdgeInsets.all(16),
						itemCount: _shippingList.length,
						itemBuilder: (_, index) {
							final shipping = _shippingList[index];
							return Card(
								margin: const EdgeInsets.symmetric(vertical: 8),
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
								elevation: 4,
								shadowColor: AppColors.shadowColor,
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												shipping.recipientName,
												style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryDark),
											),
											const SizedBox(height: 8),
											_buildInfoRow(Icons.receipt_outlined, 'رقم الطلب', shipping.orderId),
											_buildInfoRow(Icons.location_on_outlined, 'العنوان', '${shipping.addressLine1}, ${shipping.city}, ${shipping.state}, ${shipping.country}'),
											_buildInfoRow(Icons.phone_outlined, 'رقم الهاتف', shipping.phone),
											_buildInfoRow(Icons.local_post_office_outlined, 'الرمز البريدي', shipping.postalCode),
											_buildInfoRow(Icons.notes_outlined, 'ملاحظات', shipping.notes ?? 'لا توجد ملاحظات'),
											const SizedBox(height: 8),
											Row(
												children: [
													Icon(Icons.circle, size: 14, color: _getStatusColor(shipping.status)),
													const SizedBox(width: 8),
													Text(
														'الحالة: ${shipping.status}',
														style: AppTextStyles.bodyMedium.copyWith(
															color: _getStatusColor(shipping.status),
															fontWeight: FontWeight.bold,
														),
													),
												],
											),
											const Divider(height: 24, thickness: 1, color: AppColors.divider),
											Row(
												mainAxisAlignment: MainAxisAlignment.end,
												children: [
													IconButton(
														icon: const Icon(Icons.edit, color: AppColors.primary),
														onPressed: () => showForm(detail: shipping),
													),
													IconButton(
														icon: const Icon(Icons.delete, color: AppColors.error),
														onPressed: () => deleteShipping(shipping.id),
													),
												],
											),
										],
									),
								),
							);
						},
					),
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => showForm(),
				label: Text('إضافة شحنة', style: AppTextStyles.labelLarge),
				icon: const Icon(Icons.add, size: 24),
				backgroundColor: AppColors.accent,
				foregroundColor: Colors.white,
				elevation: 8,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
		);
	}

	Widget _buildInfoRow(IconData icon, String label, String value) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4),
			child: Row(
				children: [
					Icon(icon, size: 20, color: AppColors.iconColor),
					const SizedBox(width: 12),
					Expanded(
						child: Text.rich(
							TextSpan(
								children: [
									TextSpan(
										text: '$label: ',
										style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
									),
									TextSpan(
										text: value,
										style: AppTextStyles.bodyMedium,
									),
								],
							),
						),
					),
				],
			),
		);
	}

	Color _getStatusColor(String status) {
		switch (status.toLowerCase()) {
			case 'delivered':
				return AppColors.success;
			case 'shipped':
				return AppColors.warning;
			case 'cancelled':
				return AppColors.error;
			case 'pending':
				return AppColors.textSecondary;
			default:
				return AppColors.textSecondary;
		}
	}
}

