import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';
import '../service/user_server.dart';
import 'login.dart';

/// صفحة إنشاء حساب جديد للمستخدمين.
/// تتضمن حقول إدخال لاسم المستخدم، رقم الجوال، البريد الإلكتروني، كلمة المرور،
/// وخيار إضافة صورة شخصية. تم إضافة تحقق صارم من صحة المدخلات.
class SignUpPage extends StatefulWidget {
	const SignUpPage({Key? key}) : super(key: key);

	@override
	State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
	final formKey = GlobalKey<FormState>();

	TextEditingController nameController = TextEditingController();
	TextEditingController mobileController = TextEditingController();
	TextEditingController emailController = TextEditingController();
	TextEditingController passwordController = TextEditingController();
	String status = 'active'; // الحالة: 1 = مفعل
	String imageBase64 = ''; // الصورة اختيارية
	bool _isLoading = false;
	bool _obscurePassword = true;

	/// تلتقط صورة من المعرض وتحولها إلى Base64.
	/// تظهر SnackBar في حالة حدوث خطأ.
	Future<void> _pickImage() async {
		try {
			final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
			if (pickedImage != null) {
				final bytes = await File(pickedImage.path).readAsBytes();
				setState(() {
					imageBase64 = base64Encode(bytes);
				});
			}
		} catch (e) {
			_showSnackbar('حدث خطأ في اختيار الصورة: $e', isError: true);
		}
	}

	/// تحول سلسلة Base64 إلى Uint8List لعرض الصورة.
	/// تعود بـ null في حالة وجود خطأ.
	Uint8List? _decodeBase64Image(String base64Str) {
		try {
			if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
			return base64Decode(base64Str);
		} catch (e) {
			// يمكن تسجيل الخطأ هنا (اختياري)
			return null;
		}
	}

