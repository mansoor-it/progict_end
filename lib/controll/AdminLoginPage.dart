import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomeDrawerScaffold.dart';
import '../HomeDrawer_Admin.dart';
import '../home.dart';
import '../model/admin_model.dart';
import '../service/admin_server.dart';

/// --- Admin Login Page ---
/// واجهة تسجيل دخول إدارية أنيقة وآمنة.
/// مصممة لتوفير تجربة مستخدم ممتازة مع تحقق قوي من البيانات.
class AdminLoginPage extends StatefulWidget {
	const AdminLoginPage({super.key});

	@override
	State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
	// --- عناصر التحكم في النموذج والإدخال ---
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	// --- متغيرات حالة الواجهة الرسومية (UI) ---
	bool _isLoading = false;
	bool _obscurePassword = true;
	String? _errorMessage;

	/// --- دورة حياة الويدجت: التهيئة ---
	/// يتم استدعاؤها مرة واحدة عند إدراج الويدجت في شجرة الويدجت.
	/// تبدأ بالتحقق من بيانات تسجيل الدخول المحفوظة مسبقًا.
	@override
	void initState() {
		super.initState();
		_checkSavedLogin();
	}

	/// --- التحقق من تسجيل الدخول التلقائي ---
	/// تحاول تسجيل دخول المسؤول تلقائيًا إذا تم العثور على بيانات اعتماد صالحة
	/// (البريد الإلكتروني ورمز الوصول) في التفضيلات المشتركة.
	Future<void> _checkSavedLogin() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		String? email = prefs.getString('email');
		String? accessToken = prefs.getString('access_token');

