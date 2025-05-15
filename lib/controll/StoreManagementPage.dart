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

class StoreManagementPage extends StatefulWidget {
	@override
	_StoreManagementPageState createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
	//final String apiUrl = 'http://190.30.24.218/ecommerce/stores.php';
	final String apiUrl = ApiHelper.url('stores.php');
	final ImagePicker _picker = ImagePicker();

	List<Store> _stores = [];
	bool _isLoading = false;

	final TextEditingController _userIdController = TextEditingController();
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
		_fetchStores();
	}

	Future<void> _fetchStores() async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (resp.statusCode == 200) {
				final data = json.decode(resp.body) as List;
				setState(() => _stores = data.map((e) => Store.fromJson(e)).toList());
			} else {
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ خطأ في جلب البيانات')));
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ استثناء: $e')));
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

	Future<void> _submitStore({String? id}) async {
		FocusScope.of(context).unfocus();
		setState(() => _isLoading = true);
		final action = id == null ? 'add' : 'update';
		final body = {
			'action': action,
			if (id != null) 'id': id,
			'user_id': _userIdController.text.trim(),
			'category_id': _categoryController.text.trim(),
			'name': _nameController.text.trim(),
			'description': _descriptionController.text.trim(),
			'address': _addressController.text.trim(),
			'store_image': _pickedImageBase64 ?? '',
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
			if (success) _fetchStores();
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _deleteStore(String id) async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.post(Uri.parse(apiUrl), body: {'action': 'delete', 'id': id});
			final respBody = json.decode(resp.body);
			final msg = respBody['message'] ?? '';
			final success = msg.toLowerCase().contains('success');
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red),
			);
			if (success) _fetchStores();
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _showDialog({Store? store}) {
		showDialog<void>(
			context: context,
			builder: (ctx) {
				WidgetsBinding.instance.addPostFrameCallback((_) {
					if (!mounted) return;
					if (store != null) {
						_userIdController.text = store.userId;
						_categoryController.text = store.categoryId;
						_nameController.text = store.name;
						_descriptionController.text = store.description;
						_addressController.text = store.address;
						_ratingController.text = store.rating;
						_isActiveController.text = store.isActive;
						_pickedImageBase64 = store.imageBase64;
					} else {
						_userIdController.clear();
						_categoryController.clear();
						_nameController.clear();
						_descriptionController.clear();
						_addressController.clear();
						_ratingController.clear();
						_isActiveController.clear();
						_pickedImageBase64 = null;
					}
				});
				return AlertDialog(
					title: Text(store == null ? 'Add Store' : 'Edit Store'),
					content: SingleChildScrollView(
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								TextField(controller: _userIdController, decoration: InputDecoration(labelText: 'User ID')),
								TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'Category ID')),
								TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
								TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
								TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Address')),
								const SizedBox(height: 8),
								ElevatedButton(onPressed: _pickImage, child: Text('Select Image')),
								if (_pickedImageBase64 != null)
									Padding(padding: const EdgeInsets.only(top: 8), child: Image.memory(base64Decode(_pickedImageBase64!), width:100, height:100)),
								TextField(controller: _ratingController, decoration: InputDecoration(labelText: 'Rating')),
								TextField(controller: _isActiveController, decoration: InputDecoration(labelText: 'Is Active')),
							],
						),
					),
					actions: [
						TextButton(onPressed: () { FocusScope.of(ctx).unfocus(); Navigator.pop(ctx); }, child: Text('Cancel')),
						TextButton(onPressed: () { FocusScope.of(ctx).unfocus(); _submitStore(id: store?.id); Navigator.pop(ctx); }, child: Text(store == null ? 'Add' : 'Update')),
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_userIdController.dispose();
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
			appBar: AppBar(title: Text('Store Management'), actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _fetchStores)]),
			floatingActionButton: FloatingActionButton(onPressed: () => _showDialog(), child: Icon(Icons.add)),
			body: _isLoading
					? Center(child: CircularProgressIndicator())
					: _stores.isEmpty
					? Center(child: Text('No data'))
					: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					columns: [
						DataColumn(label: Text('id')),
						DataColumn(label: Text('user_id')),
						DataColumn(label: Text('category_id')),
						DataColumn(label: Text('name')),
						DataColumn(label: Text('description')),
						DataColumn(label: Text('address')),
						DataColumn(label: Text('store_image')),
						DataColumn(label: Text('rating')),
						DataColumn(label: Text('is_active')),
						DataColumn(label: Text('created_at')),
						DataColumn(label: Text('Edit')),
						DataColumn(label: Text('Copy')),
						DataColumn(label: Text('Delete')),
					],
					rows: _stores.map((s) {
						Uint8List? img;
						if (s.imageBase64 != null) { try { img = base64Decode(s.imageBase64!); } catch(_){} }
						return DataRow(cells: [
							DataCell(Text(s.id)),
							DataCell(Text(s.userId)),
							DataCell(Text(s.categoryId)),
							DataCell(Text(s.name)),
							DataCell(Text(s.description)),
							DataCell(Text(s.address)),
							DataCell(img!=null ? Image.memory(img,width:50,height:50) : Icon(Icons.store)),
							DataCell(Text(s.rating)),
							DataCell(Text(s.isActive)),
							DataCell(Text(s.createdAt)),
							DataCell(IconButton(icon: Icon(Icons.edit), onPressed: ()=>_showDialog(store: s))),
							DataCell(IconButton(icon: Icon(Icons.copy), onPressed: ()=>_showDialog(store: s))),
							DataCell(IconButton(icon: Icon(Icons.delete, color:Colors.red), onPressed: ()=>_deleteStore(s.id))),
						]);
					}).toList(),
				),
			),
		);
	}
}
