import 'dart:convert';
import 'dart:typed_data';
import 'dart:io'; // أضيفت
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // أضيفت
import 'package:untitled2/viw/login.dart';
import '../model/user_model.dart';
import '../service/user_server.dart';
import 'AboutUsPage.dart';
import 'Support or Help.dart';

// ألوان التصميم
const Color primaryBrown = Color(0xFF795548);
const Color accentBrown = Color(0xFF5D4037);
const Color lightBrown = Color(0xFFD7CCC8);
const Color darkBrown = Color(0xFF4E342E);

class HomeDrawerScaffold extends StatefulWidget {
	const HomeDrawerScaffold({super.key});

	@override
	State<HomeDrawerScaffold> createState() => _HomeDrawerScaffoldState();
}

class _HomeDrawerScaffoldState extends State<HomeDrawerScaffold> {
	String _userName = '';
	String _userEmail = '';
	String _userImage = '';

	// البيانات الإضافية
	String _userId = '';
	String _mobile = '';
	String _password = '';
	String _status = '';
	String _emailVerifiedAt = '';
	String _rememberToken = '';
	String _accessToken = '';
	String _createdAt = '';
	String _updatedAt = '';

	@override
	void initState() {
		super.initState();
		_loadUserData();
	}

	Future<void> _loadUserData() async {
		final prefs = await SharedPreferences.getInstance();

		setState(() {
			_userId = prefs.getString('id') ?? '';
			_userName = prefs.getString('name') ?? 'الاسم غير متوفر';
			_userEmail = prefs.getString('email') ?? 'البريد غير متوفر';
			_userImage = prefs.getString('image') ?? '';
			_mobile = prefs.getString('mobile') ?? '';
			_password = prefs.getString('password') ?? '';
			_status = prefs.getString('status') ?? '';
			_emailVerifiedAt = prefs.getString('email_verified_at') ?? '';
			_rememberToken = prefs.getString('remember_token') ?? '';
			_accessToken = prefs.getString('access_token') ?? '';
			_createdAt = prefs.getString('created_at') ?? '';
			_updatedAt = prefs.getString('updated_at') ?? '';
		});
	}

