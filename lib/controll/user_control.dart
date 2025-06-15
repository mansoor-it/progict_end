import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart'; // لإدارة تنسيق التاريخ والوقت

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user_model.dart';
import '../service/user_server.dart';

// تعريف الألوان الرئيسية للتطبيق بشكل أكثر احترافية وجمالية
class AppColors {
	// نظام ألوان متدرج وأنيق
	static const Color primary = Color(0xFF1565C0); // أزرق داكن احترافي
	static const Color primaryLight = Color(0xFF42A5F5); // أزرق فاتح
	static const Color primaryDark = Color(0xFF0D47A1); // أزرق أغمق
	static const Color secondary = Color(0xFFE3F2FD); // أزرق فاتح جداً للخلفيات
	static const Color accent = Color(0xFF00BCD4); // سماوي للعناصر التفاعلية
	static const Color background = Color(0xFFFAFAFA); // خلفية رمادية فاتحة جداً
	static const Color surface = Color(0xFFFFFFFF); // أبيض للبطاقات والأسطح
	static const Color cardBackground = Color(0xFFFFFFFF); // أبيض للبطاقات
	static const Color textPrimary = Color(0xFF212121); // أسود داكن للنصوص الرئيسية
	static const Color textSecondary = Color(0xFF757575); // رمادي متوسط للنصوص الثانوية
	static const Color textHint = Color(0xFFBDBDBD); // رمادي فاتح للنصوص التوضيحية
	static const Color success = Color(0xFF4CAF50); // أخضر للنجاح
	static const Color warning = Color(0xFFFF9800); // برتقالي للتحذير
	static const Color error = Color(0xFFF44336); // أحمر للخطأ
	static const Color divider = Color(0xFFE0E0E0); // رمادي فاتح للفواصل
	static const Color iconColor = Color(0xFF1565C0); // لون الأيقونات أزرق داكن
	static const Color shimmerBase = Color(0xFFE0E0E0); // لون أساسي لتأثير التحميل
	static const Color shimmerHighlight = Color(0xFFF5F5F5); // لون تمييز لتأثير التحميل

	// ألوان إضافية للتدرجات والظلال
	static const Color gradientStart = Color(0xFF1976D2);
	static const Color gradientEnd = Color(0xFF42A5F5);
	static const Color shadowColor = Color(0x1A000000); // ظل خفيف
}

// تعريف أنماط النصوص المستخدمة في التطبيق بشكل أكثر احترافية
class AppTextStyles {
	static const String fontFamily = 'Roboto'; // استخدام خط احترافي

	static const TextStyle displayLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 32,
		fontWeight: FontWeight.bold,
		color: AppColors.textPrimary,
		letterSpacing: 0.5,
		height: 1.2,
	);

	static const TextStyle displayMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 28,
		fontWeight: FontWeight.bold,
		color: AppColors.textPrimary,
		letterSpacing: 0.25,
		height: 1.2,
	);

	static const TextStyle headlineLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 24,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
		letterSpacing: 0.15,
		height: 1.3,
	);

	static const TextStyle headlineMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 20,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
		letterSpacing: 0.15,
		height: 1.3,
	);

	static const TextStyle titleLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 18,
		fontWeight: FontWeight.w600,
		color: AppColors.textPrimary,
		letterSpacing: 0.1,
		height: 1.4,
	);

	static const TextStyle titleMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 16,
		fontWeight: FontWeight.w500,
		color: AppColors.textPrimary,
		letterSpacing: 0.1,
		height: 1.4,
	);

	static const TextStyle bodyLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 16,
		fontWeight: FontWeight.normal,
		color: AppColors.textPrimary,
		letterSpacing: 0.5,
		height: 1.5,
	);

	static const TextStyle bodyMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 14,
		fontWeight: FontWeight.normal,
		color: AppColors.textPrimary,
		letterSpacing: 0.25,
		height: 1.4,
	);

	static const TextStyle bodySmall = TextStyle(
		fontFamily: fontFamily,
		fontSize: 12,
		fontWeight: FontWeight.normal,
		color: AppColors.textSecondary,
		letterSpacing: 0.4,
		height: 1.3,
	);

	static const TextStyle labelLarge = TextStyle(
		fontFamily: fontFamily,
		fontSize: 14,
		fontWeight: FontWeight.w600,
		color: Colors.white,
		letterSpacing: 0.8,
		height: 1.2,
	);

	static const TextStyle labelMedium = TextStyle(
		fontFamily: fontFamily,
		fontSize: 12,
		fontWeight: FontWeight.w500,
		color: AppColors.textSecondary,
		letterSpacing: 0.5,
		height: 1.2,
	);
}

