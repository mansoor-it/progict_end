import 'package:flutter/material.dart';
import '../home.dart';
import '../model/user_model.dart';
import '../service/user_server.dart';
import 'categories_screen.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	bool _isLoading = false;
	String? _errorMessage;

	void _login() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		final email = _emailController.text.trim();
		final password = _passwordController.text.trim();

		final user = await UserService.loginUser(email, password);

		setState(() {
			_isLoading = false;
		});

		if (user != null) {
			// نجاح تسجيل الدخول
			showDialog(
				context: context,
				builder: (_) => AlertDialog(
					title: const Text('نجاح'),
					content: Text('مرحباً ${user.name}'),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.of(context).pop(); // يغلق الـ Dialog
								Navigator.of(context).pushReplacement( // يذهب إلى الصفحة الرئيسية
									MaterialPageRoute(
										builder: (context) => CategoriesScreen(), // استبدل HomePage بصفحتك الرئيسية الفعلية
									),
								);
							},
							child: const Text('متابعة'),
						),
					],
				),
			);
		} else {
			// فشل تسجيل الدخول
			setState(() {
				_errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
			});
		}
	}

	void _goToRegister() {
		// الانتقال لصفحة التسجيل
		debugPrint('الانتقال لصفحة التسجيل');
	}

	void _forgotPassword() {
		// الانتقال لصفحة نسيت كلمة المرور
		debugPrint('الانتقال لنسيت كلمة المرور');
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			// استخدم Stack لإضافة خلفية وصفيحة أمامية
			body: Stack(
				children: [
					// خلفية الصورة
					SizedBox.expand(
						child: Image.asset(
							'assets/m.png', // تأكد من وضع ملف m.jpg داخل مجلد assets
							fit: BoxFit.cover,
						),
					),
					// المحتوى الأمامي
					Center(
						child: SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 24.0),
							child: Card(
								elevation: 12,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(20),
								),
								color: Colors.white, // تغيير خلفية الكارد إلى اللون الأبيض
								child: Padding(
									padding: const EdgeInsets.all(24.0),
									child: Form(
										key: _formKey,
										child: Column(
											mainAxisSize: MainAxisSize.min,
											children: [
												// عنوان الصفحة
												const Text(
													'تسجيل الدخول',
													style: TextStyle(
														fontSize: 26,
														fontWeight: FontWeight.bold,
														color: Colors.black, // تغيير لون النص إلى الأسود ليتناسب مع الخلفية البيضاء
													),
												),
												const SizedBox(height: 24),
												// حقل البريد الإلكتروني
												TextFormField(
													controller: _emailController,
													decoration: InputDecoration(
														labelText: 'البريد الإلكتروني',
														border: OutlineInputBorder(
															borderRadius: BorderRadius.circular(12),
														),
														prefixIcon: const Icon(Icons.email, color: Colors.black), // تغيير لون الأيقونة إلى الأسود
														labelStyle: const TextStyle(color: Colors.black), // تغيير لون النص داخل الحقل إلى الأسود
													),
													keyboardType: TextInputType.emailAddress,
													validator: (value) => value == null || value.isEmpty
															? 'أدخل البريد الإلكتروني'
															: null,
												),
												const SizedBox(height: 16),
												// حقل كلمة المرور
												TextFormField(
													controller: _passwordController,
													decoration: InputDecoration(
														labelText: 'كلمة المرور',
														border: OutlineInputBorder(
															borderRadius: BorderRadius.circular(12),
														),
														prefixIcon: const Icon(Icons.lock, color: Colors.black), // تغيير لون الأيقونة إلى الأسود
														labelStyle: const TextStyle(color: Colors.black), // تغيير لون النص داخل الحقل إلى الأسود
													),
													obscureText: true,
													validator: (value) => value == null || value.isEmpty
															? 'أدخل كلمة المرور'
															: null,
												),
												const SizedBox(height: 12),
												// رابط "نسيت كلمة المرور؟"
												Align(
													alignment: Alignment.centerRight,
													child: TextButton(
														onPressed: _forgotPassword,
														child: const Text(
															'نسيت كلمة المرور؟',
															style: TextStyle(color: Colors.black), // تغيير لون النص إلى الأسود
														),
													),
												),
												if (_errorMessage != null)
													Text(
														_errorMessage!,
														style: const TextStyle(color: Colors.red),
													),
												const SizedBox(height: 16),
												// زر تسجيل الدخول
												SizedBox(
													width: double.infinity,
													height: 50,
													child: ElevatedButton(
														onPressed: _isLoading ? null : _login,
														style: ElevatedButton.styleFrom(
															backgroundColor: Colors.blueAccent, // يمكنك تغيير لون الزر أيضًا إذا رغبت
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(12),
															),
														),
														child: _isLoading
																? const CircularProgressIndicator(color: Colors.white)
																: const Text(
															'تسجيل الدخول',
															style: TextStyle(fontSize: 18, color: Colors.white), // تغيير لون النص إلى الأبيض
														),
													),
												),
												const SizedBox(height: 16),
												// زر أو رابط إنشاء حساب جديد
												Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														const Text('ليس لديك حساب؟', style: TextStyle(color: Colors.black)), // تغيير لون النص إلى الأسود
														TextButton(
															onPressed: _goToRegister,
															child: const Text(
																'إنشاء حساب',
																style: TextStyle(
																	color: Colors.blueAccent,
																	fontWeight: FontWeight.bold,
																),
															),
														),
													],
												)
											],
										),
									),
								),
							),
						),
					),
				],
			),
		);
	}
}
