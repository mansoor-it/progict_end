import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import '../ApiConfig.dart';

// تعريف كلاس المنتج بناءً على جدول products
class Product {
	final String id;
	final String storeId;
	final String name;
	final String description;
	final String price;
	final String stockQuantity;
	final String? imageBase64;
	final String status;
	final String createdAt;

	Product({
		required this.id,
		required this.storeId,
		required this.name,
		required this.description,
		required this.price,
		required this.stockQuantity,
		this.imageBase64,
		required this.status,
		required this.createdAt,
	});

	factory Product.fromJson(Map<String, dynamic> json) {
		return Product(
			id: json['id']?.toString() ?? '',
			storeId: json['store_id']?.toString() ?? '',
			name: json['name'] ?? '',
			description: json['description'] ?? '',
			price: json['price']?.toString() ?? '',
			stockQuantity: json['stock_quantity']?.toString() ?? '',
			imageBase64: json['image'] != null && (json['image'] as String).isNotEmpty
					? json['image'] as String
					: null,
			status: json['status'] ?? 'available',
			createdAt: json['created_at'] ?? '',
		);
	}
}

// كلاس للإحصائيات
class DashboardStats {
	final int totalProducts;
	final int totalStock;
	final double totalValue;
	final int uniqueStores;
	final int availableProducts;
	final int outOfStockProducts;
	final int discontinuedProducts;
	final int lowStockItems;
	final int productsWithImages;
	final String mostExpensiveProduct;
	final String cheapestProduct;

	DashboardStats({
		required this.totalProducts,
		required this.totalStock,
		required this.totalValue,
		required this.uniqueStores,
		required this.availableProducts,
		required this.outOfStockProducts,
		required this.discontinuedProducts,
		required this.lowStockItems,
		required this.productsWithImages,
		required this.mostExpensiveProduct,
		required this.cheapestProduct,
	});
}

class ProductsManagementPage extends StatefulWidget {
	@override
	_ProductsManagementPageState createState() => _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage>
		with TickerProviderStateMixin {
	List<Product> _products = [];
	List<Product> _filteredProducts = [];
	bool _isLoading = false;
	DashboardStats? _stats;

	// Controllers للنموذج
	final TextEditingController _storeIdController = TextEditingController();
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	final TextEditingController _priceController = TextEditingController();
	final TextEditingController _stockQuantityController = TextEditingController();
	final TextEditingController _statusController = TextEditingController();
	String? _pickedImageBase64;

	// Controllers للفلترة والبحث
	final TextEditingController _searchController = TextEditingController();
	final TextEditingController _storeIdFilterController = TextEditingController();
	final TextEditingController _minPriceController = TextEditingController();
	final TextEditingController _maxPriceController = TextEditingController();
	String _selectedStatusFilter = 'الكل';
	String _selectedStockFilter = 'الكل';
	String _selectedImageFilter = 'الكل';
	String _sortBy = 'id';
	bool _sortAscending = true;

	// Animation Controllers
	late AnimationController _fadeController;
	late AnimationController _slideController;
	late Animation<double> _fadeAnimation;
	late Animation<Offset> _slideAnimation;

	// Image Picker
	final ImagePicker _picker = ImagePicker();

	// رابط API الخاص بالمنتجات
	final String apiUrl = ApiHelper.url('products_api.php');

	@override
	void initState() {
		super.initState();
		_initializeAnimations();
		_fetchProducts();
		_searchController.addListener(_filterProducts);
		_storeIdFilterController.addListener(_filterProducts);
		_minPriceController.addListener(_filterProducts);
		_maxPriceController.addListener(_filterProducts);
	}

	void _initializeAnimations() {
		_fadeController = AnimationController(
			duration: Duration(milliseconds: 800),
			vsync: this,
		);
		_slideController = AnimationController(
			duration: Duration(milliseconds: 600),
			vsync: this,
		);

		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
		);

		_slideAnimation = Tween<Offset>(
			begin: Offset(0, 0.3),
			end: Offset.zero,
		).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

		_fadeController.forward();
		_slideController.forward();
	}

