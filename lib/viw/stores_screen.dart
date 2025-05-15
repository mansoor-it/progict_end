import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/service/stores_server.dart';
import 'dart:convert';

import '../ApiConfig.dart';
import '../model/stor_model.dart';
import 'store_details_screen.dart';

// رابط الـ API

//const String apiUrl = "http://190.30.24.218/ecommerce/api.php";
final String apiUrl = ApiHelper.url('api.php');


class StoresScreen extends StatefulWidget {
	final String categoryId;
	final String categoryName;

	StoresScreen({required this.categoryId, required this.categoryName});

	@override
	_StoresScreenState createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
	List<Store> stores = [];
	bool isLoading = false;

	@override
	void initState() {
		super.initState();
		fetchStores();
	}

	Future<void> fetchStores() async {
		setState(() => isLoading = true);
		final response = await http.get(Uri.parse(
				"$apiUrl?action=stores&category_id=${widget.categoryId}"));
		if (response.statusCode == 200) {
			final jsonResponse = json.decode(response.body);
			if (jsonResponse['success'] == true) {
				List data = jsonResponse['data'];
				setState(() {
					stores = data.map((item) => Store.fromJson(item)).toList();
					isLoading = false;
				});
			} else {
				setState(() => isLoading = false);
			}
		} else {
			setState(() => isLoading = false);
		}
	}

	void navigateToStoreDetails(Store store) {
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => StoreDetailsScreen(store: store),
			),
		);
	}

	String cleanBase64(String base64Image) {
		final regex = RegExp(r'data:image/[^;]+;base64,');
		return base64Image.replaceAll(regex, '');
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text("المحلات في ${widget.categoryName}"),
				backgroundColor: Colors.teal,
			),
			body: isLoading
					? Center(child: CircularProgressIndicator())
					: ListView.builder(
				itemCount: stores.length,
				itemBuilder: (context, index) {
					final store = stores[index];
					return Card(
						margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
						elevation: 4,
						child: ListTile(
							contentPadding: EdgeInsets.all(10),
							leading: store.storeImage.isNotEmpty
									? ClipOval(
								child: Image.memory(
									base64Decode(cleanBase64(store.storeImage)),
									width: 50,
									height: 50,
									fit: BoxFit.cover,
								),
							)
									: SizedBox(width: 50, height: 50),
							title: Text(
								store.name,
								style:
								TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
							),
							subtitle: Text(
								store.description,
								maxLines: 2,
								overflow: TextOverflow.ellipsis,
								style: TextStyle(fontSize: 14, color: Colors.grey[600]),
							),
							trailing: TextButton(
								child: Text("عرض التفاصيل"),
								onPressed: () => navigateToStoreDetails(store),
							),
						),
					);
				},
			),
		);
	}
}
