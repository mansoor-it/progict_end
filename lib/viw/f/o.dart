import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled2/viw/f/product_details_page.dart';
import 'dart:math' as math;

import '../../ApiConfig.dart';
import '../../model/category_model.dart';
import '../../model/user_model.dart';
import '../../service/ProductDetailsPage_server.dart';
import '../../service/category_service.dart' hide Category;
import '../../service/server_cart.dart';
import '../AllProductsPage.dart';
import '../cart_screen.dart';
import '../stores_screen.dart';

// استيراد الملفات المحلية (تأكد من صحة المسارات)

class MainHomePage extends StatefulWidget {
	final User user;

	const MainHomePage({Key? key, required this.user}) : super(key: key);

	@override
	_MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> with TickerProviderStateMixin {
	// متغيرات البيانات
	List<dynamic> mostOrderedProducts = [];
	List<Category> categories = [];
	List<dynamic> stores = [];
	List<dynamic> allProducts = [];
	List<dynamic> colors = [];
	List<dynamic> sizes = [];

	// متغيرات البحث والفلترة
	List<dynamic> filteredProducts = [];
	List<dynamic> filteredStores = [];
	List<Category> filteredCategories = [];
	List<dynamic> filteredMostOrdered = [];
	String searchQuery = '';
	bool isSearching = false;

	// فلاتر البحث
	String selectedFilter = 'الكل'; // الكل، الأقسام، المنتجات، المحلات، الأكثر طلباً
	List<String> searchFilters = ['الكل', 'الأقسام', 'المنتجات', 'المحلات', 'الأكثر طلباً'];

	// متغيرات الحالة
	bool isLoadingMostOrdered = true;
	bool isLoadingCategories = true;
	bool isLoadingStores = true;
	bool isLoadingAllProducts = true;
	bool isRefreshing = false;

	// Controllers
	final AllProductsController _productsController = AllProductsController();
	final CartController _cartController = CartController();
	final TextEditingController _searchController = TextEditingController();
	final ScrollController _scrollController = ScrollController();

	// تهيئة AnimationController كمتغير nullable مع تهيئة متأخرة
	AnimationController? _refreshAnimationController;

	// قائمة السلة
	List<Map<String, dynamic>> cartItems = [];

	@override
	void initState() {
		super.initState();
		// تهيئة AnimationController بعد استدعاء super.initState()
		_refreshAnimationController = AnimationController(
			duration: const Duration(milliseconds: 1000),
			vsync: this,
		);
		_fetchAllData();
		_initializeFilters();
	}

	@override
	void dispose() {
		_searchController.dispose();
		_scrollController.dispose();
		_refreshAnimationController?.dispose();
		super.dispose();
	}

	// تهيئة الفلاتر
	void _initializeFilters() {
		filteredProducts = allProducts;
		filteredStores = stores;
		filteredCategories = categories;
		filteredMostOrdered = mostOrderedProducts;
	}

	// جلب جميع البيانات مع تحديث الفلاتر
	Future<void> _fetchAllData() async {
		setState(() {
			isRefreshing = true;
		});
		_refreshAnimationController?.repeat();

		await Future.wait([
			_fetchMostOrderedProducts(),
			_fetchCategories(),
			_fetchStores(),
			_fetchAllProducts(),
		]);

		_initializeFilters();
		_applySearch(searchQuery);

		setState(() {
			isRefreshing = false;
		});
		_refreshAnimationController?.stop();
		_refreshAnimationController?.reset();
	}

	// دالة البحث المتقدم مع الفلاتر
	void _applySearch(String query) {
		setState(() {
			searchQuery = query.toLowerCase();
			isSearching = query.isNotEmpty;

			if (query.isEmpty) {
				filteredProducts = allProducts;
				filteredStores = stores;
				filteredCategories = categories;
				filteredMostOrdered = mostOrderedProducts;
			} else {
				// تطبيق البحث حسب الفلتر المحدد
				switch (selectedFilter) {
					case 'الأقسام':
						filteredCategories = categories.where((category) {
							final categoryName = category.name.toLowerCase();
							return categoryName.contains(searchQuery);
						}).toList();
						filteredProducts = [];
						filteredStores = [];
						filteredMostOrdered = [];
						break;

					case 'المنتجات':
						filteredProducts = allProducts.where((product) {
							final productName = (product['product_name'] ?? '').toString().toLowerCase();
							final productDescription = (product['description'] ?? '').toString().toLowerCase();
							return productName.contains(searchQuery) || productDescription.contains(searchQuery);
						}).toList();
						filteredCategories = [];
						filteredStores = [];
						filteredMostOrdered = [];
						break;

					case 'المحلات':
						filteredStores = stores.where((store) {
							final storeName = (store['name'] ?? '').toString().toLowerCase();
							final storeDescription = (store['description'] ?? '').toString().toLowerCase();
							return storeName.contains(searchQuery) || storeDescription.contains(searchQuery);
						}).toList();
						filteredCategories = [];
						filteredProducts = [];
						filteredMostOrdered = [];
						break;

					case 'الأكثر طلباً':
						filteredMostOrdered = mostOrderedProducts.where((product) {
							final productName = (product['product_name'] ?? '').toString().toLowerCase();
							return productName.contains(searchQuery);
						}).toList();
						filteredCategories = [];
						filteredProducts = [];
						filteredStores = [];
						break;

					default: // الكل
					// البحث في المنتجات
						filteredProducts = allProducts.where((product) {
							final productName = (product['product_name'] ?? '').toString().toLowerCase();
							final productDescription = (product['description'] ?? '').toString().toLowerCase();
							return productName.contains(searchQuery) || productDescription.contains(searchQuery);
						}).toList();

						// البحث في المحلات
						filteredStores = stores.where((store) {
							final storeName = (store['name'] ?? '').toString().toLowerCase();
							final storeDescription = (store['description'] ?? '').toString().toLowerCase();
							return storeName.contains(searchQuery) || storeDescription.contains(searchQuery);
						}).toList();

						// البحث في الأقسام
						filteredCategories = categories.where((category) {
							final categoryName = category.name.toLowerCase();
							return categoryName.contains(searchQuery);
						}).toList();

						// البحث في الأكثر طلباً
						filteredMostOrdered = mostOrderedProducts.where((product) {
							final productName = (product['product_name'] ?? '').toString().toLowerCase();
							return productName.contains(searchQuery);
						}).toList();
						break;
				}
			}
		});
	}

	// تغيير الفلتر المحدد
	void _changeFilter(String filter) {
		setState(() {
			selectedFilter = filter;
		});
		_applySearch(searchQuery);
	}

	// جلب المنتجات الأكثر طلباً
	Future<void> _fetchMostOrderedProducts() async {
		try {
			final url = Uri.parse(ApiHelper.url('get_most_ordered_products.php'));
			final response = await http.get(url);

			if (response.statusCode == 200) {
				final data = jsonDecode(response.body);
				if (data['status'] == 'success') {
					setState(() {
						mostOrderedProducts = data['products'];
						isLoadingMostOrdered = false;
					});
				}
			}
		} catch (e) {
			print('Error fetching most ordered products: $e');
			setState(() => isLoadingMostOrdered = false);
		}
	}

	// جلب الأقسام
	Future<void> _fetchCategories() async {
		try {
			final categoriesService = CategoryController();
			final fetched = await categoriesService.fetchCategories();

			setState(() {
				categories = fetched.cast<Category>();
				isLoadingCategories = false;
			});
		} catch (e) {
			print('Error fetching categories: $e');
			setState(() => isLoadingCategories = false);
		}
	}

	// جلب المحلات
	Future<void> _fetchStores() async {
		try {
			final apiUrl = ApiHelper.url('stores.php');
			final resp = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (resp.statusCode == 200) {
				final data = json.decode(resp.body) as List;
				setState(() {
					stores = data;
					isLoadingStores = false;
				});
			}
		} catch (e) {
			print('Error fetching stores: $e');
			setState(() => isLoadingStores = false);
		}
	}

	// جلب جميع المنتجات مع إضافة خصائص عشوائية
	Future<void> _fetchAllProducts() async {
		try {
			final data = await _productsController.fetchAllDataWithoutStoreId();

			// إضافة خصائص عشوائية للمنتجات
			final processedProducts = (data['products'] ?? []).map((product) {
				final random = math.Random();
				product['is_new'] = random.nextBool() && random.nextDouble() > 0.7;
				product['discount_percentage'] = product['is_new']! ? 0 :
				(random.nextDouble() > 0.8 ? random.nextInt(30) + 10 : 0);
				product['is_bestseller'] = !product['is_new']! && product['discount_percentage'] == 0 &&
						random.nextDouble() > 0.7;
				return product;
			}).toList();

			setState(() {
				allProducts = processedProducts;
				colors = data['colors'] ?? [];
				sizes = data['sizes'] ?? [];
				isLoadingAllProducts = false;
			});
		} catch (e) {
			print('Error fetching all products: $e');
			setState(() => isLoadingAllProducts = false);
		}
	}

	// دالة إضافة المنتج للسلة
	Future<void> _handleAddToCart(Map<String, dynamic> itemMap) async {
		try {
			final success = await _cartController.addCartItem(
				userId: widget.user.id,
				storeId: itemMap['store_id']?.toString() ?? '',
				productId: itemMap['id'].toString(),
				quantity: itemMap['quantity']?.toString() ?? '1',
				unitPrice: itemMap['price']?.toString() ?? '0',
				productColorId: itemMap['color_id']?.toString(),
				productSizeId: itemMap['size_id']?.toString(),
				productImage: itemMap['image']?.toString(),
			);

			if (success) {
				final existingIndex = cartItems.indexWhere((cartItem) =>
				cartItem['id'] == itemMap['id'] &&
						cartItem['color_id'] == itemMap['color_id'] &&
						cartItem['size_id'] == itemMap['size_id']);

				if (existingIndex != -1) {
					setState(() {
						cartItems[existingIndex]['quantity'] =
								(cartItems[existingIndex]['quantity'] ?? 0) + (itemMap['quantity'] ?? 1);
					});
				} else {
					setState(() {
						cartItems.add(itemMap);
					});
				}

				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Row(children: [
								const Icon(Icons.check_circle_outline, color: Colors.white),
								const SizedBox(width: 8),
								Expanded(child: Text("تمت إضافة ${itemMap['name'] ?? 'المنتج'} للسلة!")),
							]),
							backgroundColor: Colors.green[600],
							duration: const Duration(seconds: 2),
							margin: const EdgeInsets.all(8),
							behavior: SnackBarBehavior.floating,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
						),
					);
				}
			} else {
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: const Row(children: [
								Icon(Icons.error_outline, color: Colors.white),
								SizedBox(width: 8),
								Text("فشل إضافة المنتج. حاول مرة أخرى."),
							]),
							backgroundColor: Colors.redAccent,
							margin: const EdgeInsets.all(8),
							behavior: SnackBarBehavior.floating,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
						margin: const EdgeInsets.all(8),
						behavior: SnackBarBehavior.floating,
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
					),
				);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Directionality(
			textDirection: TextDirection.rtl,
			child: Scaffold(
				appBar: _buildAppBar(),
				body: RefreshIndicator(
					onRefresh: _fetchAllData,
					child: CustomScrollView(
						controller: _scrollController,
						physics: const AlwaysScrollableScrollPhysics(),
						slivers: [
							// المحتوى الرئيسي
							SliverToBoxAdapter(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const SizedBox(height: 16),

										// قسم المنتجات الأكثر طلباً
										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'الأكثر طلباً')))
											_buildMostOrderedProductsSection(),

										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'الأكثر طلباً')))
											const SizedBox(height: 20),

										// قسم الأقسام
										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'الأقسام')))
											_buildCategoriesSection(),

										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'الأقسام')))
											const SizedBox(height: 20),

										// قسم المحلات
										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'المحلات')))
											_buildStoresSection(),

										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'المحلات')))
											const SizedBox(height: 20),

										// قسم جميع المنتجات - محسن
										if (!isSearching || (isSearching && (selectedFilter == 'الكل' || selectedFilter == 'المنتجات')))
											_buildAllProductsSection(),

										const SizedBox(height: 20),
									],
								),
							),
						],
					),
				),
			),
		);
	}


	// بناء شريط التطبيق المحسن مع محرك البحث
	AppBar _buildAppBar() {
		return AppBar(
			title: isSearching
					? _buildSearchField()
					: const Text('الصفحة الرئيسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
			flexibleSpace: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						colors: [Color(0xFF000000), Color(0xFF1A1A1A)], // ألوان داكنة جداً
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
				),
			),
			foregroundColor: Colors.white,
			elevation: 8.0, // ظل أعمق
			toolbarHeight: 60, // ارتفاع أعلى لشريط التطبيق
			leading: isSearching
					? IconButton(
				icon: const Icon(Icons.arrow_back, color: Colors.white),
				onPressed: () {
					setState(() {
						isSearching = false;
						searchQuery = '';
						selectedFilter = 'الكل';
						_searchController.clear();
					});
					_applySearch('');
				},
			)
					: null,
			actions: [
				// زر البحث
				if (!isSearching)
					IconButton(
						icon: const Icon(Icons.search, size: 24, color: Colors.white),
						tooltip: 'البحث',
						onPressed: () {
							setState(() {
								isSearching = true;
							});
						},
					),

				// زر التحديث المحسن مع التحقق من null
				if (!isSearching && _refreshAnimationController != null)
					AnimatedBuilder(
						animation: _refreshAnimationController!,
						builder: (context, child) {
							return IconButton(
								icon: Transform.rotate(
									angle: _refreshAnimationController!.value * 2 * math.pi, // استخدام math.pi
									child: Icon(
										Icons.refresh,
										size: 24,
										color: isRefreshing ? Colors.white70 : Colors.white,
									),
								),
								tooltip: 'تحديث البيانات',
								onPressed: isRefreshing ? null : _fetchAllData,
							);
						},
					)
				else if (!isSearching)
				// زر تحديث بسيط في حالة عدم تهيئة AnimationController
					IconButton(
						icon: Icon(
							Icons.refresh,
							size: 24,
							color: isRefreshing ? Colors.white70 : Colors.white,
						),
						tooltip: 'تحديث البيانات',
						onPressed: isRefreshing ? null : _fetchAllData,
					),

				// زر السلة
				if (!isSearching)
					IconButton(
						icon: Badge(
							label: Text(
								cartItems.length.toString(),
								style: const TextStyle(fontSize: 10, color: Colors.white), // لون النص أبيض
							),
							isLabelVisible: cartItems.isNotEmpty,
							backgroundColor: Colors.redAccent[700],
							smallSize: 18, // حجم شارة أصغر
							alignment: Alignment.topRight,
							child: const Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.white),
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
							setState(() {});
						},
					),

				const SizedBox(width: 8), // مسافة أكبر
			],
			bottom: isSearching ? _buildSearchFilters() : null,
		);
	}

	// بناء حقل البحث في AppBar
	Widget _buildSearchField() {
		return TextField(
			controller: _searchController,
			autofocus: true,
			textDirection: TextDirection.rtl,
			style: const TextStyle(color: Colors.white, fontSize: 17), // حجم خط أكبر
			decoration: InputDecoration(
				hintText: 'البحث...',
				hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 17),
				border: InputBorder.none,
				suffixIcon: searchQuery.isNotEmpty
						? IconButton(
					icon: const Icon(Icons.clear, color: Colors.white, size: 22), // أيقونة أكبر
					onPressed: () {
						_searchController.clear();
						_applySearch('');
					},
				)
						: null,
			),
			onChanged: _applySearch,
		);
	}

	// بناء فلاتر البحث
	PreferredSizeWidget _buildSearchFilters() {
		return PreferredSize(
			preferredSize: const Size.fromHeight(50),
			child: Container(
				height: 50,
				padding: const EdgeInsets.symmetric(horizontal: 8),
				alignment: Alignment.center, // توسيط الفلاتر
				child: ListView.builder(
					scrollDirection: Axis.horizontal,
					itemCount: searchFilters.length,
					itemBuilder: (context, index) {
						final filter = searchFilters[index];
						final isSelected = selectedFilter == filter;

						return Padding(
							padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // حشو أقل
							child: FilterChip(
								label: Text(
									filter,
									style: TextStyle(
										color: isSelected ? Colors.black : Colors.grey.shade300, // اللون الأسود عندما يكون مختاراً، رمادي فاتح بخلاف ذلك
										fontSize: 13, // حجم خط أكبر قليلاً
										fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
									),
								),
								selected: isSelected,
								onSelected: (selected) {
									_changeFilter(filter);
								},
								backgroundColor: isSelected ? Colors.white.withOpacity(0.9) : Colors.transparent, // خلفية بيضاء شبه شفافة عند الاختيار
								selectedColor: Colors.white.withOpacity(0.9), // نفس اللون الأبيض لتأثير متجانس
								side: BorderSide(
									color: isSelected ? Colors.white : Colors.grey.shade600, // حدود بيضاء أو رمادية
									width: 1.5, // حدود أكثر سمكاً
								),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(20), // زوايا مستديرة أكثر
								),
								padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // حشو داخلي أكبر
								showCheckmark: false,
							),
						);
					},
				),
			),
		);
	}

	// بناء قسم المنتجات الأكثر طلباً
	Widget _buildMostOrderedProductsSection() {
		final productsToShow = isSearching ? filteredMostOrdered : mostOrderedProducts;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_buildSectionHeader(
						isSearching ? 'المنتجات الأكثر طلباً (${productsToShow.length})' : 'المنتجات الأكثر طلباً',
						Icons.trending_up
				),
				const SizedBox(height: 10),
				SizedBox(
					height: 200,
					child: isLoadingMostOrdered
							? _buildLoadingShimmer()
							: productsToShow.isEmpty
							? _buildEmptyState(isSearching ? 'لا توجد منتجات مطابقة' : 'لا توجد منتجات')
							: ListView.builder(
						scrollDirection: Axis.horizontal,
						padding: const EdgeInsets.symmetric(horizontal: 16),
						itemCount: productsToShow.length,
						itemBuilder: (context, index) {
							final product = productsToShow[index];
							return _buildMostOrderedProductCard(product);
						},
					),
				),
			],
		);
	}

	// بناء قسم الأقسام
	Widget _buildCategoriesSection() {
		final categoriesToShow = isSearching ? filteredCategories : categories;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_buildSectionHeader(
						isSearching ? 'الأقسام (${categoriesToShow.length})' : 'الأقسام',
						Icons.category
				),
				const SizedBox(height: 10),
				SizedBox(
					height: 150,
					child: isLoadingCategories
							? _buildLoadingShimmer()
							: categoriesToShow.isEmpty
							? _buildEmptyState(isSearching ? 'لا توجد أقسام مطابقة' : 'لا توجد أقسام')
							: ListView.builder(
						scrollDirection: Axis.horizontal,
						padding: const EdgeInsets.symmetric(horizontal: 16),
						itemCount: categoriesToShow.length,
						itemBuilder: (context, index) {
							final category = categoriesToShow[index];
							return _buildCategoryCard(category);
						},
					),
				),
			],
		);
	}

	// بناء قسم المحلات
	Widget _buildStoresSection() {
		final storesToShow = isSearching ? filteredStores : stores;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_buildSectionHeader(
						isSearching ? 'المحلات (${storesToShow.length})' : 'المحلات',
						Icons.storefront
				),
				const SizedBox(height: 10),
				SizedBox(
					height: 180,
					child: isLoadingStores
							? _buildLoadingShimmer()
							: storesToShow.isEmpty
							? _buildEmptyState(isSearching ? 'لا توجد محلات مطابقة' : 'لا توجد محلات')
							: ListView.builder(
						scrollDirection: Axis.horizontal,
						padding: const EdgeInsets.symmetric(horizontal: 16),
						itemCount: storesToShow.length,
						itemBuilder: (context, index) {
							final store = storesToShow[index];
							return _buildStoreCard(store);
						},
					),
				),
			],
		);
	}

	// بناء قسم جميع المنتجات - محسن مع التصميم الجديد
	Widget _buildAllProductsSection() {
		final productsToShow = isSearching ? filteredProducts : allProducts;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_buildSectionHeader(
						isSearching ? 'المنتجات (${productsToShow.length})' : 'جميع المنتجات',
						Icons.inventory
				),
				const SizedBox(height: 10),
				isLoadingAllProducts
						? _buildLoadingGrid()
						: productsToShow.isEmpty
						? _buildEmptyState(isSearching ? 'لا توجد منتجات مطابقة' : 'لا توجد منتجات')
						: _buildEnhancedProductsGrid(productsToShow),
			],
		);
	}

	// بناء شبكة المنتجات المحسنة الجديدة
	Widget _buildEnhancedProductsGrid(List<dynamic> products) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16),
			child: AnimationLimiter(
				child: GridView.builder(
					shrinkWrap: true,
					physics: const NeverScrollableScrollPhysics(),
					itemCount: products.length,
					gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2,
						crossAxisSpacing: 12,
						mainAxisSpacing: 12,
						childAspectRatio: 0.65, // تعديل النسبة لتناسب التصميم الجديد
					),
					itemBuilder: (context, index) {
						final product = products[index];
						return AnimationConfiguration.staggeredGrid(
							position: index,
							duration: const Duration(milliseconds: 375),
							columnCount: 2,
							child: SlideAnimation(
								verticalOffset: 50.0,
								child: FadeInAnimation(
									child: _buildEnhancedProductCard(product, index),
								),
							),
						);
					},
				),
			),
		);
	}

	// بناء بطاقة المنتج المحسنة الجديدة
	Widget _buildEnhancedProductCard(dynamic product, int index) {
		final productIdStr = product['id'].toString();
		final productColors = colors.where((c) => c != null && c['product_id']?.toString() == productIdStr).toList();
		final productSizes = sizes.where((s) => s != null && s['product_id']?.toString() == productIdStr).toList();

		return ProductGridCardEnhanced(
			key: ValueKey(product['id']),
			product: product,
			productColors: productColors,
			productSizes: productSizes,
			getColorFromName: _productsController.getColorFromName,
			onAddToCart: _handleAddToCart,
			onTap: () => _navigateToProductDetails(product),
		);
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
					getColorFromName: _productsController.getColorFromName,
					onAddToCart: _handleAddToCart,
					user: widget.user,
					storeId: '',
				),
			),
		);
	}

	// بناء عنوان القسم
	Widget _buildSectionHeader(String title, IconData icon) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16),
			child: Row(
				children: [
					Icon(icon, color: Colors.teal.shade700, size: 24),
					const SizedBox(width: 8),
					Text(
						title,
						style: TextStyle(
							fontSize: 20,
							fontWeight: FontWeight.bold,
							color: Colors.teal.shade700,
						),
					),
				],
			),
		);
	}

	// بناء بطاقة المنتج الأكثر طلباً
	Widget _buildMostOrderedProductCard(dynamic product) {
		return Container(
			width: 140,
			margin: const EdgeInsets.only(left: 12),
			child: Card(
				elevation: 4,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// صورة المنتج
						Expanded(
							flex: 3,
							child: Container(
								width: double.infinity,
								decoration: const BoxDecoration(
									borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
								),
								child: ClipRRect(
									borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
									child: product['image'] != null && product['image'].toString().isNotEmpty
											? Image.memory(
										base64Decode(product['image']),
										fit: BoxFit.cover,
										errorBuilder: (context, error, stackTrace) =>
												_buildPlaceholderImage(),
									)
											: _buildPlaceholderImage(),
								),
							),
						),
						// اسم المنتج
						Expanded(
							flex: 1,
							child: Padding(
								padding: const EdgeInsets.all(8.0),
								child: Text(
									product['product_name'] ?? '',
									style: const TextStyle(
										fontSize: 12,
										fontWeight: FontWeight.w600,
									),
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
								),
							),
						),
					],
				),
			),
		);
	}

	// بناء بطاقة القسم
	Widget _buildCategoryCard(Category category) {
		return Container(
			width: 120,
			margin: const EdgeInsets.only(left: 12),
			child: GestureDetector(
				onTap: () {
					Navigator.push(
						context,
						MaterialPageRoute(
							builder: (context) => StoresScreen(
								categoryId: category.id,
								categoryName: category.name,
								user: widget.user,
							),
						),
					);
				},
				child: Card(
					elevation: 4,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
					child: Column(
						children: [
							// صورة القسم
							Expanded(
								flex: 2,
								child: Container(
									width: double.infinity,
									decoration: const BoxDecoration(
										borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
									),
									child: ClipRRect(
										borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
										child: category.image.isNotEmpty
												? Image.memory(
											base64Decode(category.image.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '')),
											fit: BoxFit.cover,
											errorBuilder: (context, error, stackTrace) =>
													_buildPlaceholderImage(),
										)
												: _buildPlaceholderImage(),
									),
								),
							),
							// اسم القسم
							Expanded(
								flex: 1,
								child: Padding(
									padding: const EdgeInsets.all(8.0),
									child: Text(
										category.name,
										style: const TextStyle(
											fontSize: 12,
											fontWeight: FontWeight.w600,
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										textAlign: TextAlign.center,
									),
								),
							),
						],
					),
				),
			),
		);
	}

	// بناء بطاقة المحل
	Widget _buildStoreCard(dynamic store) {
		return Container(
			width: 140,
			margin: const EdgeInsets.only(left: 12),
			child: GestureDetector(
				onTap: () {
					Navigator.push(
						context,
						MaterialPageRoute(
							builder: (context) => AllProductsPageNew(
								storeId: store['id'].toString(),
								storeName: store['name'] ?? '',
								user: widget.user,
							),
						),
					);
				},
				child: Card(
					elevation: 4,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// صورة المحل
							Expanded(
								flex: 2,
								child: Container(
									width: double.infinity,
									decoration: const BoxDecoration(
										borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
									),
									child: ClipRRect(
										borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
										child: store['store_image'] != null && store['store_image'].toString().isNotEmpty
												? Image.memory(
											base64Decode(store['store_image']),
											fit: BoxFit.cover,
											errorBuilder: (context, error, stackTrace) =>
													_buildPlaceholderImage(),
										)
												: _buildPlaceholderImage(),
									),
								),
							),
							// اسم المحل
							Expanded(
								flex: 1,
								child: Padding(
									padding: const EdgeInsets.all(8.0),
									child: Text(
										store['name'] ?? '',
										style: const TextStyle(
											fontSize: 12,
											fontWeight: FontWeight.w600,
										),
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
									),
								),
							),
						],
					),
				),
			),
		);
	}


	// الدوال المساعدة

	// بناء صورة بديلة
	Widget _buildPlaceholderImage() {
		return Container(
			color: Colors.grey[200],
			child: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.image_not_supported_outlined,
							color: Colors.grey[400],
							size: 40,
						),
						const SizedBox(height: 8),
						Text(
							'لا توجد صورة',
							style: TextStyle(
								color: Colors.grey[600],
								fontSize: 12,
							),
						),
					],
				),
			),
		);
	}

	// بناء تأثير التحميل
	Widget _buildLoadingShimmer() {
		return Shimmer.fromColors(
			baseColor: Colors.grey[300]!,
			highlightColor: Colors.blue[100]!,
			child: ListView.builder(
				scrollDirection: Axis.horizontal,
				padding: const EdgeInsets.symmetric(horizontal: 16),
				itemCount: 5,
				itemBuilder: (context, index) {
					return Container(
						width: 140,
						margin: const EdgeInsets.only(left: 12),
						child: Card(
							elevation: 4,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							child: Container(
								decoration: BoxDecoration(
									color: Colors.blue,
									borderRadius: BorderRadius.circular(12),
								),
							),
						),
					);
				},
			),
		);
	}

	// بناء شبكة التحميل
	Widget _buildLoadingGrid() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16),
			child: Shimmer.fromColors(
				baseColor: Colors.grey[300]!,
				highlightColor: Colors.grey[100]!,
				child: GridView.builder(
					shrinkWrap: true,
					physics: const NeverScrollableScrollPhysics(),
					gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: 2,
						crossAxisSpacing: 12,
						mainAxisSpacing: 12,
						childAspectRatio: 0.65,
					),
					itemCount: 6,
					itemBuilder: (context, index) {
						return Card(
							elevation: 4,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							child: Container(
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(12),
								),
							),
						);
					},
				),
			),
		);
	}

	// بناء حالة فارغة
	Widget _buildEmptyState(String message) {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(
						Icons.inbox_outlined,
						size: 60,
						color: Colors.grey[400],
					),
					const SizedBox(height: 16),
					Text(
						message,
						style: TextStyle(
							fontSize: 16,
							color: Colors.grey[600],
						),
						textAlign: TextAlign.center,
					),
				],
			),
		);
	}
}

