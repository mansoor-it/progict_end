import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

import '../ApiConfig.dart';
import 'ProductDetailsPage.dart';
import '../model/user_model.dart';

class Store {
	final String id;
	final String vendorId;
	final String categoryId;
	final String name;
	final String description;
	final String address;
	final String? imageBase64;
	final String ratingRaw;
	final String isActive;
	final String createdAt;

	Store({
		required this.id,
		required this.vendorId,
		required this.categoryId,
		required this.name,
		required this.description,
		required this.address,
		this.imageBase64,
		required this.ratingRaw,
		required this.isActive,
		required this.createdAt,
	});

	factory Store.fromJson(Map<String, dynamic> json) {
		final raw = json['rating'] ??
				json['rate'] ??
				json['avg_rating'] ??
				json['rating_value'] ??
				'0';
		return Store(
			id: json['id']?.toString() ?? '',
			vendorId: json['vendor_id']?.toString() ?? '',
			categoryId: json['category_id']?.toString() ?? '',
			name: json['name'] ?? '',
			description: json['description'] ?? '',
			address: json['address'] ?? '',
			imageBase64: (json['store_image'] as String?)?.isNotEmpty == true
					? json['store_image'] as String
					: null,
			ratingRaw: raw.toString(),
			isActive: json['is_active']?.toString() ?? '0',
			createdAt: json['created_at'] ?? '',
		);
	}
}

class SimpleStoreListPage extends StatefulWidget {
	final User user;
	const SimpleStoreListPage({Key? key, required this.user}) : super(key: key);
	@override
	_SimpleStoreListPageState createState() => _SimpleStoreListPageState();
}

class _SimpleStoreListPageState extends State<SimpleStoreListPage> {
	final String apiUrl = ApiHelper.url('stores.php');
	List<Store> _stores = [];
	bool _isLoading = true;
	int _selectedIndex = 1;

	// متغير البحث
	String _searchQuery = '';

	final Color primaryColor    = Colors.blue.shade800;
	final Color accentColor     = Colors.lightBlue.shade300;
	final Color backgroundColor = Colors.grey.shade100;
	final Color cardColor       = Colors.white;
	final Color shadowColor     = Colors.blueGrey.withOpacity(0.2);

	@override
	void initState() {
		super.initState();
		_fetchStores();
	}

	Future<void> _fetchStores() async {
		if (!mounted) return;
		setState(() => _isLoading = true);
		try {
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (resp.statusCode == 200) {
				final data = json.decode(resp.body) as List;
				if (mounted) {
					setState(() =>
					_stores = data.map((e) => Store.fromJson(e)).toList()
					);
				}
			} else {
				_showError('خطأ في جلب البيانات: ${resp.statusCode}');
			}
		} catch (e) {
			_showError('حدث خطأ: $e');
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	void _showError(String msg) {
		if (!mounted) return;
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
		);
	}

	Uint8List? _decodeImage(String? b64) {
		if (b64 == null || b64.isEmpty) return null;
		try {
			return base64Decode(b64);
		} catch (_) {
			return null;
		}
	}

	@override
	Widget build(BuildContext context) {
		final textTheme = Theme.of(context).textTheme;
		return Scaffold(
			backgroundColor: backgroundColor,
			appBar: AppBar(
				backgroundColor: primaryColor,
				flexibleSpace: Container(
					decoration: BoxDecoration(
						gradient: LinearGradient(
							colors: [primaryColor, accentColor],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
					),
				),
				toolbarHeight: 100, // رفع الارتفاع لاستيعاب الصف
				title: Padding(
					padding: const EdgeInsets.only(top: 12.0),
					child: Row(
						children: [
							const Icon(Icons.storefront, color: Colors.white),
							const SizedBox(width: 8),
							const Text(
								'المتاجر المتاحة',
								style: TextStyle(
									fontWeight: FontWeight.bold,
									fontSize: 20,
									color: Colors.white,
								),
							),
							const Spacer(),
							Expanded(
								flex: 3,
								child: Container(
									height: 36,
									padding: const EdgeInsets.only(left: 8),
									child: TextField(
										decoration: InputDecoration(
											hintText: 'ابحث عن متجر...',
											hintStyle: const TextStyle(fontSize: 14),
											prefixIcon: const Icon(Icons.search, size: 20),
											contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(30),
												borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
											),
											filled: true,
											fillColor: Colors.white,
										),
										onChanged: (val) => setState(() => _searchQuery = val),
									),
								),
							),
						],
					),
				),
				actions: [
					IconButton(
						icon: const Icon(Icons.refresh),
						onPressed: _isLoading ? null : _fetchStores,
					),
				],
			),
			body: _buildBody(textTheme),
			bottomNavigationBar: ConvexAppBar(
				style: TabStyle.reactCircle,
				backgroundColor: primaryColor,
				activeColor: Colors.white,
				color: Colors.white70,
				initialActiveIndex: _selectedIndex,
				onTap: (i) => setState(() => _selectedIndex = i),
				items: const [
					TabItem(icon: Icons.home_outlined, title: 'الرئيسية'),
					TabItem(icon: Icons.storefront_outlined, title: 'المتاجر'),
					TabItem(icon: Icons.shopping_bag_outlined, title: 'السلة'),
					TabItem(icon: Icons.person_outline, title: 'الحساب'),
				],
			),
		);
	}

	Widget _buildBody(TextTheme tt) {
		if (_isLoading) return _loadingShimmer();
		if (_stores.isEmpty) return _emptyState(tt);

		// تطبيق البحث فقط
		List<Store> filteredStores = _stores.where((store) {
			return store.name.contains(_searchQuery) ||
					store.description.contains(_searchQuery);
		}).toList();

		return AnimationLimiter(
			child: GridView.builder(
				padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
				gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2, mainAxisSpacing: 32, crossAxisSpacing: 32, childAspectRatio: 0.6
				),
				itemCount: filteredStores.length,
				itemBuilder: (_, i) => AnimationConfiguration.staggeredGrid(
					position: i, duration: const Duration(milliseconds: 400), columnCount: 2,
					child: ScaleAnimation(
						child: FadeInAnimation(
							child: StoreCard(
								store: filteredStores[i],
								user: widget.user,
								primaryColor: primaryColor,
								cardColor: cardColor,
								shadowColor: shadowColor,
								textTheme: tt,
								decodeImage: _decodeImage,
							),
						),
					),
				),
			),
		);
	}

