import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';
import '../service/user_server.dart';
import 'login.dart';

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
	String status = '1'; // الحالة: 1 = مفعل
	String imageBase64 = '';
	bool _isLoading = false;
	bool _obscurePassword = true;

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
			_showSnackbar('حدث خطأ في اختيار الصورة', isError: true);
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

	Future<void> _submit() async {
		if (!formKey.currentState!.validate()) return;

		setState(() => _isLoading = true);

		try {
			User newUser = User.create(
				id: '0',
				name: nameController.text,
				mobile: mobileController.text,
				email: emailController.text,
				password: passwordController.text,
				image: imageBase64,
				status: status,
			);

			String result = await UserService.addUser(newUser);
			if (result.toLowerCase().contains('success')) {
				_showAccountCreatedDialog();
			} else {
				_showSnackbar(result, isError: true);
			}
		} catch (e) {
			_showSnackbar('حدث خطأ: $e', isError: true);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _showSnackbar(String message, {bool isError = false}) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: isError ? Colors.red[800] : Colors.green[800],
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(10),
				),
			),
		);
	}

	void _showAccountCreatedDialog() {
		showDialog(
			context: context,
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
									color: Colors.brown[800],
								),
							),
							const SizedBox(height: 15),
							const Text(
								'هل تريد الانتقال إلى صفحة تسجيل الدخول؟',
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
												side: BorderSide(color: Colors.brown[400]!),
											),
										),
										child: Text(
											'لاحقاً',
											style: TextStyle(color: Colors.brown[800]),
										),
									),
									ElevatedButton(
										onPressed: () {
											Navigator.pop(context);
											Navigator.push(
												context,
												MaterialPageRoute(builder: (context) => LoginPage()),
											);
										},
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.brown[600],
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
					style: TextStyle(fontWeight: FontWeight.bold),
				),
				centerTitle: true,
				backgroundColor: Colors.brown[700],
				elevation: 5,
				shape: const RoundedRectangleBorder(
					borderRadius: BorderRadius.vertical(
						bottom: Radius.circular(15),
					),
				),
			),
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [
							Colors.brown[100]!,
							Colors.brown[50]!,
						],
					),
				),
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
												width: 120,
												height: 120,
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													color: Colors.white,
													border: Border.all(color: Colors.brown[300]!, width: 2),
													boxShadow: [
														BoxShadow(
															color: Colors.brown.withOpacity(0.2),
															blurRadius: 10,
															spreadRadius: 2,
															offset: const Offset(0, 4),
														),
													],
												),
												child: imageBase64.isNotEmpty
														? ClipOval(
													child: Image.memory(
														_decodeBase64Image(imageBase64)!,
														fit: BoxFit.cover,
													),
												)
														: Icon(
														Icons.person_add_alt_1,
														size: 50,
														color: Colors.brown[400]),
											),
										),
										Container(
											padding: const EdgeInsets.all(6),
											decoration: BoxDecoration(
												color: Colors.brown[600],
												shape: BoxShape.circle,
												border: Border.all(color: Colors.white, width: 2),
											),
											child: const Icon(
													Icons.camera_alt,
													size: 20,
													color: Colors.white),
										),
									],
								),
								const SizedBox(height: 30),

								// اسم المستخدم
								_buildInputField(
									controller: nameController,
									label: 'اسم المستخدم',
									icon: Icons.person_outline,
									validator: (value) => value!.isEmpty ? 'اسم المستخدم مطلوب' : null,
								),
								const SizedBox(height: 16),

								// رقم الجوال
								_buildInputField(
									controller: mobileController,
									label: 'رقم الجوال',
									icon: Icons.phone_android_outlined,
									keyboardType: TextInputType.phone,
									validator: (value) => value!.isEmpty ? 'رقم الجوال مطلوب' : null,
								),
								const SizedBox(height: 16),

								// البريد الإلكتروني
								_buildInputField(
									controller: emailController,
									label: 'البريد الإلكتروني',
									icon: Icons.email_outlined,
									keyboardType: TextInputType.emailAddress,
									validator: (value) => value!.isEmpty ? 'البريد مطلوب' : null,
								),
								const SizedBox(height: 16),

								// كلمة المرور
								_buildInputField(
									controller: passwordController,
									label: 'كلمة المرور',
									icon: Icons.lock_outline,
									obscureText: _obscurePassword,
									suffixIcon: IconButton(
										icon: Icon(
												_obscurePassword ? Icons.visibility_off : Icons.visibility,
												color: Colors.brown[400]),
										onPressed: () {
											setState(() {
												_obscurePassword = !_obscurePassword;
											});
										},
									),
									validator: (value) => value!.isEmpty ? 'كلمة المرور مطلوبة' : null,
								),
								const SizedBox(height: 30),

								// زر التسجيل
								SizedBox(
									width: double.infinity,
									child: ElevatedButton(
										onPressed: _isLoading ? null : _submit,
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.brown[600],
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
											elevation: 3,
											shadowColor: Colors.brown.withOpacity(0.4),
										),
										child: _isLoading
												? const SizedBox(
											width: 24,
											height: 24,
											child: CircularProgressIndicator(
													strokeWidth: 3,
													color: Colors.white),
										)
												: const Text(
											'إنشاء الحساب',
											style: TextStyle(
													fontSize: 18,
													fontWeight: FontWeight.bold),
										),
									),
								),
								const SizedBox(height: 20),

								// رابط تسجيل الدخول
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text(
											'لديك حساب بالفعل؟',
											style: TextStyle(
													color: Colors.brown[800],
													fontSize: 15),
										),
										const SizedBox(width: 5),
										TextButton(
											onPressed: () {
												Navigator.push(
													context,
													MaterialPageRoute(builder: (context) => LoginPage()),
												);
											},
											style: TextButton.styleFrom(
												padding: EdgeInsets.zero,
												tapTargetSize: MaterialTapTargetSize.shrinkWrap,
											),
											child: Text(
												'سجل الدخول الآن',
												style: TextStyle(
													color: Colors.brown[600],
													fontWeight: FontWeight.bold,
													fontSize: 15,
													decoration: TextDecoration.underline,
												),
											),
										),
									],
								),
							],
						),
					),
				),
			),
		);
	}

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
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(
						color: Colors.brown.withOpacity(0.1),
						blurRadius: 8,
						spreadRadius: 1,
						offset: const Offset(0, 2),
					),
				],
			),
			child: TextFormField(
				controller: controller,
				keyboardType: keyboardType,
				obscureText: obscureText,
				decoration: InputDecoration(
					labelText: label,
					labelStyle: TextStyle(color: Colors.brown[600]),
					prefixIcon: Icon(icon, color: Colors.brown[400]),
					suffixIcon: suffixIcon,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(12),
						borderSide: BorderSide.none,
					),
					filled: true,
					fillColor: Colors.white,
					contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
				),
				validator: validator,
			),
		);
	}
}