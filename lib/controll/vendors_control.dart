import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart'; // لإدارة تنسيق التاريخ والوقت
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import '../model/vendors_model.dart';
import '../service/vendors_server.dart';


class VendorManagementPage extends StatefulWidget {
	const VendorManagementPage({Key? key}) : super(key: key);

	@override
	State<VendorManagementPage> createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage> {
	bool _isLoading = false;
	List<Vendor> _vendors = [];
	List<Vendor> _filteredVendors = [];
	String searchQuery = '';

	@override
	void initState() {
		super.initState();
		_fetchVendors();
	}

	// جلب بيانات البائعين
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

	// تطبيق البحث والفلترة (يمكن البحث بواسطة الاسم، البريد الإلكتروني أو الجوال)
	void _applyFilter() {
		setState(() {
			_filteredVendors = searchQuery.isEmpty
					? List.from(_vendors)
					: _vendors.where((vendor) =>
			vendor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
					vendor.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
					vendor.mobile.contains(searchQuery)).toList();
		});
	}

	// تحويل الصورة من Base64
	Uint8List? _decodeBase64Image(String base64Str) {
		try {
			if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
			return base64Decode(base64Str);
		} catch (e) {
			return null;
		}
	}

	// اختيار صورة من المعرض
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

	// عرض رسالة خطأ
	void _showErrorSnackbar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.red),
		);
	}

	// عرض رسالة نجاح
	void _showSuccessSnackbar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.green),
		);
	}

	// عرض نموذج إضافة/تعديل بائع مع عرض كافة الحقول (إلزامية واختيارية)
	void _showVendorForm({Vendor? vendor}) {
		final formKey = GlobalKey<FormState>();
		// إنشاء Controllers لكل الحقول:
		TextEditingController nameController = TextEditingController(text: vendor?.name ?? '');
		TextEditingController addressController = TextEditingController(text: vendor?.address ?? '');
		TextEditingController cityController = TextEditingController(text: vendor?.city ?? '');
		TextEditingController stateController = TextEditingController(text: vendor?.state ?? '');
		TextEditingController countryController = TextEditingController(text: vendor?.country ?? '');
		TextEditingController pincodeController = TextEditingController(text: vendor?.pincode ?? '');
		TextEditingController mobileController = TextEditingController(text: vendor?.mobile ?? '');
		TextEditingController emailController = TextEditingController(text: vendor?.email ?? '');
		TextEditingController passwordController = TextEditingController(text: vendor?.password ?? '');
		TextEditingController commissionController = TextEditingController(
				text: vendor != null ? vendor.commission.toString() : '');
		// للقيم التي تعتمد على قوائم ثابتة:
		TextEditingController confirmController = TextEditingController(text: vendor?.confirm ?? 'No');
		TextEditingController statusController = TextEditingController(text: vendor?.status ?? '1');

		String imageBase64 = vendor?.image ?? '';

		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setStateDialog) {
					return AlertDialog(
						title: Text(vendor == null ? 'إضافة بائع جديد' : 'تعديل بيانات البائع'),
						content: Form(
							key: formKey,
							child: SingleChildScrollView(
								child: Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										// حقل الصورة
										GestureDetector(
											onTap: () async {
												String? image = await _pickImage();
												if (image != null) {
													setStateDialog(() => imageBase64 = image);
												}
											},
											child: CircleAvatar(
												radius: 50,
												backgroundColor: Colors.grey[200],
												backgroundImage: imageBase64.isNotEmpty
														? MemoryImage(_decodeBase64Image(imageBase64)!)
														: null,
												child: imageBase64.isEmpty ? const Icon(Icons.camera_alt, size: 40) : null,
											),
										),
										const SizedBox(height: 20),
										// حقل الاسم (إجباري)
										TextFormField(
											controller: nameController,
											decoration: const InputDecoration(labelText: 'الاسم'),
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										// حقل العنوان (اختياري)
										TextFormField(
											controller: addressController,
											decoration: const InputDecoration(labelText: 'العنوان'),
										),
										// حقل المدينة (اختياري)
										TextFormField(
											controller: cityController,
											decoration: const InputDecoration(labelText: 'المدينة'),
										),
										// حقل الولاية (اختياري)
										TextFormField(
											controller: stateController,
											decoration: const InputDecoration(labelText: 'الولاية'),
										),
										// حقل الدولة (اختياري)
										TextFormField(
											controller: countryController,
											decoration: const InputDecoration(labelText: 'الدولة'),
										),
										// حقل الرمز البريدي (اختياري)
										TextFormField(
											controller: pincodeController,
											decoration: const InputDecoration(labelText: 'الرمز البريدي'),
										),
										// حقل الجوال (إجباري)
										TextFormField(
											controller: mobileController,
											decoration: const InputDecoration(labelText: 'الجوال'),
											keyboardType: TextInputType.phone,
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										// حقل البريد الإلكتروني (إجباري)
										TextFormField(
											controller: emailController,
											decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
											keyboardType: TextInputType.emailAddress,
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										// حقل كلمة المرور (إجباري؛ إذا كنت تعدل يمكن تعبئته لتغييرها أو تركها كما هي)
										TextFormField(
											controller: passwordController,
											decoration: const InputDecoration(labelText: 'كلمة المرور'),
											obscureText: true,
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										// حقل العمولة (إجباري)
										TextFormField(
											controller: commissionController,
											decoration: const InputDecoration(labelText: 'العمولة'),
											keyboardType: TextInputType.number,
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										// حقل تأكيد الحساب (اختياري لكنه مطلوب إذا أردت تغييره، قائمة من قيم "No" أو "Yes")
										DropdownButtonFormField<String>(
											value: confirmController.text,
											items: const [
												DropdownMenuItem(value: 'No', child: Text('غير مؤكّد')),
												DropdownMenuItem(value: 'Yes', child: Text('مؤكّد')),
											],
											onChanged: (value) =>
											confirmController.text = value ?? 'No',
											decoration: const InputDecoration(labelText: 'تأكيد الحساب'),
										),
										// حقل حالة الحساب (إجباري)
										DropdownButtonFormField<String>(
											value: statusController.text,
											items: const [
												DropdownMenuItem(value: '1', child: Text('مفعل')),
												DropdownMenuItem(value: '0', child: Text('غير مفعل')),
											],
											onChanged: (value) =>
											statusController.text = value ?? '1',
											decoration: const InputDecoration(labelText: 'حالة الحساب'),
										),
									],
								),
							),
						),
						actions: [
							TextButton(
								child: const Text('إلغاء'),
								onPressed: () => Navigator.pop(context),
							),
							ElevatedButton(
								child: const Text('حفظ'),
								onPressed: () async {
									if (!formKey.currentState!.validate()) return;
									Navigator.pop(context);
									setState(() => _isLoading = true);
									try {
										String result;
										if (vendor == null) {
											// عند الإضافة، استخدام المُنشئ create لتعيين createdAt و updatedAt تلقائيًا
											Vendor newVendor = Vendor.create(
												id: '0', // قم بتعديل القيمة وفق نظامك إذا لزم الأمر
												name: nameController.text,
												address: addressController.text,
												city: cityController.text,
												state: stateController.text,
												country: countryController.text,
												pincode: pincodeController.text,
												mobile: mobileController.text,
												email: emailController.text,
												password: passwordController.text,
												image: imageBase64,
												confirm: confirmController.text,
												commission: double.tryParse(commissionController.text) ?? 0.0,
												status: statusController.text,
											);
											result = await VendorService.addVendor(newVendor);
										} else {
											// عند التعديل، استخدام copyWith لتحديث البيانات مع الحفاظ على createdAt وتحديث updatedAt تلقائيًا
											Vendor updatedVendor = vendor.copyWith(
												name: nameController.text,
												address: addressController.text,
												city: cityController.text,
												state: stateController.text,
												country: countryController.text,
												pincode: pincodeController.text,
												mobile: mobileController.text,
												email: emailController.text,
												password: passwordController.text,
												image: imageBase64,
												confirm: confirmController.text,
												commission: double.tryParse(commissionController.text) ?? vendor.commission,
												status: statusController.text,
											);
											result = await VendorService.updateVendor(updatedVendor);
										}

										if (result.toLowerCase().contains('success')) {
											await _fetchVendors();
											_showSuccessSnackbar(vendor == null
													? 'تم إضافة البائع بنجاح'
													: 'تم تحديث بيانات البائع');
										} else {
											_showErrorSnackbar(result);
										}
									} catch (e) {
										_showErrorSnackbar('حدث خطأ: $e');
									} finally {
										setState(() => _isLoading = false);
									}
								},
							),
						],
					);
				},
			),
		);
	}

	// حذف بائع
	Future<void> _deleteVendor(String id) async {
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

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة البائعين'),
				actions: [
					if (_isLoading)
						const Padding(
							padding: EdgeInsets.all(16),
							child: CircularProgressIndicator(color: Colors.white),
						),
				],
			),
			body: Column(
				children: [
					// شريط البحث
					Padding(
						padding: const EdgeInsets.all(16),
						child: TextField(
							onChanged: (value) {
								setState(() {
									searchQuery = value;
									_applyFilter();
								});
							},
							decoration: InputDecoration(
								hintText: 'ابحث عن بائع...',
								prefixIcon: const Icon(Icons.search),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(10),
								),
							),
						),
					),
					// قائمة البائعين
					Expanded(
						child: _isLoading && _vendors.isEmpty
								? const Center(child: CircularProgressIndicator())
								: _filteredVendors.isEmpty
								? const Center(child: Text('لا يوجد بائعين'))
								: ListView.builder(
							itemCount: _filteredVendors.length,
							itemBuilder: (context, index) {
								Vendor vendor = _filteredVendors[index];
								return Card(
									margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
									child: ListTile(
										leading: CircleAvatar(
											backgroundImage: vendor.image != null && vendor.image!.isNotEmpty
													? MemoryImage(_decodeBase64Image(vendor.image!)!)
													: null,
											child: vendor.image == null || vendor.image!.isEmpty
													? const Icon(Icons.store)
													: null,
										),
										title: Text(vendor.name),
										subtitle: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(vendor.email),
												Text(vendor.mobile),
												Text('تاريخ الإنشاء: ${vendor.createdAt}'),
												if (vendor.updatedAt != null)
													Text('آخر تحديث: ${vendor.updatedAt}'),
											],
										),
										trailing: Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												IconButton(
													icon: const Icon(Icons.edit, color: Colors.blue),
													onPressed: () => _showVendorForm(vendor: vendor),
												),
												IconButton(
													icon: const Icon(Icons.delete, color: Colors.red),
													onPressed: () => _deleteVendor(vendor.id),
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
			floatingActionButton: FloatingActionButton(
				child: const Icon(Icons.add),
				onPressed: () => _showVendorForm(),
			),
		);
	}
}