	Widget _loadingShimmer() => Shimmer.fromColors(
		baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
		child: ListView.builder(
			padding: const EdgeInsets.all(16), itemCount: 5,
			itemBuilder: (_, __) => Padding(
				padding: const EdgeInsets.only(bottom: 16),
				child: Row(children: [
					Container(width: 100, height: 100, decoration: BoxDecoration(
							color: Colors.white, borderRadius: BorderRadius.circular(12))),
					const SizedBox(width: 16),
					Expanded(child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: const [
							SizedBox(height: 18, width: double.infinity, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white))),
							SizedBox(height: 8),
							SizedBox(height: 14, width: double.infinity, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white))),
							SizedBox(height: 8),
							SizedBox(height: 14, width: 80, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white))),
						],
					)),
				]),
			),
		),
	);

	Widget _emptyState(TextTheme tt) => Center(
		child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
			Icon(Icons.store_mall_directory_outlined, size: 100, color: Colors.grey[400]),
			const SizedBox(height: 24),
			Text('لا توجد متاجر متاحة حاليًا.',
					style: tt.headlineSmall!.copyWith(color: Colors.grey[600]),
					textAlign: TextAlign.center),
			const SizedBox(height: 16),
			ElevatedButton.icon(
				onPressed: _fetchStores,
				icon: const Icon(Icons.refresh, size: 20),
				label: const Text('إعادة المحاولة'),
				style: ElevatedButton.styleFrom(
					padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
				),
			),
		]),
	);
}

class StoreCard extends StatefulWidget {
	final Store store;
	final User user;
	final Color primaryColor;
	final Color cardColor;
	final Color shadowColor;
	final TextTheme textTheme;
	final Uint8List? Function(String?) decodeImage;

	const StoreCard({
		Key? key,
		required this.store,
		required this.user,
		required this.primaryColor,
		required this.cardColor,
		required this.shadowColor,
		required this.textTheme,
		required this.decodeImage,
	}) : super(key: key);

	@override
	_StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
	bool _isHovering = false;

	double _parseRating(String s) {
		var str = s.replaceAll('٫', '.').replaceAll(',', '.');
		const map = {
			'٠': '0',
			'١': '1',
			'٢': '2',
			'٣': '3',
			'٤': '4',
			'٥': '5',
			'٦': '6',
			'٧': '7',
			'٨': '8',
			'٩': '9'
		};
		map.forEach((a, b) => str = str.replaceAll(a, b));
		return double.tryParse(str) ?? 0.0;
	}

	List<Widget> _buildRatingStars(double rating) {
		int full = rating.floor();
		bool half = (rating - full) >= 0.5;
		List<Widget> stars = [];
		for (var i = 0; i < full; i++) {
			stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
		}
		if (half) stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
		while (stars.length < 5) {
			stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
		}
		return stars;
	}

	@override
	Widget build(BuildContext context) {
		final img = widget.decodeImage(widget.store.imageBase64);
		final double ratingValue = _parseRating(widget.store.ratingRaw);

		return MouseRegion(
			onEnter: (_) => setState(() => _isHovering = true),
			onExit: (_) => setState(() => _isHovering = false),
			child: GestureDetector(
				onTap: () => Navigator.push(
					context,
					MaterialPageRoute(
						builder: (_) => AllProductsPage(
							storeId: widget.store.id,
							storeName: widget.store.name,
							user: widget.user,
						),
					),
				),
				child: AnimatedContainer(
					duration: const Duration(milliseconds: 200),
					margin: const EdgeInsets.symmetric(vertical: 12),
					decoration: BoxDecoration(
						color: widget.cardColor,
						borderRadius: BorderRadius.circular(16),
						boxShadow: [
							BoxShadow(
								color: widget.shadowColor.withOpacity(_isHovering ? 0.4 : 0.2),
								blurRadius: _isHovering ? 12 : 8,
								offset: Offset(0, _isHovering ? 6 : 4),
							)
						],
					),
					clipBehavior: Clip.antiAlias,
					child: Column(
						children: [
							SizedBox(
								height: 170,
								width: double.infinity,
								child: img != null
										? Image.memory(img, fit: BoxFit.cover)
										: Container(
									color: Colors.grey.shade200,
									child: Icon(Icons.storefront_outlined,
											size: 60, color: Colors.grey.shade400),
								),
							),
							Expanded(
								child: SingleChildScrollView(
									padding: const EdgeInsets.all(12),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												widget.store.name,
												style: widget.textTheme.titleMedium!
														.copyWith(fontWeight: FontWeight.bold, color: widget.primaryColor),
												maxLines: 1,
												overflow: TextOverflow.ellipsis,
											),
											const SizedBox(height: 6),
											Text(
												widget.store.description,
												style: widget.textTheme.bodyMedium!
														.copyWith(color: Colors.black54, height: 1.4),
												maxLines: 3, overflow: TextOverflow.ellipsis,
											),
											const SizedBox(height: 8),
											Row(children: _buildRatingStars(ratingValue)),
										],
									),
								),
							),
						],
					),
				),
			),
		);
	}
}
