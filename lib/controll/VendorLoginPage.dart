import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomeDrawerScaffold.dart';
import '../HomeDrawerVendor.dart';
import '../model/vendors_model.dart';
import '../service/VendorBankDetailsService.dart'; // تأكد أن هذه الصفحة للبائعين

class VendorLoginPage extends StatefulWidget {

	const VendorLoginPage({super.key});

	@override
	State<VendorLoginPage> createState() => _VendorLoginPageState();
}

class _VendorLoginPageState extends State<VendorLoginPage> {
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
			final vendor = await VendorService.getVendorByEmail(email);
			if (vendor != null && vendor.accessToken == accessToken && vendor.status == 'active') {
				_goToHome(vendor);
			} else {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _saveVendorToPrefs(Vendor vendor) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', vendor.id);
		await prefs.setString('name', vendor.name);
		await prefs.setString('mobile', vendor.mobile ?? '');
		await prefs.setString('email', vendor.email);
		await prefs.setString('email_verified_at', vendor.emailVerifiedAt ?? '');
		await prefs.setString('password', vendor.password);
		await prefs.setString('image', vendor.image ?? '');
		await prefs.setString('status', vendor.status);
		await prefs.setString('remember_token', vendor.rememberToken ?? '');
		await prefs.setString('access_token', vendor.accessToken ?? '');
		await prefs.setString('created_at', vendor.createdAt ?? '');
		await prefs.setString('updated_at', vendor.updatedAt ?? '');
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

			final vendor = await VendorService.loginVendor(email, password);

			if (vendor != null) {
				if (vendor.status != 'active') {
					setState(() {
						_errorMessage = 'الحساب غير مفعل، يرجى التواصل مع الإدارة';
						_isLoading = false;
					});
					return;
				}

				await _saveVendorToPrefs(vendor);

				SharedPreferences prefs = await SharedPreferences.getInstance();
				await prefs.setString('login_method', 'manual');

				await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح');
				_goToHome(vendor);
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

	void _goToHome(Vendor vendor) {
		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) => HomeDrawerVendor(),
			// تأكد أنها صفحة البائع
					));
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
				title: const Text('تسجيل دخول البائع'),
				centerTitle: true,
				backgroundColor: Colors.green,
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
										backgroundColor: Colors.green,
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
