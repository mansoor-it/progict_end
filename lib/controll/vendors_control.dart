import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart'; // لإدارة تنسيق التاريخ والوقت
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/vendors_model.dart';
import '../service/vendors_server.dart';

// تعريف الألوان الرئيسية للتطبيق (أبيض وأسود)
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
	static const Color shadowColor = Color(0x1A000000); // ظل خفيف// لون الأيقونات بني داكن
}

// تعريف أنماط النصوص المستخدمة في التطبيق
class AppTextStyles {
	static const TextStyle heading = TextStyle(
		fontSize: 20,
		fontWeight: FontWeight.bold,
		color: AppColors.textPrimary,
	);

	static const TextStyle subheading = TextStyle(
		fontSize: 16,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
	);

	static const TextStyle body = TextStyle(
		fontSize: 14,
		color: AppColors.textPrimary,
	);

	static const TextStyle caption = TextStyle(
		fontSize: 12,
		color: AppColors.textSecondary,
	);
}

class VendorManagementPage extends StatefulWidget {
	const VendorManagementPage({Key? key}) : super(key: key);

	@override
	State<VendorManagementPage> createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage>
		with SingleTickerProviderStateMixin {
	bool _isLoading = false;
	List<Vendor> _vendors = [];
	List<Vendor> _filteredVendors = [];
	String searchQuery = '';

	late TabController _tabController;
	int _currentIndex = 0;
	String _statusFilter = 'all';

	@override
	void initState() {
		super.initState();
		_tabController = TabController(length: 3, vsync: this);
		_tabController.addListener(() {
			if (!_tabController.indexIsChanging) {
				setState(() {
					_currentIndex = _tabController.index;
					_applyTabFilter();
				});
			}
		});
		_fetchVendors();
	}

	@override
	void dispose() {
		_tabController.dispose();
		super.dispose();
	}

	Future<void> _fetchVendors() async {
		setState(() => _isLoading = true);
		try {
			List<Vendor> vendors = await VendorService.getAllVendors();
			setState(() {
				_vendors = vendors;
				_applyFilter();
			});
		} catch (e) {
			_showErrorSnackbar('خطأ في جلب البيانات: $e');
		} finally {
			setState(() => _isLoading = false);
		}
	}
	void _applyFilter() {
		setState(() {
			List<Vendor> filtered = searchQuery.isEmpty
					? List.from(_vendors)
					: _vendors
					.where((vendor) =>
			vendor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
					vendor.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
					vendor.mobile.contains(searchQuery))
					.cast<Vendor>() // تأكد من أن الناتج من نوع List<Vendor>
					.toList();

			if (_statusFilter != 'all') {
				filtered = filtered
						.where((vendor) => vendor.status == (_statusFilter == 'active' ? '1' : '0'))
						.toList();
			}

			_filteredVendors = filtered; // تأكد من أن _filteredVendors من النوع الصحيح
			_applyTabFilter();
		});
	}

	void _applyTabFilter() {
		if (_currentIndex == 0) {
			// الكل - لا تغيير
		} else if (_currentIndex == 1) {
			setState(() {
				_filteredVendors = _filteredVendors.where((vendor) => vendor.confirm == 'Yes').toList();
			});
		} else if (_currentIndex == 2) {
			setState(() {
				_filteredVendors = _filteredVendors.where((vendor) => vendor.confirm == 'No').toList();
			});
		}
	}

	Uint8List? _decodeBase64Image(String base64Str) {
		try {
			if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
			return base64Decode(base64Str);
		} catch (e) {
			return null;
		}
	}

	Future<String?> _pickImage() async {
		try {
			final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
			if (pickedImage == null) return null;
			return base64.encode(await File(pickedImage.path).readAsBytes());
		} catch (e) {
			_showErrorSnackbar('خطأ في اختيار الصورة');
			return null;
		}
	}

	void _showErrorSnackbar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: AppColors.error,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
				action: SnackBarAction(
					label: 'إغلاق',
					textColor: AppColors.secondary,
					onPressed: () {
						ScaffoldMessenger.of(context).hideCurrentSnackBar();
					},
				),
			),
		);
	}

	void _showSuccessSnackbar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: AppColors.success,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
				action: SnackBarAction(
					label: 'تم',
					textColor: AppColors.secondary,
					onPressed: () {
						ScaffoldMessenger.of(context).hideCurrentSnackBar();
					},
				),
			),
		);
	}

	void _showVendorForm({Vendor? vendor}) {
		final formKey = GlobalKey<FormState>();
		TextEditingController nameController = TextEditingController(text: vendor?.name ?? '');
		TextEditingController addressController = TextEditingController(text: vendor?.address ?? '');
		TextEditingController cityController = TextEditingController(text: vendor?.city ?? '');
		TextEditingController stateController = TextEditingController(text: vendor?.state ?? '');
		TextEditingController countryController = TextEditingController(text: vendor?.country ?? '');
		TextEditingController pincodeController = TextEditingController(text: vendor?.pincode ?? '');
		TextEditingController mobileController = TextEditingController(text: vendor?.mobile ?? '');
		TextEditingController emailController = TextEditingController(text: vendor?.email ?? '');
		TextEditingController passwordController = TextEditingController(text: vendor?.password ?? '');
		TextEditingController commissionController =
		TextEditingController(text: vendor != null ? vendor.commission.toString() : '');
		TextEditingController confirmController = TextEditingController(text: vendor?.confirm ?? 'No');
		TextEditingController statusController = TextEditingController(text: vendor?.status ?? '1');

		String imageBase64 = vendor?.image ?? '';
		int _formTabIndex = 0;
		final List<String> _formTabTitles = ['معلومات أساسية', 'العنوان', 'إعدادات الحساب'];

		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setStateDialog) {
					return AlertDialog(
						title: Text(
							vendor == null ? 'إضافة بائع جديد' : 'تعديل بيانات البائع',
							style: const TextStyle(
								color: AppColors.primary,
								fontWeight: FontWeight.bold,
							),
						),
						backgroundColor: AppColors.background,
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
						content: Form(
							key: formKey,
							child: SingleChildScrollView(
								child: Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										Row(
											children: List.generate(_formTabTitles.length, (index) {
												return Expanded(
													child: InkWell(
														onTap: () {
															setStateDialog(() {
																_formTabIndex = index;
															});
														},
														child: Container(
															padding: const EdgeInsets.symmetric(vertical: 8),
															decoration: BoxDecoration(
																border: Border(
																	bottom: BorderSide(
																		color: _formTabIndex == index
																				? AppColors.primary
																				: AppColors.divider,
																		width: _formTabIndex == index ? 2 : 1,
																	),
																),
															),
															child: Text(
																_formTabTitles[index],
																textAlign: TextAlign.center,
																style: TextStyle(
																	color: _formTabIndex == index
																			? AppColors.primary
																			: AppColors.textSecondary,
																	fontWeight: _formTabIndex == index
																			? FontWeight.bold
																			: FontWeight.normal,
																),
															),
														),
													),
												);
											}),
										),
										const SizedBox(height: 20),
										Visibility(
											visible: _formTabIndex == 0,
											child: Column(
												children: [
													GestureDetector(
														onTap: () async {
															String? image = await _pickImage();
															if (image != null) {
																setStateDialog(() => imageBase64 = image);
															}
														},
														child: Container(
															decoration: BoxDecoration(
																shape: BoxShape.circle,
																border: Border.all(color: AppColors.primary, width: 2),
															),
															child: CircleAvatar(
																radius: 50,
																backgroundColor: AppColors.cardBackground,
																backgroundImage: imageBase64.isNotEmpty
																		? MemoryImage(_decodeBase64Image(imageBase64)!)
																		: null,
																child: imageBase64.isEmpty
																		? const Icon(Icons.camera_alt,
																		size: 40, color: AppColors.primary)
																		: null,
															),
														),
													),
													const SizedBox(height: 20),
													TextFormField(
														controller: nameController,
														decoration: InputDecoration(
															labelText: 'الاسم',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
																borderSide: const BorderSide(color: AppColors.primary),
															),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
																borderSide: const BorderSide(color: AppColors.primary, width: 2),
															),
															prefixIcon: const Icon(Icons.person, color: AppColors.iconColor),
														),
														validator: (value) => value!.isEmpty ? 'مطلوب' : null,
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: mobileController,
														decoration: InputDecoration(
															labelText: 'الجوال',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.phone, color: AppColors.iconColor),
														),
														keyboardType: TextInputType.phone,
														validator: (value) => value!.isEmpty ? 'مطلوب' : null,
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: emailController,
														decoration: InputDecoration(
															labelText: 'البريد الإلكتروني',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.email, color: AppColors.iconColor),
														),
														keyboardType: TextInputType.emailAddress,
														validator: (value) => value!.isEmpty ? 'مطلوب' : null,
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: passwordController,
														decoration: InputDecoration(
															labelText: 'كلمة المرور',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.lock, color: AppColors.iconColor),
														),
														obscureText: true,
														validator: (value) => value!.isEmpty ? 'مطلوب' : null,
													),
												],
											),
										),
										Visibility(
											visible: _formTabIndex == 1,
											child: Column(
												children: [
													TextFormField(
														controller: addressController,
														decoration: InputDecoration(
															labelText: 'العنوان',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.location_on, color: AppColors.iconColor),
														),
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: cityController,
														decoration: InputDecoration(
															labelText: 'المدينة',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.location_city, color: AppColors.iconColor),
														),
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: stateController,
														decoration: InputDecoration(
															labelText: 'الولاية',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.map, color: AppColors.iconColor),
														),
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: countryController,
														decoration: InputDecoration(
															labelText: 'الدولة',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.public, color: AppColors.iconColor),
														),
													),
													const SizedBox(height: 10),
													TextFormField(
														controller: pincodeController,
														decoration: InputDecoration(
															labelText: 'الرمز البريدي',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.pin_drop, color: AppColors.iconColor),
														),
													),
												],
											),
										),
										Visibility(
											visible: _formTabIndex == 2,
											child: Column(
												children: [
													TextFormField(
														controller: commissionController,
														decoration: InputDecoration(
															labelText: 'العمولة',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.monetization_on, color: AppColors.iconColor),
														),
														keyboardType: TextInputType.number,
														validator: (value) => value!.isEmpty ? 'مطلوب' : null,
													),
													const SizedBox(height: 10),
													DropdownButtonFormField<String>(
														value: confirmController.text,
														decoration: InputDecoration(
															labelText: 'تأكيد الحساب',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.check_circle, color: AppColors.iconColor),
														),
														items: const [
															DropdownMenuItem(
																value: 'Yes',
																child: Text('مؤكد'),
															),
															DropdownMenuItem(
																value: 'No',
																child: Text('غير مؤكد'),
															),
														],
														onChanged: (value) {
															confirmController.text = value!;
														},
													),
													const SizedBox(height: 10),
													DropdownButtonFormField<String>(
														value: statusController.text,
														decoration: InputDecoration(
															labelText: 'حالة الحساب',
															border: OutlineInputBorder(
																borderRadius: BorderRadius.circular(10),
															),
															prefixIcon: const Icon(Icons.toggle_on, color: AppColors.iconColor),
														),
														items: const [
															DropdownMenuItem(
																value: '1',
																child: Text('مفعل'),
															),
															DropdownMenuItem(
																value: '0',
																child: Text('غير مفعل'),
															),
														],
														onChanged: (value) {
															statusController.text = value!;
														},
													),
												],
											),
										),
									],
								),
							),
						),
						actions: [
							TextButton(
								child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
								onPressed: () => Navigator.pop(context),
							),
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.primary,
									foregroundColor: AppColors.secondary,
								),
								child: Text(vendor == null ? 'إضافة' : 'تحديث'),
								onPressed: () async {
									if (formKey.currentState!.validate()) {
										Navigator.pop(context);
										setState(() => _isLoading = true);

										try {
											Vendor updatedVendor = Vendor(
												id: vendor?.id ?? '',
												name: nameController.text,
												email: emailController.text,
												mobile: mobileController.text,
												password: passwordController.text,
												address: addressController.text,
												city: cityController.text,
												state: stateController.text,
												country: countryController.text,
												pincode: pincodeController.text,
												image: imageBase64,
												commission: double.tryParse(commissionController.text) ?? 0,
												confirm: confirmController.text,
												status: statusController.text,
												createdAt: vendor?.createdAt,
												updatedAt: DateTime.now().toString(),
											);

											String result = vendor == null
													? await VendorService.addVendor(updatedVendor)
													: await VendorService.updateVendor(updatedVendor);

											if (result.toLowerCase().contains('success')) {
												await _fetchVendors();
												_showSuccessSnackbar(vendor == null
														? 'تمت إضافة البائع بنجاح'
														: 'تم تحديث بيانات البائع بنجاح');
											} else {
												_showErrorSnackbar(result);
											}
										} catch (e) {
											_showErrorSnackbar('حدث خطأ: $e');
										} finally {
											setState(() => _isLoading = false);
										}
									}
								},
							),
						],
					);
				},
			),
		);
	}

	Future<void> _deleteVendor(String id) async {
		bool confirmDelete = await showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('تأكيد الحذف', style: TextStyle(color: AppColors.primary)),
				content: const Text('هل أنت متأكد من حذف هذا البائع؟'),
				backgroundColor: AppColors.background,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
				actions: [
					TextButton(
						child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
						onPressed: () => Navigator.pop(context, false),
					),
					ElevatedButton(
						style: ElevatedButton.styleFrom(
							backgroundColor: AppColors.error,
							foregroundColor: AppColors.secondary,
						),
						child: const Text('حذف'),
						onPressed: () => Navigator.pop(context, true),
					),
				],
			),
		) ??
				false;

		if (!confirmDelete) return;

		setState(() => _isLoading = true);
		try {
			String result = await VendorService.deleteVendor(id);
			if (result.toLowerCase().contains('success')) {
				await _fetchVendors();
				_showSuccessSnackbar('تم حذف البائع بنجاح');
			} else {
				_showErrorSnackbar(result);
			}
		} catch (e) {
			_showErrorSnackbar('حدث خطأ أثناء الحذف: $e');
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _showVendorDetails(Vendor vendor) {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				backgroundColor: AppColors.background,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
				title: Row(
					children: [
						Hero(
							tag: 'vendor-avatar-${vendor.id}',
							child: CircleAvatar(
								radius: 20,
								backgroundColor: AppColors.cardBackground,
								backgroundImage: vendor.image != null && vendor.image!.isNotEmpty
										? MemoryImage(_decodeBase64Image(vendor.image!)!)
										: null,
								child: vendor.image == null || vendor.image!.isEmpty
										? const Icon(Icons.store, color: AppColors.primary)
										: null,
							),
						),
						const SizedBox(width: 10),
						Expanded(
							child: Text(
								vendor.name,
								style: AppTextStyles.heading,
								overflow: TextOverflow.ellipsis,
							),
						),
					],
				),
				content: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						mainAxisSize: MainAxisSize.min,
						children: [
							_detailItem('البريد الإلكتروني', vendor.email, Icons.email),
							_detailItem('الجوال', vendor.mobile, Icons.phone),
							if (vendor.address != null && vendor.address!.isNotEmpty)
								_detailItem('العنوان', vendor.address!, Icons.location_on),
							if (vendor.city != null && vendor.city!.isNotEmpty)
								_detailItem('المدينة', vendor.city!, Icons.location_city),
							if (vendor.state != null && vendor.state!.isNotEmpty)
								_detailItem('الولاية', vendor.state!, Icons.map),
							if (vendor.country != null && vendor.country!.isNotEmpty)
								_detailItem('الدولة', vendor.country!, Icons.public),
							if (vendor.pincode != null && vendor.pincode!.isNotEmpty)
								_detailItem('الرمز البريدي', vendor.pincode!, Icons.pin_drop),
							_detailItem('العمولة', '${vendor.commission}%', Icons.monetization_on),
							_detailItem('حالة الحساب', vendor.status == '1' ? 'مفعل' : 'غير مفعل',
									Icons.toggle_on, vendor.status == '1' ? AppColors.success : AppColors.error),
							_detailItem(
									'تأكيد الحساب',
									vendor.confirm == 'Yes' ? 'مؤكد' : 'غير مؤكد',
									Icons.check_circle,
									vendor.confirm == 'Yes' ? AppColors.success : AppColors.textSecondary),
							_detailItem('تاريخ الإنشاء', vendor.createdAt ?? 'تاريخ غير معروف', Icons.calendar_today),

							if (vendor.updatedAt != null)
								_detailItem('آخر تحديث', vendor.updatedAt!, Icons.update),
						],
					),
				),
				actions: [
					TextButton(
						child: const Text('إغلاق', style: TextStyle(color: AppColors.textSecondary)),
						onPressed: () => Navigator.pop(context),
					),
					ElevatedButton.icon(
						style: ElevatedButton.styleFrom(
							backgroundColor: AppColors.primary,
							foregroundColor: AppColors.secondary,
						),
						icon: const Icon(Icons.edit, size: 16),
						label: const Text('تعديل'),
						onPressed: () {
							Navigator.pop(context);
							_showVendorForm(vendor: vendor);
						},
					),
				],
			),
		);
	}

	Widget _detailItem(String label, String value, IconData icon, [Color? iconColor]) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Icon(icon, size: 20, color: iconColor ?? AppColors.iconColor),
					const SizedBox(width: 10),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label, style: AppTextStyles.caption),
								Text(value, style: AppTextStyles.body),
							],
						),
					),
				],
			),
		);
	}

	// بناء قسم الإحصائيات
	Widget _buildStatsSection() {
		int totalVendors = _vendors.length;
		int activeVendors = _vendors.where((v) => v.status == '1').length;
		int inactiveVendors = totalVendors - activeVendors;
		int confirmedVendors = _vendors.where((v) => v.confirm == 'Yes').length;

		return Padding(
			padding: const EdgeInsets.all(16.0),
			child: Card(
				elevation: 2,
				color: AppColors.cardBackground,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text('إحصائيات البائعين', style: AppTextStyles.subheading),
							const SizedBox(height: 12),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceAround,
								children: [
									_statItem('الإجمالي', totalVendors, Icons.people_alt, AppColors.primary),
									_statItem('المفعلين', activeVendors, Icons.check_circle_outline, AppColors.success),
									_statItem('غير المفعلين', inactiveVendors, Icons.highlight_off, AppColors.error),
									_statItem('المؤكدين', confirmedVendors, Icons.verified_user, Colors.blue),
								],
							),
						],
					),
				),
			),
		);
	}

	Widget _statItem(String label, int count, IconData icon, Color color) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				Icon(icon, size: 32, color: color),
				const SizedBox(height: 4),
				Text(count.toString(), style: AppTextStyles.subheading.copyWith(color: color)),
				Text(label, style: AppTextStyles.caption),
			],
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة البائعين', style: TextStyle(color: AppColors.secondary)),
				backgroundColor: AppColors.primary,
				elevation: 0,
				actions: [
					if (_isLoading)
						const Padding(
							padding: EdgeInsets.all(16),
							child: CircularProgressIndicator(color: AppColors.secondary),
						),
					IconButton(
						icon: const Icon(Icons.refresh, color: AppColors.secondary),
						tooltip: 'تحديث البيانات',
						onPressed: _fetchVendors,
					),
					PopupMenuButton<String>(
						icon: const Icon(Icons.filter_list, color: AppColors.secondary),
						tooltip: 'فلترة حسب الحالة',
						onSelected: (value) {
							setState(() {
								_statusFilter = value;
								_applyFilter();
							});
						},
						itemBuilder: (context) => [
							const PopupMenuItem(
								value: 'all',
								child: Text('الكل'),
							),
							const PopupMenuItem(
								value: 'active',
								child: Text('المفعلين'),
							),
							const PopupMenuItem(
								value: 'inactive',
								child: Text('غير المفعلين'),
							),
						],
					),
				],
				bottom: TabBar(
					controller: _tabController,
					indicatorColor: AppColors.secondary,
					labelColor: AppColors.secondary,
					unselectedLabelColor: Colors.white70,
					tabs: const [
						Tab(icon: Icon(Icons.list_alt), text: 'الكل'),
						Tab(icon: Icon(Icons.verified_user_outlined), text: 'المؤكدين'),
						Tab(icon: Icon(Icons.unpublished_outlined), text: 'غير المؤكدين'),
					],
				),
			),
			body: Container(
				color: AppColors.background,
				child: Column(
					children: [
						_buildStatsSection(), // إضافة قسم الإحصائيات هنا
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
							child: TextField(
								onChanged: (value) {
									setState(() {
										searchQuery = value;
										_applyFilter();
									});
								},
								decoration: InputDecoration(
									hintText: 'ابحث عن بائع...',
									prefixIcon: const Icon(Icons.search, color: AppColors.iconColor),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: AppColors.primary),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: AppColors.primary, width: 2),
									),
									filled: true,
									fillColor: AppColors.cardBackground,
									suffixIcon: searchQuery.isNotEmpty
											? IconButton(
										icon: const Icon(Icons.clear, color: AppColors.iconColor),
										onPressed: () {
											setState(() {
												searchQuery = '';
												_applyFilter();
											});
										},
									)
											: null,
								),
							),
						),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Row(
								children: [
									Text(
										'عدد النتائج: ${_filteredVendors.length}',
										style: AppTextStyles.caption,
									),
									const Spacer(),
									if (_statusFilter != 'all')
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
											decoration: BoxDecoration(
												color: AppColors.primary,
												borderRadius: BorderRadius.circular(12),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Text(
														_statusFilter == 'active' ? 'المفعلين' : 'غير المفعلين',
														style: const TextStyle(color: AppColors.secondary, fontSize: 12),
													),
													const SizedBox(width: 4),
													InkWell(
														onTap: () {
															setState(() {
																_statusFilter = 'all';
																_applyFilter();
															});
														},
														child: const Icon(Icons.close, color: AppColors.secondary, size: 16),
													),
												],
											),
										),
								],
							),
						),
						const SizedBox(height: 8),
						Expanded(
							child: _isLoading && _vendors.isEmpty
									? const Center(child: CircularProgressIndicator(color: AppColors.primary))
									: _filteredVendors.isEmpty
									? Center(
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
										SizedBox(height: 16),
										Text('لا يوجد بائعين مطابقين للبحث أو الفلترة',
												textAlign: TextAlign.center,
												style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
									],
								),
							)
									: Padding(
								padding: const EdgeInsets.all(8.0),
								// تغيير من ListView.builder إلى GridView.builder مع تحسين خصائص التوسع
								child: GridView.builder(
									gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
										maxCrossAxisExtent: 350, // تقليل الحد الأقصى لعرض العنصر لإظهار المزيد من العناصر في الصف
										childAspectRatio: 0.8, // تعديل نسبة العرض إلى الارتفاع لتناسب المحتوى
										crossAxisSpacing: 12, // زيادة المسافة الأفقية بين العناصر
										mainAxisSpacing: 12, // زيادة المسافة الرأسية بين العناصر
										mainAxisExtent: 250, // ارتفاع ثابت للعنصر
									),
									itemCount: _filteredVendors.length,
									itemBuilder: (context, index) {
										Vendor vendor = _filteredVendors[index];
										return Card(
											margin: const EdgeInsets.all(4),
											elevation: 3, // زيادة الارتفاع للحصول على ظل أكثر وضوحاً
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
											color: AppColors.cardBackground,
											child: InkWell(
												onTap: () => _showVendorDetails(vendor),
												borderRadius: BorderRadius.circular(15),
												// استخدام ClipRRect لقص أي محتوى يتجاوز حدود البطاقة
												child: ClipRRect(
													borderRadius: BorderRadius.circular(15),
													// استخدام SingleChildScrollView لإتاحة التمرير الداخلي إذا تجاوز المحتوى الحدود
													child: SingleChildScrollView(
														physics: const BouncingScrollPhysics(), // تأثير التمرير المرتد
														child: Padding(
															padding: const EdgeInsets.all(12),
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.center,
																children: [
																	// صورة البائع
																	Hero(
																		tag: 'vendor-avatar-${vendor.id}',
																		child: Container(
																			decoration: BoxDecoration(
																				shape: BoxShape.circle,
																				border: Border.all(color: AppColors.primary, width: 2),
																				boxShadow: [
																					BoxShadow(
																						color: AppColors.primary.withOpacity(0.3),
																						blurRadius: 5,
																						offset: const Offset(0, 3),
																					),
																				],
																			),
																			child: CircleAvatar(
																				radius: 40,
																				backgroundColor: Colors.grey[200],
																				backgroundImage: vendor.image != null &&
																						vendor.image!.isNotEmpty
																						? MemoryImage(_decodeBase64Image(vendor.image!)!)
																						: null,
																				child: vendor.image == null || vendor.image!.isEmpty
																						? const Icon(Icons.store, color: AppColors.primary, size: 40)
																						: null,
																			),
																		),
																	),
																	const SizedBox(height: 12),
																	// اسم البائع
																	Text(
																		vendor.name,
																		style: const TextStyle(
																			fontWeight: FontWeight.bold,
																			fontSize: 16,
																			color: AppColors.textPrimary,
																		),
																		textAlign: TextAlign.center,
																		overflow: TextOverflow.ellipsis,
																		maxLines: 1,
																	),
																	const SizedBox(height: 6),
																	// البريد الإلكتروني
																	Text(
																		vendor.email,
																		style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
																		textAlign: TextAlign.center,
																		overflow: TextOverflow.ellipsis,
																		maxLines: 1,
																	),
																	// رقم الجوال
																	Text(
																		vendor.mobile,
																		style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
																		textAlign: TextAlign.center,
																	),
																	const SizedBox(height: 10),
																	// حالة البائع
																	Row(
																		mainAxisAlignment: MainAxisAlignment.center,
																		children: [
																			Container(
																				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
																				decoration: BoxDecoration(
																					color: vendor.status == '1'
																							? AppColors.success
																							: AppColors.error,
																					borderRadius: BorderRadius.circular(12),
																				),
																				child: Text(
																					vendor.status == '1' ? 'مفعل' : 'غير مفعل',
																					style: const TextStyle(color: Colors.white, fontSize: 12),
																				),
																			),
																			const SizedBox(width: 8),
																			Container(
																				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
																				decoration: BoxDecoration(
																					color: vendor.confirm == 'Yes'
																							? AppColors.success
																							: AppColors.textSecondary,
																					borderRadius: BorderRadius.circular(12),
																				),
																				child: Text(
																					vendor.confirm == 'Yes' ? 'مؤكد' : 'غير مؤكد',
																					style: const TextStyle(color: Colors.white, fontSize: 12),
																				),
																			),
																		],
																	),
																	const SizedBox(height: 15),
																	// أزرار التعديل والحذف
																	Row(
																		mainAxisAlignment: MainAxisAlignment.center,
																		children: [
																			Expanded(
																				child: ElevatedButton.icon(
																					icon: const Icon(Icons.edit, size: 16),
																					label: const Text('تعديل', style: TextStyle(fontSize: 12)),
																					style: ElevatedButton.styleFrom(
																						backgroundColor: AppColors.primary,
																						foregroundColor: AppColors.secondary,
																						padding: const EdgeInsets.symmetric(vertical: 8),
																						shape: RoundedRectangleBorder(
																							borderRadius: BorderRadius.circular(8),
																						),
																					),
																					onPressed: () => _showVendorForm(vendor: vendor),
																				),
																			),
																			const SizedBox(width: 8),
																			Expanded(
																				child: ElevatedButton.icon(
																					icon: const Icon(Icons.delete, size: 16),
																					label: const Text('حذف', style: TextStyle(fontSize: 12)),
																					style: ElevatedButton.styleFrom(
																						backgroundColor: AppColors.error,
																						foregroundColor: Colors.white,
																						padding: const EdgeInsets.symmetric(vertical: 8),
																						shape: RoundedRectangleBorder(
																							borderRadius: BorderRadius.circular(8),
																						),
																					),
																					onPressed: () => _deleteVendor(vendor.id),
																				),
																			),
																		],
																	),
																],
															),
														),
													),
												),
											),
										);
									},
								),
							),
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				backgroundColor: AppColors.primary,
				foregroundColor: AppColors.secondary,
				elevation: 4,
				icon: const Icon(Icons.add),
				label: const Text('إضافة بائع'),
				tooltip: 'إضافة بائع جديد',
				onPressed: () => _showVendorForm(),
			),
			bottomNavigationBar: BottomAppBar(
				color: AppColors.primary,
				shape: const CircularNotchedRectangle(),
				notchMargin: 8,
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceAround,
					children: [
						_bottomNavItem(Icons.home, 'الرئيسية', 0),
						_bottomNavItem(Icons.store, 'البائعين', 1),
						const SizedBox(width: 48), // مساحة للزر العائم
						_bottomNavItem(Icons.shopping_cart, 'المنتجات', 2),
						_bottomNavItem(Icons.settings, 'الإعدادات', 3),
					],
				),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
		);
	}

	// بناء عنصر شريط التنقل السفلي
	Widget _bottomNavItem(IconData icon, String label, int index) {
		// يمكنك إضافة منطق لتغيير الصفحة هنا بناءً على الـ index
		// حاليًا، سيعرض فقط رسالة Snackbar
		return IconButton(
			icon: Icon(icon, color: AppColors.secondary),
			tooltip: label,
			onPressed: () {
				_showSuccessSnackbar('التنقل إلى $label');
			},
		);
	}
}

