import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/service/VendorBankDetailsService.dart';

import 'package:untitled2/viw/login.dart';

import 'package:untitled2/home.dart';
import 'AboutUsPage.dart';
import 'Support or Help.dart';
import 'controll/VendorLoginPage.dart';
import 'model/vendors_model.dart';

class HomeDrawerVendor extends StatefulWidget {
	const HomeDrawerVendor({Key? key}) : super(key: key);

	@override
	State<HomeDrawerVendor> createState() => _HomeDrawerVendorState();
}

class _HomeDrawerVendorState extends State<HomeDrawerVendor> {
	Vendor? vendor;
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
		_loadVendorData();
	}

	Future<void> _loadVendorData() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		String? email = prefs.getString('email');

		if (email != null) {
			final loadedVendor = await VendorService.getVendorByEmail(email);
			if (loadedVendor != null) {
				setState(() {
					vendor = loadedVendor;
					_nameController.text = vendor!.name;
					_mobileController.text = vendor!.mobile ?? '';
					_emailController.text = vendor!.email;
					_passwordController.text = vendor!.password;
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

	Future<void> _updateVendor() async {
		if (vendor == null) return;

		setState(() => _isLoading = true);

		try {
			Vendor updatedVendor = Vendor(
				id: vendor!.id,
				name: _nameController.text,
				mobile: _mobileController.text,
				email: _emailController.text,
				password: _passwordController.text,
				status: vendor!.status,
				image: _newImageBase64 ?? vendor!.image,
				confirm: vendor!.confirm,
				commission: vendor!.commission ?? 0.0,  // هنا غيرت null إلى 0.0
			);

			final result = await VendorService.updateVendor(updatedVendor);
			if (result == "تم تحديث الفيدور بنجاح") {
				await _saveVendorToPrefs(updatedVendor);
				setState(() {
					vendor = updatedVendor;
					_isEditing = false;
					_newImageBase64 = null;
				});

				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(
							content: Text('تم تحديث البيانات بنجاح'),
							backgroundColor: Colors.green,
						),
					);
				});
			} else {
				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text('خطأ في التحديث: $result'),
							backgroundColor: Colors.red,
						),
					);
				});
			}
		} catch (e) {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				ScaffoldMessenger.of(context).showSnackBar(
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

	Future<void> _saveVendorToPrefs(Vendor vendor) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('id', vendor.id);
		await prefs.setString('name', vendor.name);
		await prefs.setString('mobile', vendor.mobile ?? '');
		await prefs.setString('email', vendor.email);
		await prefs.setString('password', vendor.password);
		await prefs.setString('status', vendor.status);
	}

	Future<void> _toggleVendorStatus() async {
		if (vendor == null) return;

		setState(() => _isLoading = true);

		try {
			String newStatus = vendor!.status == 'active' ? 'inactive' : 'active';

			Vendor updatedVendor = Vendor(
				id: vendor!.id,
				name: vendor!.name,
				mobile: vendor!.mobile,
				email: vendor!.email,
				password: vendor!.password,
				status: newStatus,
				image: vendor!.image,
				confirm: vendor!.confirm,
				commission: vendor!.commission ?? 0.0,  // نفس التعديل هنا
			);

			final result = await VendorService.updateVendor(updatedVendor);
			if (result == "تم تحديث الفيدور بنجاح") {
				await _saveVendorToPrefs(updatedVendor);
				setState(() {
					vendor = updatedVendor;
				});

				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text('تم ${newStatus == 'active' ? 'تفعيل' : 'تعطيل'} الحساب'),
							backgroundColor: Colors.green,
						),
					);
				});
			} else {
				WidgetsBinding.instance.addPostFrameCallback((_) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text('خطأ في التحديث: $result'),
							backgroundColor: Colors.red,
						),
					);
				});
			}
		} catch (e) {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				ScaffoldMessenger.of(context).showSnackBar(
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
			MaterialPageRoute(builder: (_) => const VendorLoginPage()),
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
						vendor?.name.isNotEmpty ?? false ? vendor!.name[0] : 'V',
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
		} else if (vendor?.image != null && vendor!.image!.isNotEmpty) {
			return MemoryImage(base64Decode(vendor!.image!));
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
									vendor?.name ?? '',
									style: const TextStyle(
										fontSize: 20,
										fontWeight: FontWeight.bold,
										color: Colors.white,
									),
								),
								const SizedBox(height: 5),
								Text(
									vendor?.email ?? '',
									style: TextStyle(
										fontSize: 14,
										color: Colors.brown[200],
									),
								),
								const SizedBox(height: 5),
								Row(
									children: [
										Icon(Icons.circle,
												color:
												vendor?.status == 'active' ? Colors.green : Colors.red,
												size: 12),
										const SizedBox(width: 5),
										Text(
											vendor?.status == 'active' ? 'نشط' : 'غير نشط',
											style: TextStyle(
												color:
												vendor?.status == 'active' ? Colors.green : Colors.red,
												fontWeight: FontWeight.bold,
											),
										),
									],
								),
							],
						),
					),
					IconButton(
						icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
						onPressed: () {
							if (_isEditing) {
								_updateVendor();
							} else {
								setState(() => _isEditing = true);
							}
						},
					),
				],
			),
		);
	}

	Widget _buildTextField(
			{required TextEditingController controller,
				required String label,
				bool enabled = true,
				bool obscureText = false,
				TextInputType keyboardType = TextInputType.text}) {
		return TextField(
			controller: controller,
			enabled: enabled && _isEditing,
			obscureText: obscureText,
			keyboardType: keyboardType,
			decoration: InputDecoration(
				labelText: label,
				border: const OutlineInputBorder(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		if (_isLoading) {
			return const Center(child: CircularProgressIndicator());
		}

		return Drawer(
			child: ListView(
				children: [
					_buildProfileHeader(),
					const SizedBox(height: 10),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: Column(
							children: [
								_buildTextField(controller: _nameController, label: 'الاسم'),
								const SizedBox(height: 10),
								_buildTextField(
										controller: _mobileController,
										label: 'رقم الهاتف',
										keyboardType: TextInputType.phone),
								const SizedBox(height: 10),
								_buildTextField(
										controller: _emailController,
										label: 'البريد الإلكتروني',
										keyboardType: TextInputType.emailAddress),
								const SizedBox(height: 10),
								_buildTextField(
										controller: _passwordController,
										label: 'كلمة المرور',
										obscureText: true),
								const SizedBox(height: 10),
								ElevatedButton(
									onPressed: _isEditing ? _updateVendor : null,
									child: const Text('تحديث البيانات'),
								),
								const Divider(height: 40),
								ListTile(
									leading: const Icon(Icons.info),
									title: const Text('عن التطبيق'),
									onTap: () {
										Navigator.of(context).push(
												MaterialPageRoute(builder: (_) => const AboutUsPage()));
									},
								),
								ListTile(
									leading: const Icon(Icons.support_agent),
									title: const Text('الدعم والمساعدة'),
									onTap: () {
										Navigator.of(context).push(
												MaterialPageRoute(builder: (_) => const SupportPage()));
									},
								),
								ListTile(
									leading: Icon(
										vendor?.status == 'active' ? Icons.pause_circle : Icons.play_circle,
										color: vendor?.status == 'active' ? Colors.red : Colors.green,
									),
									title: Text(vendor?.status == 'active' ? 'تعطيل الحساب' : 'تفعيل الحساب'),
									onTap: _toggleVendorStatus,
								),
								ListTile(
									leading: const Icon(Icons.logout),
									title: const Text('تسجيل الخروج'),
									onTap: _logout,
								),
							],
						),
					),
				],
			),
		);
	}
}
