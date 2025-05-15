import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig.dart';
import '../model/stor_model.dart';

class StoreService {

	//static const String baseUrl = "http://190.30.24.218/ecommerce/stores.php";

	static var baseUrl = ApiHelper.url('stores.php');



	static Future<List<Store>> fetchStores() async {
		final response = await http.get(Uri.parse("$baseUrl?action=fetch"));
		if (response.statusCode == 200) {
			final List<dynamic> data = json.decode(response.body);
			return data.map((item) => Store.fromJson(item)).toList();
		} else {
			throw Exception("Failed to fetch stores");
		}
	}

	static Future<void> addOrUpdateStore({String? id, required Map<String, String> data}) async {
		final response = await http.post(Uri.parse(baseUrl), body: {
			"action": id == null ? "add" : "update",
			if (id != null) "id": id,
			...data,
		});
		if (response.statusCode != 200 || !json.decode(response.body)['message'].contains("success")) {
			throw Exception("Failed to ${id == null ? 'add' : 'update'} store");
		}
	}

	static Future<void> deleteStore(String id) async {
		final response = await http.post(Uri.parse(baseUrl), body: {"action": "delete", "id": id});
		if (response.statusCode != 200 || !json.decode(response.body)['message'].contains("success")) {
			throw Exception("Failed to delete store");
		}
	}
}

class StoreManagementPage extends StatefulWidget {
	@override
	_StoreManagementPageState createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
	List<Store> _stores = [];
	bool _isLoading = false;

	final TextEditingController _categoryIdController = TextEditingController();
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _addressController = TextEditingController();
	final TextEditingController _storeImageController = TextEditingController();

	@override
	void initState() {
		super.initState();
		_fetchStores();
	}

	Future<void> _fetchStores() async {
		setState(() => _isLoading = true);
		try {
			final stores = await StoreService.fetchStores();
			setState(() {
				_stores = stores;
				_isLoading = false;
			});
		} catch (e) {
			_showError("Failed to fetch stores: $e");
		}
	}

	Future<void> _addOrUpdateStore({String? id}) async {
		if (_categoryIdController.text.isEmpty ||
				_nameController.text.isEmpty ||
				_descriptionController.text.isEmpty ||
				_addressController.text.isEmpty ||
				_storeImageController.text.isEmpty) {
			_showError("Please fill all fields");
			return;
		}

		setState(() => _isLoading = true);
		try {
			await StoreService.addOrUpdateStore(
				id: id,
				data: {
					"category_id": _categoryIdController.text.trim(),
					"name": _nameController.text.trim(),
					"description": _descriptionController.text.trim(),
					"address": _addressController.text.trim(),
					"store_image": _storeImageController.text.trim(),
				},
			);
			_fetchStores();
			Navigator.of(context).pop();
		} catch (e) {
			_showError("Failed to ${id == null ? 'add' : 'update'} store: $e");
		}
	}

	Future<void> _deleteStore(String id) async {
		setState(() => _isLoading = true);
		try {
			await StoreService.deleteStore(id);
			_fetchStores();
		} catch (e) {
			_showError("Failed to delete store: $e");
		}
	}

	void _showError(String message) {
		setState(() => _isLoading = false);
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.red),
		);
	}

	void _showStoreDialog({Store? store}) {
		if (store != null) {
			_categoryIdController.text = store.categoryId;
			_nameController.text = store.name;
			_descriptionController.text = store.description;
			_addressController.text = store.address;
			_storeImageController.text = store.storeImage;
		} else {
			_categoryIdController.clear();
			_nameController.clear();
			_descriptionController.clear();
			_addressController.clear();
			_storeImageController.clear();
		}
		showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: Text(store == null ? "Add Store" : "Edit Store"),
					content: SingleChildScrollView(
						child: Column(children: [
							TextField(controller: _categoryIdController, decoration: InputDecoration(labelText: "Category ID")),
							TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
							TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description")),
							TextField(controller: _addressController, decoration: InputDecoration(labelText: "Address")),
							TextField(controller: _storeImageController, decoration: InputDecoration(labelText: "Store Image URL")),
						]),
					),
					actions: [
						TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
						TextButton(
							onPressed: () => _addOrUpdateStore(id: store?.id),
							child: Text(store == null ? "Add" : "Update"),
						),
					],
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text("Store Management"), actions: [
				IconButton(icon: Icon(Icons.refresh), onPressed: _fetchStores),
			]),
			body: _isLoading
					? Center(child: CircularProgressIndicator())
					: _stores.isEmpty
					? Center(child: Text("No stores available"))
					: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					columns: const [
						DataColumn(label: Text("ID")),
						DataColumn(label: Text("Category ID")),
						DataColumn(label: Text("Name")),
						DataColumn(label: Text("Description")),
						DataColumn(label: Text("Address")),
						DataColumn(label: Text("Image")),
						DataColumn(label: Text("Actions")),
					],
					rows: _stores.map((store) {
						return DataRow(cells: [
							DataCell(Text(store.id)),
							DataCell(Text(store.categoryId)),
							DataCell(Text(store.name)),
							DataCell(Text(store.description)),
							DataCell(Text(store.address)),
							DataCell(Image.network(store.storeImage, width: 50, height: 50)),
							DataCell(Row(
								children: [
									IconButton(
										icon: Icon(Icons.edit, color: Colors.blue),
										onPressed: () => _showStoreDialog(store: store),
									),
									IconButton(
										icon: Icon(Icons.delete, color: Colors.red),
										onPressed: () => _deleteStore(store.id),
									),
								],
							)),
						]);
					}).toList(),
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _showStoreDialog(),
				child: Icon(Icons.add),
			),
		);
	}
}