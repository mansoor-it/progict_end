import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/viw/login.dart';
import '../model/user_model.dart';
import '../service/user_server.dart';

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

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('الصفحة الرئيسية')),
			drawer: Drawer(
				child: Column(
					children: [
						UserAccountsDrawerHeader(
							currentAccountPicture: _userImage.isNotEmpty
									? CircleAvatar(
								backgroundImage:
								MemoryImage(_decodeBase64Image(_userImage) ?? Uint8List(0)),
							)
									: const CircleAvatar(child: Icon(Icons.person)),
							accountName: Text(_userName),
							accountEmail: Text(_userEmail),
						),
						ListTile(
							leading: const Icon(Icons.person),
							title: const Text('ملفي الشخصي'),
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
													image: _userImage,
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
										),
									),
								);
							},
						),
						const Divider(),
						ListTile(
							leading: const Icon(Icons.logout, color: Colors.red),
							title: const Text('تسجيل الخروج'),
							onTap: _logout,
						),
					],
				),
			),
			body: const Center(child: Text('مرحبًا بك في الصفحة الرئيسية!')),
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
	});

	@override
	State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
	late String _name;
	late String _mobile;
	late String _emailVerifiedAt;
	late String _password;

	@override
	void initState() {
		super.initState();
		_name = widget.name;
		_mobile = widget.mobile;
		_emailVerifiedAt = widget.emailVerifiedAt;
		_password = widget.password;
	}

	Uint8List? _decodeBase64Image(String base64Image) {
		try {
			return base64Decode(base64Image);
		} catch (_) {
			return null;
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
				title: const Text('تعديل البيانات'),
				content: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextField(
								controller: _nameController,
								decoration:
								const InputDecoration(labelText: 'الاسم الكامل'),
							),
							TextField(
								controller: _mobileController,
								keyboardType: TextInputType.phone,
								decoration:
								const InputDecoration(labelText: 'رقم الجوال'),
							),
							TextField(
								controller: _passwordController,
								obscureText: true,
								decoration:
								const InputDecoration(labelText: 'كلمة المرور'),
							),
							TextField(
								controller: _emailVerifiedController,
								decoration: const InputDecoration(
										labelText: 'تم التحقق من البريد'),
							),
						],
					),
				),
				actions: [
					TextButton(
						onPressed: () {
							Navigator.of(context).pop();
						},
						child: const Text('إلغاء'),
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
						child: const Text('حفظ'),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('ملفي الشخصي')),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						if (widget.image.isNotEmpty)
							CircleAvatar(
								radius: 60,
								backgroundImage: MemoryImage(
										_decodeBase64Image(widget.image) ?? Uint8List(0)),
							),
						const SizedBox(height: 16),
						_buildTile('الاسم الكامل', _name),
						_buildTile('البريد الإلكتروني', widget.email),
						_buildTile('رقم الجوال', _mobile),
						_buildTile('تم التحقق من البريد', _emailVerifiedAt),
						_buildTile('كلمة المرور', _password),
						_buildTile('تاريخ الإنشاء', widget.createdAt),
						_buildTile('آخر تحديث', widget.updatedAt),
						const SizedBox(height: 20),
						ElevatedButton.icon(
							onPressed: _showEditDialog,
							icon: const Icon(Icons.edit),
							label: const Text('تعديل البيانات'),
						),
					],
				),
			),
		);
	}

	Widget _buildTile(String label, String value) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: Row(
				children: [
					Text(
						'$label: ',
						style: const TextStyle(
								fontWeight: FontWeight.bold, fontSize: 16),
					),
					Expanded(
						child: Text(
							value.isNotEmpty ? value : 'غير متوفر',
							style: const TextStyle(fontSize: 16),
						),
					),
				],
			),
		);
	}
}