// ======================================================
// ودجت بطاقة المنتج المحسنة (للشبكة) - مع وظيفة النقر
// ======================================================
class ProductGridCardEnhanced extends StatefulWidget {
	final dynamic product;
	final List<dynamic> productColors;
	final List<dynamic> productSizes;
	final Color Function(String) getColorFromName;
	final Future<void> Function(Map<String, dynamic>) onAddToCart;
	final VoidCallback? onTap;

	const ProductGridCardEnhanced({
		Key? key,
		required this.product,
		required this.productColors,
		required this.productSizes,
		required this.getColorFromName,
		required this.onAddToCart,
		this.onTap,
	}) : super(key: key);

	@override
	_ProductGridCardEnhancedState createState() => _ProductGridCardEnhancedState();
}

class _ProductGridCardEnhancedState extends State<ProductGridCardEnhanced> {
	int quantity = 1;
	String? selectedColorId;
	String? selectedColorName;
	String? selectedSizeId;
	String? selectedSizeName;
	bool _isHovering = false;

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
		final productName = widget.product['product_name'] ?? "منتج غير مسمى";

		return MouseRegion(
			onEnter: (_) => setState(() => _isHovering = true),
			onExit: (_) => setState(() => _isHovering = false),
			child:Card(
				elevation: _isHovering ? 8.0 : 3.0,
				shadowColor: Colors.teal.withOpacity(0.3),
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				clipBehavior: Clip.antiAlias,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						_buildProductImageWithBadge(),
						Expanded(
							child: InkWell(
								onTap: widget.onTap,
								child: Padding(
									padding: const EdgeInsets.all(12.0),
									child: Column(
										children: [
											// المحتوى القابل للتمرير (اسم + سعر)
											Expanded(
												child: SingleChildScrollView(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.center,
														children: [
															Text(
																widget.product['name'] ?? '',
																style: const TextStyle(
																	fontWeight: FontWeight.w600,
																	fontSize: 14,
																),
																maxLines: 2,
																overflow: TextOverflow.ellipsis,
															),
															const SizedBox(height: 4),
															Text(
																"$price ريال",
																style: TextStyle(
																	fontWeight: FontWeight.bold,
																	color: Colors.teal[800],
																	fontSize: 16,
																),
															),
														],
													),
												),
											),

											const SizedBox(height: 8),

											// زر إضافة للسلة (ثابت أسفل البطاقة)
											SizedBox(
												width: double.infinity,
												height: 32,
												child: ElevatedButton(
													onPressed: () {
														widget.onAddToCart({
															'id': widget.product['id'],
															'name': widget.product['name'] ?? 'منتج',
															'price': double.tryParse(price) ?? 0.0,
															'quantity': quantity,
															'color_id': selectedColorId,
															'color_name': selectedColorName,
															'size_id': selectedSizeId,
															'size_name': selectedSizeName,
															'image': widget.product['image'],
															'store_id': widget.product['store_id'],
														});
													},
													style: ElevatedButton.styleFrom(
														backgroundColor: Colors.teal[600],
														foregroundColor: Colors.white,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(8),
														),
														elevation: 2.0,
													),
													child: Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: const [
															Icon(Icons.add_shopping_cart_outlined, size: 16),
															SizedBox(width: 4),
															Text('إضافة للسلة', style: TextStyle(fontSize: 12)),
														],
													),
												),
											),
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
}