	/// ترسل بيانات المستخدم بعد التحقق من صحة الحقول.
	/// تعرض رسائل نجاح أو خطأ باستخدام SnackBar أو Dialog.
	Future<void> _submit() async {
		// التحقق من صحة جميع الحقول المطلوبة قبل المتابعة
		if (!formKey.currentState!.validate()) {
			_showSnackbar('الرجاء تعبئة جميع الحقول المطلوبة بشكل صحيح.', isError: true);
			return;
		}

		setState(() => _isLoading = true);

		try {
			User newUser = User.create(
				id: '0', // ID سيتم تعيينه من قبل الخادم
				name: nameController.text,
				mobile: mobileController.text,
				email: emailController.text,
				password: passwordController.text,
				image: imageBase64, // الصورة اختيارية
				status: status,
			);

			String result = await UserService.addUser(newUser);
			if (result.toLowerCase().contains('success')) {
				_showAccountCreatedDialog();
			} else {
				_showSnackbar(result, isError: true);
			}
		} catch (e) {
			_showSnackbar('حدث خطأ غير متوقع: $e', isError: true);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	/// تعرض SnackBar مع رسالة مخصصة ولون حسب نوع الرسالة (خطأ أو نجاح).
	void _showSnackbar(String message, {bool isError = false}) {
		if (!mounted) return; // للتأكد من أن الويدجت لا يزال موجودًا
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(
					message,
					style: const TextStyle(color: Colors.white),
				),
				backgroundColor: isError ? Colors.red[800] : Colors.green[800],
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(10),
				),
				duration: const Duration(seconds: 3),
			),
		);
	}

	/// تعرض مربع حوار أنيق لإبلاغ المستخدم بنجاح إنشاء الحساب
	/// وتقديم خيار الانتقال إلى صفحة تسجيل الدخول.
	void _showAccountCreatedDialog() {
		showDialog(
			context: context,
			barrierDismissible: false, // لا يمكن إغلاقه بالنقر خارجاً
			builder: (context) => Dialog(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20),
				),
				elevation: 10,
				child: Padding(
					padding: const EdgeInsets.all(20),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Icon(Icons.check_circle, color: Colors.green[600], size: 60),
							const SizedBox(height: 20),
							Text(
								'تم إنشاء الحساب بنجاح!',
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.bold,
									color: Colors.blue[800],
								),
								textAlign: TextAlign.center,
							),
							const SizedBox(height: 15),
							const Text(
								'هل تريد الانتقال إلى صفحة تسجيل الدخول الآن؟',
								textAlign: TextAlign.center,
								style: TextStyle(fontSize: 16),
							),
							const SizedBox(height: 25),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								children: [
									TextButton(
										onPressed: () => Navigator.pop(context),
										style: TextButton.styleFrom(
											padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(10),
												side: BorderSide(color: Colors.blue[400]!),
											),
										),
										child: Text(
											'لاحقاً',
											style: TextStyle(color: Colors.blue[800]),
										),
									),
									ElevatedButton(
										onPressed: () {
											Navigator.pop(context); // إغلاق مربع الحوار
											Navigator.pushReplacement( // استخدام pushReplacement لمنع العودة لصفحة التسجيل
												context,
												MaterialPageRoute(builder: (context) => const LoginPage()),
											);
										},
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.blue[600],
											padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(10),
											),
										),
										child: const Text(
											'نعم',
											style: TextStyle(color: Colors.white),
										),
									),
								],
							),
						],
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text(
					'إنشاء حساب جديد',
					style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // لون الخط أبيض
				),
				centerTitle: true,
				backgroundColor: Colors.blue[700],
				elevation: 8, // ظل أعلى
				shape: const RoundedRectangleBorder(
					borderRadius: BorderRadius.vertical(
						bottom: Radius.circular(25), // زوايا مستديرة أكبر
					),
				),
			),
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [
							Colors.blue.shade50!, // لون أزرق فاتح جداً
							Colors.white, // أبيض
						],
					),
				),
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25), // حشو أكبر
					child: Form(
						key: formKey,
						child: Column(
							children: [
								// صورة الملف الشخصي
								Stack(
									alignment: Alignment.bottomRight,
									children: [
										GestureDetector(
											onTap: _pickImage,
											child: Container(
												width: 130, // حجم أكبر للصورة
												height: 130,
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													color: Colors.grey.shade200, // لون خلفية الصورة
													border: Border.all(color: Colors.blue.shade300, width: 3), // حدود أوسع
													boxShadow: [
														BoxShadow(
															color: Colors.blue.withOpacity(0.3), // ظل أزرق خفيف
															blurRadius: 15,
															spreadRadius: 3,
															offset: const Offset(0, 6),
														),
													],
												),
												child: imageBase64.isNotEmpty
														? ClipOval(
													child: Image.memory(
														_decodeBase64Image(imageBase64)!,
														fit: BoxFit.cover,
														errorBuilder: (context, error, stackTrace) =>
														const Icon(Icons.broken_image, size: 60, color: Colors.red),
													),
												)
														: Icon(
													Icons.person_add_alt_1,
													size: 60, // أيقونة أكبر
													color: Colors.blue[400],
												),
											),
										),
										Container(
											padding: const EdgeInsets.all(8), // حشو أكبر
											decoration: BoxDecoration(
												color: Colors.blue[600],
												shape: BoxShape.circle,
												border: Border.all(color: Colors.white, width: 3), // حدود أوسع
											),
											child: const Icon(
												Icons.camera_alt,
												size: 22, // أيقونة أكبر
												color: Colors.white,
											),
										),
									],
								),
								const SizedBox(height: 40), // مسافة أكبر

								// اسم المستخدم
								_buildInputField(
									controller: nameController,
									label: 'اسم المستخدم',
									icon: Icons.person_outline,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'الرجاء إدخال اسم المستخدم.';
										}
										return null;
									},
								),
								const SizedBox(height: 20), // مسافة ثابتة

								// رقم الجوال
								_buildInputField(
									controller: mobileController,
									label: 'رقم الجوال',
									icon: Icons.phone_android_outlined,
									keyboardType: TextInputType.phone,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'الرجاء إدخال رقم الجوال.';
										}
										// يمكن إضافة تحقق إضافي لصيغة رقم الجوال إذا لزم الأمر
										if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value)) { // مثال: 9-15 رقم
											return 'الرجاء إدخال رقم جوال صحيح (9-15 رقماً).';
										}
										return null;
									},
								),
								const SizedBox(height: 20),

								// البريد الإلكتروني
								_buildInputField(
									controller: emailController,
									label: 'البريد الإلكتروني',
									icon: Icons.email_outlined,
									keyboardType: TextInputType.emailAddress,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'الرجاء إدخال البريد الإلكتروني.';
										}
										// تعبير نمطي للتحقق من صحة صيغة البريد الإلكتروني
										if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
												.hasMatch(value)) {
											return 'الرجاء إدخال بريد إلكتروني صحيح.';
										}
										return null;
									},
								),
								const SizedBox(height: 20),

								// كلمة المرور
								_buildInputField(
									controller: passwordController,
									label: 'كلمة المرور',
									icon: Icons.lock_outline,
									obscureText: _obscurePassword,
									suffixIcon: IconButton(
										icon: Icon(
											_obscurePassword ? Icons.visibility_off : Icons.visibility,
											color: Colors.blue[400],
										),
										onPressed: () {
											setState(() {
												_obscurePassword = !_obscurePassword;
											});
										},
									),
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'الرجاء إدخال كلمة المرور.';
										}
										if (value.length < 8) {
											return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل.';
										}
										if (!value.contains(RegExp(r'[A-Z]'))) {
											return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل.';
										}
										if (!value.contains(RegExp(r'[a-z]'))) {
											return 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل.';
										}
										if (!value.contains(RegExp(r'[0-9]'))) {
											return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل.';
										}

										return null;
									},
								),
								const SizedBox(height: 40), // مسافة أكبر

								// زر التسجيل
								SizedBox(
									width: double.infinity,
									height: 55, // زر أطول
									child: ElevatedButton(
										onPressed: _isLoading ? null : _submit,
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.blue[600],
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(15), // زوايا مستديرة أكثر
											),
											elevation: 8, // ظل أعمق
											shadowColor: Colors.blue.withOpacity(0.4),
										),
										child: _isLoading
												? const SizedBox(
											width: 28, // حجم أكبر للمؤشر
											height: 28,
											child: CircularProgressIndicator(
													strokeWidth: 4, // سمك أكبر
													color: Colors.white),
										)
												: const Text(
											'إنشاء الحساب',
											style: TextStyle(
												fontSize: 20, // حجم خط أكبر
												fontWeight: FontWeight.bold,
												color: Colors.white,
											),
										),
									),
								),
								const SizedBox(height: 25), // مسافة أكبر

								// رابط تسجيل الدخول
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text(
											'لديك حساب بالفعل؟',
											style: TextStyle(
													color: Colors.blue[800],
													fontSize: 16), // حجم خط أكبر
										),
										const SizedBox(width: 8), // مسافة أكبر
										TextButton(
											onPressed: () {
												Navigator.push(
													context,
													MaterialPageRoute(builder: (context) => const LoginPage()),
												);
											},
											style: TextButton.styleFrom(
												padding: EdgeInsets.zero,
												tapTargetSize: MaterialTapTargetSize.shrinkWrap,
											),
											child: Text(
												'سجل الدخول الآن',
												style: TextStyle(
													color: Colors.blue[600],
													fontWeight: FontWeight.bold,
													fontSize: 16, // حجم خط أكبر
													decoration: TextDecoration.underline,
												),
											),
										),
									],
								),
								const SizedBox(height: 10), // مسافة إضافية في الأسفل
							],
						),
					),
				),
			),
		);
	}

	/// ودجت مساعد لبناء حقول الإدخال.
	/// تم تحسينها لتشمل تصميمًا جذابًا وتحققًا من الصحة.
	Widget _buildInputField({
		required TextEditingController controller,
		required String label,
		required IconData icon,
		TextInputType? keyboardType,
		bool obscureText = false,
		Widget? suffixIcon,
		String? Function(String?)? validator,
	}) {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15), // زوايا مستديرة أكثر
				boxShadow: [
					BoxShadow(
						color: Colors.blue.withOpacity(0.1), // ظل أزرق خفيف
						blurRadius: 10,
						spreadRadius: 2,
						offset: const Offset(0, 4),
					),
				],
			),
			child: TextFormField(
				controller: controller,
				keyboardType: keyboardType,
				obscureText: obscureText,
				decoration: InputDecoration(
					labelText: label,
					labelStyle: TextStyle(color: Colors.blue[600], fontSize: 16), // حجم خط أكبر
					prefixIcon: Icon(icon, color: Colors.blue[400], size: 24), // أيقونة أكبر
					suffixIcon: suffixIcon,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(15),
						borderSide: BorderSide.none, // إزالة الحدود الخارجية
					),
					enabledBorder: OutlineInputBorder( // حدود عند عدم التركيز
						borderRadius: BorderRadius.circular(15),
						borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
					),
					focusedBorder: OutlineInputBorder( // حدود عند التركيز
						borderRadius: BorderRadius.circular(15),
						borderSide: BorderSide(color: Colors.blue.shade600, width: 2.0),
					),
					errorBorder: OutlineInputBorder( // حدود عند وجود خطأ
						borderRadius: BorderRadius.circular(15),
						borderSide: const BorderSide(color: Colors.red, width: 2.0),
					),
					focusedErrorBorder: OutlineInputBorder( // حدود عند التركيز على حقل به خطأ
						borderRadius: BorderRadius.circular(15),
						borderSide: const BorderSide(color: Colors.red, width: 2.5),
					),
					filled: true,
					fillColor: Colors.white,
					contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20), // حشو داخلي أكبر
				),
				validator: validator, // تطبيق دالة التحقق
				style: const TextStyle(fontSize: 17), // حجم خط المدخلات
				cursorColor: Colors.blue[700], // لون مؤشر الكتابة
			),
		);
	}
}