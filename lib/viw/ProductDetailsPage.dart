import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// --- استيراد الملفات الأخرى (تأكد من صحة المسارات) ---
import '../service/ProductDetailsPage_server.dart';
import '../service/server_cart.dart';
import 'cart_screen.dart';
import '../model/user_model.dart';
import '../model/model_cart.dart';
import 'f/product_details_page.dart';

// --- قائمة السلة العامة (يفضل استخدام إدارة حالة أفضل) ---
List<Map<String, dynamic>> cartItems = [];

// ======================================================
// الصفحة الرئيسية لعرض جميع المنتجات
// ======================================================
class AllProductsPage extends StatefulWidget {
	final String storeId;
	final String storeName;
	final User user;

	const AllProductsPage({
		Key? key,
		required this.storeId,
		required this.storeName,
		required this.user,
	}) : super(key: key);

	@override
	_AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
	List<dynamic> products = [];
	List<dynamic> colors = [];
	List<dynamic> sizes = [];
	bool isLoading = true;
	bool _isGridView = true;

	final AllProductsController _controller = AllProductsController();
	final CartController _cartController = CartController();

	@override
	void initState() {
		super.initState();
		fetchAllData();
	}

	Future<void> fetchAllData() async {
		try {
			final data = await _controller.fetchAllData(widget.storeId);
			if (mounted) {
				setState(() {
					products = (data['products'] ?? []).map((p) {
						final random = math.Random();
						p['is_new'] = random.nextBool() && random.nextDouble() > 0.7;
						p['discount_percentage'] = p['is_new']! ? 0 : (random.nextDouble() > 0.8 ? random.nextInt(30) + 10 : 0);
						p['is_bestseller'] = !p['is_new']! && p['discount_percentage'] == 0 && random.nextDouble() > 0.7;
						return p;
					}).toList();
					colors = data['colors'] ?? [];
					sizes = data['sizes'] ?? [];
					isLoading = false;
				});
			}
		} catch (e) {
			print("Error fetching products data: $e");
			if (mounted) {
				setState(() {
					isLoading = false;
				});
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('حدث خطأ أثناء جلب المنتجات')),
				);
			}
		}
	}

	Color getColorFromName(String colorName) {
		return _controller.getColorFromName(colorName);
	}

	void _updateCartState() {
		setState(() {});
	}

	Future<void> _handleAddToCart(Map<String, dynamic> itemMap) async {
		try {
			final success = await _cartController.addCartItem(
				userId: widget.user.id,
				storeId: widget.storeId,
				productId: itemMap['id'].toString(),
				quantity: itemMap['quantity'].toString(),
				unitPrice: itemMap['price'].toString(),
				productColorId: itemMap['color_id']?.toString(),
				productSizeId: itemMap['size_id']?.toString(),
				productImage: itemMap['image']?.toString(),
			);

			if (success) {
				final existingIndex = cartItems.indexWhere((cartItem) =>
				cartItem['id'] == itemMap['id'] &&
						cartItem['color_id'] == itemMap['color_id'] &&
						cartItem['size_id'] == itemMap['size_id'] &&
						cartItem['store_id'] == widget.storeId);
				if (existingIndex != -1) {
					setState(() {
						cartItems[existingIndex]['quantity'] += itemMap['quantity'];
					});
				} else {
					setState(() {
						cartItems.add({
							...itemMap,
							'store_id': widget.storeId,
						});
					});
				}
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Row(children: [
								const Icon(Icons.check_circle_outline, color: Colors.white),
								const SizedBox(width: 8),
								Expanded(child: Text("تمت إضافة ${itemMap['name']} للسلة!")),
							]),
							backgroundColor: Colors.green[600],
							duration: const Duration(seconds: 2),
						),
					);
				}
			} else {
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(
							content: Row(children: [
								Icon(Icons.error_outline, color: Colors.white),
								SizedBox(width: 8),
								Text("فشل إضافة المنتج. حاول مرة أخرى."),
							]),
							backgroundColor: Colors.redAccent,
						),
					);
				}
			}
		} catch (e) {
			print("Error adding item to cart: $e");
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text("حدث خطأ غير متوقع: ${e.toString()}"),
						backgroundColor: Colors.red,
					),
				);
			}
		}
	}

	// دالة للانتقال إلى صفحة تفاصيل المنتج
	void _navigateToProductDetails(dynamic product) {
		final productIdStr = product['id'].toString();
		final productColors = colors.where((c) => c != null && c['product_id']?.toString() == productIdStr).toList();
		final productSizes = sizes.where((s) => s != null && s['product_id']?.toString() == productIdStr).toList();

		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => ProductDetailsPage(
					product: product,
					productColors: productColors,
					productSizes: productSizes,
					getColorFromName: getColorFromName,
					onAddToCart: _handleAddToCart,
					user: widget.user,
					storeId: widget.storeId,
				),
			),
		).then((_) {
			// تحديث حالة السلة عند العودة من صفحة التفاصيل
			_updateCartState();
		});
	}

	@override
	Widget build(BuildContext context) {
		final double screenWidth = MediaQuery.of(context).size.width;
		final int gridCrossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
		// --- الحفاظ على childAspectRatio لتحديد ارتفاع ثابت للبطاقة ---
		final double gridChildAspectRatio = screenWidth < 600 ? 0.68 : (screenWidth < 900 ? 0.75 : 0.85);

		return Directionality(
			textDirection: TextDirection.rtl,
			child: Scaffold(
				appBar: AppBar(
					title: Text(widget.storeName),
					flexibleSpace: Container(
						decoration: BoxDecoration(
							gradient: LinearGradient(
								colors: [Colors.teal[400]!, Colors.teal[700]!],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
						),
					),
					foregroundColor: Colors.white,
					elevation: 3.0,
					actions: [
						IconButton(
							icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
							tooltip: _isGridView ? 'عرض كقائمة' : 'عرض كشبكة',
							onPressed: () {
								setState(() {
									_isGridView = !_isGridView;
								});
							},
						),
						IconButton(
							icon: Badge(
								label: Text(cartItems.length.toString()),
								isLabelVisible: cartItems.isNotEmpty,
								backgroundColor: Colors.redAccent[700],
								child: const Icon(Icons.shopping_bag_outlined),
							),
							tooltip: 'عرض السلة',
							onPressed: () async {
								await Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => CartPage(
											userId: widget.user.id,
											cartItems: cartItems,
										),
									),
								);
								_updateCartState();
							},
						),
						const SizedBox(width: 8),
					],
				),
				body: isLoading
						? Center(child: CircularProgressIndicator(color: Colors.teal[700]))
						: products.isEmpty
						? _buildEmptyState()
						: _buildProductDisplay(gridCrossAxisCount, gridChildAspectRatio),
			),
		);
	}

	Widget _buildEmptyState() {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[400]),
					const SizedBox(height: 20),
					Text(
						"لا توجد منتجات متاحة حاليًا",
						style: TextStyle(fontSize: 18, color: Colors.grey[600]),
						textAlign: TextAlign.center,
					),
				],
			),
		);
	}

	Widget _buildProductDisplay(int crossAxisCount, double childAspectRatio) {
		return AnimationLimiter(
			child: _isGridView
					? GridView.builder(
				padding: const EdgeInsets.all(12.0),
				itemCount: products.length,
				// --- الحفاظ على المندوب الأصلي لتثبيت حجم البطاقة ---
				gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
					crossAxisCount: crossAxisCount,
					crossAxisSpacing: 12.0,
					mainAxisSpacing: 12.0,
					childAspectRatio: childAspectRatio,
				),
				itemBuilder: (context, index) {
					return _buildAnimatedItem(index, _buildGridItem(index));
				},
			)
					: ListView.builder(
				padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
				itemCount: products.length,
				itemBuilder: (context, index) {
					return _buildAnimatedItem(index, _buildListItem(index));
				},
			),
		);
	}

	Widget _buildAnimatedItem(int index, Widget child) {
		return AnimationConfiguration.staggeredList(
			position: index,
			duration: const Duration(milliseconds: 375),
			child: SlideAnimation(
				verticalOffset: 50.0,
				child: FadeInAnimation(
					child: child,
				),
			),
		);
	}

	Widget _buildGridItem(int index) {
		final product = products[index];
		if (product == null || product['id'] == null) return const SizedBox.shrink();
		final productIdStr = product['id'].toString();
		final productColors = colors.where((c) => c != null && c['product_id']?.toString() == productIdStr).toList();
		final productSizes = sizes.where((s) => s != null && s['product_id']?.toString() == productIdStr).toList();

		return ProductGridCard(
			key: ValueKey(product['id']),
			product: product,
			productColors: productColors,
			productSizes: productSizes,
			getColorFromName: getColorFromName,
			onAddToCart: _handleAddToCart,
			onTap: () => _navigateToProductDetails(product), // إضافة دالة النقر
		);
	}

	Widget _buildListItem(int index) {
		final product = products[index];
		if (product == null || product['id'] == null) return const SizedBox.shrink();
		final productIdStr = product['id'].toString();
		final productColors = colors.where((c) => c != null && c['product_id']?.toString() == productIdStr).toList();
		final productSizes = sizes.where((s) => s != null && s['product_id']?.toString() == productIdStr).toList();

		return Padding(
			padding: const EdgeInsets.only(bottom: 12.0),
			child: ProductListCard(
				key: ValueKey(product['id']),
				product: product,
				productColors: productColors,
				productSizes: productSizes,
				getColorFromName: getColorFromName,
				onAddToCart: _handleAddToCart,
				onTap: () => _navigateToProductDetails(product), // إضافة دالة النقر
			),
		);
	}
}

