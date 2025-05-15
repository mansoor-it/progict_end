import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../ApiConfig.dart';

// تعريف كلاس المنتج بناءً على جدول products مع حقل الصورة بصيغة Base64
class Product {
	final String id;
	final String storeId;
	final String name;
	final String description;
	final String price;
	final String stockQuantity;
	final String? imageBase64;
	final String status;
	final String createdAt;

	Product({
		required this.id,
		required this.storeId,
		required this.name,
		required this.description,
		required this.price,
		required this.stockQuantity,
		this.imageBase64,
		required this.status,
		required this.createdAt,
	});

	factory Product.fromJson(Map<String, dynamic> json) {
		return Product(
			id: json['id']?.toString() ?? '',
			storeId: json['store_id']?.toString() ?? '',
			name: json['name'] ?? '',
			description: json['description'] ?? '',
			price: json['price']?.toString() ?? '',
			stockQuantity: json['stock_quantity']?.toString() ?? '',
			imageBase64: json['image'] != null && (json['image'] as String).isNotEmpty
					? json['image'] as String
					: null,
			status: json['status'] ?? 'available',
			createdAt: json['created_at'] ?? '',
		);
	}
}

class ProductsManagementPage extends StatefulWidget {
	@override
	_ProductsManagementPageState createState() => _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage> {
	//final String apiUrl = 'http://190.30.24.218/ecommerce/products_api.php';
	final String apiUrl = ApiHelper.url('products_api.php');
	final ImagePicker _picker = ImagePicker();

	List<Product> _products = [];
	bool _isLoading = false;

	// Controllers للنموذج
	final TextEditingController _storeIdController = TextEditingController();
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _priceController = TextEditingController();
	final TextEditingController _stockQuantityController = TextEditingController();
	final TextEditingController _statusController = TextEditingController();
	String? _pickedImageBase64;

	@override
	void initState() {
		super.initState();
		_fetchProducts();
	}

	Future<void> _fetchProducts() async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (resp.statusCode == 200) {
				final List data = json.decode(resp.body);
				_products = data.map((e) => Product.fromJson(e)).toList();
			} else {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('❌ خطأ في جلب البيانات')),
				);
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('❌ استثناء: \$e')),
			);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _pickImage() async {
		final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
		if (image != null) {
			final bytes = await image.readAsBytes();
			setState(() => _pickedImageBase64 = base64Encode(bytes));
		}
	}

	Future<void> _submitProduct({String? id}) async {
		final action = id == null ? 'add' : 'update';
		final body = {
			'action': action,
			if (id != null) 'id': id,
			'store_id': _storeIdController.text.trim(),
			'name': _nameController.text.trim(),
			'description': _descriptionController.text.trim(),
			'price': _priceController.text.trim(),
			'stock_quantity': _stockQuantityController.text.trim(),
			'image': _pickedImageBase64 ?? '',
			'status': _statusController.text.trim().isEmpty
					? 'available'
					: _statusController.text.trim(),
		};
		setState(() => _isLoading = true);
		try {
			final resp = await http.post(Uri.parse(apiUrl), body: body);
			final respBody = json.decode(resp.body);
			final msg = respBody['message'] ?? '';
			final success = msg.toLowerCase().contains('successfully');
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red),
			);
			if (success) _fetchProducts();
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('❌ استثناء: \$e'), backgroundColor: Colors.red),
			);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _deleteProduct(String id) async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.post(Uri.parse(apiUrl), body: { 'action': 'delete', 'id': id });
			final respBody = json.decode(resp.body);
			final msg = respBody['message'] ?? '';
			final success = msg.toLowerCase().contains('successfully');
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red),
			);
			if (success) _fetchProducts();
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('❌ استثناء: \$e'), backgroundColor: Colors.red),
			);
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _showDialog({Product? product}) {
		if (product != null) {
			_storeIdController.text = product.storeId;
			_nameController.text = product.name;
			_descriptionController.text = product.description;
			_priceController.text = product.price;
			_stockQuantityController.text = product.stockQuantity;
			_statusController.text = product.status;
			_pickedImageBase64 = product.imageBase64;
		} else {
			_storeIdController.clear();
			_nameController.clear();
			_descriptionController.clear();
			_priceController.clear();
			_stockQuantityController.clear();
			_statusController.clear();
			_pickedImageBase64 = null;
		}

		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(product == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
				content: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							TextField(controller: _storeIdController, decoration: InputDecoration(labelText: 'معرّف المتجر')),
							TextField(controller: _nameController, decoration: InputDecoration(labelText: 'اسم المنتج')),
							TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'الوصف')),
							TextField(controller: _priceController, decoration: InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
							TextField(controller: _stockQuantityController, decoration: InputDecoration(labelText: 'كمية المخزون'), keyboardType: TextInputType.number),
							SizedBox(height: 8),
							ElevatedButton(onPressed: _pickImage, child: Text('اختر صورة من المعرض')),
							if (_pickedImageBase64 != null) Padding(
								padding: EdgeInsets.only(top: 8),
								child: Image.memory(base64Decode(_pickedImageBase64!), height:100, width:100),
							),
							TextField(controller: _statusController, decoration: InputDecoration(labelText: 'الحالة (available, out_of_stock, discontinued)')),
						],
					),
				),
				actions: [
					TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
					TextButton(onPressed: () { Navigator.pop(context); _submitProduct(id: product?.id); }, child: Text(product==null?'إضافة':'تعديل')),
				],
			),
		);
	}

	@override
	void dispose() {
		_storeIdController.dispose();
		_nameController.dispose();
		_descriptionController.dispose();
		_priceController.dispose();
		_stockQuantityController.dispose();
		_statusController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('إدارة المنتجات'), actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _fetchProducts)]),
			body: _isLoading ? Center(child:CircularProgressIndicator()) : _products.isEmpty ? Center(child:Text('لا توجد بيانات')) : SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					columns: [
						DataColumn(label: Text('ID')),
						DataColumn(label: Text('معرّف المتجر')),
						DataColumn(label: Text('الاسم')),
						DataColumn(label: Text('الوصف')),
						DataColumn(label: Text('السعر')),
						DataColumn(label: Text('المخزون')),
						DataColumn(label: Text('الصورة')),
						DataColumn(label: Text('الحالة')),
						DataColumn(label: Text('تاريخ الإنشاء')),
						DataColumn(label: Text('إجراءات')),
					],
					rows: _products.map((p) {
						Uint8List? img;
						if (p.imageBase64 != null) {
							try { img = base64Decode(p.imageBase64!); } catch (_) {}
						}
						return DataRow(cells: [
							DataCell(Text(p.id)),
							DataCell(Text(p.storeId)),
							DataCell(Text(p.name)),
							DataCell(Text(p.description)),
							DataCell(Text(p.price)),
							DataCell(Text(p.stockQuantity)),
							DataCell(img!=null?Image.memory(img,width:50,height:50):Icon(Icons.image)),
							DataCell(Text(p.status)),
							DataCell(Text(p.createdAt)),
							DataCell(Row(children:[
								IconButton(icon:Icon(Icons.edit,size:18),onPressed:()=>_showDialog(product: p)),
								IconButton(icon:Icon(Icons.delete,size:18,color:Colors.red),onPressed:(){showDialog(context:context,builder: (_) => AlertDialog(title:Text('تأكيد الحذف'),content:Text('حذف '+p.name+'؟'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:Text('إلغاء')),TextButton(onPressed:(){Navigator.pop(context);_deleteProduct(p.id);},child:Text('حذف'))]));}),
							])),
						]);
					}).toList(),
				),
			),
			floatingActionButton: FloatingActionButton(onPressed:()=>_showDialog(),child:Icon(Icons.add)),
		);
	}
}
