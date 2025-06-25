import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // لاستخدام تنسيق التاريخ
import '../model/user_model.dart'; // تأكد من صحة المسار
import '../service/user_server.dart'; // استيراد خدمة المستخدم الفعلية

class EditProfilePage extends StatefulWidget {
	final User user;
	final VoidCallback onProfileUpdateSuccess;

	const EditProfilePage({
		Key? key,
		required this.user,
		required this.onProfileUpdateSuccess,
	}) : super(key: key);

	@override
	_EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
	late TextEditingController _nameController;
	late TextEditingController _emailController;
	late TextEditingController _mobileController;
	late TextEditingController _createdAtController; // لعرض وقت الإنشاء
	late TextEditingController _updatedAtController; // لعرض وقت التعديل
	late TextEditingController _passwordController; // حقل كلمة المرور

	String? _imageBase64;
	File? _imageFile;
	final ImagePicker _picker = ImagePicker();
	bool _isLoading = false;

	final Color primaryColor = Colors.teal;
	final Color accentColor = Colors.amber;

	@override
	void initState() {
		super.initState();

		// تهيئة المتحكمات
		_nameController = TextEditingController(text: widget.user.name);
		_emailController = TextEditingController(text: widget.user.email);
		_mobileController = TextEditingController(text: widget.user.mobile ?? '');
		_passwordController = TextEditingController(text: widget.user.password ?? '');
		_imageBase64 = widget.user.image;

		// إضافة مستمعين لحفظ البيانات عند التغيير
		_nameController.addListener(() => _saveToPrefs('name', _nameController.text.trim()));
		_mobileController.addListener(() => _saveToPrefs('mobile', _mobileController.text.trim()));
		_passwordController.addListener(() => _saveToPrefs('password', _passwordController.text.trim()));

		// تهيئة حقل وقت الإنشاء وتنسيقه
		String formattedCreatedAt = 'غير متوفر';
		if (widget.user.createdAt != null && widget.user.createdAt!.isNotEmpty) {
			try {
				DateTime parsedDate = DateTime.parse(widget.user.createdAt!);
				formattedCreatedAt = DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(parsedDate);
			} catch (e) {
				print("Error parsing createdAt date: $e");
				formattedCreatedAt = widget.user.createdAt!;
			}
		}
		_createdAtController = TextEditingController(text: formattedCreatedAt);

		// تهيئة حقل وقت التعديل وتنسيقه
		String formattedUpdatedAt = 'غير متوفر';
		if (widget.user.updatedAt != null && widget.user.updatedAt!.isNotEmpty) {
			try {
				DateTime parsedDate = DateTime.parse(widget.user.updatedAt!);
				formattedUpdatedAt = DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(parsedDate);
			} catch (e) {
				print("Error parsing updatedAt date: $e");
				formattedUpdatedAt = widget.user.updatedAt!;
			}
		}
		_updatedAtController = TextEditingController(text: formattedUpdatedAt);
	}

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_mobileController.dispose();
		_createdAtController.dispose();
		_updatedAtController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _saveToPrefs(String key, String value) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(key, value);
	}

	Uint8List? _decodeImage(String? base64String) {
		if (base64String == null || base64String.isEmpty) return null;
		try {
			String actualBase64 = base64String.contains(',')
					? base64String.substring(base64String.indexOf(',') + 1)
					: base64String;
			return base64Decode(actualBase64);
		} catch (e) {
			print("Error decoding image: $e");
			return null;
		}
	}

	Future<void> _pickImage() async {
		final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
		if (pickedFile != null) {
			final File file = File(pickedFile.path);
			final Uint8List imageBytes = await file.readAsBytes();
			setState(() {
				_imageFile = file;
				_imageBase64 = base64Encode(imageBytes);
			});
			// حفظ الصورة في SharedPreferences عند التغيير
			final prefs = await SharedPreferences.getInstance();
			await prefs.setString('image', _imageBase64!);
		}
	}

	Future<void> _refreshProfile() async {
		setState(() => _isLoading = true);
		try {
			final updatedUser = await UserService.getUserById(widget.user.id.toString());
			if (updatedUser != null) {
				setState(() {
					_nameController.text = updatedUser.name;
					_emailController.text = updatedUser.email;
					_mobileController.text = updatedUser.mobile ?? '';
					_passwordController.text = updatedUser.password ?? '';
					_imageBase64 = updatedUser.image;

					_createdAtController.text = updatedUser.createdAt != null
							? DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(DateTime.parse(updatedUser.createdAt!))
							: 'غير متوفر';

					_updatedAtController.text = updatedUser.updatedAt != null
							? DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(DateTime.parse(updatedUser.updatedAt!))
							: 'غير متوفر';
				});
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('تم تحديث البيانات بنجاح')),
				);
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('فشل في تحديث البيانات')),
				);
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('حدث خطأ أثناء التحديث')),
			);
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	Future<void> _saveProfile() async {
		if (_isLoading) return;
		setState(() => _isLoading = true);

		User updatedUser = User(
			id: widget.user.id,
			name: _nameController.text.trim(),
			email: widget.user.email,
			mobile: _mobileController.text.trim(),
			image: _imageBase64 ?? '',
			password: _passwordController.text.trim(),
			status: widget.user.status,
			emailVerifiedAt: widget.user.emailVerifiedAt,
			rememberToken: widget.user.rememberToken,
			accessToken: widget.user.accessToken,
			createdAt: widget.user.createdAt, // وقت الإنشاء لا يتغير
			updatedAt: DateTime.now().toIso8601String(), // نحدّث التاريخ إلى اللحظة الحالية
		);

		try {
			String result = await UserService.updateUser(updatedUser);
			if (result.toLowerCase().contains('success') ||
					result.toLowerCase().contains('تم التحديث بنجاح')) {
				final prefs = await SharedPreferences.getInstance();
				await prefs.setString('name', updatedUser.name);
				await prefs.setString('mobile', updatedUser.mobile ?? '');
				await prefs.setString('password', updatedUser.password ?? '');
				if (updatedUser.image != null && updatedUser.image!.isNotEmpty) {
					await prefs.setString('image', updatedUser.image!);
				}
				// حفظ تاريخ التحديث
				await prefs.setString('updated_at', updatedUser.updatedAt ?? '');

				// تحديث البيانات في واجهة المستخدم
				widget.onProfileUpdateSuccess();
				// تحديث البيانات في SharedPreferences
				await SharedPreferences.getInstance().then((prefs) {
					prefs.setString('name', updatedUser.name);
					prefs.setString('mobile', updatedUser.mobile ?? '');
					prefs.setString('image', updatedUser.image ?? '');
					if (updatedUser.updatedAt != null) {
						prefs.setString('updated_at', updatedUser.updatedAt!);
					}
				});

				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text('تم تحديث الملف الشخصي بنجاح'),
							backgroundColor: Colors.green,
						),
					);
					Navigator.pop(context);
				}
			} else {
				throw Exception('فشل تحديث الملف الشخصي: $result');
			}
		} catch (e) {
			print("Error saving profile via service: $e");
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('حدث خطأ أثناء حفظ التغييرات: ${e.toString()}'),
						backgroundColor: Colors.red,
					),
				);
			}
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('تعديل الملف الشخصي', style: TextStyle(color: Colors.white)),
				backgroundColor: primaryColor,
				iconTheme: IconThemeData(color: Colors.white),
				elevation: 2,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _refreshProfile,
						tooltip: 'تحديث البيانات',
					),
				],
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(24.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						Stack(
							alignment: Alignment.bottomRight,
							children: [
								CircleAvatar(
									radius: 65,
									backgroundColor: primaryColor.withOpacity(0.2),
									child: CircleAvatar(
										radius: 60,
										backgroundColor: Colors.grey[200],
										backgroundImage: _imageFile != null
												? FileImage(_imageFile!)
												: (_imageBase64 != null && _imageBase64!.isNotEmpty
												? MemoryImage(_decodeImage(_imageBase64!)!)
												: null) as ImageProvider?,
										child: (_imageFile == null &&
												(_imageBase64 == null || _imageBase64!.isEmpty))
												? Icon(Icons.person, size: 60, color: Colors.grey[400])
												: null,
									),
								),
								Material(
									color: accentColor,
									shape: CircleBorder(),
									elevation: 4,
									child: InkWell(
										onTap: _pickImage,
										customBorder: CircleBorder(),
										child: Padding(
											padding: const EdgeInsets.all(8.0),
											child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
										),
									),
								)
							],
						),
						const SizedBox(height: 30),

						// حقل الاسم
						_buildTextField(
							_nameController,
							'الاسم الكامل',
							Icons.person_outline,
						),
						const SizedBox(height: 20),

						// حقل رقم الجوال
						_buildTextField(
							_mobileController,
							'رقم الجوال',
							Icons.phone_android_outlined,
							keyboardType: TextInputType.phone,
						),
						const SizedBox(height: 20),

						// حقل البريد (غير قابل للتعديل)
						_buildTextField(
							_emailController,
							'البريد الإلكتروني',
							Icons.email_outlined,
							enabled: false,
						),
						const SizedBox(height: 20),

						// --- إضافة حقل كلمة المرور ---
						_buildTextField(
							_passwordController,
							'كلمة المرور',
							Icons.lock_outline,
							obscureText: true,
						),
						const SizedBox(height: 20),

						// --- إضافة حقل وقت الإنشاء (للقراءة فقط) ---
						_buildReadOnlyField(
							_createdAtController,
							'تاريخ الإنشاء',
							Icons.calendar_today_outlined,
						),
						const SizedBox(height: 20),

						// --- إضافة حقل وقت التعديل (للقراءة فقط) ---
						_buildReadOnlyField(
							_updatedAtController,
							'آخر تحديث',
							Icons.update_outlined,
						),
						const SizedBox(height: 40),

						SizedBox(
							width: double.infinity,
							child: ElevatedButton.icon(
								onPressed: _isLoading ? null : _saveProfile,
								style: ElevatedButton.styleFrom(
									backgroundColor: primaryColor,
									foregroundColor: Colors.white,
									padding: const EdgeInsets.symmetric(vertical: 14),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
									textStyle:
									const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
								),
								icon: _isLoading
										? SizedBox(
									width: 20,
									height: 20,
									child: CircularProgressIndicator(
										strokeWidth: 2,
										color: Colors.white,
									),
								)
										: Icon(Icons.save_outlined),
								label: Text(_isLoading ? 'جار الحفظ...' : 'حفظ التغييرات'),
							),
						),
					],
				),
			),
		);
	}

	// ويدجت مساعد لبناء حقول النص القابلة للتعديل
	Widget _buildTextField(
			TextEditingController controller,
			String label,
			IconData icon, {
				bool enabled = true,
				TextInputType keyboardType = TextInputType.text,
				bool obscureText = false,
			}) {
		return TextField(
			controller: controller,
			enabled: enabled,
			obscureText: obscureText,
			keyboardType: keyboardType,
			style: TextStyle(color: enabled ? Colors.black87 : Colors.grey[600]),
			decoration: InputDecoration(
				labelText: label,
				labelStyle: TextStyle(color: primaryColor),
				prefixIcon: Icon(icon, color: primaryColor),
				filled: true,
				fillColor: enabled ? Colors.white : Colors.grey[100],
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: Colors.grey[300]!),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: Colors.grey[300]!),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: primaryColor, width: 1.5),
				),
				disabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: Colors.grey[200]!),
				),
				contentPadding:
				const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
			),
		);
	}

	// --- ويدجت مساعد جديد لبناء حقول للقراءة فقط ---
	Widget _buildReadOnlyField(
			TextEditingController controller,
			String label,
			IconData icon,
			) {
		return TextField(
			controller: controller,
			readOnly: true, // للقراءة فقط
			style: TextStyle(color: Colors.grey[700]), // لون مختلف للإشارة لعدم التعديل
			decoration: InputDecoration(
				labelText: label,
				labelStyle: TextStyle(color: primaryColor),
				prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
				filled: true,
				fillColor: Colors.grey[100], // خلفية مختلفة
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: Colors.grey[200]!),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: Colors.grey[200]!),
				),
				contentPadding:
				const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
			),
		);
	}
}