// تعريف أنماط الظلال والتأثيرات البصرية
class AppShadows {
	static const List<BoxShadow> light = [
		BoxShadow(
			color: AppColors.shadowColor,
			offset: Offset(0, 1),
			blurRadius: 3,
			spreadRadius: 0,
		),
	];

	static const List<BoxShadow> medium = [
		BoxShadow(
			color: AppColors.shadowColor,
			offset: Offset(0, 2),
			blurRadius: 6,
			spreadRadius: 0,
		),
	];

	static const List<BoxShadow> heavy = [
		BoxShadow(
			color: AppColors.shadowColor,
			offset: Offset(0, 4),
			blurRadius: 12,
			spreadRadius: 0,
		),
	];
}

class UserManagementPage extends StatefulWidget {
	const UserManagementPage({Key? key}) : super(key: key);

	@override
	State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
		with TickerProviderStateMixin {
	bool _isLoading = false;
	List<User> _users = [];
	List<User> _filteredUsers = [];
	String _searchQuery = '';
	String _statusFilter = 'all'; // 'all', 'active', 'inactive'

	late TabController _tabController;
	Animation<double>? _fadeAnimation; // تم جعلها قابلة للقيمة الفارغة
	late AnimationController _animationController;
	final TextEditingController _searchController = TextEditingController();

	@override
	void initState() {
		super.initState();
		_tabController = TabController(length: 3, vsync: this); // الكل، المفعلين، غير المفعلين
		_tabController.addListener(_handleTabSelection);

		_animationController = AnimationController(
			duration: const Duration(milliseconds: 300),
			vsync: this,
		);
		// تم تهيئة _fadeAnimation هنا
		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
		);

		_fetchUsers();
	}

	void _handleTabSelection() {
		if (_tabController.indexIsChanging) return;
		setState(() {
			_statusFilter = ['all', 'active', 'inactive'][_tabController.index];
			_applyFilters();
		});
	}

	@override
	void dispose() {
		_tabController.removeListener(_handleTabSelection);
		_tabController.dispose();
		_animationController.dispose();
		super.dispose();
	}