	Future<void> _fetchProducts() async {
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				setState(() {
					_products = data.map((item) => Product.fromJson(item)).toList();
					_filteredProducts = List.from(_products);
					_stats = _calculateStats();
					_isLoading = false;
				});
				_filterProducts();
			} else {
				setState(() {
					_isLoading = false;
				});
				_showSnackBar("خطأ في جلب البيانات", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	DashboardStats _calculateStats() {
		if (_products.isEmpty) {
			return DashboardStats(
				totalProducts: 0,
				totalStock: 0,
				totalValue: 0.0,
				uniqueStores: 0,
				availableProducts: 0,
				outOfStockProducts: 0,
				discontinuedProducts: 0,
				lowStockItems: 0,
				productsWithImages: 0,
				mostExpensiveProduct: 'غير متوفر',
				cheapestProduct: 'غير متوفر',
			);
		}

		int totalStock = _products.fold(0, (sum, product) => sum + int.parse(product.stockQuantity));
		double totalValue = _products.fold(0.0, (sum, product) => sum + (double.parse(product.price) * int.parse(product.stockQuantity)));
		Set<String> uniqueStores = _products.map((product) => product.storeId).toSet();

		// حساب المنتجات حسب الحالة
		int availableProducts = _products.where((product) => product.status == 'available').length;
		int outOfStockProducts = _products.where((product) => product.status == 'out_of_stock').length;
		int discontinuedProducts = _products.where((product) => product.status == 'discontinued').length;

		// حساب العناصر منخفضة المخزون (أقل من 10)
		int lowStockItems = _products.where((product) => int.parse(product.stockQuantity) < 10).length;

		// حساب المنتجات التي تحتوي على صور
		int productsWithImages = _products.where((product) => product.imageBase64 != null && product.imageBase64!.isNotEmpty).length;

		// حساب أغلى وأرخص منتج
		String mostExpensiveProduct = 'غير متوفر';
		String cheapestProduct = 'غير متوفر';

		if (_products.isNotEmpty) {
			var sortedByPrice = List<Product>.from(_products);
			sortedByPrice.sort((a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
			cheapestProduct = sortedByPrice.first.name;
			mostExpensiveProduct = sortedByPrice.last.name;
		}

		return DashboardStats(
			totalProducts: _products.length,
			totalStock: totalStock,
			totalValue: totalValue,
			uniqueStores: uniqueStores.length,
			availableProducts: availableProducts,
			outOfStockProducts: outOfStockProducts,
			discontinuedProducts: discontinuedProducts,
			lowStockItems: lowStockItems,
			productsWithImages: productsWithImages,
			mostExpensiveProduct: mostExpensiveProduct,
			cheapestProduct: cheapestProduct,
		);
	}

	void _filterProducts() {
		setState(() {
			_filteredProducts = _products.where((product) {
				bool matchesSearch = _searchController.text.isEmpty ||
						product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
						product.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
						product.storeId.contains(_searchController.text);

				bool matchesStoreId = _storeIdFilterController.text.isEmpty ||
						product.storeId.contains(_storeIdFilterController.text);

				bool matchesStatus = _selectedStatusFilter == 'الكل' ||
						product.status == _selectedStatusFilter;

				bool matchesStock = _selectedStockFilter == 'الكل' ||
						(_selectedStockFilter == 'متوفر' && int.parse(product.stockQuantity) > 0) ||
						(_selectedStockFilter == 'غير متوفر' && int.parse(product.stockQuantity) == 0) ||
						(_selectedStockFilter == 'مخزون منخفض' && int.parse(product.stockQuantity) < 10);

				bool matchesImage = _selectedImageFilter == 'الكل' ||
						(_selectedImageFilter == 'مع صورة' && product.imageBase64 != null && product.imageBase64!.isNotEmpty) ||
						(_selectedImageFilter == 'بدون صورة' && (product.imageBase64 == null || product.imageBase64!.isEmpty));

				bool matchesPrice = true;
				if (_minPriceController.text.isNotEmpty) {
					try {
						double minPrice = double.parse(_minPriceController.text);
						matchesPrice = matchesPrice && double.parse(product.price) >= minPrice;
					} catch (_) {}
				}
				if (_maxPriceController.text.isNotEmpty) {
					try {
						double maxPrice = double.parse(_maxPriceController.text);
						matchesPrice = matchesPrice && double.parse(product.price) <= maxPrice;
					} catch (_) {}
				}

				return matchesSearch && matchesStoreId && matchesStatus && matchesStock && matchesImage && matchesPrice;
			}).toList();

			_sortProducts();
		});
	}

	void _sortProducts() {
		_filteredProducts.sort((a, b) {
			int comparison = 0;
			switch (_sortBy) {
				case 'id':
					comparison = int.parse(a.id).compareTo(int.parse(b.id));
					break;
				case 'storeId':
					comparison = int.parse(a.storeId).compareTo(int.parse(b.storeId));
					break;
				case 'name':
					comparison = a.name.compareTo(b.name);
					break;
				case 'price':
					comparison = double.parse(a.price).compareTo(double.parse(b.price));
					break;
				case 'stockQuantity':
					comparison = int.parse(a.stockQuantity).compareTo(int.parse(b.stockQuantity));
					break;
				case 'status':
					comparison = a.status.compareTo(b.status);
					break;
				case 'createdAt':
					comparison = a.createdAt.compareTo(b.createdAt);
					break;
			}
			return _sortAscending ? comparison : -comparison;
		});
	}

	Future<void> _pickImage() async {
		final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
		if (image != null) {
			final bytes = await image.readAsBytes();
			setState(() => _pickedImageBase64 = base64Encode(bytes));
		}
	}

	Future<void> _addProduct() async {
		final Map<String, String> data = {
			"action": "add",
			"store_id": _storeIdController.text.trim(),
			"name": _nameController.text.trim(),
			"description": _descriptionController.text.trim(),
			"price": _priceController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"image": _pickedImageBase64 ?? '',
			"status": _statusController.text.trim().isEmpty ? 'available' : _statusController.text.trim(),
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
			if (responseBody['message'].toString().toLowerCase().contains('successfully')) {
				_showSnackBar("تم إضافة المنتج بنجاح", Colors.green);
				_fetchProducts();
			} else {
				_showSnackBar("فشل في إضافة المنتج: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _updateProduct(String id) async {
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"store_id": _storeIdController.text.trim(),
			"name": _nameController.text.trim(),
			"description": _descriptionController.text.trim(),
			"price": _priceController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"image": _pickedImageBase64 ?? '',
			"status": _statusController.text.trim().isEmpty ? 'available' : _statusController.text.trim(),
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
			if (responseBody['message'].toString().toLowerCase().contains('successfully')) {
				_showSnackBar("تم تحديث المنتج بنجاح", Colors.green);
				_fetchProducts();
			} else {
				_showSnackBar("فشل في تحديث المنتج: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _deleteProduct(String id) async {
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
			if (responseBody['message'].toString().toLowerCase().contains('successfully')) {
				_showSnackBar("تم حذف المنتج بنجاح", Colors.green);
				_fetchProducts();
			} else {
				_showSnackBar("فشل في حذف المنتج: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	void _showSnackBar(String message, Color color) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: color,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
			),
		);
	}

	void _showAddEditDialog({Product? productObj}) {
		if (productObj != null) {
			_storeIdController.text = productObj.storeId;
			_nameController.text = productObj.name;
			_descriptionController.text = productObj.description;
			_priceController.text = productObj.price;
			_stockQuantityController.text = productObj.stockQuantity;
			_statusController.text = productObj.status;
			_pickedImageBase64 = productObj.imageBase64;
		} else {
			_storeIdController.clear();
			_nameController.clear();
			_descriptionController.clear();
			_priceController.clear();
			_stockQuantityController.clear();
			_statusController.clear();
			_pickedImageBase64 = null;
		}

		showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
					title: Container(
						padding: EdgeInsets.all(16),
						decoration: BoxDecoration(
							gradient: LinearGradient(
								colors: [Colors.teal.shade600, Colors.teal.shade800],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(15),
						),
						child: Text(
							productObj == null ? "إضافة منتج جديد" : "تعديل المنتج",
							style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
						),
					),
					content: Container(
						width: double.maxFinite,
						child: SingleChildScrollView(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildDialogTextField(_storeIdController, "معرف المتجر", Icons.store, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_nameController, "اسم المنتج", Icons.shopping_bag, TextInputType.text),
									SizedBox(height: 16),
									_buildDialogTextField(_descriptionController, "الوصف", Icons.description, TextInputType.multiline),
									SizedBox(height: 16),
									_buildDialogTextField(_priceController, "السعر", Icons.attach_money, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_stockQuantityController, "كمية المخزون", Icons.storage, TextInputType.number),
									SizedBox(height: 16),
									Container(
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: Colors.grey.shade300),
										),
										child: DropdownButtonFormField<String>(
											value: _statusController.text.isEmpty ? 'available' : _statusController.text,
											decoration: InputDecoration(
												labelText: "حالة المنتج",
												prefixIcon: Icon(Icons.info, color: Colors.teal.shade600),
												border: InputBorder.none,
												contentPadding: EdgeInsets.all(16),
											),
											items: [
												DropdownMenuItem(value: 'available', child: Text('متوفر')),
												DropdownMenuItem(value: 'out_of_stock', child: Text('نفد المخزون')),
												DropdownMenuItem(value: 'discontinued', child: Text('متوقف')),
											],
											onChanged: (value) {
												_statusController.text = value!;
											},
										),
									),
									SizedBox(height: 16),
									Container(
										width: double.infinity,
										child: ElevatedButton.icon(
											onPressed: _pickImage,
											icon: Icon(Icons.image, color: Colors.teal.shade600),
											label: Text("اختيار صورة من المعرض"),
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.teal.shade50,
												foregroundColor: Colors.teal.shade600,
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
												padding: EdgeInsets.all(16),
											),
										),
									),
									if (_pickedImageBase64 != null && _pickedImageBase64!.isNotEmpty)
										Padding(
											padding: const EdgeInsets.only(top: 16.0),
											child: Container(
												decoration: BoxDecoration(
													borderRadius: BorderRadius.circular(10),
													border: Border.all(color: Colors.grey.shade300),
												),
												child: ClipRRect(
													borderRadius: BorderRadius.circular(10),
													child: Image.memory(
														base64Decode(_pickedImageBase64!),
														height: 100,
														width: 100,
														fit: BoxFit.cover,
													),
												),
											),
										),
								],
							),
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(),
							child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600)),
						),
						ElevatedButton(
							onPressed: () {
								if (productObj == null) {
									_addProduct();
								} else {
									_updateProduct(productObj.id);
								}
								Navigator.of(context).pop();
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.teal.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text(
								productObj == null ? "إضافة" : "تحديث",
								style: TextStyle(color: Colors.white),
							),
						),
					],
				);
			},
		);
	}

	Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon, TextInputType keyboardType) {
		return Container(
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: Colors.grey.shade300),
			),
			child: TextField(
				controller: controller,
				decoration: InputDecoration(
					labelText: label,
					prefixIcon: Icon(icon, color: Colors.teal.shade600),
					border: InputBorder.none,
					contentPadding: EdgeInsets.all(16),
				),
				keyboardType: keyboardType,
				maxLines: keyboardType == TextInputType.multiline ? 3 : 1,
			),
		);
	}

	Widget _buildDashboard() {
		if (_stats == null) return SizedBox.shrink();

		return FadeTransition(
			opacity: _fadeAnimation,
			child: SlideTransition(
				position: _slideAnimation,
				child: Container(
					margin: EdgeInsets.all(16),
					padding: EdgeInsets.all(20),
					decoration: BoxDecoration(
						gradient: LinearGradient(
							colors: [Colors.teal.shade50, Colors.teal.shade100],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
						borderRadius: BorderRadius.circular(20),
						boxShadow: [
							BoxShadow(
								color: Colors.teal.shade200.withOpacity(0.5),
								blurRadius: 15,
								offset: Offset(0, 5),
							),
						],
					),
					child: SingleChildScrollView(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Icon(Icons.dashboard, color: Colors.teal.shade700, size: 28),
										SizedBox(width: 12),
										Text(
											"لوحة الإحصائيات",
											style: TextStyle(
												fontSize: 24,
												fontWeight: FontWeight.bold,
												color: Colors.teal.shade800,
											),
										),
									],
								),
								SizedBox(height: 20),
								GridView.count(
									shrinkWrap: true,
									physics: NeverScrollableScrollPhysics(),
									crossAxisCount: 2,
									childAspectRatio: 1.5,
									crossAxisSpacing: 16,
									mainAxisSpacing: 16,
									children: [
										_buildStatCard("إجمالي المنتجات", _stats!.totalProducts.toString(), Icons.shopping_bag, Colors.green),
										_buildStatCard("إجمالي المخزون", _stats!.totalStock.toString(), Icons.storage, Colors.orange),
										_buildStatCard("القيمة الإجمالية", "${_stats!.totalValue.toStringAsFixed(2)} ر.س", Icons.attach_money, Colors.blue),
										_buildStatCard("المتاجر الفريدة", _stats!.uniqueStores.toString(), Icons.store, Colors.purple),
										_buildStatCard("منتجات متوفرة", _stats!.availableProducts.toString(), Icons.check_circle, Colors.green),
										_buildStatCard("نفد المخزون", _stats!.outOfStockProducts.toString(), Icons.remove_circle, Colors.red),
										_buildStatCard("منتجات متوقفة", _stats!.discontinuedProducts.toString(), Icons.cancel, Colors.grey),
										_buildStatCard("مخزون منخفض", _stats!.lowStockItems.toString(), Icons.warning, Colors.amber),
										_buildStatCard("منتجات مع صور", _stats!.productsWithImages.toString(), Icons.image, Colors.teal),
										_buildStatCard("أغلى منتج", _stats!.mostExpensiveProduct, Icons.trending_up, Colors.indigo),
										_buildStatCard("أرخص منتج", _stats!.cheapestProduct, Icons.trending_down, Colors.cyan),
									],
								),
							],
						),
					),
				),
			),
		);
	}

	Widget _buildStatCard(String title, String value, IconData icon, Color color) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15),
				boxShadow: [
					BoxShadow(
						color: color.withOpacity(0.2),
						blurRadius: 8,
						offset: Offset(0, 3),
					),
				],
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(icon, color: color, size: 26),
					SizedBox(height: 6),
					Text(
						value,
						style: TextStyle(
							fontSize: 16,
							fontWeight: FontWeight.bold,
							color: color,
						),
						textAlign: TextAlign.center,
					),
					SizedBox(height: 2),
					Text(
						title,
						textAlign: TextAlign.center,
						style: TextStyle(
							fontSize: 10,
							color: Colors.grey.shade600,
						),
					),
				],
			),
		);
	}

	Widget _buildFilterSection() {
		return Container(
			margin: EdgeInsets.symmetric(horizontal: 16),
			padding: EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15),
				boxShadow: [
					BoxShadow(
						color: Colors.grey.shade200,
						blurRadius: 10,
						offset: Offset(0, 3),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(Icons.filter_list, color: Colors.teal.shade600),
							SizedBox(width: 8),
							Text(
								"البحث والفلترة",
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.teal.shade800,
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: TextField(
									controller: _searchController,
									decoration: InputDecoration(
										hintText: "البحث في المنتجات...",
										prefixIcon: Icon(Icons.search),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: TextField(
									controller: _storeIdFilterController,
									decoration: InputDecoration(
										hintText: "فلترة بمعرف المتجر...",
										prefixIcon: Icon(Icons.store),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: TextField(
									controller: _minPriceController,
									decoration: InputDecoration(
										hintText: "أقل سعر...",
										prefixIcon: Icon(Icons.attach_money),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									keyboardType: TextInputType.number,
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: TextField(
									controller: _maxPriceController,
									decoration: InputDecoration(
										hintText: "أعلى سعر...",
										prefixIcon: Icon(Icons.attach_money),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									keyboardType: TextInputType.number,
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: DropdownButtonFormField<String>(
									value: _selectedStatusFilter,
									decoration: InputDecoration(
										labelText: "فلترة بالحالة",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', 'available', 'out_of_stock', 'discontinued']
											.map((status) => DropdownMenuItem(
										value: status,
										child: Text(status == 'الكل' ? 'الكل' :
										status == 'available' ? 'متوفر' :
										status == 'out_of_stock' ? 'نفد المخزون' : 'متوقف'),
									))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedStatusFilter = value!;
											_filterProducts();
										});
									},
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: DropdownButtonFormField<String>(
									value: _selectedStockFilter,
									decoration: InputDecoration(
										labelText: "فلترة بالمخزون",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', 'متوفر', 'غير متوفر', 'مخزون منخفض']
											.map((status) => DropdownMenuItem(value: status, child: Text(status)))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedStockFilter = value!;
											_filterProducts();
										});
									},
								),
							),
						],
					),
					SizedBox(height: 16),
					DropdownButtonFormField<String>(
						value: _selectedImageFilter,
						decoration: InputDecoration(
							labelText: "فلترة بالصورة",
							border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
							filled: true,
							fillColor: Colors.grey.shade50,
						),
						items: ['الكل', 'مع صورة', 'بدون صورة']
								.map((status) => DropdownMenuItem(value: status, child: Text(status)))
								.toList(),
						onChanged: (value) {
							setState(() {
								_selectedImageFilter = value!;
								_filterProducts();
							});
						},
					),
				],
			),
		);
	}

	Widget _buildSortingSection() {
		return Container(
			margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			padding: EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.grey.shade50,
				borderRadius: BorderRadius.circular(10),
			),
			child: Row(
				children: [
					Icon(Icons.sort, color: Colors.grey.shade600),
					SizedBox(width: 8),
					Text("ترتيب حسب:", style: TextStyle(fontWeight: FontWeight.w500)),
					SizedBox(width: 12),
					Expanded(
						child: DropdownButton<String>(
							value: _sortBy,
							isExpanded: true,
							underline: SizedBox.shrink(),
							items: [
								DropdownMenuItem(value: 'id', child: Text('المعرف')),
								DropdownMenuItem(value: 'storeId', child: Text('معرف المتجر')),
								DropdownMenuItem(value: 'name', child: Text('اسم المنتج')),
								DropdownMenuItem(value: 'price', child: Text('السعر')),
								DropdownMenuItem(value: 'stockQuantity', child: Text('كمية المخزون')),
								DropdownMenuItem(value: 'status', child: Text('الحالة')),
								DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإنشاء')),
							],
							onChanged: (value) {
								setState(() {
									_sortBy = value!;
									_filterProducts();
								});
							},
						),
					),
					IconButton(
						icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
						onPressed: () {
							setState(() {
								_sortAscending = !_sortAscending;
								_filterProducts();
							});
						},
					),
				],
			),
		);
	}

	Widget _buildDataTable() {
		return Container(
			margin: EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15),
				boxShadow: [
					BoxShadow(
						color: Colors.grey.shade200,
						blurRadius: 10,
						offset: Offset(0, 3),
					),
				],
			),
			child: ClipRRect(
				borderRadius: BorderRadius.circular(15),
				child: SingleChildScrollView(
					scrollDirection: Axis.horizontal,
					child: Container(
						constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
						child: DataTable(
							headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
							headingTextStyle: TextStyle(
								fontWeight: FontWeight.bold,
								color: Colors.teal.shade800,
							),
							dataRowHeight: 80,
							columnSpacing: 20,
							columns: [
								DataColumn(
									label: Text("المعرف"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'id';
											_sortAscending = ascending;
											_filterProducts();
										});
									},
								),
								DataColumn(
									label: Text("معرف المتجر"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'storeId';
											_sortAscending = ascending;
											_filterProducts();
										});
									},
								),
								DataColumn(
									label: Text("اسم المنتج"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'name';
											_sortAscending = ascending;
											_filterProducts();
										});
									},
								),
								DataColumn(label: Text("الوصف")),
								DataColumn(
									label: Text("السعر"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'price';
											_sortAscending = ascending;
											_filterProducts();
										});
									},
								),
								DataColumn(
									label: Text("كمية المخزون"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'stockQuantity';
											_sortAscending = ascending;
											_filterProducts();
										});
									},
								),
								DataColumn(label: Text("الصورة")),
								DataColumn(
									label: Text("الحالة"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'status';
											_sortAscending = ascending;
											_filterProducts();
										});
									},
								),
								DataColumn(label: Text("تاريخ الإنشاء")),
								DataColumn(label: Text("الإجراءات")),
							],
							rows: _filteredProducts.map((productObj) {
								int stockQuantity = int.parse(productObj.stockQuantity);
								Color stockColor = stockQuantity == 0
										? Colors.red
										: stockQuantity < 10
										? Colors.orange
										: Colors.green;

								Color statusColor = productObj.status == 'available'
										? Colors.green
										: productObj.status == 'out_of_stock'
										? Colors.red
										: Colors.grey;

								String statusText = productObj.status == 'available'
										? 'متوفر'
										: productObj.status == 'out_of_stock'
										? 'نفد المخزون'
										: 'متوقف';

								Uint8List? imageBytes;
								if (productObj.imageBase64 != null && productObj.imageBase64!.isNotEmpty) {
									try {
										imageBytes = base64Decode(productObj.imageBase64!);
									} catch (_) {}
								}

								return DataRow(
									color: MaterialStateProperty.resolveWith<Color?>(
												(Set<MaterialState> states) {
											if (states.contains(MaterialState.hovered)) {
												return Colors.teal.shade50;
											}
											return null;
										},
									),
									cells: [
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.teal.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													productObj.id,
													style: TextStyle(fontWeight: FontWeight.bold),
												),
											),
										),
										DataCell(Text(productObj.storeId)),
										DataCell(
											Container(
												constraints: BoxConstraints(maxWidth: 150),
												child: Text(
													productObj.name,
													style: TextStyle(fontWeight: FontWeight.w500),
													overflow: TextOverflow.ellipsis,
												),
											),
										),
										DataCell(
											Container(
												constraints: BoxConstraints(maxWidth: 200),
												child: Text(
													productObj.description,
													overflow: TextOverflow.ellipsis,
													maxLines: 2,
												),
											),
										),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.green.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													"${productObj.price} ر.س",
													style: TextStyle(
														color: Colors.green.shade700,
														fontWeight: FontWeight.bold,
													),
												),
											),
										),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: stockColor.withOpacity(0.2),
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													productObj.stockQuantity,
													style: TextStyle(
														color: stockColor,
														fontWeight: FontWeight.bold,
													),
												),
											),
										),
										DataCell(
											imageBytes != null
													? Container(
												decoration: BoxDecoration(
													borderRadius: BorderRadius.circular(8),
													border: Border.all(color: Colors.grey.shade300),
												),
												child: ClipRRect(
													borderRadius: BorderRadius.circular(8),
													child: Image.memory(
														imageBytes,
														width: 60,
														height: 60,
														fit: BoxFit.cover,
													),
												),
											)
													: Container(
												width: 60,
												height: 60,
												decoration: BoxDecoration(
													color: Colors.grey.shade100,
													borderRadius: BorderRadius.circular(8),
													border: Border.all(color: Colors.grey.shade300),
												),
												child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
											),
										),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
												decoration: BoxDecoration(
													color: statusColor.withOpacity(0.2),
													borderRadius: BorderRadius.circular(20),
												),
												child: Text(
													statusText,
													style: TextStyle(
														color: statusColor,
														fontWeight: FontWeight.w500,
													),
												),
											),
										),
										DataCell(Text(productObj.createdAt)),
										DataCell(
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														decoration: BoxDecoration(
															color: Colors.teal.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.edit, size: 18, color: Colors.teal.shade600),
															tooltip: "تعديل",
															onPressed: () => _showAddEditDialog(productObj: productObj),
														),
													),
													SizedBox(width: 8),
													Container(
														decoration: BoxDecoration(
															color: Colors.red.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.delete, size: 18, color: Colors.red.shade600),
															tooltip: "حذف",
															onPressed: () => _showDeleteConfirmation(productObj),
														),
													),
												],
											),
										),
									],
								);
							}).toList(),
						),
					),
				),
			),
		);
	}

	void _showDeleteConfirmation(Product productObj) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
					title: Row(
						children: [
							Icon(Icons.warning, color: Colors.red.shade600),
							SizedBox(width: 8),
							Text("تأكيد الحذف"),
						],
					),
					content: Text("هل أنت متأكد من حذف المنتج '${productObj.name}'؟"),
					actions: [
						TextButton(
							child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600)),
							onPressed: () => Navigator.of(context).pop(),
						),
						ElevatedButton(
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.red.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text("حذف", style: TextStyle(color: Colors.white)),
							onPressed: () {
								Navigator.of(context).pop();
								_deleteProduct(productObj.id);
							},
						),
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_storeIdController.dispose();
		_nameController.dispose();
		_descriptionController.dispose();
		_priceController.dispose();
		_stockQuantityController.dispose();
		_statusController.dispose();
		_searchController.dispose();
		_storeIdFilterController.dispose();
		_minPriceController.dispose();
		_maxPriceController.dispose();
		_fadeController.dispose();
		_slideController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey.shade50,
			appBar: AppBar(
				title: Text(
					"إدارة المنتجات",
					style: TextStyle(fontWeight: FontWeight.bold),
				),
				backgroundColor: Colors.teal.shade600,
				foregroundColor: Colors.white,
				elevation: 0,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchProducts,
						tooltip: "تحديث",
					),
					IconButton(
						icon: Icon(Icons.info_outline),
						onPressed: () {
							showDialog(
								context: context,
								builder: (context) => AlertDialog(
									title: Text("معلومات التطبيق"),
									content: Text("تطبيق إدارة المنتجات مع لوحة إحصائيات وطرق فلترة متقدمة"),
									actions: [
										TextButton(
											onPressed: () => Navigator.pop(context),
											child: Text("موافق"),
										),
									],
								),
							);
						},
					),
				],
			),
			body: _isLoading
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						CircularProgressIndicator(
							valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
						),
						SizedBox(height: 16),
						Text("جاري التحميل...", style: TextStyle(color: Colors.grey.shade600)),
					],
				),
			)
					: _products.isEmpty
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
						SizedBox(height: 16),
						Text(
							"لا توجد منتجات متاحة",
							style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
						),
						SizedBox(height: 8),
						Text(
							"اضغط على زر الإضافة لبدء إضافة المنتجات",
							style: TextStyle(color: Colors.grey.shade500),
						),
					],
				),
			)
					: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_buildDashboard(),
						_buildFilterSection(),
						_buildSortingSection(),
						Container(
							margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
							child: Text(
								"عرض ${_filteredProducts.length} من ${_products.length} منتج",
								style: TextStyle(
									color: Colors.grey.shade600,
									fontWeight: FontWeight.w500,
								),
							),
						),
						_buildDataTable(),
						SizedBox(height: 80), // مساحة إضافية للـ FloatingActionButton
					],
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => _showAddEditDialog(),
				backgroundColor: Colors.teal.shade600,
				foregroundColor: Colors.white,
				icon: Icon(Icons.add),
				label: Text("إضافة منتج"),
				tooltip: "إضافة منتج جديد",
			),
		);
	}
}

