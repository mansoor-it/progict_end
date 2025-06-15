import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../ApiConfig.dart';

// تعريف كلاس المحل بناءً على الحقول المطلوبة
class Store {
	final String id;
	final String userId;
	final String categoryId;
	final String name;
	final String description;
	final String address;
	final String? imageBase64;
	final String rating;
	final String isActive;
	final String createdAt;

	Store({
		required this.id,
		required this.userId,
		required this.categoryId,
		required this.name,
		required this.description,
		required this.address,
		this.imageBase64,
		required this.rating,
		required this.isActive,
		required this.createdAt,
	});

	factory Store.fromJson(Map<String, dynamic> json) {
		return Store(
			id: json['id']?.toString() ?? '',
			userId: json['user_id']?.toString() ?? '',
			categoryId: json['category_id']?.toString() ?? '',
			name: json['name'] ?? '',
			description: json['description'] ?? '',
			address: json['address'] ?? '',
			imageBase64: json['store_image'] != null && (json['store_image'] as String).isNotEmpty
					? json['store_image'] as String
					: null,
			rating: json['rating']?.toString() ?? '0',
			isActive: json['is_active']?.toString() ?? '0',
			createdAt: json['created_at'] ?? '',
		);
	}
}

class StoreManagemenPage extends StatefulWidget {
	final String user;
	const StoreManagemenPage({Key? key, required this.user}) : super(key: key);

	@override
	_StoreManagemenPageState createState() => _StoreManagemenPageState();
}

class _StoreManagemenPageState extends State<StoreManagemenPage> {
	final String apiUrl = ApiHelper.url('stores.php');
	final ImagePicker _picker = ImagePicker();

	Store? _store;
	bool _isLoading = false;

	final TextEditingController _categoryController = TextEditingController();
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _addressController = TextEditingController();
	final TextEditingController _ratingController = TextEditingController();
	final TextEditingController _isActiveController = TextEditingController();
	String? _pickedImageBase64;

	@override
	void initState() {
		super.initState();
		_fetchStore();
	}

	Future<void> _fetchStore() async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch&user_id=${widget.user}'));
			if (resp.statusCode == 200) {
				final data = json.decode(resp.body) as List;
				if (data.isNotEmpty) {
					setState(() => _store = Store.fromJson(data.first));
				}
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('❌ خطأ في جلب بيانات المحل')),
				);
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('❌ استثناء: $e')),
			);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _pickImage() async {
		final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
		if (img != null) {
			final bytes = await img.readAsBytes();
			setState(() => _pickedImageBase64 = base64Encode(bytes));
		}
	}

	Future<void> _submitStore() async {
		FocusScope.of(context).unfocus();
		if (_store == null) return;
		setState(() => _isLoading = true);
		final body = {
			'action': 'update',
			'id': _store!.id,
			'user_id': widget.user,
			'category_id': _categoryController.text.trim(),
			'name': _nameController.text.trim(),
			'description': _descriptionController.text.trim(),
			'address': _addressController.text.trim(),
			'store_image': _pickedImageBase64 ?? _store!.imageBase64 ?? '',
			'rating': _ratingController.text.trim(),
			'is_active': _isActiveController.text.trim(),
		};
		try {
			final resp = await http.post(Uri.parse(apiUrl), body: body);
			final respBody = json.decode(resp.body);
			final msg = respBody['message'] ?? '';
			final success = msg.toLowerCase().contains('success');
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red),
			);
			if (success) _fetchStore();
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
			);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _showEditDialog() {
		if (_store == null) return;
		_categoryController.text = _store!.categoryId;
		_nameController.text = _store!.name;
		_descriptionController.text = _store!.description;
		_addressController.text = _store!.address;
		_ratingController.text = _store!.rating;
		_isActiveController.text = _store!.isActive;
		_pickedImageBase64 = _store!.imageBase64;

		showDialog<void>(
			context: context,
			builder: (ctx) => AlertDialog(
				title: Text('تعديل بيانات المحل'),
				content: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'معرف القسم')),
							TextField(controller: _nameController, decoration: InputDecoration(labelText: 'اسم المحل')),
							TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'الوصف')),
							TextField(controller: _addressController, decoration: InputDecoration(labelText: 'العنوان')),
							const SizedBox(height: 8),
							ElevatedButton(onPressed: _pickImage, child: Text('تحديد صورة')),
							if (_pickedImageBase64 != null)
								Padding(
									padding: const EdgeInsets.only(top: 8),
									child: Image.memory(base64Decode(_pickedImageBase64!), width: 100, height: 100),
								),
							TextField(controller: _ratingController, decoration: InputDecoration(labelText: 'التقييم')),
							TextField(controller: _isActiveController, decoration: InputDecoration(labelText: 'نشط')),
						],
					),
				),
				actions: [
					TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
					TextButton(onPressed: () { Navigator.pop(ctx); _submitStore(); }, child: Text('تحديث')),
				],
			),
		);
	}

	@override
	void dispose() {
		_categoryController.dispose();
		_nameController.dispose();
		_descriptionController.dispose();
		_addressController.dispose();
		_ratingController.dispose();
		_isActiveController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('إدارة المحل')),
			body: _isLoading
					? Center(child: CircularProgressIndicator())
					: _store == null
					? Center(child: Text('لا يوجد بيانات للمحل'))
					: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text('اسم المحل: ${_store!.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
						SizedBox(height: 8),
						if (_store!.imageBase64 != null)
							Image.memory(base64Decode(_store!.imageBase64!), width: 150, height: 150),
						SizedBox(height: 8),
						Text('الوصف: ${_store!.description}'),
						SizedBox(height: 8),
						Text('العنوان: ${_store!.address}'),
						SizedBox(height: 8),
						Text('التقييم: ${_store!.rating}'),
						SizedBox(height: 8),
						Text('نشط: ${_store!.isActive}'),
						Spacer(),
						Center(
							child: ElevatedButton(
								onPressed: _showEditDialog,
								child: Text('تعديل المحل'),
							),
						),
					],
				),
			),
		);
	}
}
