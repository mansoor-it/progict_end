import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';
import '../service/user_server.dart';
import 'SignUpPage.dart';
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
	bool _obscurePassword = true;
	String? _errorMessage;

	@override
	void initState() {
		super.initState();
		_checkSavedLogin();
	}

	Future<void> _checkSavedLogin() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		String? savedEmail = prefs.getString('email');
		String? savedPassword = prefs.getString('password');

		if (savedEmail != null && savedPassword != null) {
			setState(() => _isLoading = true);
			final user = await UserService.loginUser(savedEmail, savedPassword);
			if (user != null) {
				_goToHome(user);
			} else {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _login() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		try {
			final email = _emailController.text.trim();
			final password = _passwordController.text.trim();

			final user = await UserService.loginUser(email, password);

			if (user != null) {
				SharedPreferences prefs = await SharedPreferences.getInstance();
				await prefs.setString('email', email);
				await prefs.setString('password', password);

				_showSuccessDialog(user);
			} else {
				setState(() {
					_errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
				});
			}
		} catch (e) {
			setState(() {
				_errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
			});
		} finally {
			setState(() {
				_isLoading = false;
			});
		}
	}

	Future<void> _loginWithGoogle() async {
		try {
			print('🔄 بدء تسجيل الدخول عبر Google...');
			final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

			if (googleUser == null) {
				print('❌ تم إلغاء تسجيل الدخول من قبل المستخدم.');
				setState(() {
					_errorMessage = 'تم إلغاء تسجيل الدخول من قبل المستخدم';
				});
				return;
			}

			final String email = googleUser.email;
			final String name = googleUser.displayName ?? 'مستخدم Google';
			final String id = googleUser.id;

			print('✅ تسجيل الدخول عبر Google ناجح');
			print('📧 البريد الإلكتروني: $email');
			print('👤 الاسم: $name');
			print('🆔 المعرف: $id');

			final defaultPassword = 'google_default_password';

			// تسجيل الدخول للتحقق مما إذا كان المستخدم موجوداً
			final existingUser = await UserService.loginUser(email, defaultPassword);

			User user;

			if (existingUser != null) {
				print('👤 تم العثور على المستخدم في قاعدة البيانات');
				user = existingUser;
			} else {
				// إذا لم يكن موجوداً، يتم إنشاؤه
				user = User(
					id: id,
					name: name,
					email: email,
					password: defaultPassword,
					mobile: '',
					image: '',
					status: '',
				);
				await UserService.registerUser(user);
				print('🆕 تم إنشاء مستخدم جديد في قاعدة البيانات عبر Google');
			}

			// حفظ البيانات
			SharedPreferences prefs = await SharedPreferences.getInstance();
			await prefs.setString('email', email);
			await prefs.setString('password', defaultPassword);
			await prefs.setString('login_method', 'google');

			_showSuccessDialog(user);
		} catch (error, stackTrace) {
			print('🚫 فشل تسجيل الدخول عبر Google: $error');
			print('📛 Stack Trace:\n$stackTrace');
			setState(() {
				_errorMessage = 'فشل تسجيل الدخول عبر Google: $error';
			});
		}
	}



	void _showSuccessDialog(User user) {
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text('مرحبًا ${user.name}'),
				content: const Text('تم تسجيل الدخول بنجاح'),
				actions: [
					TextButton(
						onPressed: () {
							Navigator.of(context).pop();
							_goToHome(user);
						},
						child: const Text('متابعة'),
					)
				],
			),
		);
	}

	void _goToHome(User user) {
		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) =>  CategoriesScreen()),
		);
	}

	void _goToRegister() {
		Navigator.push(
			context,
			MaterialPageRoute(builder: (_) =>  SignUpPage()),
		);
	}

	void _forgotPassword() {
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: const Text('نسيت كلمة المرور؟'),
				content: const Text('سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'),
				actions: [
					TextButton(onPressed: Navigator.of(context).pop, child: const Text('إلغاء')),
					TextButton(onPressed: () {}, child: const Text('إرسال')),
				],
			),
		);
	}

	Widget _buildTextInput({
		required String label,
		required IconData icon,
		required TextEditingController controller,
		bool obscure = false,
		Widget? suffixIcon,
		String? Function(String?)? validator,
	}) {
		return TextFormField(
			controller: controller,
			obscureText: obscure,
			decoration: InputDecoration(
				labelText: label,
				prefixIcon: Icon(icon),
				suffixIcon: suffixIcon,
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
			),
			validator: validator,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('تسجيل الدخول'),
				centerTitle: true,
				backgroundColor: Colors.brown,
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(20),
				child: Form(
					key: _formKey,
					child: Column(
						children: [
							Image.asset('assets/logo.jpg', height: 120),
							const SizedBox(height: 20),
							_buildTextInput(
								label: 'البريد الإلكتروني',
								icon: Icons.email,
								controller: _emailController,
								validator: (value) => value!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
							),
							const SizedBox(height: 15),
							_buildTextInput(
								label: 'كلمة المرور',
								icon: Icons.lock,
								controller: _passwordController,
								obscure: _obscurePassword,
								suffixIcon: IconButton(
									icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
									onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
								),
								validator: (value) => value!.isEmpty ? 'أدخل كلمة المرور' : null,
							),
							Align(
								alignment: Alignment.centerLeft,
								child: TextButton(
									onPressed: _forgotPassword,
									child: const Text('نسيت كلمة المرور؟'),
								),
							),
							if (_errorMessage != null)
								Text(
									_errorMessage!,
									style: const TextStyle(color: Colors.red),
								),
							const SizedBox(height: 20),
							ElevatedButton(
								onPressed: _isLoading ? null : _login,
								child: _isLoading
										? const CircularProgressIndicator()
										: const Text('تسجيل الدخول'),
							),
							const SizedBox(height: 15),
							OutlinedButton.icon(
								onPressed: _loginWithGoogle,
								icon: Image.asset('assets/m.png', height: 24),
								label: const Text('تسجيل الدخول عبر Google'),
							),
							const SizedBox(height: 10),
							TextButton(
								onPressed: _goToRegister,
								child: const Text('ليس لديك حساب؟ سجل الآن'),
							),
						],
					),
				),
			),
		);
	}
}
