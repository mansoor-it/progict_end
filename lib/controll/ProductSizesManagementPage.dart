import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// تعريف كلاس المقاسات بناءً على جدول product_sizes
class ProductSize {
	final String id;
	final String productId;
	final String size;
	final String stockQuantity;
	final String additionalPrice;
	final String createdAt;

	ProductSize({
		required this.id,
		required this.productId,
		required this.size,
		required this.stockQuantity,
		required this.additionalPrice,
		required this.createdAt,
	});

	factory ProductSize.fromJson(Map<String, dynamic> json) {
		return ProductSize(
			id: json['id'].toString(),
			productId: json['product_id'].toString(),
			size: json['size'],
			stockQuantity: json['stock_quantity'].toString(),
			additionalPrice: json['additional_price'].toString(),
			createdAt: json['created_at'] ?? '',
		);
	}
}

class ProductSizesManagementPage extends StatefulWidget {
	@override
	_ProductSizesManagementPageState createState() => _ProductSizesManagementPageState();
}

class _ProductSizesManagementPageState extends State<ProductSizesManagementPage> {
	List<ProductSize> _sizes = [];
	bool _isLoading = false;

	// Controllers للنموذج
	final TextEditingController _productIdController = TextEditingController();
	final TextEditingController _sizeController = TextEditingController();
	final TextEditingController _stockQuantityController = TextEditingController();
	final TextEditingController _additionalPriceController = TextEditingController();

	// رابط API الخاص بالمقاسات
	final String apiUrl = "http://190.30.24.218/ecommerce/product_sizes_api.php";

	@override
	void initState() {
		super.initState();
		_fetchSizes();
	}

