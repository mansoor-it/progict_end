import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/viw/login.dart';
import 'package:untitled2/model/admin_model.dart';
import 'package:untitled2/service/admin_server.dart';
import 'package:untitled2/home.dart';
import 'AboutUsPage.dart';
import 'Support or Help.dart';
import 'controll/AdminLoginPage.dart';


class HomeDrawerAdmin extends StatefulWidget {
	const HomeDrawerAdmin({Key? key}) : super(key: key);

	@override
	State<HomeDrawerAdmin> createState() => _HomeDrawerAdminState();
}

class _HomeDrawerAdminState extends State<HomeDrawerAdmin> {
	Admin? admin;
	bool _isLoading = true;
	bool _isEditing = false;
	final _nameController = TextEditingController();
	final _mobileController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final ImagePicker _picker = ImagePicker();
	String? _newImageBase64;

	@override
	void initState() {
		super.initState();
		_loadAdminData();
	}

	Future<void> _loadAdminData() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		String? email = prefs.getString('email');

		if (email != null) {
			final loadedAdmin = await AdminService.getAdminByEmail(email);
			if (loadedAdmin != null) {
				setState(() {
					admin = loadedAdmin;
					_nameController.text = admin!.name;
					_mobileController.text = admin!.mobile ?? '';
					_emailController.text = admin!.email;
					_passwordController.text = admin!.password;
					_isLoading = false;
				});
			}
		}
	}

	Future<void> _pickImage() async {
		final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
		if (image == null) return;

		final bytes = await File(image.path).readAsBytes();
		setState(() {
			_newImageBase64 = base64Encode(bytes);
		});
	}

	Future<void> _updateAdmin() async {
		if (admin == null) return;

		setState(() => _isLoading = true);

		try {
			Admin updatedAdmin = Admin(
				id: admin!.id,
				name: _nameController.text,
				mobile: _mobileController.text,
				email: _emailController.text,
				password: _passwordController.text,
				status: admin!.status,
				image: _newImageBase64 ?? admin!.image,
				type: admin!.type,
				vendorId: admin!.vendorId,
				confirm: admin!.confirm,
			);

			final result = await AdminService.updateAdmin(updatedAdmin);
			if (result == "تم تحديث الأدمن بنجاح") {
				await _saveAdminToPrefs(updatedAdmin);
				setState(() {
					admin = updatedAdmin;
					_isEditing = false;
					_newImageBase64 = null;
				});

				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(ScaffoldKey.currentContext!).showSnackBar(
						const SnackBar(
							content: Text('تم تحديث البيانات بنجاح'),
							backgroundColor: Colors.green,
						),
					);
				});
			} else {
				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(ScaffoldKey.currentContext!).showSnackBar(
						SnackBar(
							content: Text('خطأ في التحديث: $result'),
							backgroundColor: Colors.red,
						),
					);
				});
			}
		} catch (e) {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				ScaffoldMessenger.of(ScaffoldKey.currentContext!).showSnackBar(
					SnackBar(
						content: Text('حدث خطأ: ${e.toString()}'),
						backgroundColor: Colors.red,
					),
				);
			});
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _saveAdminToPrefs(Admin admin) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', admin.id);
		await prefs.setString('name', admin.name);
		await prefs.setString('mobile', admin.mobile ?? '');
		await prefs.setString('email', admin.email);
		await prefs.setString('password', admin.password);
		await prefs.setString('status', admin.status);
		await prefs.setString('type', admin.type);
		await prefs.setString('vendorId', admin.vendorId);
	}

	Future<void> _toggleAdminStatus() async {
		if (admin == null) return;

		setState(() => _isLoading = true);

		try {
			String newStatus = admin!.status == 'active' ? 'inactive' : 'active';

			Admin updatedAdmin = Admin(
				id: admin!.id,
				name: admin!.name,
				mobile: admin!.mobile,
				email: admin!.email,
				password: admin!.password,
				status: newStatus,
				image: admin!.image,
				type: admin!.type,
				vendorId: admin!.vendorId,
				confirm: admin!.confirm,
			);

			final result = await AdminService.updateAdmin(updatedAdmin);
			if (result == "تم تحديث الأدمن بنجاح") {
				await _saveAdminToPrefs(updatedAdmin);
				setState(() {
					admin = updatedAdmin;
				});

				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(ScaffoldKey.currentContext!).showSnackBar(
						SnackBar(
							content: Text('تم ${newStatus == 'active' ? 'تفعيل' : 'تعطيل'} الحساب'),
							backgroundColor: Colors.green,
						),
					);
				});
			} else {
				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(ScaffoldKey.currentContext!).showSnackBar(
						SnackBar(
							content: Text('خطأ في التحديث: $result'),
							backgroundColor: Colors.red,
						),
					);
				});
			}
		} catch (e) {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				ScaffoldMessenger.of(ScaffoldKey.currentContext!).showSnackBar(
					SnackBar(
						content: Text('حدث خطأ: ${e.toString()}'),
						backgroundColor: Colors.red,
					),
				);
			});
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _logout() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.clear();
		Navigator.of(context).pushAndRemoveUntil(
			MaterialPageRoute(builder: (_) => const AdminLoginPage()),
					(route) => false,
		);
	}

	Widget _buildProfileImage() {
		return Stack(
			alignment: Alignment.bottomRight,
			children: [
				CircleAvatar(
					radius: 40,
					backgroundColor: Colors.brown[100],
					backgroundImage: _buildImageProvider(),
					child: _buildImageProvider() == null
							? Text(
						admin?.name.isNotEmpty ?? false ? admin!.name[0] : 'A',
						style: const TextStyle(fontSize: 40, color: Colors.white),
					)
							: null,
				),
				if (_isEditing)
					Container(
						decoration: BoxDecoration(
							color: Colors.brown,
							shape: BoxShape.circle,
							border: Border.all(color: Colors.white, width: 2),
						),
						child: IconButton(
							icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
							onPressed: _pickImage,
						),
					),
			],
		);
	}

	ImageProvider? _buildImageProvider() {
		if (_newImageBase64 != null) {
			return MemoryImage(base64Decode(_newImageBase64!));
		} else if (admin?.image != null && admin!.image!.isNotEmpty) {
			return MemoryImage(base64Decode(admin!.image!));
		}
		return null;
	}

	Widget _buildProfileHeader() {
		return Container(
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: Colors.brown[700],
				borderRadius: const BorderRadius.only(
					bottomLeft: Radius.circular(20),
					bottomRight: Radius.circular(20),
				),
				boxShadow: [
					BoxShadow(
						color: Colors.brown.withOpacity(0.5),
						spreadRadius: 2,
						blurRadius: 7,
						offset: const Offset(0, 3),
					),
				],
			),
			child: Row(
				children: [
					_buildProfileImage(),
					const SizedBox(width: 20),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									admin?.name ?? '',
									style: const TextStyle(
										fontSize: 20,
										fontWeight: FontWeight.bold,
										color: Colors.white,
									),
								),
								const SizedBox(height: 5),
								Text(
									admin?.email ?? '',
									style: TextStyle(
										fontSize: 14,
										color: Colors.brown[200],
									),
								),
								const SizedBox(height: 5),
								Row(
									children: [
										Icon(Icons.circle, color: admin?.status == 'active' ? Colors.green : Colors.red, size: 12),
										const SizedBox(width: 5),
										Text(
											admin?.status == 'active' ? 'نشط' : 'غير نشط',
											style: TextStyle(
												fontSize: 14,
												color: Colors.brown[200],
											),
										),
									],
								),
							],
						),
					),
				],
			),
		);
	}

	Widget _buildEditableField({
		required String label,
		required TextEditingController controller,
		bool obscureText = false,
	}) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: TextFormField(
				controller: controller,
				obscureText: obscureText,
				decoration: InputDecoration(
					labelText: label,
					filled: true,
					fillColor: Colors.grey[50],
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(10),
						borderSide: BorderSide.none,
					),
					focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(10),
						borderSide: const BorderSide(color: Colors.brown),
					),
					contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
				),
			),
		);
	}

	Widget _buildActionButton({
		required String text,
		required IconData icon,
		required VoidCallback onPressed,
		Color color = Colors.brown,
	}) {
		return Container(
			margin: const EdgeInsets.symmetric(vertical: 4),
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: Colors.white,
				boxShadow: [
					BoxShadow(
						color: Colors.grey.withOpacity(0.1),
						spreadRadius: 1,
						blurRadius: 5,
						offset: const Offset(0, 2),
					),
				],
			),
			child: ListTile(
				leading: Icon(icon, color: color),
				title: Text(text),
				trailing: const Icon(Icons.arrow_forward_ios, size: 16),
				onTap: onPressed,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(10),
				),
			),
		);
	}

	static final GlobalKey<ScaffoldMessengerState> ScaffoldKey = GlobalKey<ScaffoldMessengerState>();

	@override
	Widget build(BuildContext context) {
		return Builder(
				builder: (context) {
					return Drawer(
						shape: const RoundedRectangleBorder(
							borderRadius: BorderRadius.only(
								topRight: Radius.circular(30),
								bottomRight: Radius.circular(30),
							),
						),
						child: _isLoading
								? const Center(child: CircularProgressIndicator(color: Colors.brown))
								: admin == null
								? const Center(child: Text('لا توجد بيانات'))
								: ListView(
							padding: EdgeInsets.zero,
							children: [
								_buildProfileHeader(),
								const SizedBox(height: 20),
								// أقسام التنقل الجديدة
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 16),
									child: Column(
										children: [
											_buildActionButton(
												text: 'لوجه التحكم',
												icon: Icons.home,
												onPressed: () {
													Navigator.pop(context);
													Navigator.push(context, MaterialPageRoute(builder: (_) => const NavigationHomePage()));
												},
											),
											_buildActionButton(
												text: 'من نحن',
												icon: Icons.info,
												onPressed: () {
													Navigator.pop(context);
													Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()));
												},
											),
											_buildActionButton(
												text: 'الدعم الفني',
												icon: Icons.support_agent,
												onPressed: () {
													Navigator.pop(context);
													Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage()));
												},
											),
										],
									),
								),
								const SizedBox(height: 20),
								const Divider(thickness: 1, height: 1, indent: 20, endIndent: 20),
								const SizedBox(height: 20),
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 16),
									child: Column(
										children: [
											if (_isEditing) ...[
												Padding(
													padding: const EdgeInsets.all(16),
													child: Column(
														children: [
															_buildEditableField(
																label: 'الاسم',
																controller: _nameController,
															),
															_buildEditableField(
																label: 'الجوال',
																controller: _mobileController,
															),
															_buildEditableField(
																label: 'البريد الإلكتروني',
																controller: _emailController,
															),
															_buildEditableField(
																label: 'كلمة المرور',
																controller: _passwordController,
																obscureText: true,
															),
															const SizedBox(height: 20),
															Row(
																mainAxisAlignment: MainAxisAlignment.spaceAround,
																children: [
																	ElevatedButton(
																		onPressed: () {
																			setState(() => _isEditing = false);
																			_loadAdminData();
																		},
																		style: ElevatedButton.styleFrom(
																			backgroundColor: Colors.grey,
																			shape: RoundedRectangleBorder(
																				borderRadius: BorderRadius.circular(10),
																			),
																			padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
																		),
																		child: const Text('إلغاء'),
																	),
																	ElevatedButton(
																		onPressed: _updateAdmin,
																		style: ElevatedButton.styleFrom(
																			backgroundColor: Colors.brown,
																			shape: RoundedRectangleBorder(
																				borderRadius: BorderRadius.circular(10),
																			),
																			padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
																		),
																		child: const Text('حفظ'),
																	),
																],
															),
														],
													),
												),
											] else ...[
												_buildActionButton(
													text: 'تعديل الملف الشخصي',
													icon: Icons.edit,
													onPressed: () => setState(() => _isEditing = true),
												),
												_buildActionButton(
													text: admin!.status == 'active' ? 'تعطيل الحساب' : 'تفعيل الحساب',
													icon: admin!.status == 'active' ? Icons.block : Icons.check_circle,
													onPressed: _toggleAdminStatus,
													color: admin!.status == 'active' ? Colors.orange : Colors.green,
												),
											],
											const SizedBox(height: 10),
											_buildActionButton(
												text: 'تسجيل الخروج',
												icon: Icons.logout,
												onPressed: _logout,
												color: Colors.red,
											),
										],
									),
								),
							],
						),
					);
				}
		);
	}
}