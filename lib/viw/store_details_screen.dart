import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled2/service/stores_server.dart';

import '../model/stor_model.dart';
import 'ProductDetailsPage.dart';

class StoreDetailsScreen extends StatelessWidget {
	final Store store;

	StoreDetailsScreen({required this.store});

	String cleanBase64(String base64Image) {
		final regex = RegExp(r'data:image/[^;]+;base64,');
		return base64Image.replaceAll(regex, '');
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(store.name),
				backgroundColor: Colors.teal,
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						if (store.storeImage.isNotEmpty)
							ClipRRect(
								borderRadius: BorderRadius.circular(16),
								child: AspectRatio(
									aspectRatio: 1, // عرض = طول
									child: Image.memory(
										base64Decode(cleanBase64(store.storeImage)),
										fit: BoxFit.cover,
										alignment: Alignment.center,
									),
								),
							),
						SizedBox(height: 20),
						Text(
							"الوصف:",
							style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
						),
						Text(store.description),
						SizedBox(height: 10),
						Text(
							"العنوان: ${store.address}",
							style: TextStyle(fontWeight: FontWeight.bold),
						),
						SizedBox(height: 10),
						Text(
							"التقييم: ${store.rating ?? 'غير متوفر'}",
							style: TextStyle(fontWeight: FontWeight.bold),
						),
						SizedBox(height: 20),
						Center(
							child: ElevatedButton(
								onPressed: () {
									Navigator.push(
										context,
										MaterialPageRoute(
											builder: (context) => AllProductsPage(
												storeId: store.id,
												storeName: store.name,
											),
										),
									);
								},
								child: Text("عرض المنتجات"),
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.teal,
								),
							),
						),
					],
				),
			),
		);
	}
}

// إذا كان حقل التقييم غير موجود فعلاً في الـ Store، نتركه Null مؤقتاً
extension on Store {
	get rating => null;
}