	Future<void> _fetchUsers() async {
		setState(() => _isLoading = true);
		try {
			// محاكاة تأخير للتحميل
			await Future.delayed(const Duration(milliseconds: 500));
			List<User> users = await UserService.getAllUsers();
			setState(() {
				_users = users;
				_applyFilters();
			});
			_animationController.forward();
		} catch (e) {
			_showSnackbar('خطأ في جلب بيانات المستخدمين: ${e.toString()}', isError: true);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _applyFilters() {
		List<User> tempUsers = List.from(_users);

		// تطبيق البحث
		if (_searchQuery.isNotEmpty) {
			tempUsers = tempUsers
					.where((user) =>
			user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
					user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
					(user.mobile?.contains(_searchQuery) ?? false))
					.toList();
		}

		// تطبيق فلتر الحالة
		if (_statusFilter != 'all') {
			tempUsers = tempUsers.where((user) => user.status == _statusFilter).toList();
		}

		setState(() {
			_filteredUsers = tempUsers;
		});
	}

	Uint8List? _decodeBase64Image(String? base64Str) {
		if (base64Str == null || base64Str.isEmpty) return null;
		try {
			String cleanBase64 = base64Str;
			if (base64Str.contains(',')) cleanBase64 = base64Str.split(',').last;
			return base64Decode(cleanBase64);
		} catch (e) {
			if (kDebugMode) {
				print('Error decoding base64 image: $e');
			}
			return null;
		}
	}

	Future<String?> _pickImage() async {
		try {
			final pickedFile = await ImagePicker().pickImage(
				source: ImageSource.gallery,
				maxWidth: 800,
				maxHeight: 800,
				imageQuality: 85,
			);
			if (pickedFile == null) return null;
			final bytes = await File(pickedFile.path).readAsBytes();
			return base64Encode(bytes);
		} catch (e) {
			_showSnackbar('خطأ في اختيار الصورة', isError: true);
			return null;
		}
	}

	void _showSnackbar(String message, {bool isError = false}) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Row(
					children: [
						Icon(
							isError ? Icons.error_outline : Icons.check_circle_outline,
							color: Colors.white,
							size: 20,
						),
						const SizedBox(width: 12),
						Expanded(
							child: Text(
								message,
								style: const TextStyle(color: Colors.white, fontSize: 14),
							),
						),
					],
				),
				backgroundColor: isError ? AppColors.error : AppColors.success,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
				margin: const EdgeInsets.all(16),
				elevation: 6,
				action: SnackBarAction(
					label: 'إغلاق',
					textColor: Colors.white70,
					onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
				),
			),
		);
	}

	void _showUserForm({User? user}) {
		final formKey = GlobalKey<FormState>();
		final nameController = TextEditingController(text: user?.name ?? '');
		final mobileController = TextEditingController(text: user?.mobile ?? '');
		final emailController = TextEditingController(text: user?.email ?? '');
		final passwordController = TextEditingController();
		String currentStatus = user?.status ?? 'active';
		String? imageBase64 = user?.image;
		bool _obscurePassword = true;

		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (context) => StatefulBuilder(
				builder: (context, setStateDialog) {
					return Dialog(
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
						elevation: 16,
						child: Container(
							constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									// Header مع تدرج لوني
									Container(
										padding: const EdgeInsets.all(24),
										decoration: BoxDecoration(
											gradient: LinearGradient(
												colors: [AppColors.gradientStart, AppColors.gradientEnd],
												begin: Alignment.topLeft,
												end: Alignment.bottomRight,
											),
											borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
										),
										child: Row(
											children: [
												Icon(
													user == null ? Icons.person_add : Icons.edit,
													color: Colors.white,
													size: 28,
												),
												const SizedBox(width: 12),
												Expanded(
													child: Text(
														user == null ? 'إضافة مستخدم جديد' : 'تعديل بيانات المستخدم',
														style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
													),
												),
												IconButton(
													icon: const Icon(Icons.close, color: Colors.white),
													onPressed: () => Navigator.pop(context),
												),
											],
										),
									),
									// Content
									Expanded(
										child: Form(
											key: formKey,
											child: SingleChildScrollView(
												padding: const EdgeInsets.all(24),
												child: Column(
													children: [
														// صورة المستخدم
														GestureDetector(
															onTap: () async {
																final pickedImage = await _pickImage();
																if (pickedImage != null) {
																	setStateDialog(() => imageBase64 = pickedImage);
																}
															},
															child: Container(
																decoration: BoxDecoration(
																	shape: BoxShape.circle,
																	boxShadow: AppShadows.medium,
																	border: Border.all(color: AppColors.primary, width: 3),
																),
																child: CircleAvatar(
																	radius: 60,
																	backgroundColor: AppColors.secondary,
																	backgroundImage: imageBase64 != null
																			? MemoryImage(_decodeBase64Image(imageBase64)!)
																			: null,
																	child: imageBase64 == null
																			? Column(
																		mainAxisAlignment: MainAxisAlignment.center,
																		children: [
																			Icon(Icons.camera_alt, size: 32, color: AppColors.primary),
																			const SizedBox(height: 4),
																			Text('اختر صورة', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
																		],
																	)
																			: null,
																),
															),
														),
														const SizedBox(height: 32),
														// حقول النموذج
														_buildFormField(
															controller: nameController,
															label: 'الاسم الكامل',
															icon: Icons.person_outline,
															validator: (value) => value?.isEmpty == true ? 'الاسم مطلوب' : null,
														),
														const SizedBox(height: 16),
														_buildFormField(
															controller: mobileController,
															label: 'رقم الجوال',
															icon: Icons.phone_outlined,
															keyboardType: TextInputType.phone,
															validator: (value) => value?.isEmpty == true ? 'رقم الجوال مطلوب' : null,
														),
														const SizedBox(height: 16),
														_buildFormField(
															controller: emailController,
															label: 'البريد الإلكتروني',
															icon: Icons.email_outlined,
															keyboardType: TextInputType.emailAddress,
															validator: (value) {
																if (value?.isEmpty == true) return 'البريد الإلكتروني مطلوب';
																if (!value!.contains('@')) return 'البريد الإلكتروني غير صحيح';
																return null;
															},
														),
														const SizedBox(height: 16),
														// حقل كلمة المرور
														_buildFormField(
															controller: passwordController,
															label: user == null ? 'كلمة المرور' : 'كلمة مرور جديدة (اختياري)',
															icon: Icons.lock_outline,
															obscureText: _obscurePassword,
															suffixIcon: IconButton(
																icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
																onPressed: () => setStateDialog(() => _obscurePassword = !_obscurePassword),
															),
															validator: user == null
																	? (value) => value?.isEmpty == true ? 'كلمة المرور مطلوبة' : null
																	: null,
														),
														const SizedBox(height: 16),
														// حقل الحالة
														Container(
															decoration: BoxDecoration(
																borderRadius: BorderRadius.circular(12),
																border: Border.all(color: AppColors.divider),
															),
															child: DropdownButtonFormField<String>(
																value: currentStatus,
																decoration: InputDecoration(
																	labelText: 'حالة الحساب',
																	prefixIcon: Icon(Icons.toggle_on_outlined, color: AppColors.iconColor),
																	border: InputBorder.none,
																	contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
																),
																items: const [
																	DropdownMenuItem(value: 'active', child: Text('مفعل')),
																	DropdownMenuItem(value: 'inactive', child: Text('غير مفعل')),
																],
																onChanged: (value) => setStateDialog(() => currentStatus = value!),
															),
														),
													],
												),
											),
										),
									),
									// Footer مع الأزرار
									Container(
										padding: const EdgeInsets.all(24),
										decoration: BoxDecoration(
											color: AppColors.background,
											borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
										),
										child: Row(
											children: [
												Expanded(
													child: TextButton(
														style: TextButton.styleFrom(
															padding: const EdgeInsets.symmetric(vertical: 16),
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
														),
														child: Text('إلغاء', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
														onPressed: () => Navigator.pop(context),
													),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 2,
													child: ElevatedButton(
														style: ElevatedButton.styleFrom(
															backgroundColor: AppColors.primary,
															foregroundColor: Colors.white,
															padding: const EdgeInsets.symmetric(vertical: 16),
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
															elevation: 2,
														),
														child: Text(user == null ? 'إضافة المستخدم' : 'حفظ التعديلات', style: AppTextStyles.labelLarge),
														onPressed: () => _saveUser(context, formKey, user, nameController, mobileController, emailController, passwordController, currentStatus, imageBase64),
													),
												),
											],
										),
									),
								],
							),
						),
					);
				},
			),
		);
	}

	Widget _buildFormField({
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
				borderRadius: BorderRadius.circular(12),
				boxShadow: AppShadows.light,
			),
			child: TextFormField(
				controller: controller,
				keyboardType: keyboardType,
				obscureText: obscureText,
				validator: validator,
				style: AppTextStyles.bodyMedium,
				decoration: InputDecoration(
					labelText: label,
					prefixIcon: Icon(icon, color: AppColors.iconColor),
					suffixIcon: suffixIcon,
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(12),
						borderSide: BorderSide(color: AppColors.divider),
					),
					focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(12),
						borderSide: BorderSide(color: AppColors.primary, width: 2),
					),
					filled: true,
					fillColor: AppColors.surface,
					contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
				),
			),
		);
	}

	Future<void> _saveUser(
			BuildContext context,
			GlobalKey<FormState> formKey,
			User? user,
			TextEditingController nameController,
			TextEditingController mobileController,
			TextEditingController emailController,
			TextEditingController passwordController,
			String currentStatus,
			String? imageBase64,
			) async {
		if (!formKey.currentState!.validate()) return;

		Navigator.pop(context);
		setState(() => _isLoading = true);

		try {
			String result;
			if (user == null) {
				// إضافة مستخدم جديد
				User newUser = User.create(
					id: '0',
					name: nameController.text,
					mobile: mobileController.text,
					email: emailController.text,
					password: passwordController.text,
					image: imageBase64 ?? '',
					status: currentStatus,
				);
				result = await UserService.addUser(newUser);
			} else {
				// تحديث مستخدم موجود
				User updatedUser = user.copyWith(
					name: nameController.text,
					mobile: mobileController.text,
					email: emailController.text,
					password: passwordController.text.isNotEmpty ? passwordController.text : user.password,
					image: imageBase64 ?? user.image,
					status: currentStatus,
				);
				result = await UserService.updateUser(updatedUser);
			}

			if (result.toLowerCase().contains('success')) {
				await _fetchUsers();
				_showSnackbar(user == null ? 'تم إضافة المستخدم بنجاح' : 'تم تحديث بيانات المستخدم بنجاح');
			} else {
				_showSnackbar('فشل ${user == null ? "الإضافة" : "التحديث"}: $result', isError: true);
			}
		} catch (e) {
			_showSnackbar('حدث خطأ: ${e.toString()}', isError: true);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _deleteUser(String id) async {
		final confirm = await showDialog<bool>(
			context: context,
			builder: (context) => AlertDialog(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				title: Row(
					children: [
						Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
						const SizedBox(width: 12),
						Text('تأكيد الحذف', style: AppTextStyles.headlineMedium),
					],
				),
				content: Text(
					'هل أنت متأكد من رغبتك في حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.',
					style: AppTextStyles.bodyMedium,
				),
				actions: [
					TextButton(
						child: Text('إلغاء', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
						onPressed: () => Navigator.pop(context, false),
					),
					ElevatedButton(
						style: ElevatedButton.styleFrom(
							backgroundColor: AppColors.error,
							foregroundColor: Colors.white,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
						),
						child: Text('حذف', style: AppTextStyles.labelLarge),
						onPressed: () => Navigator.pop(context, true),
					),
				],
			),
		);

		if (confirm != true) return;

		setState(() => _isLoading = true);
		try {
			String result = await UserService.deleteUser(id);
			if (result.toLowerCase().contains('success')) {
				await _fetchUsers();
				_showSnackbar('تم حذف المستخدم بنجاح');
			} else {
				_showSnackbar('فشل الحذف: $result', isError: true);
			}
		} catch (e) {
			_showSnackbar('حدث خطأ أثناء الحذف: ${e.toString()}', isError: true);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Widget _buildStatsCard(String title, int count, IconData icon, Color color) {
		return Expanded(
			child: Container(
				margin: const EdgeInsets.symmetric(horizontal: 4),
				padding: const EdgeInsets.all(20),
				decoration: BoxDecoration(
					color: AppColors.surface,
					borderRadius: BorderRadius.circular(16),
					boxShadow: AppShadows.light,
					border: Border.all(color: color.withOpacity(0.2), width: 1),
				),
				child: Column(
					children: [
						Container(
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: color.withOpacity(0.1),
								shape: BoxShape.circle,
							),
							child: Icon(icon, size: 28, color: color),
						),
						const SizedBox(height: 12),
						Text(
							count.toString(),
							style: AppTextStyles.displayMedium.copyWith(color: color, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 4),
						Text(
							title,
							style: AppTextStyles.bodySmall.copyWith(color: color.withOpacity(0.8)),
							textAlign: TextAlign.center,
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.background,
			appBar: AppBar(
				title: Text(
					'إدارة المستخدمين',
					style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
				),
				flexibleSpace: Container(
					decoration: BoxDecoration(
						gradient: LinearGradient(
							colors: [AppColors.gradientStart, AppColors.gradientEnd],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
					),
				),
				elevation: 0,
				systemOverlayStyle: SystemUiOverlayStyle.light,
				actions: [
					if (_isLoading && _users.isEmpty)
						const Padding(
							padding: EdgeInsets.all(16.0),
							child: SizedBox(
								width: 20,
								height: 20,
								child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
							),
						)
					else
						IconButton(
							icon: const Icon(Icons.refresh_rounded, color: Colors.white),
							tooltip: 'تحديث البيانات',
							onPressed: _isLoading ? null : _fetchUsers,
						),
				],
				bottom: TabBar(
					controller: _tabController,
					indicatorColor: Colors.white,
					indicatorWeight: 3,
					labelColor: Colors.white,
					unselectedLabelColor: Colors.white70,
					labelStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
					unselectedLabelStyle: AppTextStyles.titleMedium,
					tabs: const [
						Tab(icon: Icon(Icons.people_outline), text: 'الكل'),
						Tab(icon: Icon(Icons.verified_user_outlined), text: 'المفعلين'),
						Tab(icon: Icon(Icons.person_off_outlined), text: 'غير المفعلين'),
					],
				),
			),
			body: FadeTransition(
				opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0), // توفير قيمة احتياطية لتجنب LateInitializationError
				child: Column(
					children: [
						// قسم الإحصائيات
						Container(
							margin: const EdgeInsets.all(16),
							child: Row(
								children: [
									_buildStatsCard('الإجمالي', _users.length, Icons.people_alt_outlined, AppColors.primary),
									_buildStatsCard('المفعلين', _users.where((u) => u.status == 'active').length, Icons.check_circle_outline, AppColors.success),
									_buildStatsCard('غير المفعلين', _users.where((u) => u.status == 'inactive').length, Icons.highlight_off_outlined, AppColors.error),
								],
							),
						),
						// شريط البحث
						Container(
							margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
							decoration: BoxDecoration(
								color: AppColors.surface,
								borderRadius: BorderRadius.circular(16),
								boxShadow: AppShadows.light,
							),
							child: TextField(
								controller: _searchController,
								onChanged: (value) {
									setState(() => _searchQuery = value);
									_applyFilters();
								},
								style: AppTextStyles.bodyMedium,
								decoration: InputDecoration(
									hintText: 'ابحث بالاسم، البريد، أو رقم الجوال...',
									hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
									prefixIcon: Icon(Icons.search_rounded, color: AppColors.iconColor),
									suffixIcon: _searchQuery.isNotEmpty
											? IconButton(
										icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary),
										onPressed: () {
											_searchController.clear();
											setState(() => _searchQuery = '');
											_applyFilters();
										},
									)
											: null,
									border: InputBorder.none,
									contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
								),
							),
						),
						// عداد النتائج
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Row(
								children: [
									Text(
										'عدد النتائج: ${_filteredUsers.length}',
										style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
									),
									const Spacer(),
									if (_searchQuery.isNotEmpty || _statusFilter != 'all')
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
											decoration: BoxDecoration(
												color: AppColors.accent.withOpacity(0.1),
												borderRadius: BorderRadius.circular(20),
												border: Border.all(color: AppColors.accent.withOpacity(0.3)),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.accent),
													const SizedBox(width: 4),
													Text(
														'مفلتر',
														style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
													),
													const SizedBox(width: 4),
													InkWell(
														onTap: () {
															_searchController.clear();
															setState(() {
																_searchQuery = '';
																_statusFilter = 'all';
																_tabController.animateTo(0);
															});
															_applyFilters();
														},
														child: Icon(Icons.close, size: 16, color: AppColors.accent),
													),
												],
											),
										),
								],
							),
						),
						const SizedBox(height: 16),
						// قائمة المستخدمين
						Expanded(
							child: _isLoading && _users.isEmpty
									? _buildShimmerLoading()
									: _filteredUsers.isEmpty
									? _buildEmptyState()
									: _buildUserGrid(),
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => _showUserForm(),
				backgroundColor: AppColors.accent,
				foregroundColor: Colors.white,
				icon: const Icon(Icons.add_rounded),
				label: Text('إضافة مستخدم', style: AppTextStyles.labelLarge),
				elevation: 6,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
		);
	}

	Widget _buildShimmerLoading() {
		return GridView.builder(
			padding: const EdgeInsets.all(16),
			gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
				maxCrossAxisExtent: 380,
				childAspectRatio: 0.8,
				crossAxisSpacing: 16,
				mainAxisSpacing: 16,
				mainAxisExtent: 320,
			),
			itemCount: 6,
			itemBuilder: (context, index) {
				return Container(
					decoration: BoxDecoration(
						color: AppColors.shimmerBase,
						borderRadius: BorderRadius.circular(16),
					),
					child: Padding(
						padding: const EdgeInsets.all(16.0),
						child: Column(
							children: [
								CircleAvatar(radius: 40, backgroundColor: AppColors.shimmerHighlight),
								const SizedBox(height: 16),
								Container(width: 120, height: 16, color: AppColors.shimmerHighlight),
								const SizedBox(height: 8),
								Container(width: 150, height: 12, color: AppColors.shimmerHighlight),
								const SizedBox(height: 8),
								Container(width: 100, height: 12, color: AppColors.shimmerHighlight),
								const Spacer(),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: [
										Container(width: 70, height: 32, color: AppColors.shimmerHighlight),
										Container(width: 70, height: 32, color: AppColors.shimmerHighlight),
									],
								),
							],
						),
					),
				);
			},
		);
	}

	Widget _buildEmptyState() {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Container(
						padding: const EdgeInsets.all(24),
						decoration: BoxDecoration(
							color: AppColors.textHint.withOpacity(0.1),
							shape: BoxShape.circle,
						),
						child: Icon(
							_searchQuery.isNotEmpty || _statusFilter != 'all'
									? Icons.search_off_rounded
									: Icons.people_outline_rounded,
							size: 64,
							color: AppColors.textHint,
						),
					),
					const SizedBox(height: 24),
					Text(
						_searchQuery.isNotEmpty || _statusFilter != 'all'
								? 'لا يوجد مستخدمين يطابقون معايير البحث أو الفلترة'
								: 'لا يوجد مستخدمين لعرضهم حالياً',
						textAlign: TextAlign.center,
						style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
					),
					if (_searchQuery.isEmpty && _statusFilter == 'all') ...[
						const SizedBox(height: 16),
						ElevatedButton.icon(
							icon: const Icon(Icons.add_rounded),
							label: const Text('إضافة مستخدم جديد'),
							style: ElevatedButton.styleFrom(
								backgroundColor: AppColors.accent,
								foregroundColor: Colors.white,
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							),
							onPressed: () => _showUserForm(),
						),
					]
				],
			),
		);
	}

	Widget _buildUserGrid() {
		return GridView.builder(
			padding: const EdgeInsets.all(16),
			gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
				maxCrossAxisExtent: 380,
				childAspectRatio: 0.8,
				crossAxisSpacing: 16,
				mainAxisSpacing: 16,
				mainAxisExtent: 320,
			),
			itemCount: _filteredUsers.length,
			itemBuilder: (context, index) {
				final user = _filteredUsers[index];
				final imageBytes = _decodeBase64Image(user.image);

				return Container(
					decoration: BoxDecoration(
						color: AppColors.surface,
						borderRadius: BorderRadius.circular(16),
						boxShadow: AppShadows.medium,
						border: Border.all(color: AppColors.divider.withOpacity(0.5)),
					),
					child: Material(
						color: Colors.transparent,
						child: InkWell(
							onTap: () => _showUserDetailsDialog(user),
							borderRadius: BorderRadius.circular(16),
							child: Padding(
								padding: const EdgeInsets.all(16),
								child: Column(
									children: [
										// صورة المستخدم
										Hero(
											tag: 'user_avatar_${user.id}',
											child: Container(
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													boxShadow: AppShadows.light,
													border: Border.all(
														color: user.status == 'active' ? AppColors.success : AppColors.error,
														width: 3,
													),
												),
												child: CircleAvatar(
													radius: 40,
													backgroundColor: AppColors.secondary,
													backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
													child: imageBytes == null
															? Icon(Icons.person_outline_rounded, size: 40, color: AppColors.primary.withOpacity(0.7))
															: null,
												),
											),
										),
										const SizedBox(height: 16),
										// اسم المستخدم
										Text(
											user.name,
											style: AppTextStyles.titleLarge,
											textAlign: TextAlign.center,
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
										const SizedBox(height: 4),
										// البريد الإلكتروني
										Text(
											user.email,
											style: AppTextStyles.bodySmall,
											textAlign: TextAlign.center,
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
										// رقم الجوال
										if (user.mobile != null && user.mobile!.isNotEmpty) ...[
											const SizedBox(height: 2),
											Text(
												user.mobile!,
												style: AppTextStyles.bodySmall,
												textAlign: TextAlign.center,
											),
										],
										const SizedBox(height: 12),
										// حالة المستخدم
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
											decoration: BoxDecoration(
												color: (user.status == 'active' ? AppColors.success : AppColors.error).withOpacity(0.1),
												borderRadius: BorderRadius.circular(20),
												border: Border.all(
													color: (user.status == 'active' ? AppColors.success : AppColors.error).withOpacity(0.3),
												),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Icon(
														user.status == 'active' ? Icons.check_circle : Icons.cancel,
														size: 16,
														color: user.status == 'active' ? AppColors.success : AppColors.error,
													),
													const SizedBox(width: 4),
													Text(
														user.status == 'active' ? 'مفعل' : 'غير مفعل',
														style: AppTextStyles.labelMedium.copyWith(
															color: user.status == 'active' ? AppColors.success : AppColors.error,
															fontWeight: FontWeight.w600,
														),
													),
												],
											),
										),
										const Spacer(),
										// أزرار التعديل والحذف
										Row(
											children: [
												Expanded(
													child: _actionButton(
														Icons.edit_outlined,
														'تعديل',
														AppColors.accent,
																() => _showUserForm(user: user),
													),
												),
												const SizedBox(width: 8),
												Expanded(
													child: _actionButton(
														Icons.delete_outline,
														'حذف',
														AppColors.error,
																() => _deleteUser(user.id),
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
			},
		);
	}

	Widget _actionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
		return ElevatedButton.icon(
			icon: Icon(icon, size: 16),
			label: Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
			style: ElevatedButton.styleFrom(
				backgroundColor: color,
				foregroundColor: Colors.white,
				padding: const EdgeInsets.symmetric(vertical: 8),
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
				elevation: 2,
			),
			onPressed: onPressed,
		);
	}

	void _showUserDetailsDialog(User user) {
		final imageBytes = _decodeBase64Image(user.image);
		showDialog(
			context: context,
			builder: (context) => Dialog(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
				elevation: 16,
				child: Container(
					constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							// Header مع صورة المستخدم
							Container(
								padding: const EdgeInsets.all(24),
								decoration: BoxDecoration(
									gradient: LinearGradient(
										colors: [AppColors.gradientStart, AppColors.gradientEnd],
										begin: Alignment.topLeft,
										end: Alignment.bottomRight,
									),
									borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
								),
								child: Column(
									children: [
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												Text('تفاصيل المستخدم', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
												IconButton(
													icon: const Icon(Icons.close, color: Colors.white),
													onPressed: () => Navigator.pop(context),
												),
											],
										),
										const SizedBox(height: 16),
										Hero(
											tag: 'user_avatar_${user.id}',
											child: CircleAvatar(
												radius: 50,
												backgroundColor: Colors.white.withOpacity(0.2),
												backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
												child: imageBytes == null
														? Icon(Icons.person_outline_rounded, size: 50, color: Colors.white.withOpacity(0.8))
														: null,
											),
										),
										const SizedBox(height: 12),
										Text(user.name, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
									],
								),
							),
							// Content
							Expanded(
								child: SingleChildScrollView(
									padding: const EdgeInsets.all(24),
									child: Column(
										children: [
											_buildDetailRow(Icons.email_outlined, 'البريد الإلكتروني:', user.email),
											if (user.mobile != null && user.mobile!.isNotEmpty)
												_buildDetailRow(Icons.phone_outlined, 'رقم الجوال:', user.mobile!),
											_buildDetailRow(
												Icons.toggle_on_outlined,
												'حالة الحساب:',
												user.status == 'active' ? 'مفعل' : 'غير مفعل',
												valueColor: user.status == 'active' ? AppColors.success : AppColors.error,
											),
											_buildDetailRow(Icons.calendar_today_outlined, 'تاريخ الإنشاء:', user.createdAt ?? 'غير متوفر'),
											if (user.updatedAt != null)
												_buildDetailRow(Icons.update_outlined, 'آخر تحديث:', user.updatedAt!),
										],
									),
								),
							),
							// Footer مع الأزرار
							Container(
								padding: const EdgeInsets.all(24),
								decoration: BoxDecoration(
									color: AppColors.background,
									borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
								),
								child: Row(
									children: [
										Expanded(
											child: TextButton(
												style: TextButton.styleFrom(
													padding: const EdgeInsets.symmetric(vertical: 12),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
												),
												child: Text('إغلاق', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
												onPressed: () => Navigator.pop(context),
											),
										),
										const SizedBox(width: 16),
										Expanded(
											child: ElevatedButton.icon(
												icon: const Icon(Icons.edit_outlined, size: 18),
												label: const Text('تعديل'),
												style: ElevatedButton.styleFrom(
													backgroundColor: AppColors.accent,
													foregroundColor: Colors.white,
													padding: const EdgeInsets.symmetric(vertical: 12),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
												),
												onPressed: () {
													Navigator.pop(context);
													_showUserForm(user: user);
												},
											),
										),
									],
								),
							),
						],
					),
				),
			),
		);
	}

	Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
		return Container(
			margin: const EdgeInsets.only(bottom: 16),
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: AppColors.background,
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: AppColors.divider.withOpacity(0.5)),
			),
			child: Row(
				children: [
					Container(
						padding: const EdgeInsets.all(8),
						decoration: BoxDecoration(
							color: AppColors.iconColor.withOpacity(0.1),
							borderRadius: BorderRadius.circular(8),
						),
						child: Icon(icon, size: 20, color: AppColors.iconColor),
					),
					const SizedBox(width: 16),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label, style: AppTextStyles.labelMedium),
								const SizedBox(height: 4),
								Text(
									value,
									style: AppTextStyles.bodyMedium.copyWith(
										color: valueColor ?? AppColors.textPrimary,
										fontWeight: FontWeight.w500,
									),
								),
							],
						),
					),
				],
			),
		);
	}
}

