import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart'; // لإدارة تنسيق التاريخ والوقت

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';
import '../service/user_server.dart';

class UserManagementPage extends StatefulWidget {
	const UserManagementPage({Key? key}) : super(key: key);

	@override
	State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
	bool _isLoading = false;
	List<User> _users = [];
	List<User> _filteredUsers = [];
	String searchQuery = '';

	@override
	void initState() {
		super.initState();
		_fetchUsers();
	}

	// جلب بيانات المستخدمين
	Future<void> _fetchUsers() async {
		setState(() => _isLoading = true);
		try {
			List<User> users = await UserService.getAllUsers();
			setState(() {
				_users = users;
				_applyFilter();
			});
		} catch (e) {
			_showErrorSnackbar('خطأ في جلب البيانات: $e');
		} finally {
			setState(() => _isLoading = false);
		}
	}

	// تطبيق البحث والفلترة
	void _applyFilter() {
		setState(() {
			_filteredUsers = searchQuery.isEmpty
					? List.from(_users)
					: _users.where((user) =>
			user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
					user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
					user.mobile.contains(searchQuery)).toList();
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
			final pickedImage =
			await ImagePicker().pickImage(source: ImageSource.gallery);
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
			SnackBar(
				content: Text(message),
				backgroundColor: Colors.red,
			),
		);
	}

	// عرض رسالة نجاح
	void _showSuccessSnackbar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: Colors.green,
			),
		);
	}

	// عرض نموذج إضافة/تعديل مستخدم
	void _showUserForm({User? user}) {
		final formKey = GlobalKey<FormState>();
		TextEditingController nameController =
		TextEditingController(text: user?.name ?? '');
		TextEditingController mobileController =
		TextEditingController(text: user?.mobile ?? '');
		TextEditingController emailController =
		TextEditingController(text: user?.email ?? '');
		TextEditingController passwordController =
		TextEditingController(text: user?.password ?? '');
		TextEditingController statusController =
		TextEditingController(text: user?.status ?? '1');
		String imageBase64 = user?.image ?? '';

		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setStateDialog) {
					return AlertDialog(
						title: Text(user == null ? 'إضافة مستخدم جديد' : 'تعديل المستخدم'),
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
												if (image != null)
													setStateDialog(() => imageBase64 = image);
											},
											child: CircleAvatar(
												radius: 50,
												backgroundColor: Colors.grey[200],
												backgroundImage: imageBase64.isNotEmpty
														? MemoryImage(_decodeBase64Image(imageBase64)!)
														: null,
												child: imageBase64.isEmpty
														? const Icon(Icons.camera_alt, size: 40)
														: null,
											),
										),
										const SizedBox(height: 20),

										// حقل الاسم
										TextFormField(
											controller: nameController,
											decoration:
											const InputDecoration(labelText: 'الاسم الكامل'),
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),

										// حقل الجوال
										TextFormField(
											controller: mobileController,
											decoration:
											const InputDecoration(labelText: 'رقم الجوال'),
											keyboardType: TextInputType.phone,
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),

										// حقل البريد الإلكتروني
										TextFormField(
											controller: emailController,
											decoration:
											const InputDecoration(labelText: 'البريد الإلكتروني'),
											keyboardType: TextInputType.emailAddress,
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),

										// حقل كلمة المرور (يظهر فقط عند الإضافة)
										if (user == null) ...[
											TextFormField(
												controller: passwordController,
												decoration:
												const InputDecoration(labelText: 'كلمة المرور'),
												obscureText: true,
												validator: (value) => value!.isEmpty ? 'مطلوب' : null,
											),
										],

										// حقل الحالة
										DropdownButtonFormField<String>(
											value: statusController.text,
											items: const [
												DropdownMenuItem(value: '1', child: Text('مفعل')),
												DropdownMenuItem(value: '0', child: Text('غير مفعل')),
											],
											onChanged: (value) =>
											statusController.text = value ?? '1',
											decoration:
											const InputDecoration(labelText: 'حالة الحساب'),
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
										if (user == null) {
											// عند الإضافة، استخدام المُنشئ create لتعيين createdAt و updatedAt تلقائيًا
											User newUser = User.create(
												id: '0', // يمكنك تعديل القيمة وفق نظام إدارة المستخدمين لديك
												name: nameController.text,
												mobile: mobileController.text,
												email: emailController.text,
												password: passwordController.text,
												image: imageBase64,
												status: statusController.text,
												// الحقول الاختيارية تُترك فارغة أو تُمرر حسب الحاجة
											);
											result = await UserService.addUser(newUser);
										} else {
											// عند التعديل، استخدام copyWith لتحديث البيانات مع الحفاظ على createdAt وتحديث updatedAt تلقائيًا
											User updatedUser = user.copyWith(
												name: nameController.text,
												mobile: mobileController.text,
												email: emailController.text,
												password: passwordController.text,
												image: imageBase64,
												status: statusController.text,
											);
											result = await UserService.updateUser(updatedUser);
										}

										if (result.toLowerCase().contains('success')) {
											await _fetchUsers();
											_showSuccessSnackbar(user == null
													? 'تم إضافة المستخدم بنجاح'
													: 'تم تحديث بيانات المستخدم');
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

	// حذف مستخدم
	Future<void> _deleteUser(String id) async {
		setState(() => _isLoading = true);
		try {
			String result = await UserService.deleteUser(id);
			if (result.toLowerCase().contains('success')) {
				await _fetchUsers();
				_showSuccessSnackbar('تم حذف المستخدم بنجاح');
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
				title: const Text('إدارة المستخدمين'),
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
								hintText: 'ابحث عن مستخدم...',
								prefixIcon: const Icon(Icons.search),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(10),
								),
							),
						),
					),

					// قائمة المستخدمين
					Expanded(
						child: _isLoading && _users.isEmpty
								? const Center(child: CircularProgressIndicator())
								: _filteredUsers.isEmpty
								? const Center(child: Text('لا يوجد مستخدمين'))
								: ListView.builder(
							itemCount: _filteredUsers.length,
							itemBuilder: (context, index) {
								User user = _filteredUsers[index];
								return Card(
									margin: const EdgeInsets.symmetric(
											horizontal: 16, vertical: 8),
									child: ListTile(
										leading: CircleAvatar(
											backgroundImage: user.image.isNotEmpty
													? MemoryImage(
													_decodeBase64Image(user.image)!)
													: null,
											child: user.image.isEmpty
													? const Icon(Icons.person)
													: null,
										),
										title: Text(user.name),
										subtitle: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(user.email),
												Text(user.mobile),
												Text('تاريخ الإنشاء: ${user.createdAt}'),
												if (user.updatedAt != null)
													Text('آخر تحديث: ${user.updatedAt}'),
											],
										),
										trailing: Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												IconButton(
													icon: const Icon(Icons.edit, color: Colors.blue),
													onPressed: () => _showUserForm(user: user),
												),
												IconButton(
													icon: const Icon(Icons.delete, color: Colors.red),
													onPressed: () => _deleteUser(user.id),
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
				onPressed: () => _showUserForm(),
			),
		);
	}
}
