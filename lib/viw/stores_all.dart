import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:convex_bottom_bar/convex_bottom_bar.dart'; // <-- إضافة مكتبة شريط التنقل
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // <-- إضافة مكتبة التأثيرات الحركية
import 'package:shimmer/shimmer.dart'; // <-- إضافة مكتبة تأثير التحميل

// --- تأكد من صحة مسارات الاستيراد ---
import '../ApiConfig.dart';
import 'ProductDetailsPage.dart';
import '../model/user_model.dart';

// --- نموذج المتجر (لا تغييرات هنا) ---
class Store {
	final String id;
	final String vendorId; // تم تغيير الاسم هنا
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
		required this.vendorId, // تغيير هنا
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
			vendorId: json['vendor_id']?.toString() ?? '', // تغيير هنا
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

// --- الصفحة الرئيسية لعرض قائمة المتاجر (مع التعديلات الجمالية) ---
class SimpleStoreListPage extends StatefulWidget {
	final User user;

	const SimpleStoreListPage({Key? key, required this.user}) : super(key: key);

	@override
	_SimpleStoreListPageState createState() => _SimpleStoreListPageState();
}

class _SimpleStoreListPageState extends State<SimpleStoreListPage> {
	final String apiUrl = ApiHelper.url('stores.php');
	List<Store> _stores = [];
	bool _isLoading = true; // <-- البدء بحالة التحميل
	int _selectedIndex = 1; // <-- فهرس التبويب النشط (المتاجر)

	// --- تعريف ألوان الثيم ---
	final Color primaryColor = Colors.blue.shade800;
	final Color accentColor = Colors.lightBlue.shade300;
	final Color backgroundColor = Colors.grey.shade100;
	final Color cardColor = Colors.white;
	final Color shadowColor = Colors.blueGrey.withOpacity(0.2);

	@override
	void initState() {
		super.initState();
		_fetchStores();
	}

	Future<void> _fetchStores() async {
		if (!mounted) return;
		setState(() => _isLoading = true);
		try {
			// --- تأخير بسيط لمحاكاة التحميل وإظهار تأثير Shimmer ---
			await Future.delayed(const Duration(milliseconds: 1500));
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (resp.statusCode == 200) {
				final data = json.decode(resp.body) as List;
				if (mounted) {
					setState(() => _stores = data.map((e) => Store.fromJson(e)).toList());
				}
			} else {
				_showErrorSnackBar('خطأ في جلب البيانات: ${resp.statusCode}');
			}
		} catch (e) {
			_showErrorSnackBar('حدث خطأ: $e');
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	void _showErrorSnackBar(String message) {
		if (!mounted) return;
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: Colors.redAccent,
			),
		);
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
		final textTheme = Theme.of(context).textTheme;

		return Scaffold(
			backgroundColor: backgroundColor,
			appBar: AppBar(
				title: Text('المتاجر المتاحة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
				centerTitle: true,
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
				elevation: 4.0,
				actions: [
					IconButton(
						icon: const Icon(Icons.refresh, color: Colors.white),
						onPressed: _isLoading ? null : _fetchStores,
						tooltip: 'تحديث القائمة',
					),
				],
			),
			body: _buildBody(textTheme),
			// --- شريط التنقل السفلي الأنيق ---
			bottomNavigationBar: ConvexAppBar(
				style: TabStyle.reactCircle,
				backgroundColor: primaryColor,
				activeColor: Colors.white,
				color: Colors.white70,
				initialActiveIndex: _selectedIndex,
				onTap: (index) => setState(() => _selectedIndex = index),
				items: const [
					TabItem(icon: Icons.home_outlined, title: 'الرئيسية'),
					TabItem(icon: Icons.storefront_outlined, title: 'المتاجر'),
					TabItem(icon: Icons.shopping_bag_outlined, title: 'السلة'),
					TabItem(icon: Icons.person_outline, title: 'الحساب'),
				],
			),
		);
	}

	Widget _buildBody(TextTheme textTheme) {
		if (_isLoading) {
			return _buildLoadingShimmer();
		}
		if (_stores.isEmpty) {
			return _buildEmptyState(textTheme);
		}
		return _buildStoreList(textTheme);
	}

	// --- تأثير التحميل (Shimmer) ---
	Widget _buildLoadingShimmer() {
		return Shimmer.fromColors(
			baseColor: Colors.grey[300]!,
			highlightColor: Colors.grey[100]!,
			child: ListView.builder(
				padding: const EdgeInsets.all(16.0),
				itemCount: 5, // عدد العناصر الوهمية أثناء التحميل
				itemBuilder: (_, __) => Padding(
					padding: const EdgeInsets.only(bottom: 16.0),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Container(
								width: 100.0,
								height: 100.0,
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(12),
								),
							),
							const SizedBox(width: 16.0),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>[
										Container(
											width: double.infinity,
											height: 18.0,
											color: Colors.white,
										),
										const SizedBox(height: 8.0),
										Container(
											width: double.infinity,
											height: 14.0,
											color: Colors.white,
										),
										const SizedBox(height: 8.0),
										Container(
											width: 100.0,
											height: 14.0,
											color: Colors.white,
										),
									],
								),
							)
						],
					),
				),
			),
		);
	}

	// --- حالة عدم وجود بيانات ---
	Widget _buildEmptyState(TextTheme textTheme) {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(Icons.store_mall_directory_outlined, size: 100, color: Colors.grey[400]),
					const SizedBox(height: 24),
					Text(
						'لا توجد متاجر متاحة حاليًا.',
						style: textTheme.headlineSmall!.copyWith(
							color: Colors.grey[600],
						),
						textAlign: TextAlign.center,
					),
					const SizedBox(height: 16),
					ElevatedButton.icon(
						onPressed: _fetchStores,
						icon: const Icon(Icons.refresh, size: 20),
						label: const Text('إعادة المحاولة'),
						style: ElevatedButton.styleFrom(
							backgroundColor: primaryColor,
							foregroundColor: Colors.white,
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(30),
							),
						),
					),
				],
			),
		);
	}

	// --- قائمة المتاجر مع تأثيرات الدخول ---
	Widget _buildStoreList(TextTheme textTheme) {
		return AnimationLimiter(
			child: ListView.separated(
				padding: const EdgeInsets.all(16.0),
				itemCount: _stores.length,
				separatorBuilder: (_, __) => const SizedBox(height: 16),
				itemBuilder: (context, index) {
					final store = _stores[index];
					return AnimationConfiguration.staggeredList(
						position: index,
						duration: const Duration(milliseconds: 400),
						child: SlideAnimation(
							verticalOffset: 50.0,
							child: FadeInAnimation(
								child: StoreCard( // <-- استخدام ودجت البطاقة الجديد
									store: store,
									user: widget.user,
									primaryColor: primaryColor,
									cardColor: cardColor,
									shadowColor: shadowColor,
									textTheme: textTheme,
									decodeImage: _decodeImage,
								),
							),
						),
					);
				},
			),
		);
	}
}

