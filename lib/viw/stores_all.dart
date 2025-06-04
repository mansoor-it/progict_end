import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';
import 'ProductDetailsPage.dart';
import '../model/user_model.dart'; // <-- إضافة استيراد لنموذج المستخدم

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

class SimpleStoreListPage extends StatefulWidget {
	final User user; // <-- إضافة متغير لاستقبال المستخدم

	const SimpleStoreListPage({Key? key, required this.user}) : super(key: key); // <-- تعديل المنشئ

	@override
	_SimpleStoreListPageState createState() => _SimpleStoreListPageState();
}

class _SimpleStoreListPageState extends State<SimpleStoreListPage> {
	final String apiUrl = ApiHelper.url('stores.php');

	List<Store> _stores = [];
	bool _isLoading = false;

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
				if (mounted) {
					setState(() => _stores = data.map((e) => Store.fromJson(e)).toList());
				}
			} else {
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(content: Text('❌ خطأ في جلب البيانات: ${resp.statusCode}')),
					);
				}
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('❌ حدث خطأ: $e')),
				);
			}
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	Uint8List? _decodeImage(String? base64Str) {
		if (base64Str == null || base64Str.isEmpty) return null;
		try {
			return base64Decode(base64Str);
		} catch (_) {
			return null;
		}
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		return Scaffold(
			appBar: AppBar(
				title: Text('قائمة المحلات'),
				centerTitle: true,
				backgroundColor: Colors.deepPurple,
				elevation: 0,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh, color: Colors.white),
						onPressed: _fetchStores,
						tooltip: 'تحديث',
					),
				],
			),
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade50],
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
					),
				),
				padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
				child: _isLoading
						? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
						: _stores.isEmpty
						? Center(
					child: Text(
						'لا توجد بيانات متاحة حاليًا.',
						style: theme.textTheme.titleLarge!.copyWith(
							color: Colors.deepPurple.shade700,
							fontWeight: FontWeight.bold,
						),
					),
				)
						: ListView.separated(
					itemCount: _stores.length,
					separatorBuilder: (_, __) => SizedBox(height: 14),
					itemBuilder: (context, index) {
						final store = _stores[index];
						final img = _decodeImage(store.imageBase64);

						// هنا نغلف البطاقة بـ InkWell حتى تكون كلها قابلة للنقر
						return InkWell(
							borderRadius: BorderRadius.circular(20),
							onTap: () {
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => AllProductsPage(
											storeId: store.id,
											storeName: store.name,
											user: widget.user, // <-- تمرير المستخدم هنا
										),
									),
								);
							},
							child: Card(
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(20),
								),
								elevation: 6,
								shadowColor: Colors.deepPurple.withOpacity(0.4),
								child: Container(
									padding: EdgeInsets.all(14),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(20),
										color: Colors.white.withOpacity(0.9),
									),
									child: Column(
										children: [
											Row(
												children: [
													ClipRRect(
														borderRadius: BorderRadius.circular(15),
														child: img != null
																? Image.memory(
															img,
															width: 100,
															height: 100,
															fit: BoxFit.cover,
														)
																: Container(
															width: 100,
															height: 100,
															color: Colors.deepPurple.shade100,
															child: Icon(
																Icons.storefront,
																size: 50,
																color: Colors.deepPurple.shade400,
															),
														),
													),
													SizedBox(width: 16),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text(
																	store.name,
																	style: theme.textTheme.titleLarge!.copyWith(
																		color: Colors.deepPurple.shade900,
																		fontWeight: FontWeight.bold,
																	),
																),
																SizedBox(height: 8),
																Text(
																	store.description,
																	maxLines: 3,
																	overflow: TextOverflow.ellipsis,
																	style: theme.textTheme.bodyMedium!.copyWith(
																		color: Colors.deepPurple.shade700,
																		height: 1.3,
																	),
																),
																SizedBox(height: 8),
																Row(
																	children: [
																		Icon(Icons.location_on,
																				color: Colors.deepPurple.shade300,
																				size: 18),
																		SizedBox(width: 4),
																		Expanded(
																			child: Text(
																				store.address,
																				style: theme.textTheme.bodySmall!.copyWith(
																					color: Colors.deepPurple.shade400,
																				),
																				overflow: TextOverflow.ellipsis,
																			),
																		),
																	],
																),
															],
														),
													),
												],
											),
											SizedBox(height: 12),
											ElevatedButton.icon(
												onPressed: () {
													Navigator.push(
														context,
														MaterialPageRoute(
															builder: (context) => AllProductsPage(
																storeId: store.id,
																storeName: store.name,
																user: widget.user, // <-- تمرير المستخدم هنا
															),
														),
													);
												},
												icon: Icon(Icons.storefront_outlined,
														size: 28, color: Color(0xFF4A2900)),
												label: Text(
													"عرض المنتجات",
													style: TextStyle(
														fontSize: 20,
														fontWeight: FontWeight.bold,
														color: Color(0xFF4A2900),
													),
												),
												style: ElevatedButton.styleFrom(
													padding:
													EdgeInsets.symmetric(horizontal: 70, vertical: 18),
													backgroundColor: Color(0xFFFFC107),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(40),
													),
													elevation: 18,
													shadowColor: Colors.amberAccent.withOpacity(0.9),
													foregroundColor: Colors.brown.shade800,
												),
											),
										],
									),
								),
							),
						);
					},
				),
			),
		);
	}
}