// ======================================================
// ودجت بطاقة المنتج (للشبكة) - معدلة لإضافة وظيفة النقر
// ======================================================
class ProductGridCard extends StatefulWidget {
	final dynamic product;
	final List<dynamic> productColors;
	final List<dynamic> productSizes;
	final Color Function(String) getColorFromName;
	final Future<void> Function(Map<String, dynamic>) onAddToCart;
	final VoidCallback? onTap; // إضافة دالة النقر

	const ProductGridCard({
		Key? key,
		required this.product,
		required this.productColors,
		required this.productSizes,
		required this.getColorFromName,
		required this.onAddToCart,
		this.onTap, // إضافة دالة النقر
	}) : super(key: key);

	@override
	_ProductGridCardState createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {
	int quantity = 1;
	String? selectedColorId;
	String? selectedColorName;
	String? selectedSizeId;
	String? selectedSizeName;
	bool _isHovering = false;
	bool _showFullDescription = false;

	Widget _buildProductImageWithBadge() {
		final imageBase64 = widget.product['image']?.toString();
		final badge = _buildBadge(widget.product);

		return AspectRatio(
			aspectRatio: 1.0,
			child: Stack(
				children: [
					Container(
						decoration: BoxDecoration(
							color: Colors.grey[100],
							borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
						),
						child: ClipRRect(
							borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
							child: (imageBase64 != null && imageBase64.isNotEmpty)
									? Image.memory(
								base64Decode(imageBase64),
								fit: BoxFit.cover,
								width: double.infinity,
								height: double.infinity,
								errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage("خطأ بالصورة"),
							)
									: _buildPlaceholderImage("لا توجد صورة"),
						),
					),
					if (badge != null)
						Positioned(
							top: 8,
							right: 8,
							child: badge,
						),
					// إضافة طبقة شفافة للنقر على الصورة
					Positioned.fill(
						child: Material(
							color: Colors.transparent,
							child: InkWell(
								borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
								onTap: widget.onTap,
								child: Container(
									decoration: BoxDecoration(
										color: _isHovering ? Colors.black.withOpacity(0.1) : Colors.transparent,
										borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
									),
									child: _isHovering ? const Center(
										child: Icon(
											Icons.visibility_outlined,
											color: Colors.white,
											size: 32,
										),
									) : null,
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildPlaceholderImage(String message) {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40),
					const SizedBox(height: 8),
					Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
				],
			),
		);
	}

	Widget? _buildBadge(dynamic product) {
		final isNew = product['is_new'] == true;
		final discountPercentage = product['discount_percentage'] ?? 0;
		final isBestseller = product['is_bestseller'] == true;

		if (isNew) {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
				decoration: BoxDecoration(
					color: Colors.green[600],
					borderRadius: BorderRadius.circular(12),
				),
				child: const Text(
					"جديد",
					style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
				),
			);
		} else if (discountPercentage > 0) {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
				decoration: BoxDecoration(
					color: Colors.red[600],
					borderRadius: BorderRadius.circular(12),
				),
				child: Text(
					"-$discountPercentage%",
					style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
				),
			);
		} else if (isBestseller) {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
				decoration: BoxDecoration(
					color: Colors.orange[600],
					borderRadius: BorderRadius.circular(12),
				),
				child: const Text(
					"الأكثر مبيعاً",
					style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
				),
			);
		}
		return null;
	}

	@override
	Widget build(BuildContext context) {
		final price = widget.product['price']?.toString() ?? '0.0';
		final productName = widget.product['name'] ?? "منتج غير مسمى";
		final productDescription = widget.product['description'] ?? "لا يوجد وصف لهذا المنتج";

		return MouseRegion(
			onEnter: (_) => setState(() => _isHovering = true),
			onExit: (_) => setState(() => _isHovering = false),
			child: Card(
				elevation: _isHovering ? 8.0 : 3.0,
				shadowColor: Colors.teal.withOpacity(0.3),
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				clipBehavior: Clip.antiAlias,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						_buildProductImageWithBadge(),
						// --- تعديل: استخدام Expanded مع SingleChildScrollView للمحتوى ---
						Expanded(
							child: InkWell(
								onTap: widget.onTap, // إضافة النقر على المحتوى أيضاً
								child: SingleChildScrollView(
									padding: const EdgeInsets.all(12.0),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											// --- الجزء العلوي: الاسم والسعر ---
											Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(
														productName,
														style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
														maxLines: 1,
														overflow: TextOverflow.ellipsis,
													),
													const SizedBox(height: 4),
													Text(
														"$price \$",
														style: Theme.of(context).textTheme.titleMedium?.copyWith(
															fontWeight: FontWeight.bold,
															color: Colors.teal[800],
															fontSize: 16,
														),
													),
												],
											),
											const SizedBox(height: 8),

											// --- وصف المنتج قابل للتوسيع ---
											Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													InkWell(
														onTap: () => setState(() => _showFullDescription = !_showFullDescription),
														child: Row(
															children: [
																Text(
																	"الوصف:",
																	style: TextStyle(
																		fontWeight: FontWeight.bold,
																		fontSize: 12,
																		color: Colors.grey[700],
																	),
																),
																Icon(
																	_showFullDescription ? Icons.expand_less : Icons.expand_more,
																	size: 18,
																	color: Colors.grey[600],
																),
															],
														),
													),
													const SizedBox(height: 4),
													Text(
														productDescription,
														style: TextStyle(
															fontSize: 12,
															color: Colors.grey[600],
														),
														maxLines: _showFullDescription ? null : 2,
														overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
													),
												],
											),
											const SizedBox(height: 8),

											// --- الجزء السفلي: الألوان والمقاسات والأزرار ---
											if (widget.productColors.isNotEmpty || widget.productSizes.isNotEmpty)
												_buildCompactSelectors(),
											_buildActionRow(price),
										],
									),
								),
							),
						),
					],
				),
			),
		);
	}

	Widget _buildCompactSelectors() {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4.0),
			child: Row(
				children: [
					if (widget.productColors.isNotEmpty)
						Expanded(
							child: _buildDropdown(selectedColorId, "اللون", widget.productColors, (value, item) {
								setState(() {
									selectedColorId = value;
									selectedColorName = item?['color_name']?.toString();
								});
							}, (item) {
								final colorName = item?['color_name']?.toString() ?? '';
								return Row(mainAxisSize: MainAxisSize.min, children: [
									CircleAvatar(backgroundColor: widget.getColorFromName(colorName), radius: 7),
									const SizedBox(width: 6),
									Expanded(child: Text(colorName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
								]);
							}),
						),
					if (widget.productColors.isNotEmpty && widget.productSizes.isNotEmpty)
						const SizedBox(width: 8),
					if (widget.productSizes.isNotEmpty)
						Expanded(
							child: _buildDropdown(selectedSizeId, "المقاس", widget.productSizes, (value, item) {
								setState(() {
									selectedSizeId = value;
									selectedSizeName = item?['size']?.toString();
								});
							}, (item) {
								final sizeValue = item?['size']?.toString() ?? '';
								return Text(sizeValue, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis);
							}),
						),
				],
			),
		);
	}

	Widget _buildDropdown(
			String? currentValue,
			String hint,
			List<dynamic> items,
			Function(String?, dynamic) onChanged,
			Widget Function(dynamic) itemBuilder,
			) {
		return DropdownButtonHideUnderline(
			child: DropdownButtonFormField<String>(
				value: currentValue,
				isDense: true,
				isExpanded: true,
				hint: Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
				decoration: InputDecoration(
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
					),
					enabledBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
					),
					focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide(color: Colors.teal, width: 1.5),
					),
					contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
					fillColor: Colors.white,
					filled: true,
				),
				onChanged: (value) {
					final selectedItem = items.firstWhere((i) => i['id']?.toString() == value, orElse: () => null);
					onChanged(value, selectedItem);
				},
				items: items.map<DropdownMenuItem<String>>((item) {
					final itemId = item['id']?.toString();
					return DropdownMenuItem<String>(
						value: itemId,
						child: itemBuilder(item),
					);
				}).toList(),
			),
		);
	}

	Widget _buildActionRow(String price) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Row(
					children: [
						_buildQuantityButton(Icons.remove, () => setState(() => quantity--), quantity > 1),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 8.0),
							child: Text(quantity.toString(), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
						),
						_buildQuantityButton(Icons.add, () => setState(() => quantity++)),
					],
				),
				SizedBox(
					width: 42, height: 42,
					child: Tooltip(
						message: 'إضافة إلى السلة',
						child: ElevatedButton(
							onPressed: () {
								if (widget.productColors.isNotEmpty && selectedColorId == null) {
									_showWarningSnackBar("الرجاء اختيار اللون أولاً"); return;
								}
								if (widget.productSizes.isNotEmpty && selectedSizeId == null) {
									_showWarningSnackBar("الرجاء اختيار المقاس أولاً"); return;
								}
								widget.onAddToCart({
									'id': widget.product['id'], 'name': widget.product['name'] ?? 'منتج',
									'price': double.tryParse(price) ?? 0.0, 'quantity': quantity,
									'color_id': selectedColorId, 'color_name': selectedColorName,
									'size_id': selectedSizeId, 'size_name': selectedSizeName,
									'image': widget.product['image'],
									'store_id': widget.product['store_id'], // تأكد من وجود هذا الحقل أو قم بتمريره
								});
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.teal[600],
								foregroundColor: Colors.white,
								padding: EdgeInsets.zero,
								shape: const CircleBorder(),
								elevation: 3.0,
							),
							child: const Icon(Icons.add_shopping_cart_outlined, size: 20),
						),
					),
				),
			],
		);
	}

	Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed, [bool enabled = true]) {
		return SizedBox(
			width: 30, height: 30,
			child: IconButton(
				padding: EdgeInsets.zero,
				icon: Icon(icon, size: 18, color: enabled ? (icon == Icons.add ? Colors.green[700] : Colors.red[700]) : Colors.grey[400]),
				onPressed: enabled ? onPressed : null,
			),
		);
	}

	void _showWarningSnackBar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.orangeAccent[700]),
		);
	}
}