	void _logout() async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.clear();
		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (context) => LoginPage()),
		);
	}

	Uint8List? _decodeBase64Image(String base64Image) {
		try {
			return base64Decode(base64Image);
		} catch (_) {
			return null;
		}
	}

	// أضيفت: دالة تحديث الصورة
	Future<void> _updateUserImage(String newImageBase64) async {
		User updatedUser = User(
			id: _userId,
			name: _userName,
			mobile: _mobile,
			email: _userEmail,
			password: _password,
			image: newImageBase64,
			status: _status,
			emailVerifiedAt: _emailVerifiedAt,
			rememberToken: _rememberToken,
			accessToken: _accessToken,
			createdAt: _createdAt,
			updatedAt: DateTime.now().toIso8601String(),
		);

		String result = await UserService.updateUser(updatedUser);
		if (!result.toLowerCase().contains('success')) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('فشل تحديث الصورة في السيرفر'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		final prefs = await SharedPreferences.getInstance();
		await prefs.setString('image', newImageBase64);

		setState(() {
			_userImage = newImageBase64;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('الصفحة الرئيسية', style: TextStyle(color: Colors.white)),
				backgroundColor: primaryBrown,
				iconTheme: const IconThemeData(color: Colors.white),
			),
			drawer: Drawer(
				backgroundColor: primaryBrown,
				shape: const RoundedRectangleBorder(
					borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
					side: BorderSide(color: Colors.white, width: 2.0),
				),
				child: ListView(
					children: [
						UserAccountsDrawerHeader(
							decoration: const BoxDecoration(
								color: darkBrown,
								border: Border(bottom: BorderSide(color: Colors.white, width: 1.0)),
							),
							currentAccountPicture: _userImage.isNotEmpty
									? CircleAvatar(
								backgroundColor: Colors.transparent,
								backgroundImage:
								MemoryImage(_decodeBase64Image(_userImage) ?? Uint8List(0)),
							)
									: const CircleAvatar(
									backgroundColor: lightBrown,
									child: Icon(Icons.person, size: 40, color: darkBrown)),
							accountName: Text(
								_userName,
								style: const TextStyle(
									color: Colors.white,
									fontWeight: FontWeight.bold,
									fontSize: 18,
								),
							),
							accountEmail: Text(
								_userEmail,
								style: const TextStyle(
									color: lightBrown,
									fontSize: 14,
								),
							),
						),
						const Divider(color: Colors.white, height: 1, thickness: 0.5),
						ListTile(
							leading: const Icon(Icons.account_circle, color: Colors.white, size: 28),
							title: const Text('ملفي الشخصي', style: TextStyle(color: Colors.white, fontSize: 16)),
							onTap: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (_) => UserProfilePage(
											userId: _userId,
											name: _userName,
											email: _userEmail,
											mobile: _mobile,
											emailVerifiedAt: _emailVerifiedAt,
											password: _password,
											image: _userImage,
											createdAt: _createdAt,
											updatedAt: _updatedAt,
											onUserUpdated:
													(newName, newMobile, newPassword, newEmailVerifiedAt) async {
												// أولاً: أرسل التحديث إلى السيرفر عبر UserService.updateUser
												User updatedUser = User(
													id: _userId,
													name: newName,
													mobile: newMobile,
													email: _userEmail,
													password: newPassword,
													image: _userImage, // تم تحديثها لاحقاً
													status: _status,
													emailVerifiedAt: newEmailVerifiedAt,
													rememberToken: _rememberToken,
													accessToken: _accessToken,
													createdAt: _createdAt,
													updatedAt: DateTime.now().toIso8601String(),
												);
												String result = await UserService.updateUser(updatedUser);
												if (!result.toLowerCase().contains('success')) {
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(
															content: Text('فشل التحديث في السيرفر'),
															backgroundColor: Colors.red,
														),
													);
													return;
												}

												// ثم حدّث SharedPreferences
												final prefs = await SharedPreferences.getInstance();
												await prefs.setString('name', newName);
												await prefs.setString('mobile', newMobile);
												await prefs.setString('password', newPassword);
												await prefs.setString('email_verified_at', newEmailVerifiedAt);
												await prefs.setString(
														'updated_at', updatedUser.updatedAt ?? '');

												// حدّث بيانات الواجهة
												setState(() {
													_userName = newName;
													_mobile = newMobile;
													_password = newPassword;
													_emailVerifiedAt = newEmailVerifiedAt;
													_updatedAt = updatedUser.updatedAt ?? '';
												});
											},
											onImageUpdated: _updateUserImage, // أضيفت
										),
									),
								);
							},
						),
						const Divider(color: Colors.white, height: 1, thickness: 0.5),
						ListTile(
							leading: const Icon(Icons.support_agent, color: Colors.white, size: 28),
							title: const Text('الدعم', style: TextStyle(color: Colors.white, fontSize: 16)),
							onTap: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (_) => SupportPage()),
								);
							},
						),
						const Divider(color: Colors.white, height: 1, thickness: 0.5),
						ListTile(
							leading: const Icon(Icons.info, color: Colors.white, size: 28),
							title: const Text('من نحن', style: TextStyle(color: Colors.white, fontSize: 16)),
							onTap: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (_) => AboutUsPage()),
								);
							},
						),
						const Divider(color: Colors.white, height: 1, thickness: 0.5),
						ListTile(
							leading: const Icon(Icons.logout, color: Colors.red, size: 28),
							title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontSize: 16)),
							onTap: _logout,
						),
					],
				),
			),
			body: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [lightBrown, Colors.white],
					),
				),
				child: const Center(
					child: Text(
						'مرحبًا بك في الصفحة الرئيسية!',
						style: TextStyle(
							fontSize: 24,
							fontWeight: FontWeight.bold,
							color: darkBrown,
						),
					),
				),
			),
		);
	}
}

class UserProfilePage extends StatefulWidget {
	final String userId;
	final String name;
	final String email;
	final String mobile;
	final String emailVerifiedAt;
	final String password;
	final String image;
	final String createdAt;
	final String updatedAt;
	final Function(String, String, String, String) onUserUpdated;
	final Function(String) onImageUpdated; // أضيفت

	const UserProfilePage({
		super.key,
		required this.userId,
		required this.name,
		required this.email,
		required this.mobile,
		required this.emailVerifiedAt,
		required this.password,
		required this.image,
		required this.createdAt,
		required this.updatedAt,
		required this.onUserUpdated,
		required this.onImageUpdated, // أضيفت
	});

	@override
	State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
	late String _name;
	late String _mobile;
	late String _emailVerifiedAt;
	late String _password;
	late String _image; // أضيفت

	@override
	void initState() {
		super.initState();
		_name = widget.name;
		_mobile = widget.mobile;
		_emailVerifiedAt = widget.emailVerifiedAt;
		_password = widget.password;
		_image = widget.image; // أضيفت
	}

	Uint8List? _decodeBase64Image(String base64Image) {
		try {
			return base64Decode(base64Image);
		} catch (_) {
			return null;
		}
	}

	// أضيفت: دالة اختيار الصورة
	Future<void> _pickImage() async {
		final picker = ImagePicker();
		final pickedFile = await picker.pickImage(source: ImageSource.gallery);

		if (pickedFile != null) {
			final bytes = await pickedFile.readAsBytes();
			String base64Image = base64Encode(bytes);

			// تحديث الصورة محلياً
			setState(() {
				_image = base64Image;
			});

			// إرسال التحديث للسيرفر
			widget.onImageUpdated(base64Image);
		}
	}

