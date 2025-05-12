// products_screen_view.dart
import 'package:flutter/material.dart';
import '../model/products_screen_model.dart';
import '../service/products_screen_server.dart';


class ProductsScreen extends StatefulWidget {
	final String storeId;
	final String storeName;

	ProductsScreen({required this.storeId, required this.storeName});

	@override
	_ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
	List<Product> products = [];
	bool isLoading = false;
	final ProductsScreenController _controller = ProductsScreenController();

	@override
	void initState() {
		super.initState();
		fetchProducts();
	}

	Future<void> fetchProducts() async {
		setState(() => isLoading = true);
		final fetchedProducts = await _controller.fetchProducts(widget.storeId);
		setState(() {
			products = fetchedProducts;
			isLoading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text("المنتجات في ${widget.storeName}"),
				backgroundColor: Colors.teal,
			),
			body: isLoading
					? Center(child: CircularProgressIndicator())
					: ListView.builder(
				itemCount: products.length,
				itemBuilder: (context, index) {
					final product = products[index];
					return Card(
						margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
						elevation: 4,
						child: ListTile(
							contentPadding: EdgeInsets.all(10),
							leading: product.image.isNotEmpty
									? Image.network(
								product.image,
								width: 50,
								height: 50,
								fit: BoxFit.cover,
							)
									: Icon(Icons.shopping_bag),
							title: Text(
								product.name,
								style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
							),
							subtitle: Text("السعر: ${product.price}"),
						),
					);
				},
			),
		);
	}
}