// --- ودجت بطاقة المتجر المعاد تصميمه ---
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

	@override
	Widget build(BuildContext context) {
		final img = widget.decodeImage(widget.store.imageBase64);

		return MouseRegion(
			onEnter: (_) => setState(() => _isHovering = true),
			onExit: (_) => setState(() => _isHovering = false),
			child: GestureDetector(
				onTap: () {
					Navigator.push(
						context,
						MaterialPageRoute(
							builder: (context) => AllProductsPage(
								storeId: widget.store.id,
								storeName: widget.store.name,
								user: widget.user,
							),
						),
					);
				},
				child: AnimatedContainer(
					duration: const Duration(milliseconds: 200),
					decoration: BoxDecoration(
						color: widget.cardColor,
						borderRadius: BorderRadius.circular(16),
						boxShadow: [
							BoxShadow(
								color: widget.shadowColor.withOpacity(_isHovering ? 0.4 : 0.2),
								blurRadius: _isHovering ? 12 : 8,
								offset: Offset(0, _isHovering ? 6 : 4),
							),
						],
					),
					clipBehavior: Clip.antiAlias,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// --- صورة المتجر المحسنة ---
							SizedBox(
								height: 150,
								width: double.infinity,
								child: img != null
										? Image.memory(
									img,
									fit: BoxFit.cover,
								)
										: Container(
									color: Colors.grey.shade200,
									child: Icon(
										Icons.storefront_outlined,
										size: 60,
										color: Colors.grey.shade400,
									),
								),
							),
							// --- تفاصيل المتجر المنسقة ---
							Padding(
								padding: const EdgeInsets.all(16.0),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											widget.store.name,
											style: widget.textTheme.titleLarge!.copyWith(
												fontWeight: FontWeight.bold,
												color: widget.primaryColor,
											),
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
										),
										const SizedBox(height: 8),
										Text(
											widget.store.description,
											maxLines: 2,
											overflow: TextOverflow.ellipsis,
											style: widget.textTheme.bodyMedium!.copyWith(
												color: Colors.black54,
												height: 1.4,
											),
										),
										const SizedBox(height: 12),
										Row(
											children: [
												Icon(Icons.location_on_outlined, color: widget.primaryColor.withOpacity(0.7), size: 18),
												const SizedBox(width: 6),
												Expanded(
													child: Text(
														widget.store.address,
														style: widget.textTheme.bodySmall!.copyWith(color: Colors.black45),
														maxLines: 1,
														overflow: TextOverflow.ellipsis,
													),
												),
											],
										),
										const SizedBox(height: 16),
										// --- زر عرض المنتجات المحسن ---
										Align(
											alignment: Alignment.centerLeft,
											child: ElevatedButton.icon(
												onPressed: () {
													Navigator.push(
														context,
														MaterialPageRoute(
															builder: (context) => AllProductsPage(
																storeId: widget.store.id,
																storeName: widget.store.name,
																user: widget.user,
															),
														),
													);
												},
												icon: const Icon(Icons.arrow_forward_ios, size: 16),
												label: const Text('عرض المنتجات'),
												style: ElevatedButton.styleFrom(
													backgroundColor: widget.primaryColor,
													foregroundColor: Colors.white,
													padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(20),
													),
													elevation: 2,
												),
											),
										),
									],
								),
							),
						],
					),
				),
			),
		);
	}
}