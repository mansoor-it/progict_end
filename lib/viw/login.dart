
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../HomeDrawerScaffold.dart';
import '../model/user_model.dart';
import '../service/user_server.dart';
import 'AllProductsPage.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	bool _isLoading = false;
	bool _obscurePassword = true;
	String? _errorMessage;

	late AnimationController _animationController;
	late Animation<double> _scaleAnimation;

	@override
	void initState() {
		super.initState();

		_animationController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 300),
		);
		_scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
			CurvedAnimation(
				parent: _animationController,
				curve: Curves.easeIn,
			),
		);
	}

	@override
	void dispose() {
		_animationController.dispose();
		super.dispose();
	}

	Future<void> _checkSavedLogin() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		String? email = prefs.getString('email');
		String? accessToken = prefs.getString('access_token');
		if (email != null && accessToken != null) {
			setState(() => _isLoading = true);
			final user = await UserService.getUserByEmail(email);
			if (user != null &&
					user.accessToken == accessToken &&
					user.status == 'active') {
				_goToHome(user);
			} else {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _saveUserDataToPrefs(User user) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', user.id);
		await prefs.setString('name', user.name);
		await prefs.setString('mobile', user.mobile ?? '');
		await prefs.setString('email', user.email);
		await prefs.setString('email_verified_at', user.emailVerifiedAt ?? '');
		await prefs.setString('password', user.password);
		await prefs.setString('image', user.image ?? '');
		await prefs.setString('status', user.status);
		await prefs.setString('remember_token', user.rememberToken ?? '');
		await prefs.setString('access_token', user.accessToken ?? '');
		await prefs.setString('created_at', user.createdAt ?? '');
		await prefs.setString('updated_at', user.updatedAt ?? '');
	}

	Future<void> _showMessageDialog(String title, String message,
			{bool isError = false}) async {
		return showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(title,
						style: TextStyle(color: isError ? Colors.red : Colors.green)),
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
			final user = await UserService.loginUser(email, password);
			if (user != null) {
				if (user.status != 'active') {
					setState(() {
						_errorMessage =
						'(733494291)الحساب غير مفعل، يرجى التواصل مع الإدارة';
						_isLoading = false;
					});
					return;
				}
				await _saveUserDataToPrefs(user);
				SharedPreferences prefs = await SharedPreferences.getInstance();
				await prefs.setString('login_method', 'manual');
				await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح');
				_goToHome(user);
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

	Future<void> _loginWithGoogle() async {
		try {
			final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
			if (googleUser == null) {
				setState(() =>
				_errorMessage = 'تم إلغاء تسجيل الدخول من قبل المستخدم');
				return;
			}
			final String email = googleUser.email;
			final String name = googleUser.displayName ?? 'مستخدم Google';
			final String id = googleUser.id;
			final String photoUrl = googleUser.photoUrl ?? '';
			const defaultPassword = 'google_default_password';
			final existingUser = await UserService.loginUser(email, defaultPassword);
			User user;
			if (existingUser != null) {
				user = existingUser;
			} else {
				user = User(
					id: id,
					name: name,
					email: email,
					password: defaultPassword,
					mobile: '',
					image: photoUrl,
					status: 'active',
					emailVerifiedAt: '',
					rememberToken: '',
					accessToken:
					'google_token_${DateTime.now().millisecondsSinceEpoch}',
					createdAt: DateTime.now().toIso8601String(),
					updatedAt: DateTime.now().toIso8601String(),
				);
				await UserService.registerUser(user);
			}
			if (user.status != 'active') {
				setState(() =>
				_errorMessage = 'الحساب غير مفعل، يرجى التواصل مع الإدارة');
				return;
			}
			await _saveUserDataToPrefs(user);
			SharedPreferences prefs = await SharedPreferences.getInstance();
			await prefs.setString('login_method', 'google');
			await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح');
			_goToHome(user);
		} catch (e) {
			setState(() {
				_errorMessage = e.toString().contains('SocketException')
						? 'تحقق من اتصال الإنترنت'
						: 'فشل تسجيل الدخول عبر Google';
			});
		}
	}

	void _goToHome(User user) {
		if (!mounted) return;
		Navigator.of(context).pushReplacement(
			PageRouteBuilder(
				pageBuilder: (_, __, ___) => HomeDrawerScaffold(user: user),
				transitionsBuilder: (_, animation, __, child) {
					return FadeTransition(opacity: animation, child: child);
				},
			),
		);
	}

	void _goToRegister() {
		Navigator.push(
			context,
			PageRouteBuilder(
				pageBuilder: (_, __, ___) => const SignUpPage(),
				transitionsBuilder: (_, animation, __, child) {
					return SlideTransition(position: Tween<Offset>(
						begin: const Offset(1, 0),
						end: Offset.zero,
					).animate(animation), child: child);
				},
			),
		);
	}

	void _forgotPassword() {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
			),
			builder: (context) => Padding(
				padding: MediaQuery.of(context).viewInsets,
				child: Container(
					padding: const EdgeInsets.all(20),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Text(
								'نسيت كلمة المرور؟',
								style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
							),
							const SizedBox(height: 10),
							const Text('سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'),
							const SizedBox(height: 20),
							ElevatedButton.icon(
								onPressed: () {
									Navigator.pop(context);
									_showMessageDialog('تم', 'تم إرسال الرابط بنجاح');
								},
								icon: Icon(Icons.send),
								label: const Text('إرسال'),
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.purple,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
								),
							),
						],
					),
				),
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
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
				filled: true,
				fillColor: Colors.white.withOpacity(0.8),
			),
			validator: validator,
			textInputAction: TextInputAction.next,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			resizeToAvoidBottomInset: false,
			body: Container(
				width: double.infinity,
				height: double.infinity,
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)],
					),
				),
				child: Stack(
					alignment: Alignment.center,
					children: [

						Positioned(
							top: 190,
							child: Container(
								width: MediaQuery.of(context).size.width * 0.9,
								padding: const EdgeInsets.all(20),
								decoration: BoxDecoration(
									color: Colors.white.withOpacity(0.95),
									borderRadius: BorderRadius.circular(20),
									boxShadow: [
										BoxShadow(
											color: Colors.black.withOpacity(0.1),
											blurRadius: 10,
											offset: const Offset(0, 5),
										)
									],
								),
								child: Form(
									key: _formKey,
									child: Column(
										children: [
											const SizedBox(height: 10),
											_buildTextInput(
												label: 'البريد الإلكتروني',
												icon: Icons.email,
												controller: _emailController,
												keyboardType: TextInputType.emailAddress,
												validator: (value) => value?.isEmpty ?? true
														? 'أدخل البريد الإلكتروني'
														: null,
											),
											const SizedBox(height: 15),
											_buildTextInput(
												label: 'كلمة المرور',
												icon: Icons.lock,
												controller: _passwordController,
												obscure: _obscurePassword,
												suffixIcon: IconButton(
													icon: Icon(_obscurePassword
															? Icons.visibility
															: Icons.visibility_off),
													onPressed: () =>
															setState(() => _obscurePassword = !_obscurePassword),
												),
												validator: (value) => value?.isEmpty ?? true
														? 'أدخل كلمة المرور'
														: null,
											),
											Align(
												alignment: Alignment.centerLeft,
												child: TextButton(
													onPressed: _forgotPassword,
													child: const Text('نسيت كلمة المرور؟'),
												),
											),
											if (_errorMessage != null)
												Padding(
													padding: const EdgeInsets.symmetric(vertical: 10),
													child: Text(
														_errorMessage!,
														style: const TextStyle(
																color: Colors.red, fontWeight: FontWeight.bold),
													),
												),
											const SizedBox(height: 10),
											AnimatedBuilder(
												animation: _scaleAnimation,
												builder: (context, child) {
													return Transform.scale(
														scale: _scaleAnimation.value,
														child: child,
													);
												},
												child: SizedBox(
													width: double.infinity,
													height: 50,
													child: ElevatedButton(
														onPressed: _isLoading ? null : () {
															_animationController.forward();
															Future.delayed(const Duration(milliseconds: 200),
																	_animationController.reverse);
															_login();
														},
														style: ElevatedButton.styleFrom(
															backgroundColor: Colors.deepPurple.shade700,
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(10),
															),
														),
														child: _isLoading
																? Row(
															mainAxisAlignment: MainAxisAlignment.center,
															children: const [
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
															style: TextStyle(fontSize: 18),
														),
													),
												),
											),
											const SizedBox(height: 15),
											SizedBox(
												width: double.infinity,
												height: 50,
												child: OutlinedButton.icon(
													onPressed: _loginWithGoogle,
													icon: Image.asset('assets/m.png', height: 24),
													label: const Text('تسجيل الدخول عبر Google'),
													style: OutlinedButton.styleFrom(
														foregroundColor: Colors.deepPurple.shade700,
														side: BorderSide(
																color: Colors.deepPurple.shade700, width: 1.5),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(10),
														),
													),
												),
											),
											const SizedBox(height: 15),
											TextButton(
												onPressed: _goToRegister,
												child: const Text('ليس لديك حساب؟ سجل الآن'),
											),
										],
									),
								),
							),
						),
					],
				),
			),
		);
	}
}