		if (email != null && accessToken != null) {
			setState(() => _isLoading = true); // إظهار مؤشر التحميل
			final admin = await AdminService.getAdminByEmail(email);

			// التحقق من حالة المسؤول ورمز الوصول لتسجيل الدخول التلقائي
			if (admin != null && admin.accessToken == accessToken && admin.status == 'active') {
				_goToHome(admin); // الانتقال إلى الصفحة الرئيسية للمسؤول
			} else {
				setState(() => _isLoading = false); // إخفاء التحميل عند الفشل
			}
		}
	}

	/// --- حفظ بيانات المسؤول ---
	/// يحفظ تفاصيل المسؤول الأساسية في التفضيلات المشتركة
	/// لتسجيل الدخول التلقائي المستقبلي وإدارة الجلسات.
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

	/// --- عرض رسالة حوارية ---
	/// يعرض مربع حوار أنيقًا لعرض رسائل النجاح أو الخطأ
	/// للمستخدم.
	Future<void> _showMessageDialog(String title, String message, {bool isError = false}) async {
		return showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(
					title,
					style: TextStyle(
							color: isError ? Colors.red.shade700 : Colors.green.shade700,
							fontWeight: FontWeight.bold,
							fontFamily: 'Almarai'), // خط أكثر جاذبية
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
							style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: 'Almarai'),
						),
					),
				],
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
				elevation: 10.0,
			),
		);
	}

	/// --- منطق تسجيل الدخول الأساسي ---
	/// يتعامل مع عملية تسجيل دخول المستخدم: التحقق، استدعاء API،
	/// إدارة الحالة، والتنقل.
	Future<void> _login() async {
		FocusScope.of(context).unfocus(); // إخفاء لوحة المفاتيح

		if (!_formKey.currentState!.validate()) return; // التحقق من صحة مدخلات النموذج

		setState(() {
			_isLoading = true; // إظهار التحميل
			_errorMessage = null; // مسح الأخطاء السابقة
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

				await _saveAdminToPrefs(admin); // حفظ بيانات المسؤول
				SharedPreferences prefs = await SharedPreferences.getInstance();
				await prefs.setString('login_method', 'manual'); // تحديد طريقة تسجيل الدخول

				await _showMessageDialog('نجاح', 'تم تسجيل الدخول بنجاح');
				_goToHome(admin); // الانتقال إلى الصفحة الرئيسية
			} else {
				setState(() {
					_errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
				});
			}
		} catch (e) {
			// التعامل مع أخطاء الشبكة أو الأخطاء الأخرى بشكل أنيق
			setState(() {
				_errorMessage = e.toString().contains('SocketException')
						? 'تحقق من اتصال الإنترنت'
						: 'حدث خطأ أثناء تسجيل الدخول';
			});
		} finally {
			setState(() => _isLoading = false); // إخفاء التحميل دائمًا
		}
	}

	/// --- الانتقال إلى الصفحة الرئيسية ---
	/// يستبدل صفحة تسجيل الدخول الحالية بشاشة المسؤول الرئيسية.
	void _goToHome(Admin admin) {
		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) => const HomeDrawerAdmin()),
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
				prefixIcon: Icon(icon, color: Colors.deepPurple.shade300), // لون أيقونة مميز
				suffixIcon: suffixIcon,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(15), // زوايا أكثر استدارة
					borderSide: BorderSide(color: Colors.deepPurple.shade100, width: 1.5),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(15),
					borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(15),
					borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.5), // تسليط ضوء أقوى عند التركيز
				),
				errorBorder: OutlineInputBorder( //border for error
					borderRadius: BorderRadius.circular(15),
					borderSide: const BorderSide(color: Colors.red, width: 2.0),
				),
				focusedErrorBorder: OutlineInputBorder( //border for error when focused
					borderRadius: BorderRadius.circular(15),
					borderSide: const BorderSide(color: Colors.red, width: 2.5),
				),
				filled: true,
				fillColor: Colors.white.withOpacity(0.9), // خلفية بيضاء شفافة قليلاً
				contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0), // مساحة داخلية أكبر
				labelStyle: TextStyle(color: Colors.grey.shade600, fontFamily: 'Almarai'),
				hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Almarai'),
			),
			validator: validator,
			textInputAction: TextInputAction.next,
			cursorColor: Colors.deepPurpleAccent, // لون المؤشر
			style: const TextStyle(fontSize: 17.0, color: Colors.black87, fontFamily: 'Almarai'),
		);
	}

	/// --- بناء الواجهة الرسومية (UI) ---
	/// يحدد الهيكل المرئي لصفحة تسجيل دخول المسؤول.
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.deepPurple.shade50, // لون خلفية بنفسجي فاتح وهادئ
			appBar: AppBar(
				title: const Text(
					'تسجيل دخول المسؤول',
					style: TextStyle(
						color: Colors.white,
						fontWeight: FontWeight.bold,
						fontSize: 24, // حجم خط أكبر
						fontFamily: 'Almarai', // استخدام خط مخصص
						letterSpacing: 0.8, // تباعد بين الأحرف
					),
				),
				centerTitle: true,
				backgroundColor: Colors.deepPurple, // لون بنفسجي داكن وثري لشريط التطبيق
				elevation: 12.0, // ظل أعمق لشريط التطبيق
				shadowColor: Colors.black.withOpacity(0.4),
				shape: const RoundedRectangleBorder(
					borderRadius: BorderRadius.vertical(
						bottom: Radius.circular(30), // زوايا سفلية مستديرة لشريط التطبيق
					),
				),
			),
			body: Center( // توسيط المحتوى
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0), // زيادة المساحة الهامشية
					child: Form(
						key: _formKey,
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center, // توسيط عمودي
							children: [
								// --- قسم الشعار ---
								Container(
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										gradient: LinearGradient( // تدرج لوني للشعار
											colors: [Colors.deepPurple.shade400, Colors.deepPurpleAccent.shade100],
											begin: Alignment.topLeft,
											end: Alignment.bottomRight,
										),
										boxShadow: [
											BoxShadow(
												color: Colors.black.withOpacity(0.3),
												blurRadius: 20,
												offset: const Offset(0, 10),
											),
										],
									),
									child: ClipOval(
										child: Image.asset(
											'assets/logo.jpg',
											height: 180, // شعار أكبر قليلاً
											width: 180,
											fit: BoxFit.cover,
										),
									),
								),
								const SizedBox(height: 50), // مسافة أكبر بعد الشعار

								// --- حقل إدخال البريد الإلكتروني ---
								_buildTextInput(
									label: 'البريد الإلكتروني',
									icon: Icons.email_outlined, // أيقونة أنيقة
									controller: _emailController,
									keyboardType: TextInputType.emailAddress,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'الرجاء إدخال البريد الإلكتروني';
										}
										// التحقق من صحة صيغة البريد الإلكتروني
										if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
											return 'الرجاء إدخال بريد إلكتروني صحيح';
										}
										return null;
									},
								),
								const SizedBox(height: 25), // مسافة ثابتة

								// --- حقل إدخال كلمة المرور ---
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
											return 'الرجاء إدخال كلمة المرور';
										}
										// التحقق من قوة كلمة المرور
										if (value.length < 8) {
											return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
										}
										if (!value.contains(RegExp(r'[A-Z]'))) {
											return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
										}
										if (!value.contains(RegExp(r'[a-z]'))) {
											return 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';
										}
										if (!value.contains(RegExp(r'[0-9]'))) {
											return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
										}

										return null;
									},
								),

								// --- عرض رسالة الخطأ ---
								if (_errorMessage != null)
									Padding(
										padding: const EdgeInsets.only(top: 25, bottom: 15),
										child: Text(
											_errorMessage!,
											style: TextStyle(
												color: Colors.red.shade700,
												fontWeight: FontWeight.bold,
												fontSize: 16.0,
												fontFamily: 'Almarai',
											),
											textAlign: TextAlign.center,
										),
									),
								const SizedBox(height: 40), // مسافة قبل الزر

								// --- زر تسجيل الدخول ---
								SizedBox(
									width: double.infinity,
									height: 60, // زر أطول
									child: ElevatedButton(
										onPressed: _isLoading ? null : _login,
										style: ElevatedButton.styleFrom(
											backgroundColor: Colors.deepPurpleAccent, // لون زر مميز
											foregroundColor: Colors.white, // لون النص
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(15), // زوايا مستديرة متناسقة
											),
											elevation: 10.0, // ظل عميق للزر
											shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
											textStyle: const TextStyle(
												fontFamily: 'Almarai', // خط مخصص
												fontSize: 20, // حجم خط أكبر
												fontWeight: FontWeight.w700, // خط سميك
											),
										),
										child: _isLoading
												? const Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												SizedBox(
													width: 30, // مؤشر تحميل أكبر
													height: 30,
													child: CircularProgressIndicator(
														color: Colors.white,
														strokeWidth: 4, // سمك أكبر للمؤشر
													),
												),
												SizedBox(width: 20),
												Text('جارٍ تسجيل الدخول...'),
											],
										)
												: const Text('تسجيل الدخول'),
									),
								),
							],
						),
					),
				),
			),
		);
	}
}