import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductColor {
	final String id;
	final String productId;
	final String colorName;
	final String colorCode;
	final String stockQuantity;
	final String? imageBase64;
	final String createdAt;

	ProductColor({
		required this.id,
		required this.productId,
		required this.colorName,
		required this.colorCode,
		required this.stockQuantity,
		this.imageBase64,
		required this.createdAt,
	});

	factory ProductColor.fromJson(Map<String, dynamic> json) {
		return ProductColor(
			id: json['id']?.toString() ?? '',
			productId: json['product_id']?.toString() ?? '',
			colorName: json['color_name'] ?? '',
			colorCode: json['color_code'] ?? '',
			stockQuantity: json['stock_quantity']?.toString() ?? '',
			imageBase64: json['image'] != null ? json['image'] as String : null,
			createdAt: json['created_at'] ?? '',
		);
	}
}

class ProductColorsManagementPage extends StatefulWidget {
	@override
	_ProductColorsManagementPageState createState() => _ProductColorsManagementPageState();
}

class _ProductColorsManagementPageState extends State<ProductColorsManagementPage> {
	final String apiUrl = 'http://192.168.43.129/ecommerce/product_colors_api.php';
	final ImagePicker _picker = ImagePicker();

	List<ProductColor> _colors = [];
	bool _isLoading = false;

	final TextEditingController _productIdController = TextEditingController();
	final TextEditingController _colorNameController = TextEditingController();
	final TextEditingController _colorCodeController = TextEditingController();
	final TextEditingController _stockQuantityController = TextEditingController();
	String? _pickedImageBase64;

	@override
	void initState() {
		super.initState();
		_fetchColors();
	}

	Future<void> _fetchColors() async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (resp.statusCode == 200) {
				final List data = json.decode(resp.body);
				_colors = data.map((e) => ProductColor.fromJson(e)).toList();
			} else {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text('Error fetching colors')));
			}
		} catch (e) {
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text('Exception: $e')));
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

	Future<void> _submitColor({String? id}) async {
		final action = id == null ? 'add' : 'update';
		final data = {
			'action': action,
			if (id != null) 'id': id,
			'product_id': _productIdController.text.trim(),
			'color_name': _colorNameController.text.trim(),
			'color_code': _colorCodeController.text.trim(),
			'stock_quantity': _stockQuantityController.text.trim(),
			'image': _pickedImageBase64 ?? '',
		};
		setState(() => _isLoading = true);
		try {
			final resp = await http.post(Uri.parse(apiUrl), body: data);
			final body = json.decode(resp.body);
			final msg = body['message'] ?? 'Unknown response';
			final success = msg.toLowerCase().contains('successfully');
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red),
			);
			if (success) _fetchColors();
		} catch (e) {
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text('Exception: $e'), backgroundColor: Colors.red));
		} finally {
			setState(() => _isLoading = false);
		}
	}

	Future<void> _deleteColor(String id) async {
		setState(() => _isLoading = true);
		try {
			final resp = await http.post(Uri.parse(apiUrl), body: {'action': 'delete', 'id': id});
			final body = json.decode(resp.body);
			final msg = body['message'] ?? 'Unknown';
			final success = msg.toLowerCase().contains('successfully');
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : Colors.red));
			if (success) _fetchColors();
		} catch (e) {
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text('Exception: $e'), backgroundColor: Colors.red));
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _showDialog({ProductColor? color}) {
		if (color != null) {
			_productIdController.text = color.productId;
			_colorNameController.text = color.colorName;
			_colorCodeController.text = color.colorCode;
			_stockQuantityController.text = color.stockQuantity;
			_pickedImageBase64 = color.imageBase64;
		} else {
			_productIdController.clear();
			_colorNameController.clear();
			_colorCodeController.clear();
			_stockQuantityController.clear();
			_pickedImageBase64 = null;
		}
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(color == null ? 'Add Color' : 'Edit Color'),
				content: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							TextField(
								controller: _productIdController,
								decoration: InputDecoration(labelText: 'Product ID'),
								keyboardType: TextInputType.number,
							),
							TextField(
								controller: _colorNameController,
								decoration: InputDecoration(labelText: 'Color Name'),
							),
							TextField(
								controller: _colorCodeController,
								decoration: InputDecoration(labelText: 'Color Code'),
							),
							TextField(
								controller: _stockQuantityController,
								decoration: InputDecoration(labelText: 'Stock Quantity'),
								keyboardType: TextInputType.number,
							),
							SizedBox(height: 8),
							ElevatedButton(onPressed: _pickImage, child: Text('Pick Image from Gallery')),
							if (_pickedImageBase64 != null && _pickedImageBase64!.isNotEmpty)
								Padding(
									padding: const EdgeInsets.only(top: 8.0),
									child: Image.memory(base64Decode(_pickedImageBase64!), height: 100, width: 100),
								),
						],
					),
				),
				actions: [
					TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
					TextButton(
						onPressed: () {
							Navigator.pop(context);
							_submitColor(id: color?.id);
						},
						child: Text(color == null ? 'Add' : 'Update'),
					),
				],
			),
		);
	}

	@override
	void dispose() {
		_productIdController.dispose();
		_colorNameController.dispose();
		_colorCodeController.dispose();
		_stockQuantityController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Manage Product Colors'),
				actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _fetchColors)],
			),
			body: _isLoading
					? Center(child: CircularProgressIndicator())
					: _colors.isEmpty
					? Center(child: Text('No colors found'))
					: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					columns: [
						DataColumn(label: Text('ID')),
						DataColumn(label: Text('Product ID')),
						DataColumn(label: Text('Name')),
						DataColumn(label: Text('Code')),
						DataColumn(label: Text('Stock')),
						DataColumn(label: Text('Image')),
						DataColumn(label: Text('Created At')),
						DataColumn(label: Text('Actions')),
					],
					rows: _colors.map((c) {
						Uint8List? img;
						if (c.imageBase64 != null && c.imageBase64!.isNotEmpty) {
							try {
								img = base64Decode(c.imageBase64!);
							} catch (_) {}
						}
						return DataRow(cells: [
							DataCell(Text(c.id)),
							DataCell(Text(c.productId)),
							DataCell(Text(c.colorName)),
							DataCell(Text(c.colorCode)),
							DataCell(Text(c.stockQuantity)),
							DataCell(img != null
									? Image.memory(img, width: 50, height: 50)
									: Icon(Icons.image)),
							DataCell(Text(c.createdAt)),
							DataCell(Row(
								children: [
									IconButton(icon: Icon(Icons.edit), onPressed: () => _showDialog(color: c)),
									IconButton(
										icon: Icon(Icons.delete, color: Colors.red),
										onPressed: () {
											showDialog(
												context: context,
												builder: (_) => AlertDialog(
													title: Text('Confirm Delete'),
													content: Text('Delete "${c.colorName}"?'),
													actions: [
														TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
														TextButton(
															onPressed: () {
																Navigator.pop(context);
																_deleteColor(c.id);
															},
															child: Text('Delete'),
														),
													],
												),
											);
										},
									),
								],
							)),
						]);
					}).toList(),
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _showDialog(),
				child: Icon(Icons.add),
			),
		);
	}
}