// ======================================================
// ودجت بطاقة المنتج (للقائمة) - معدلة لإضافة وظيفة النقر
// ======================================================
class ProductListCard extends StatefulWidget {
	final dynamic product;
	final List<dynamic> productColors;
	final List<dynamic> productSizes;
	final Color Function(String) getColorFromName;
	final Future<void> Function(Map<String, dynamic>) onAddToCart;
	final VoidCallback? onTap; // إضافة دالة النقر

	const ProductListCard({
		Key? key,
		required this.product,
		required this.productColors,
		required this.productSizes,
		required this.getColorFromName,
		required this.onAddToCart,
		this.onTap, // إضافة دالة النقر
	}) : super(key: key);

	@override
	_ProductListCardState createState() => _ProductListCardState();
}

class _ProductListCardState extends State<ProductListCard> {
	int quantity = 1;
	String? selectedColorId;
	String? selectedColorName;
	String? selectedSizeId;
	String? selectedSizeName;
	bool _showFullDescription = false;

	Widget _buildProductImageWithBadge() {
		final imageBase64 = widget.product['image']?.toString();
		final badge = _buildBadge(widget.product);

		return SizedBox(
			width: 110,
			height: 110,
			child: Stack(
				fit: StackFit.expand,
				children: [
					ClipRRect(
						borderRadius: BorderRadius.circular(12),
						child: Container(
							color: Colors.grey[100],
							child: (imageBase64 != null && imageBase64.isNotEmpty)
									? Image.memory(
								base64Decode(imageBase64),
								fit: BoxFit.cover,
								errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage("خطأ"),
							)
									: _buildPlaceholderImage("لا صورة"),
						),
					),
					if (badge != null)
						Positioned(
							top: 6,
							right: 6,
							child: badge,
						),
					// إضافة طبقة شفافة للنقر على الصورة
					Positioned.fill(
						child: Material(
							color: Colors.transparent,
							child: InkWell(
								borderRadius: BorderRadius.circular(12),
								onTap: widget.onTap,
								child: Container(
									decoration: BoxDecoration(
										color: Colors.black.withOpacity(0.05),
										borderRadius: BorderRadius.circular(12),
									),
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildPlaceholderImage(String message) {
		return Center(
			child: Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
		);
	}

	Widget? _buildBadge(dynamic product) {
		final isNew = product['is_new'] == true;
		final discountPercentage = product['discount_percentage'] ?? 0;
		final isBestseller = product['is_bestseller'] == true;

		if (isNew) {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
				decoration: BoxDecoration(
					color: Colors.green[600],
					borderRadius: BorderRadius.circular(8),
				),
				child: const Text(
					"جديد",
					style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
				),
			);
		} else if (discountPercentage > 0) {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
				decoration: BoxDecoration(
					color: Colors.red[600],
					borderRadius: BorderRadius.circular(8),
				),
				child: Text(
					"-$discountPercentage%",
					style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
				),
			);
		} else if (isBestseller) {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
				decoration: BoxDecoration(
					color: Colors.orange[600],
					borderRadius: BorderRadius.circular(8),
				),
				child: const Text(
					"الأكثر مبيعاً",
					style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
				),
			);
		}
		return null;
	}

	@override
	Widget build(BuildContext context) {
		final price = widget.product['price']?.toString() ?? '0.0';
		final productName = widget.product['name'] ?? "منتج غير مسمى";
		final productDescription = widget.product['description'] ?? "لا يوجد وصف لهذا المنتج";

		return Card(
			elevation: 2.5,
			shadowColor: Colors.black.withOpacity(0.1),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			clipBehavior: Clip.antiAlias,
			child: InkWell(
				onTap: widget.onTap, // إضافة النقر على البطاقة كاملة
				child: Padding(
					padding: const EdgeInsets.all(12.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildProductImageWithBadge(),
									const SizedBox(width: 12),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													mainAxisAlignment: MainAxisAlignment.spaceBetween,
													children: [
														Expanded(
															child: Text(
																productName,
																style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
																maxLines: 1,
																overflow: TextOverflow.ellipsis,
															),
														),
														Text(
															"$price \$",
															style: Theme.of(context).textTheme.titleLarge?.copyWith(
																fontWeight: FontWeight.bold,
																color: Colors.teal[800],
															),
														),
													],
												),
												const SizedBox(height: 8),
												InkWell(
													onTap: () => setState(() => _showFullDescription = !_showFullDescription),
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Row(
																children: [
																	Text(
																		"الوصف:",
																		style: TextStyle(
																			fontWeight: FontWeight.bold,
																			fontSize: 12,
																			color: Colors.grey[700],
																		),
																	),
																	Icon(
																		_showFullDescription ? Icons.expand_less : Icons.expand_more,
																		size: 18,
																		color: Colors.grey[600],
																	),
																],
															),
															const SizedBox(height: 4),
															Text(
																productDescription,
																style: TextStyle(
																	fontSize: 12,
																	color: Colors.grey[600],
																),
																maxLines: _showFullDescription ? null : 2,
																overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
															),
														],
													),
												),
											],
										),
									),
								],
							),
							const SizedBox(height: 12),
							// --- الجزء السفلي: الألوان والمقاسات والأزرار ---
							if (widget.productColors.isNotEmpty || widget.productSizes.isNotEmpty)
								_buildCompactSelectors(),
							_buildActionRow(price),
						],
					),
				),
			),
		);
	}

	Widget _buildCompactSelectors() {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8.0),
			child: Row(
				children: [
					if (widget.productColors.isNotEmpty)
						Expanded(
							child: _buildDropdown(selectedColorId, "اللون", widget.productColors, (value, item) {
								setState(() {
									selectedColorId = value;
									selectedColorName = item?['color_name']?.toString();
								});
							}, (item) {
								final colorName = item?['color_name']?.toString() ?? '';
								return Row(mainAxisSize: MainAxisSize.min, children: [
									CircleAvatar(backgroundColor: widget.getColorFromName(colorName), radius: 8),
									const SizedBox(width: 8),
									Expanded(child: Text(colorName, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
								]);
							}),
						),
					if (widget.productColors.isNotEmpty && widget.productSizes.isNotEmpty)
						const SizedBox(width: 12),
					if (widget.productSizes.isNotEmpty)
						Expanded(
							child: _buildDropdown(selectedSizeId, "المقاس", widget.productSizes, (value, item) {
								setState(() {
									selectedSizeId = value;
									selectedSizeName = item?['size']?.toString();
								});
							}, (item) {
								final sizeValue = item?['size']?.toString() ?? '';
								return Text(sizeValue, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis);
							}),
						),
				],
			),
		);
	}

	Widget _buildDropdown(
			String? currentValue,
			String hint,
			List<dynamic> items,
			Function(String?, dynamic) onChanged,
			Widget Function(dynamic) itemBuilder,
			) {
		return DropdownButtonHideUnderline(
			child: DropdownButtonFormField<String>(
				value: currentValue,
				isDense: true,
				isExpanded: true,
				hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
				decoration: InputDecoration(
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
					),
					enabledBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
					),
					focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide(color: Colors.teal, width: 1.5),
					),
					contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
					fillColor: Colors.white,
					filled: true,
				),
				onChanged: (value) {
					final selectedItem = items.firstWhere((i) => i['id']?.toString() == value, orElse: () => null);
					onChanged(value, selectedItem);
				},
				items: items.map<DropdownMenuItem<String>>((item) {
					final itemId = item['id']?.toString();
					return DropdownMenuItem<String>(
						value: itemId,
						child: itemBuilder(item),
					);
				}).toList(),
			),
		);
	}

	Widget _buildActionRow(String price) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Row(
					children: [
						_buildQuantityButton(Icons.remove, () => setState(() => quantity--), quantity > 1),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 12.0),
							child: Text(quantity.toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
						),
						_buildQuantityButton(Icons.add, () => setState(() => quantity++)),
					],
				),
				SizedBox(
					width: 50, height: 50,
					child: Tooltip(
						message: 'إضافة إلى السلة',
						child: ElevatedButton(
							onPressed: () {
								if (widget.productColors.isNotEmpty && selectedColorId == null) {
									_showWarningSnackBar("الرجاء اختيار اللون أولاً"); return;
								}
								if (widget.productSizes.isNotEmpty && selectedSizeId == null) {
									_showWarningSnackBar("الرجاء اختيار المقاس أولاً"); return;
								}
								widget.onAddToCart({
									'id': widget.product['id'], 'name': widget.product['name'] ?? 'منتج',
									'price': double.tryParse(price) ?? 0.0, 'quantity': quantity,
									'color_id': selectedColorId, 'color_name': selectedColorName,
									'size_id': selectedSizeId, 'size_name': selectedSizeName,
									'image': widget.product['image'],
									'store_id': widget.product['store_id'], // تأكد من وجود هذا الحقل أو قم بتمريره
								});
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.teal[600],
								foregroundColor: Colors.white,
								padding: EdgeInsets.zero,
								shape: const CircleBorder(),
								elevation: 3.0,
							),
							child: const Icon(Icons.add_shopping_cart_outlined, size: 24),
						),
					),
				),
			],
		);
	}

	Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed, [bool enabled = true]) {
		return SizedBox(
			width: 36, height: 36,
			child: IconButton(
				padding: EdgeInsets.zero,
				icon: Icon(icon, size: 20, color: enabled ? (icon == Icons.add ? Colors.green[700] : Colors.red[700]) : Colors.grey[400]),
				onPressed: enabled ? onPressed : null,
			),
		);
	}

	void _showWarningSnackBar(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.orangeAccent[700]),
		);
	}
}

