import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomeDrawerScaffold.dart';
import '../HomeDrawer_Admin.dart';
import '../home.dart';
import '../model/admin_model.dart';
import '../service/admin_server.dart';


class AdminLoginPage extends StatefulWidget {
	const AdminLoginPage({super.key});

	@override
	State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
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
		String? email = prefs.getString('email');
		String? accessToken = prefs.getString('access_token');

		if (email != null && accessToken != null) {
			setState(() => _isLoading = true);
			final admin = await AdminService.getAdminByEmail(email);
			if (admin != null && admin.accessToken == accessToken && admin.status == 'active') {
				_goToHome(admin);
			} else {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _saveAdminToPrefs(Admin admin) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', admin.id);
		await prefs.setString('name', admin.name);
		await prefs.setString('mobile', admin.mobile ?? '');
		await prefs.setString('email', admin.email);
		await prefs.setString('email_verified_at', admin.emailVerifiedAt ?? '');
		await prefs.setString('password', admin.password);
		await prefs.setString('image', admin.image ?? '');
		await prefs.setString('status', admin.status);
		await prefs.setString('remember_token', admin.rememberToken ?? '');
		await prefs.setString('access_token', admin.accessToken ?? '');
		await prefs.setString('created_at', admin.createdAt ?? '');
		await prefs.setString('updated_at', admin.updatedAt ?? '');
	}

	Future<void> _showMessageDialog(String title, String message, {bool isError = false}) async {
		return showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(title, style: TextStyle(color: isError ? Colors.red : Colors.green)),
				content: Text(message),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(context).pop(),
						child: const Text('حسناً'),
					),
				],
			),
		);
	}

	Future<void> _login() async {
		FocusScope.of(context).unfocus();

		if (!_formKey.currentState!.validate()) return;

		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		try {
			final email = _emailController.text.trim();
			final password = _passwordController.text.trim();

			final admin = await AdminService.loginAdmin(email, password);

			if (admin != null) {
				if (admin.status != 'active') {
					setState(() {
						_errorMessage = 'الحساب غير مفعل، يرجى التواصل مع الإدارة';
						_isLoading = false;
					});
					return;
				}

				await _saveAdminToPrefs(admin);

				SharedPreferences prefs = await SharedPreferences.getInstance();
				await prefs.setString('login_method', 'manual');

				await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح');
				_goToHome(admin);
			} else {
				setState(() {
					_errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
				});
			}
		} catch (e) {
			setState(() {
				_errorMessage = e.toString().contains('SocketException')
						? 'تحقق من اتصال الإنترنت'
						: 'حدث خطأ أثناء تسجيل الدخول';
			});
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _goToHome(Admin admin) {
		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) => const HomeDrawerAdmin()),
		);
	}

	Widget _buildTextInput({
		required String label,
		required IconData icon,
		required TextEditingController controller,
		bool obscure = false,
		Widget? suffixIcon,
		String? Function(String?)? validator,
		TextInputType? keyboardType,
	}) {
		return TextFormField(
			controller: controller,
			obscureText: obscure,
			keyboardType: keyboardType,
			decoration: InputDecoration(
				labelText: label,
				prefixIcon: Icon(icon),
				suffixIcon: suffixIcon,
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
			),
			validator: validator,
			textInputAction: TextInputAction.next,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('تسجيل دخول الأدمن'),
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
								keyboardType: TextInputType.emailAddress,
								validator: (value) =>
								value == null || value.isEmpty ? 'أدخل البريد الإلكتروني' : null,
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
								validator: (value) =>
								value == null || value.isEmpty ? 'أدخل كلمة المرور' : null,
							),
							if (_errorMessage != null)
								Padding(
									padding: const EdgeInsets.symmetric(vertical: 10),
									child: Text(
										_errorMessage!,
										style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
									),
								),
							const SizedBox(height: 10),
							SizedBox(
								width: double.infinity,
								height: 50,
								child: ElevatedButton(
									onPressed: _isLoading ? null : _login,
									style: ElevatedButton.styleFrom(
										backgroundColor: Colors.brown,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(10),
										),
									),
									child: _isLoading
											? const Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											SizedBox(
												width: 20,
												height: 20,
												child: CircularProgressIndicator(
													color: Colors.white,
													strokeWidth: 2,
												),
											),
											SizedBox(width: 10),
											Text('جارٍ تسجيل الدخول...'),
										],
									)
											: const Text(
										'تسجيل الدخول',
										style: TextStyle(fontSize: 16),
									),
								),
							),
						],
					),
				),
			),
		);
	}
}