	void _showEditDialog() {
		final _nameController = TextEditingController(text: _name);
		final _mobileController = TextEditingController(text: _mobile);
		final _emailVerifiedController =
		TextEditingController(text: _emailVerifiedAt);
		final _passwordController = TextEditingController(text: _password);

		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('تعديل البيانات', style: TextStyle(color: primaryBrown)),
				content: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextField(
								controller: _nameController,
								decoration: InputDecoration(
									labelText: 'الاسم الكامل',
									labelStyle: const TextStyle(color: primaryBrown),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown, width: 2),
									),
								),
							),
							const SizedBox(height: 15),
							TextField(
								controller: _mobileController,
								keyboardType: TextInputType.phone,
								decoration: InputDecoration(
									labelText: 'رقم الجوال',
									labelStyle: const TextStyle(color: primaryBrown),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown, width: 2),
									),
								),
							),
							const SizedBox(height: 15),
							TextField(
								controller: _passwordController,
								obscureText: true,
								decoration: InputDecoration(
									labelText: 'كلمة المرور',
									labelStyle: const TextStyle(color: primaryBrown),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown, width: 2),
									),
								),
							),
							const SizedBox(height: 15),
							TextField(
								controller: _emailVerifiedController,
								decoration: InputDecoration(
									labelText: 'تم التحقق من البريد',
									labelStyle: const TextStyle(color: primaryBrown),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(color: primaryBrown, width: 2),
									),
								),
							),
						],
					),
				),
				actions: [
					TextButton(
						onPressed: () {
							Navigator.of(context).pop();
						},
						child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
					),
					ElevatedButton(
						onPressed: () {
							setState(() {
								_name = _nameController.text.trim();
								_mobile = _mobileController.text.trim();
								_password = _passwordController.text.trim();
								_emailVerifiedAt = _emailVerifiedController.text.trim();
							});

							// نرسل البيانات المحدثة للخارج لحفظها في السيرفر وSharedPreferences
							widget.onUserUpdated(
									_name, _mobile, _password, _emailVerifiedAt);

							Navigator.of(context).pop();
						},
						style: ElevatedButton.styleFrom(
							backgroundColor: primaryBrown,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(10),
							),
						),
						child: const Text('حفظ', style: TextStyle(color: Colors.white)),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('ملفي الشخصي', style: TextStyle(color: Colors.white)),
				backgroundColor: primaryBrown,
				iconTheme: const IconThemeData(color: Colors.white),
			),
			body: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [lightBrown, Colors.white],
					),
				),
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						children: [
							Stack(
								alignment: Alignment.bottomRight,
								children: [
									Container(
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											border: Border.all(color: primaryBrown, width: 3),
										),
										child: CircleAvatar(
											radius: 60,
											backgroundColor: Colors.transparent,
											backgroundImage: _image.isNotEmpty
													? MemoryImage(_decodeBase64Image(_image) ?? Uint8List(0))
													: null,
											child: _image.isEmpty
													? const Icon(Icons.person, size: 60, color: primaryBrown)
													: null,
										),
									),
									Container(
										decoration: const BoxDecoration(
											shape: BoxShape.circle,
											color: primaryBrown,
										),
										child: IconButton(
											icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
											onPressed: _pickImage,
										),
									),
								],
							),
							const SizedBox(height: 20),
							_buildTile(Icons.person, 'الاسم الكامل', _name),
							_buildTile(Icons.email, 'البريد الإلكتروني', widget.email),
							_buildTile(Icons.phone, 'رقم الجوال', _mobile),
							_buildTile(Icons.verified_user, 'تم التحقق من البريد', _emailVerifiedAt),
							_buildTile(Icons.lock, 'كلمة المرور', _password),
							_buildTile(Icons.calendar_today, 'تاريخ الإنشاء', widget.createdAt),
							_buildTile(Icons.update, 'آخر تحديث', widget.updatedAt),
							const SizedBox(height: 30),
							ElevatedButton.icon(
								onPressed: _showEditDialog,
								icon: const Icon(Icons.edit, color: Colors.white),
								label: const Text('تعديل البيانات', style: TextStyle(color: Colors.white)),
								style: ElevatedButton.styleFrom(
									backgroundColor: primaryBrown,
									padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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

	Widget _buildTile(IconData icon, String label, String value) {
		return Container(
			margin: const EdgeInsets.symmetric(vertical: 8),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(10),
				border: Border.all(color: lightBrown),
				boxShadow: [
					BoxShadow(
						color: Colors.grey.withOpacity(0.2),
						spreadRadius: 1,
						blurRadius: 3,
						offset: const Offset(0, 2),
					),
				],
			),
			child: ListTile(
				leading: Icon(icon, color: primaryBrown),
				title: Text(
					label,
					style: const TextStyle(
						fontWeight: FontWeight.bold,
						fontSize: 16,
						color: darkBrown,
					),
				),
				subtitle: Text(
					value.isNotEmpty ? value : 'غير متوفر',
					style: const TextStyle(fontSize: 14, color: primaryBrown),
				),
			),
		);
	}
}