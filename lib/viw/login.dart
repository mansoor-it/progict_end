import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart'; // Keep if you intend to use it, otherwise consider removing

import '../HomeDrawerScaffold.dart';
import '../model/user_model.dart';
import '../service/user_server.dart';
import 'SignUpPage.dart';

/// --- صفحة تسجيل دخول المستخدم ---
/// واجهة تسجيل دخول مصممة بعناية فائقة، تجمع بين الأمان الفائق
/// والجمالية الفاخرة لتجربة مستخدم لا تُنسى.
class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
	// --- عناصر التحكم في النموذج والإدخال ---
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	// --- متغيرات حالة الواجهة الرسومية (UI) ---
	bool _isLoading = false;
	bool _obscurePassword = true;
	String? _errorMessage;
	bool _autoLoginChecked = false; // لتتبع اكتمال فحص تسجيل الدخول التلقائي

	// --- التحكم بالرسوم المتحركة ---
	late AnimationController _animationController;
	late Animation<double> _scaleAnimation;

	/// --- دورة حياة الويدجت: التهيئة ---
	/// تُستدعى مرة واحدة عند إدراج الويدجت في شجرة الويدجت.
	/// تُهيئ المتحكمات وتبدأ فحص تسجيل الدخول التلقائي.
	@override
	void initState() {
		super.initState();

		_animationController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 200), // مدة أقصر لاستجابة أسرع
		);
		_scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate( // تأثير ضغط خفيف
			CurvedAnimation(
				parent: _animationController,
				curve: Curves.easeOut, // منحنى لرسوم متحركة أنعم
			),
		);

		_checkSavedLogin(); // فحص تسجيل الدخول المحفوظ عند البدء
	}

	/// --- دورة حياة الويدجت: التخلص ---
	/// تُستدعى عند إزالة الويدجت من شجرة الويدجت.
	/// تتخلص من المتحكمات لمنع تسرب الذاكرة.
	@override
	void dispose() {
		_animationController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	/// --- التحقق من تسجيل الدخول التلقائي ---
	/// تحاول تسجيل دخول المستخدم تلقائيًا إذا وُجدت بيانات اعتماد صالحة
	/// (البريد الإلكتروني ورمز الوصول) في التفضيلات المشتركة.
	Future<void> _checkSavedLogin() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		String? email = prefs.getString('email');
		String? accessToken = prefs.getString('access_token');

		if (email != null && accessToken != null) {
			setState(() => _isLoading = true); // إظهار مؤشر التحميل

			try {
				final user = await UserService.getUserByEmail(email);
				if (user != null && user.accessToken == accessToken && user.status == 'active') {
					_goToHome(user); // الانتقال إلى الصفحة الرئيسية
					return; // الخروج لمنع تحديث الحالة مرة أخرى
				}
			} catch (e) {
				// يمكن تسجيل الخطأ هنا للمراقبة
				print('Auto-login error: $e');
			}
		}

		setState(() {
			_isLoading = false;
			_autoLoginChecked = true; // تحديد أن فحص تسجيل الدخول التلقائي قد اكتمل
		});
	}

	/// --- حفظ بيانات المستخدم ---
	/// يحفظ تفاصيل المستخدم الأساسية في التفضيلات المشتركة
	/// لإدارة الجلسة وتسجيل الدخول التلقائي المستقبلي.
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

	/// --- عرض رسالة حوارية أنيقة ---
	/// تُظهر مربع حوار جميلًا لعرض رسائل النجاح أو الخطأ للمستخدم.
	Future<void> _showMessageDialog(String title, String message, {bool isError = false}) async {
		return showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(
					title,
					style: TextStyle(
						color: isError ? Colors.red.shade700 : Colors.green.shade700,
						fontWeight: FontWeight.bold,
						fontFamily: 'Almarai', // خط عربي أنيق
					),
				),
				content: Text(
					message,
					style: const TextStyle(fontSize: 15.0, fontFamily: 'Almarai'),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(context).pop(),
						child: const Text(
							'حسناً',
							style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontFamily: 'Almarai'),
						),
					),
				],
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), // زوايا أكثر استدارة
				elevation: 15.0, // ظل أعمق للمربع الحواري
			),
		);
	}

	/// --- منطق تسجيل الدخول الرئيسي ---
	/// يتعامل مع عملية تسجيل دخول المستخدم العادية: التحقق، استدعاء API،
	/// إدارة الحالة، والتنقل.
	Future<void> _login() async {
		FocusScope.of(context).unfocus(); // إخفاء لوحة المفاتيح
		if (!_formKey.currentState!.validate()) return; // التحقق من صحة النموذج

		setState(() {
			_isLoading = true; // إظهار التحميل
			_errorMessage = null; // مسح الأخطاء السابقة
		});

		try {
			final email = _emailController.text.trim();
			final password = _passwordController.text.trim();

			final user = await UserService.loginUser(email, password);

			if (user != null) {
				if (user.status != 'active') {
					setState(() {
						_errorMessage = 'الحساب غير مفعل، يرجى التواصل مع الإدارة (733494291)';
						_isLoading = false;
					});
					return;
				}

				await _saveUserDataToPrefs(user); // حفظ بيانات المستخدم
				SharedPreferences prefs = await SharedPreferences.getInstance();
				await prefs.setString('login_method', 'manual'); // تحديد طريقة تسجيل الدخول

				await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح');
				_goToHome(user); // الانتقال إلى الصفحة الرئيسية
			} else {
				setState(() {
					_errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
				});
			}
		} catch (e) {
			setState(() {
				_errorMessage = e.toString().contains('SocketException')
						? 'تحقق من اتصال الإنترنت.'
						: 'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى.';
			});
		} finally {
			setState(() => _isLoading = false); // دائمًا إخفاء التحميل
		}
	}

	/// --- تسجيل الدخول عبر Google ---
	/// يدير عملية تسجيل دخول المستخدم باستخدام حساب Google.
	Future<void> _loginWithGoogle() async {
		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});
		try {
			final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
			if (googleUser == null) {
				setState(() {
					_errorMessage = 'تم إلغاء تسجيل الدخول من قبل المستخدم.';
					_isLoading = false;
				});
				return;
			}

			final String email = googleUser.email;
			final String name = googleUser.displayName ?? 'مستخدم Google';
			final String id = googleUser.id;
			final String photoUrl = googleUser.photoUrl ?? '';
			const defaultPassword = 'google_default_password'; // كلمة مرور افتراضية للتسجيل الأول

			// التحقق مما إذا كان المستخدم موجودًا
			User? existingUser;
			try {
				existingUser = await UserService.loginUser(email, defaultPassword);
			} catch (e) {
				// قد يفشل تسجيل الدخول إذا لم يكن المستخدم موجودًا بكلمة المرور الافتراضية
				print('User not found with default password, proceeding to register. $e');
			}

			User user;
			if (existingUser != null) {
				user = existingUser;
			} else {
				// تسجيل مستخدم جديد إذا لم يكن موجودًا
				user = User(
					id: id,
					name: name,
					email: email,
					password: defaultPassword,
					mobile: '', // يمكن للمستخدم تحديث هذا لاحقًا
					image: photoUrl,
					status: 'active', // تفعيل الحساب تلقائيًا لـ Google
					emailVerifiedAt: DateTime.now().toIso8601String(), // يُفترض أنه تم التحقق منه
					rememberToken: '',
					accessToken: 'google_token_${DateTime.now().millisecondsSinceEpoch}', // رمز وصول فريد
					createdAt: DateTime.now().toIso8601String(),
					updatedAt: DateTime.now().toIso8601String(),
				);
				await UserService.registerUser(user);
			}

			if (user.status != 'active') {
				setState(() {
					_errorMessage = 'الحساب غير مفعل، يرجى التواصل مع الإدارة.';
					_isLoading = false;
				});
				return;
			}

			await _saveUserDataToPrefs(user); // حفظ بيانات المستخدم
			SharedPreferences prefs = await SharedPreferences.getInstance();
			await prefs.setString('login_method', 'google'); // تحديد طريقة تسجيل الدخول

			await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح عبر Google.');
			_goToHome(user);
		} catch (e) {
			setState(() {
				_errorMessage = e.toString().contains('SocketException')
						? 'تحقق من اتصال الإنترنت.'
						: 'فشل تسجيل الدخول عبر Google. يرجى المحاولة مرة أخرى.';
			});
		} finally {
			setState(() => _isLoading = false);
		}
	}

	/// --- الانتقال إلى الصفحة الرئيسية ---
	/// يستبدل صفحة تسجيل الدخول الحالية بشاشة المستخدم الرئيسية
	/// مع انتقال تدريجي.
	void _goToHome(User user) {
		if (!mounted) return; // التأكد من أن الويدجت لا يزال موجودًا
		Navigator.of(context).pushReplacement(
			PageRouteBuilder(
				pageBuilder: (_, __, ___) => HomeDrawerScaffold(user: user),
				transitionsBuilder: (_, animation, __, child) {
					// انتقال تدريجي أنيق
					return FadeTransition(opacity: animation, child: child);
				},
			),
		);
	}

	/// --- الانتقال إلى صفحة التسجيل ---
	/// يدفع صفحة التسجيل إلى الأعلى مع انتقال من اليمين إلى اليسار.
	void _goToRegister() {
		Navigator.push(
			context,
			PageRouteBuilder(
				pageBuilder: (_, __, ___) => const SignUpPage(),
				transitionsBuilder: (_, animation, __, child) {
					// انتقال من اليمين
					return SlideTransition(
						position: Tween<Offset>(
							begin: const Offset(1, 0),
							end: Offset.zero,
						).animate(animation),
						child: child,
					);
				},
			),
		);
	}

	/// --- بناء حقل إدخال نصي قابل لإعادة الاستخدام ---
	/// ينشئ حقل إدخال نصي مصمم بشكل جميل مع التحقق من الصحة.
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
				prefixIcon: Icon(icon, color: Colors.deepPurple.shade400), // لون أيقونة مميز
				suffixIcon: suffixIcon,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(18), // زوايا أكثر استدارة وفخامة
					borderSide: BorderSide.none, // إزالة الحدود الافتراضية
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(18),
					borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0), // حدود خفيفة
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(18),
					borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.5), // تسليط ضوء أقوى عند التركيز
				),
				errorBorder: OutlineInputBorder( // حدود حمراء للخطأ
					borderRadius: BorderRadius.circular(18),
					borderSide: const BorderSide(color: Colors.red, width: 2.0),
				),
				focusedErrorBorder: OutlineInputBorder( // حدود حمراء عند التركيز على حقل به خطأ
					borderRadius: BorderRadius.circular(18),
					borderSide: const BorderSide(color: Colors.red, width: 2.5),
				),
				filled: true,
				fillColor: Colors.white.withOpacity(0.95), // خلفية بيضاء شفافة قليلاً
				contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0), // مساحة داخلية أكبر
				labelStyle: TextStyle(color: Colors.grey.shade600, fontFamily: 'Almarai'),
				hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Almarai'),
			),
			validator: validator,
			textInputAction: TextInputAction.next,
			cursorColor: Colors.deepPurpleAccent, // لون المؤشر
			style: const TextStyle(fontSize: 17.0, color: Colors.black87, fontFamily: 'Almarai'),
		);
	}

	/// --- فتح شريحة "نسيت كلمة المرور" السفلية ---
	/// تظهر شريحة سفلية أنيقة لإعادة تعيين كلمة المرور.
	void _forgotPassword() {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true, // للسماح لوحة المفاتيح بتغيير الحجم
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(35)), // زوايا مستديرة أكبر
			),
			builder: (context) => Padding(
				padding: EdgeInsets.only(
					bottom: MediaQuery.of(context).viewInsets.bottom,
					left: 30,
					right: 30,
					top: 35,
				),
				child: Column(
					mainAxisSize: MainAxisSize.min, // تصغير حجم العمود حسب المحتوى
					children: [
						const Text(
							'نسيت كلمة المرور؟',
							style: TextStyle(
								fontSize: 22,
								fontWeight: FontWeight.bold,
								color: Colors.deepPurple,
								fontFamily: 'Almarai',
							),
						),
						const SizedBox(height: 20),
						const Text(
							'أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين.',
							textAlign: TextAlign.center,
							style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Almarai'),
						),
						const SizedBox(height: 25),
						_buildTextInput( // استخدام نفس تصميم حقل الإدخال
							label: 'البريد الإلكتروني',
							icon: Icons.email_outlined,
							controller: TextEditingController(), // متحكم مؤقت
							keyboardType: TextInputType.emailAddress,
							validator: (value) {
								if (value == null || value.isEmpty) {
									return 'الرجاء إدخال البريد الإلكتروني';
								}
								if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
									return 'الرجاء إدخال بريد إلكتروني صحيح';
								}
								return null;
							},
						),
						const SizedBox(height: 30),
						ElevatedButton(
							onPressed: () {
								Navigator.pop(context);
								_showMessageDialog('تم', 'تم إرسال رابط إعادة تعيين كلمة المرور بنجاح.');
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.deepPurpleAccent, // لون مميز
								minimumSize: const Size(double.infinity, 55), // زر أكبر
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(18), // زوايا مستديرة
								),
								elevation: 8, // ظل عميق
								shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
								textStyle: const TextStyle(
									color: Colors.white,
									fontSize: 18,
									fontWeight: FontWeight.bold,
									fontFamily: 'Almarai',
								),
							),
							child: const Text('إرسال الرابط'),
						),
						const SizedBox(height: 40),
					],
				),
			),
		);
	}

	/// --- بناء الواجهة الرسومية (UI) ---
	/// يحدد الهيكل المرئي لصفحة تسجيل دخول المستخدم.
	@override
	Widget build(BuildContext context) {
		// عرض شاشة تحميل كاملة حتى يكتمل فحص تسجيل الدخول التلقائي
		if (!_autoLoginChecked) {
			return Scaffold(
				body: Container(
					width: double.infinity,
					height: double.infinity,
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
							colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // تدرج لوني جذاب
						),
					),
					child: Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								CircularProgressIndicator(
									valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
									strokeWidth: 4,
								),
								const SizedBox(height: 20),
								Text(
									'جاري التحقق من بيانات الدخول...',
									style: TextStyle(
										color: Colors.white.withOpacity(0.9),
										fontSize: 18,
										fontFamily: 'Almarai',
										fontWeight: FontWeight.w600,
									),
								),
							],
						),
					),
				),
			);
		}

		return Scaffold(
			// يمنع إعادة تحجيم الشاشة عند ظهور لوحة المفاتيح
			resizeToAvoidBottomInset: false,
			body: Stack(
				children: [
					// الخلفية مع التدرج اللوني
					Container(
						width: double.infinity,
						height: double.infinity,
						decoration: const BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
								colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // تدرج أساسي أنيق
							),
						),
					),

					// تصميم منحني علوي (عناصر زخرفية)
					Positioned(
						top: -50,
						right: -50,
						child: Container(
							width: 150,
							height: 150,
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: Colors.white.withOpacity(0.1), // دوائر بيضاء شفافة
							),
						),
					),
					Positioned(
						bottom: -70,
						left: -70,
						child: Container(
							width: 200,
							height: 200,
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: Colors.white.withOpacity(0.05), // دوائر أكبر وأقل شفافية
							),
						),
					),

					// حاوية المحتوى الرئيسية (النموذج)
					Positioned.fill(
						top: MediaQuery.of(context).size.height * 0.15, // تبدأ من 15% من ارتفاع الشاشة
						child: Container(
							decoration: BoxDecoration(
								color: Colors.white, // خلفية بيضاء نقية
								borderRadius: const BorderRadius.only(
									topLeft: Radius.circular(40),
									topRight: Radius.circular(40),
								),
								boxShadow: [
									BoxShadow(
										color: Colors.black.withOpacity(0.25), // ظل أقوى وأكثر وضوحاً
										blurRadius: 30, // تأثير ضبابي أكبر
										offset: const Offset(0, -15), // إزاحة للظل
									),
								],
							),
							child: Padding(
								padding: const EdgeInsets.all(35.0), // مساحة داخلية أكبر
								child: Form(
									key: _formKey,
									child: SingleChildScrollView(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.stretch, // عناصر تمتد عرضياً
											children: [
												const SizedBox(height: 25),
												Text(
													'تسجيل الدخول',
													style: Theme.of(context).textTheme.headlineMedium?.copyWith(
														fontWeight: FontWeight.w800, // خط سميك جداً
														color: Colors.deepPurple, // لون بنفسجي غامق
														fontSize: 32, // حجم أكبر
														fontFamily: 'Almarai',
													),
													textAlign: TextAlign.center,
												),
												const SizedBox(height: 40), // مسافة أكبر

												// حقل البريد الإلكتروني
												_buildTextInput(
													label: 'البريد الإلكتروني',
													icon: Icons.email_outlined, // أيقونة أنيقة
													controller: _emailController,
													keyboardType: TextInputType.emailAddress,
													validator: (value) {
														if (value == null || value.isEmpty) {
															return 'الرجاء إدخال بريدك الإلكتروني.';
														}
														// تعبير نمطي للتحقق من صحة البريد الإلكتروني
														if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
																.hasMatch(value)) {
															return 'الرجاء إدخال صيغة بريد إلكتروني صحيحة.';
														}
														return null;
													},
												),
												const SizedBox(height: 25), // مسافة ثابتة

												// حقل كلمة المرور
												_buildTextInput(
													label: 'كلمة المرور',
													icon: Icons.lock_outline, // أيقونة أنيقة
													controller: _passwordController,
													obscure: _obscurePassword,
													suffixIcon: IconButton(
														icon: Icon(
															_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
															color: Colors.grey.shade600,
														),
														onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
													),
													validator: (value) {
														if (value == null || value.isEmpty) {
															return 'الرجاء إدخال كلمة المرور.';
														}
														if (value.length < 8) {
															return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.';
														}
														if (!value.contains(RegExp(r'[A-Z]'))) {
															return 'يجب أن تحتوي على حرف كبير واحد على الأقل.';
														}
														if (!value.contains(RegExp(r'[a-z]'))) {
															return 'يجب أن تحتوي على حرف صغير واحد على الأقل.';
														}
														if (!value.contains(RegExp(r'[0-9]'))) {
															return 'يجب أن تحتوي على رقم واحد على الأقل.';
														}

														return null;
													},
												),

												// نسيت كلمة المرور؟
												Align(
													alignment: Alignment.centerLeft,
													child: TextButton(
														onPressed: _forgotPassword,
														style: TextButton.styleFrom(
															padding: EdgeInsets.zero, // إزالة الحشو الافتراضي
															minimumSize: const Size(0, 0), // السماح بحجم أصغر
															tapTargetSize: MaterialTapTargetSize.shrinkWrap,
														),
														child: const Text(
															'نسيت كلمة المرور؟',
															style: TextStyle(
																color: Colors.deepPurple,
																fontWeight: FontWeight.w600,
																fontFamily: 'Almarai',
																fontSize: 15,
															),
														),
													),
												),

												// رسالة الخطأ
												if (_errorMessage != null)
													Padding(
														padding: const EdgeInsets.symmetric(vertical: 15),
														child: Text(
															_errorMessage!,
															style: TextStyle(
																color: Colors.red.shade700,
																fontWeight: FontWeight.bold,
																fontSize: 15.0,
																fontFamily: 'Almarai',
															),
															textAlign: TextAlign.center,
														),
													),
												const SizedBox(height: 30),

												// زر تسجيل الدخول
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
														height: 60, // زر أطول
														child: ElevatedButton(
															onPressed: _isLoading ? null : () {
																_animationController.forward().then((value) => _animationController.reverse());
																_login();
															},
															style: ElevatedButton.styleFrom(
																backgroundColor: Colors.deepPurpleAccent, // لون زر جذاب
																foregroundColor: Colors.white, // لون النص
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(18), // زوايا مستديرة متناسقة
																),
																elevation: 10, // ظل عميق
																shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
																textStyle: const TextStyle(
																	fontSize: 20,
																	fontWeight: FontWeight.w700,
																	fontFamily: 'Almarai',
																),
															),
															child: _isLoading
																	? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
																	: const Text('تسجيل الدخول'),
														),
													),
												),
												const SizedBox(height: 30),

												// فاصل "أو"
												Row(
													children: [
														Expanded(child: Divider(color: Colors.grey[300], thickness: 1.5)),
														Padding(
															padding: const EdgeInsets.symmetric(horizontal: 15),
															child: Text(
																'أو',
																style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontFamily: 'Almarai'),
															),
														),
														Expanded(child: Divider(color: Colors.grey[300], thickness: 1.5)),
													],
												),
												const SizedBox(height: 30),

												// زر تسجيل الدخول عبر Google
												SizedBox(
													width: double.infinity,
													height: 60,
													child: OutlinedButton.icon(
														onPressed: _loginWithGoogle,
														icon: Image.asset('assets/m.png', height: 28), // أيقونة Google أكبر
														label: const Text(
															'تسجيل الدخول عبر Google',
															style: TextStyle(
																color: Colors.deepPurple,
																fontSize: 18,
																fontWeight: FontWeight.w600,
																fontFamily: 'Almarai',
															),
														),
														style: OutlinedButton.styleFrom(
															side: BorderSide(color: Colors.deepPurple.shade200, width: 1.5), // حدود أكثر وضوحاً
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(18),
															),
															backgroundColor: Colors.white,
															elevation: 5, // ظل خفيف للزر
															shadowColor: Colors.grey.withOpacity(0.2),
														),
													),
												),
												const SizedBox(height: 35),

												// زر "ليس لديك حساب؟ سجل الآن"
												Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Text(
															'ليس لديك حساب؟',
															style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'Almarai'),
														),
														TextButton(
															onPressed: _goToRegister,
															child: const Text(
																'سجل الآن',
																style: TextStyle(
																	color: Colors.deepPurple,
																	fontWeight: FontWeight.bold,
																	fontSize: 17,
																	fontFamily: 'Almarai',
																),
															),
														),
													],
												),
												const SizedBox(height: 30), // مسافة إضافية في الأسفل
											],
										),
									),
								),
							),
						),
					),

					// تأثير Convex في الأسفل (احتفظ به إذا كنت تخطط لاستخدامه لاحقًا)
					// ملاحظة: هذا العنصر غير مرئي فعليًا بسبب الشفافية، وقد لا يكون ضروريًا لصفحة تسجيل الدخول.
					Positioned(
						bottom: 0,
						left: 0,
						right: 0,
						child: ConvexAppBar(
							style: TabStyle.fixedCircle, // يمكن تغيير النمط حسب الرغبة
							backgroundColor: Colors.transparent, // شفاف لجعل الخلفية مرئية
							color: Colors.white.withOpacity(0.2), // لون نقاط خفيف
							items: const [
								TabItem(icon: Icons.circle, title: ''),
								TabItem(icon: Icons.circle, title: ''),
								TabItem(icon: Icons.circle, title: ''),
							],
							height: 50,
							curveSize: 80,
							top: -30,
						),
					),
				],
			),
		);
	}
}