	Future<void> _fetchSizes() async {
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				setState(() {
					_sizes = data.map((item) => ProductSize.fromJson(item)).toList();
					_isLoading = false;
				});
			} else {
				setState(() {
					_isLoading = false;
				});
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Error fetching sizes")));
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text("Exception: $e")));
		}
	}

	Future<void> _addSize() async {
		final Map<String, String> data = {
			"action": "add",
			"product_id": _productIdController.text.trim(),
			"size": _sizeController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"additional_price": _additionalPriceController.text.trim(),
		};
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			final responseBody = json.decode(response.body);
			setState(() {
				_isLoading = false;
			});
			if (responseBody['message'] == "Product size added successfully") {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Size added successfully"), backgroundColor: Colors.green));
				_fetchSizes();
			} else {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Failed to add size: ${responseBody['message']}"), backgroundColor: Colors.red));
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text("Exception: $e"), backgroundColor: Colors.red));
		}
	}

	Future<void> _updateSize(String id) async {
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"product_id": _productIdController.text.trim(),
			"size": _sizeController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"additional_price": _additionalPriceController.text.trim(),
		};
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			final responseBody = json.decode(response.body);
			setState(() {
				_isLoading = false;
			});
			if (responseBody['message'] == "Product size updated successfully") {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Size updated successfully"), backgroundColor: Colors.green));
				_fetchSizes();
			} else {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Failed to update size: ${responseBody['message']}"), backgroundColor: Colors.red));
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text("Exception: $e"), backgroundColor: Colors.red));
		}
	}

	Future<void> _deleteSize(String id) async {
		final Map<String, String> data = {
			"action": "delete",
			"id": id,
		};
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			final responseBody = json.decode(response.body);
			setState(() {
				_isLoading = false;
			});
			if (responseBody['message'] == "Product size deleted successfully") {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Size deleted successfully"), backgroundColor: Colors.green));
				_fetchSizes();
			} else {
				ScaffoldMessenger.of(context)
						.showSnackBar(SnackBar(content: Text("Failed to delete size: ${responseBody['message']}"), backgroundColor: Colors.red));
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			ScaffoldMessenger.of(context)
					.showSnackBar(SnackBar(content: Text("Exception: $e"), backgroundColor: Colors.red));
		}
	}

	void _showAddEditDialog({ProductSize? sizeObj}) {
		if (sizeObj != null) {
			_productIdController.text = sizeObj.productId;
			_sizeController.text = sizeObj.size;
			_stockQuantityController.text = sizeObj.stockQuantity;
			_additionalPriceController.text = sizeObj.additionalPrice;
		} else {
			_productIdController.clear();
			_sizeController.clear();
			_stockQuantityController.clear();
			_additionalPriceController.clear();
		}
		showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: Text(sizeObj == null ? "Add Product Size" : "Edit Product Size"),
					content: SingleChildScrollView(
						child: Column(
							children: [
								TextField(
									controller: _productIdController,
									decoration: InputDecoration(labelText: "Product ID"),
									keyboardType: TextInputType.number,
								),
								TextField(
									controller: _sizeController,
									decoration: InputDecoration(labelText: "Size"),
								),
								TextField(
									controller: _stockQuantityController,
									decoration: InputDecoration(labelText: "Stock Quantity"),
									keyboardType: TextInputType.number,
								),
								TextField(
									controller: _additionalPriceController,
									decoration: InputDecoration(labelText: "Additional Price"),
									keyboardType: TextInputType.number,
								),
							],
						),
					),
					actions: [
						TextButton(
								onPressed: () => Navigator.of(context).pop(),
								child: Text("Cancel")),
						TextButton(
								onPressed: () {
									if (sizeObj == null) {
										_addSize();
									} else {
										_updateSize(sizeObj.id);
									}
									Navigator.of(context).pop();
								},
								child: Text(sizeObj == null ? "Add" : "Update"))
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_productIdController.dispose();
		_sizeController.dispose();
		_stockQuantityController.dispose();
		_additionalPriceController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text("Manage Product Sizes"),
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchSizes,
						tooltip: "Refresh",
					)
				],
			),
			body: _isLoading
					? Center(child: CircularProgressIndicator())
					: _sizes.isEmpty
					? Center(child: Text("No sizes available"))
					: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					columns: const [
						DataColumn(label: Text("ID")),
						DataColumn(label: Text("Product ID")),
						DataColumn(label: Text("Size")),
						DataColumn(label: Text("Stock Quantity")),
						DataColumn(label: Text("Additional Price")),
						DataColumn(label: Text("Created At")),
						DataColumn(label: Text("Actions")),
					],
					rows: _sizes.map((sizeObj) {
						return DataRow(cells: [
							DataCell(Text(sizeObj.id)),
							DataCell(Text(sizeObj.productId)),
							DataCell(Text(sizeObj.size)),
							DataCell(Text(sizeObj.stockQuantity)),
							DataCell(Text(sizeObj.additionalPrice)),
							DataCell(Text(sizeObj.createdAt)),
							DataCell(Row(
								mainAxisSize: MainAxisSize.min,
								children: [
									IconButton(
										icon: Icon(Icons.edit, size: 18),
										tooltip: "Edit",
										onPressed: () => _showAddEditDialog(sizeObj: sizeObj),
									),
									IconButton(
										icon: Icon(Icons.delete, size: 18, color: Colors.red),
										tooltip: "Delete",
										onPressed: () {
											showDialog(
												context: context,
												builder: (BuildContext context) {
													return AlertDialog(
														title: Text("Confirm Delete"),
														content: Text("Are you sure you want to delete size '${sizeObj.size}'?"),
														actions: [
															TextButton(
																child: Text("Cancel"),
																onPressed: () => Navigator.of(context).pop(),
															),
															TextButton(
																child: Text("Delete"),
																onPressed: () {
																	Navigator.of(context).pop();
																	_deleteSize(sizeObj.id);
																},
															),
														],
													);
												},
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
				onPressed: () => _showAddEditDialog(),
				child: Icon(Icons.add),
				tooltip: "Add Product Size",
			),
		);
	}
}
