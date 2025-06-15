import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig.dart';

// تعريف كلاس تفاصيل الطلب بناءً على جدول order_details
class OrderDetail {
	final String id;
	final String orderId;
	final String productId;
	final String quantity;
	final String price;
	final String? color;
	final String? size;
	final String? createdAt;
	final String? updatedAt;

	OrderDetail({
		required this.id,
		required this.orderId,
		required this.productId,
		required this.quantity,
		required this.price,
		this.color,
		this.size,
		this.createdAt,
		this.updatedAt,
	});

	factory OrderDetail.fromJson(Map<String, dynamic> json) {
		return OrderDetail(
			id: json['id']?.toString() ?? '',
			orderId: json['order_id']?.toString() ?? '',
			productId: json['product_id']?.toString() ?? '',
			quantity: json['quantity']?.toString() ?? '',
			price: json['price']?.toString() ?? '',
			color: json['color'],
			size: json['size'],
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}
}

// كلاس للإحصائيات
class DashboardStats {
	final int totalOrderDetails;
	final int uniqueOrders;
	final int uniqueProducts;
	final int totalQuantity;
	final double totalValue;
	final double averagePrice;
	final double averageQuantity;
	final String mostOrderedProduct;
	final String largestOrder;
	final int itemsWithColor;
	final int itemsWithSize;
	final double highestPrice;
	final double lowestPrice;

	DashboardStats({
		required this.totalOrderDetails,
		required this.uniqueOrders,
		required this.uniqueProducts,
		required this.totalQuantity,
		required this.totalValue,
		required this.averagePrice,
		required this.averageQuantity,
		required this.mostOrderedProduct,
		required this.largestOrder,
		required this.itemsWithColor,
		required this.itemsWithSize,
		required this.highestPrice,
		required this.lowestPrice,
	});
}

class OrderDetailManagementPage extends StatefulWidget {
	@override
	_OrderDetailManagementPageState createState() => _OrderDetailManagementPageState();
}

class _OrderDetailManagementPageState extends State<OrderDetailManagementPage>
		with TickerProviderStateMixin {
	List<OrderDetail> _orderDetails = [];
	List<OrderDetail> _filteredOrderDetails = [];
	bool _isLoading = false;
	DashboardStats? _stats;

	// Controllers للنموذج
	final TextEditingController _orderIdController = TextEditingController();
	final TextEditingController _productIdController = TextEditingController();
	final TextEditingController _quantityController = TextEditingController();
	final TextEditingController _priceController = TextEditingController();
	final TextEditingController _colorController = TextEditingController();
	final TextEditingController _sizeController = TextEditingController();

	// Controllers للفلترة والبحث
	final TextEditingController _searchController = TextEditingController();
	final TextEditingController _orderIdFilterController = TextEditingController();
	final TextEditingController _productIdFilterController = TextEditingController();
	final TextEditingController _minPriceController = TextEditingController();
	final TextEditingController _maxPriceController = TextEditingController();
	final TextEditingController _minQuantityController = TextEditingController();
	final TextEditingController _maxQuantityController = TextEditingController();
	String _selectedColorFilter = 'الكل';
	String _selectedSizeFilter = 'الكل';
	String _selectedAttributeFilter = 'الكل';
	String _sortBy = 'id';
	bool _sortAscending = true;

	// Animation Controllers
	AnimationController? _fadeController;
	AnimationController? _slideController;
	Animation<double>? _fadeAnimation;
	Animation<Offset>? _slideAnimation;

	// رابط API الخاص بتفاصيل الطلبات
	final String apiUrl = ApiHelper.url('order_items.php');

	@override
	void initState() {
		super.initState();

		_fadeController = AnimationController(
			duration: Duration(milliseconds: 800),
			vsync: this,
		);
		_slideController = AnimationController(
			duration: Duration(milliseconds: 600),
			vsync: this,
		);

		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
		);

		_slideAnimation = Tween<Offset>(
			begin: Offset(0, 0.3),
			end: Offset.zero,
		).animate(CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic));

		_fadeController!.forward();
		_slideController!.forward();

		_fetchOrderDetails();
		_searchController.addListener(_filterOrderDetails);
		_orderIdFilterController.addListener(_filterOrderDetails);
		_productIdFilterController.addListener(_filterOrderDetails);
		_minPriceController.addListener(_filterOrderDetails);
		_maxPriceController.addListener(_filterOrderDetails);
		_minQuantityController.addListener(_filterOrderDetails);
		_maxQuantityController.addListener(_filterOrderDetails);
	}

	Future<void> _fetchOrderDetails() async {
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final body = json.decode(response.body);
				if (body is List) {
					setState(() {
						_orderDetails = body.map((item) => OrderDetail.fromJson(item)).toList();
						_filteredOrderDetails = List.from(_orderDetails);
						_stats = _calculateStats();
						_isLoading = false;
					});
					_filterOrderDetails();
				} else {
					setState(() {
						_isLoading = false;
					});
					_showSnackBar("تنسيق استجابة غير متوقع", Colors.red);
				}
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
		if (_orderDetails.isEmpty) {
			return DashboardStats(
				totalOrderDetails: 0,
				uniqueOrders: 0,
				uniqueProducts: 0,
				totalQuantity: 0,
				totalValue: 0.0,
				averagePrice: 0.0,
				averageQuantity: 0.0,
				mostOrderedProduct: 'غير متوفر',
				largestOrder: 'غير متوفر',
				itemsWithColor: 0,
				itemsWithSize: 0,
				highestPrice: 0.0,
				lowestPrice: 0.0,
			);
		}

		Set<String> uniqueOrders = _orderDetails.map((detail) => detail.orderId).toSet();
		Set<String> uniqueProducts = _orderDetails.map((detail) => detail.productId).toSet();
		int totalQuantity = _orderDetails.fold(0, (sum, detail) => sum + int.parse(detail.quantity));
		double totalValue = _orderDetails.fold(0.0, (sum, detail) => sum + (double.parse(detail.price) * int.parse(detail.quantity)));
		double averagePrice = _orderDetails.fold(0.0, (sum, detail) => sum + double.parse(detail.price)) / _orderDetails.length;
		double averageQuantity = totalQuantity / _orderDetails.length;

		// حساب المنتج الأكثر طلباً
		Map<String, int> productCount = {};
		for (var detail in _orderDetails) {
			productCount[detail.productId] = (productCount[detail.productId] ?? 0) + int.parse(detail.quantity);
		}
		String mostOrderedProduct = productCount.entries.isNotEmpty
				? productCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
				: 'غير متوفر';

		// حساب أكبر طلب (بالكمية)
		Map<String, int> orderQuantities = {};
		for (var detail in _orderDetails) {
			orderQuantities[detail.orderId] = (orderQuantities[detail.orderId] ?? 0) + int.parse(detail.quantity);
		}
		String largestOrder = orderQuantities.entries.isNotEmpty
				? orderQuantities.entries.reduce((a, b) => a.value > b.value ? a : b).key
				: 'غير متوفر';

		// حساب العناصر التي تحتوي على لون وحجم
		int itemsWithColor = _orderDetails.where((detail) => detail.color != null && detail.color!.isNotEmpty).length;
		int itemsWithSize = _orderDetails.where((detail) => detail.size != null && detail.size!.isNotEmpty).length;

		// حساب أعلى وأقل سعر
		var sortedByPrice = List<OrderDetail>.from(_orderDetails);
		sortedByPrice.sort((a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
		double lowestPrice = sortedByPrice.isNotEmpty ? double.parse(sortedByPrice.first.price) : 0.0;
		double highestPrice = sortedByPrice.isNotEmpty ? double.parse(sortedByPrice.last.price) : 0.0;

		return DashboardStats(
			totalOrderDetails: _orderDetails.length,
			uniqueOrders: uniqueOrders.length,
			uniqueProducts: uniqueProducts.length,
			totalQuantity: totalQuantity,
			totalValue: totalValue,
			averagePrice: averagePrice,
			averageQuantity: averageQuantity,
			mostOrderedProduct: mostOrderedProduct,
			largestOrder: largestOrder,
			itemsWithColor: itemsWithColor,
			itemsWithSize: itemsWithSize,
			highestPrice: highestPrice,
			lowestPrice: lowestPrice,
		);
	}

	void _filterOrderDetails() {
		setState(() {
			_filteredOrderDetails = _orderDetails.where((detail) {
				bool matchesSearch = _searchController.text.isEmpty ||
						detail.id.contains(_searchController.text) ||
						detail.orderId.contains(_searchController.text) ||
						detail.productId.contains(_searchController.text) ||
						(detail.color?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
						(detail.size?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);

				bool matchesOrderId = _orderIdFilterController.text.isEmpty ||
						detail.orderId.contains(_orderIdFilterController.text);

				bool matchesProductId = _productIdFilterController.text.isEmpty ||
						detail.productId.contains(_productIdFilterController.text);

				bool matchesColor = _selectedColorFilter == 'الكل' ||
						detail.color == _selectedColorFilter;

				bool matchesSize = _selectedSizeFilter == 'الكل' ||
						detail.size == _selectedSizeFilter;

				bool matchesAttribute = _selectedAttributeFilter == 'الكل' ||
						(_selectedAttributeFilter == 'مع لون' && detail.color != null && detail.color!.isNotEmpty) ||
						(_selectedAttributeFilter == 'بدون لون' && (detail.color == null || detail.color!.isEmpty)) ||
						(_selectedAttributeFilter == 'مع حجم' && detail.size != null && detail.size!.isNotEmpty) ||
						(_selectedAttributeFilter == 'بدون حجم' && (detail.size == null || detail.size!.isEmpty));

				bool matchesPrice = true;
				if (_minPriceController.text.isNotEmpty) {
					try {
						double minPrice = double.parse(_minPriceController.text);
						matchesPrice = matchesPrice && double.parse(detail.price) >= minPrice;
					} catch (_) {}
				}
				if (_maxPriceController.text.isNotEmpty) {
					try {
						double maxPrice = double.parse(_maxPriceController.text);
						matchesPrice = matchesPrice && double.parse(detail.price) <= maxPrice;
					} catch (_) {}
				}

				bool matchesQuantity = true;
				if (_minQuantityController.text.isNotEmpty) {
					try {
						int minQuantity = int.parse(_minQuantityController.text);
						matchesQuantity = matchesQuantity && int.parse(detail.quantity) >= minQuantity;
					} catch (_) {}
				}
				if (_maxQuantityController.text.isNotEmpty) {
					try {
						int maxQuantity = int.parse(_maxQuantityController.text);
						matchesQuantity = matchesQuantity && int.parse(detail.quantity) <= maxQuantity;
					} catch (_) {}
				}

				return matchesSearch && matchesOrderId && matchesProductId && matchesColor && matchesSize && matchesAttribute && matchesPrice && matchesQuantity;
			}).toList();

			_sortOrderDetails();
		});
	}

	void _sortOrderDetails() {
		_filteredOrderDetails.sort((a, b) {
			int comparison = 0;
			switch (_sortBy) {
				case 'id':
					comparison = int.parse(a.id).compareTo(int.parse(b.id));
					break;
				case 'orderId':
					comparison = int.parse(a.orderId).compareTo(int.parse(b.orderId));
					break;
				case 'productId':
					comparison = int.parse(a.productId).compareTo(int.parse(b.productId));
					break;
				case 'quantity':
					comparison = int.parse(a.quantity).compareTo(int.parse(b.quantity));
					break;
				case 'price':
					comparison = double.parse(a.price).compareTo(double.parse(b.price));
					break;
				case 'color':
					comparison = (a.color ?? '').compareTo(b.color ?? '');
					break;
				case 'size':
					comparison = (a.size ?? '').compareTo(b.size ?? '');
					break;
				case 'createdAt':
					comparison = (a.createdAt ?? '').compareTo(b.createdAt ?? '');
					break;
			}
			return _sortAscending ? comparison : -comparison;
		});
	}

	Future<void> _addOrderDetail() async {
		final Map<String, String> data = {
			"action": "add",
			"order_id": _orderIdController.text.trim(),
			"product_id": _productIdController.text.trim(),
			"quantity": _quantityController.text.trim(),
			"price": _priceController.text.trim(),
			"color": _colorController.text.trim(),
			"size": _sizeController.text.trim(),
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
			if (responseBody['message'] != null && responseBody['message'].toString().toLowerCase().contains('success')) {
				_showSnackBar("تم إضافة تفاصيل الطلب بنجاح", Colors.green);
				_fetchOrderDetails();
			} else {
				_showSnackBar("فشل في إضافة تفاصيل الطلب: ${responseBody['message'] ?? 'خطأ غير معروف'}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _updateOrderDetail(String id) async {
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"order_id": _orderIdController.text.trim(),
			"product_id": _productIdController.text.trim(),
			"quantity": _quantityController.text.trim(),
			"price": _priceController.text.trim(),
			"color": _colorController.text.trim(),
			"size": _sizeController.text.trim(),
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
			if (responseBody['message'] != null && responseBody['message'].toString().toLowerCase().contains('success')) {
				_showSnackBar("تم تحديث تفاصيل الطلب بنجاح", Colors.green);
				_fetchOrderDetails();
			} else {
				_showSnackBar("فشل في تحديث تفاصيل الطلب: ${responseBody['message'] ?? 'خطأ غير معروف'}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _deleteOrderDetail(String id) async {
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
			if (responseBody['message'] != null && responseBody['message'].toString().toLowerCase().contains('success')) {
				_showSnackBar("تم حذف تفاصيل الطلب بنجاح", Colors.green);
				_fetchOrderDetails();
			} else {
				_showSnackBar("فشل في حذف تفاصيل الطلب: ${responseBody['message'] ?? 'خطأ غير معروف'}", Colors.red);
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

	void _showAddEditDialog({OrderDetail? orderDetailObj}) {
		if (orderDetailObj != null) {
			_orderIdController.text = orderDetailObj.orderId;
			_productIdController.text = orderDetailObj.productId;
			_quantityController.text = orderDetailObj.quantity;
			_priceController.text = orderDetailObj.price;
			_colorController.text = orderDetailObj.color ?? '';
			_sizeController.text = orderDetailObj.size ?? '';
		} else {
			_orderIdController.clear();
			_productIdController.clear();
			_quantityController.clear();
			_priceController.clear();
			_colorController.clear();
			_sizeController.clear();
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
								colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade800],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(15),
						),
						child: Text(
							orderDetailObj == null ? "إضافة تفاصيل طلب جديدة" : "تعديل تفاصيل الطلب",
							style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
						),
					),
					content: Container(
						width: double.maxFinite,
						child: SingleChildScrollView(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildDialogTextField(_orderIdController, "رقم الطلب", Icons.receipt_long, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_productIdController, "رقم المنتج", Icons.shopping_bag, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_quantityController, "الكمية", Icons.numbers, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_priceController, "السعر", Icons.attach_money, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_colorController, "اللون", Icons.color_lens, TextInputType.text),
									SizedBox(height: 16),
									_buildDialogTextField(_sizeController, "الحجم", Icons.straighten, TextInputType.text),
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
								if (orderDetailObj == null) {
									_addOrderDetail();
								} else {
									_updateOrderDetail(orderDetailObj.id);
								}
								Navigator.of(context).pop();
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.deepPurple.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text(
								orderDetailObj == null ? "إضافة" : "تحديث",
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
					prefixIcon: Icon(icon, color: Colors.deepPurple.shade600),
					border: InputBorder.none,
					contentPadding: EdgeInsets.all(16),
				),
				keyboardType: keyboardType,
			),
		);
	}

	Widget _buildDashboard() {
		if (_stats == null) return SizedBox.shrink();

		// Ensure animations are initialized before use
		if (_fadeAnimation == null || _slideAnimation == null) {
			return Container(
				margin: EdgeInsets.all(16),
				padding: EdgeInsets.all(20),
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
					borderRadius: BorderRadius.circular(20),
					boxShadow: [
						BoxShadow(
							color: Colors.deepPurple.shade200.withOpacity(0.5),
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
									Icon(Icons.dashboard, color: Colors.deepPurple.shade700, size: 28),
									SizedBox(width: 12),
									Text(
										"لوحة الإحصائيات",
										style: TextStyle(
											fontSize: 24,
											fontWeight: FontWeight.bold,
											color: Colors.deepPurple.shade800,
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
									_buildStatCard("إجمالي التفاصيل", _stats!.totalOrderDetails.toString(), Icons.list_alt, Colors.green),
									_buildStatCard("الطلبات الفريدة", _stats!.uniqueOrders.toString(), Icons.receipt_long, Colors.blue),
									_buildStatCard("المنتجات الفريدة", _stats!.uniqueProducts.toString(), Icons.shopping_bag, Colors.orange),
									_buildStatCard("إجمالي الكمية", _stats!.totalQuantity.toString(), Icons.numbers, Colors.purple),
									_buildStatCard("القيمة الإجمالية", "${_stats!.totalValue.toStringAsFixed(2)} ر.س", Icons.attach_money, Colors.teal),
									_buildStatCard("متوسط السعر", "${_stats!.averagePrice.toStringAsFixed(2)} ر.س", Icons.analytics, Colors.amber),
									_buildStatCard("متوسط الكمية", _stats!.averageQuantity.toStringAsFixed(1), Icons.bar_chart, Colors.cyan),
									_buildStatCard("المنتج الأكثر طلباً", _stats!.mostOrderedProduct, Icons.trending_up, Colors.indigo),
									_buildStatCard("أكبر طلب", _stats!.largestOrder, Icons.shopping_cart, Colors.red),
									_buildStatCard("عناصر مع لون", _stats!.itemsWithColor.toString(), Icons.color_lens, Colors.pink),
									_buildStatCard("عناصر مع حجم", _stats!.itemsWithSize.toString(), Icons.straighten, Colors.brown),
									_buildStatCard("أعلى سعر", "${_stats!.highestPrice.toStringAsFixed(2)} ر.س", Icons.arrow_upward, Colors.green),
									_buildStatCard("أقل سعر", "${_stats!.lowestPrice.toStringAsFixed(2)} ر.س", Icons.arrow_downward, Colors.red),
								],
							),
						],
					),
				),
			);
		}

		return FadeTransition(
			opacity: _fadeAnimation!,
			child: SlideTransition(
				position: _slideAnimation!,
				child: Container(
					margin: EdgeInsets.all(16),
					padding: EdgeInsets.all(20),
					decoration: BoxDecoration(
						gradient: LinearGradient(
							colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
						borderRadius: BorderRadius.circular(20),
						boxShadow: [
							BoxShadow(
								color: Colors.deepPurple.shade200.withOpacity(0.5),
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
										Icon(Icons.dashboard, color: Colors.deepPurple.shade700, size: 28),
										SizedBox(width: 12),
										Text(
											"لوحة الإحصائيات",
											style: TextStyle(
												fontSize: 24,
												fontWeight: FontWeight.bold,
												color: Colors.deepPurple.shade800,
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
										_buildStatCard("إجمالي التفاصيل", _stats!.totalOrderDetails.toString(), Icons.list_alt, Colors.green),
										_buildStatCard("الطلبات الفريدة", _stats!.uniqueOrders.toString(), Icons.receipt_long, Colors.blue),
										_buildStatCard("المنتجات الفريدة", _stats!.uniqueProducts.toString(), Icons.shopping_bag, Colors.orange),
										_buildStatCard("إجمالي الكمية", _stats!.totalQuantity.toString(), Icons.numbers, Colors.purple),
										_buildStatCard("القيمة الإجمالية", "${_stats!.totalValue.toStringAsFixed(2)} ر.س", Icons.attach_money, Colors.teal),
										_buildStatCard("متوسط السعر", "${_stats!.averagePrice.toStringAsFixed(2)} ر.س", Icons.analytics, Colors.amber),
										_buildStatCard("متوسط الكمية", _stats!.averageQuantity.toStringAsFixed(1), Icons.bar_chart, Colors.cyan),
										_buildStatCard("المنتج الأكثر طلباً", _stats!.mostOrderedProduct, Icons.trending_up, Colors.indigo),
										_buildStatCard("أكبر طلب", _stats!.largestOrder, Icons.shopping_cart, Colors.red),
										_buildStatCard("عناصر مع لون", _stats!.itemsWithColor.toString(), Icons.color_lens, Colors.pink),
										_buildStatCard("عناصر مع حجم", _stats!.itemsWithSize.toString(), Icons.straighten, Colors.brown),
										_buildStatCard("أعلى سعر", "${_stats!.highestPrice.toStringAsFixed(2)} ر.س", Icons.arrow_upward, Colors.green),
										_buildStatCard("أقل سعر", "${_stats!.lowestPrice.toStringAsFixed(2)} ر.س", Icons.arrow_downward, Colors.red),
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
							Icon(Icons.filter_list, color: Colors.deepPurple.shade600),
							SizedBox(width: 8),
							Text(
								"البحث والفلترة",
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.deepPurple.shade800,
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
										hintText: "البحث في تفاصيل الطلبات...",
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
									controller: _orderIdFilterController,
									decoration: InputDecoration(
										hintText: "فلترة برقم الطلب...",
										prefixIcon: Icon(Icons.receipt_long),
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
									controller: _productIdFilterController,
									decoration: InputDecoration(
										hintText: "فلترة برقم المنتج...",
										prefixIcon: Icon(Icons.shopping_bag),
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
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
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
							SizedBox(width: 12),
							Expanded(
								child: TextField(
									controller: _minQuantityController,
									decoration: InputDecoration(
										hintText: "أقل كمية...",
										prefixIcon: Icon(Icons.numbers),
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
								child: TextField(
									controller: _maxQuantityController,
									decoration: InputDecoration(
										hintText: "أعلى كمية...",
										prefixIcon: Icon(Icons.numbers),
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
								child: DropdownButtonFormField<String>(
									value: _selectedColorFilter,
									decoration: InputDecoration(
										labelText: "فلترة باللون",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', ...(_orderDetails.where((d) => d.color != null && d.color!.isNotEmpty).map((d) => d.color!).toSet().toList())]
											.map((color) => DropdownMenuItem(value: color, child: Text(color)))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedColorFilter = value!;
											_filterOrderDetails();
										});
									},
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: DropdownButtonFormField<String>(
									value: _selectedSizeFilter,
									decoration: InputDecoration(
										labelText: "فلترة بالحجم",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', ...(_orderDetails.where((d) => d.size != null && d.size!.isNotEmpty).map((d) => d.size!).toSet().toList())]
											.map((size) => DropdownMenuItem(value: size, child: Text(size)))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedSizeFilter = value!;
											_filterOrderDetails();
										});
									},
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: DropdownButtonFormField<String>(
									value: _selectedAttributeFilter,
									decoration: InputDecoration(
										labelText: "فلترة بالخصائص",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', 'مع لون', 'بدون لون', 'مع حجم', 'بدون حجم']
											.map((attr) => DropdownMenuItem(value: attr, child: Text(attr)))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedAttributeFilter = value!;
											_filterOrderDetails();
										});
									},
								),
							),
						],
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
								DropdownMenuItem(value: 'orderId', child: Text('رقم الطلب')),
								DropdownMenuItem(value: 'productId', child: Text('رقم المنتج')),
								DropdownMenuItem(value: 'quantity', child: Text('الكمية')),
								DropdownMenuItem(value: 'price', child: Text('السعر')),
								DropdownMenuItem(value: 'color', child: Text('اللون')),
								DropdownMenuItem(value: 'size', child: Text('الحجم')),
								DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإنشاء')),
							],
							onChanged: (value) {
								setState(() {
									_sortBy = value!;
									_filterOrderDetails();
								});
							},
						),
					),
					IconButton(
						icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
						onPressed: () {
							setState(() {
								_sortAscending = !_sortAscending;
								_filterOrderDetails();
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
							headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade50),
							headingTextStyle: TextStyle(
								fontWeight: FontWeight.bold,
								color: Colors.deepPurple.shade800,
							),
							dataRowHeight: 70,
							columnSpacing: 20,
							columns: [
								DataColumn(
									label: Text("المعرف"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'id';
											_sortAscending = ascending;
											_filterOrderDetails();
										});
									},
								),
								DataColumn(
									label: Text("رقم الطلب"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'orderId';
											_sortAscending = ascending;
											_filterOrderDetails();
										});
									},
								),
								DataColumn(
									label: Text("رقم المنتج"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'productId';
											_sortAscending = ascending;
											_filterOrderDetails();
										});
									},
								),
								DataColumn(
									label: Text("الكمية"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'quantity';
											_sortAscending = ascending;
											_filterOrderDetails();
										});
									},
								),
								DataColumn(
									label: Text("السعر"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'price';
											_sortAscending = ascending;
											_filterOrderDetails();
										});
									},
								),
								DataColumn(label: Text("اللون")),
								DataColumn(label: Text("الحجم")),
								DataColumn(label: Text("تاريخ الإنشاء")),
								DataColumn(label: Text("الإجراءات")),
							],
							rows: _filteredOrderDetails.map((orderDetailObj) {
								return DataRow(
									color: MaterialStateProperty.resolveWith<Color?>(
												(Set<MaterialState> states) {
											if (states.contains(MaterialState.hovered)) {
												return Colors.deepPurple.shade50;
											}
											return null;
										},
									),
									cells: [
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.deepPurple.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													orderDetailObj.id,
													style: TextStyle(fontWeight: FontWeight.bold),
												),
											),
										),
										DataCell(Text(orderDetailObj.orderId)),
										DataCell(Text(orderDetailObj.productId)),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.blue.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													orderDetailObj.quantity,
													style: TextStyle(
														color: Colors.blue.shade700,
														fontWeight: FontWeight.bold,
													),
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
													"${orderDetailObj.price} ر.س",
													style: TextStyle(
														color: Colors.green.shade700,
														fontWeight: FontWeight.bold,
													),
												),
											),
										),
										DataCell(
											orderDetailObj.color != null && orderDetailObj.color!.isNotEmpty
													? Container(
												padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
												decoration: BoxDecoration(
													color: Colors.pink.shade100,
													borderRadius: BorderRadius.circular(20),
												),
												child: Text(
													orderDetailObj.color!,
													style: TextStyle(
														color: Colors.pink.shade700,
														fontWeight: FontWeight.w500,
													),
												),
											)
													: Text("غير محدد", style: TextStyle(color: Colors.grey.shade500)),
										),
										DataCell(
											orderDetailObj.size != null && orderDetailObj.size!.isNotEmpty
													? Container(
												padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
												decoration: BoxDecoration(
													color: Colors.orange.shade100,
													borderRadius: BorderRadius.circular(20),
												),
												child: Text(
													orderDetailObj.size!,
													style: TextStyle(
														color: Colors.orange.shade700,
														fontWeight: FontWeight.w500,
													),
												),
											)
													: Text("غير محدد", style: TextStyle(color: Colors.grey.shade500)),
										),
										DataCell(Text(orderDetailObj.createdAt ?? 'غير متوفر')),
										DataCell(
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														decoration: BoxDecoration(
															color: Colors.deepPurple.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.edit, size: 18, color: Colors.deepPurple.shade600),
															tooltip: "تعديل",
															onPressed: () => _showAddEditDialog(orderDetailObj: orderDetailObj),
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
															onPressed: () => _showDeleteConfirmation(orderDetailObj),
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

	void _showDeleteConfirmation(OrderDetail orderDetailObj) {
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
					content: Text("هل أنت متأكد من حذف تفاصيل الطلب رقم '${orderDetailObj.id}' للطلب ${orderDetailObj.orderId}؟"),
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
								_deleteOrderDetail(orderDetailObj.id);
							},
						),
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_orderIdController.dispose();
		_productIdController.dispose();
		_quantityController.dispose();
		_priceController.dispose();
		_colorController.dispose();
		_sizeController.dispose();
		_searchController.dispose();
		_orderIdFilterController.dispose();
		_productIdFilterController.dispose();
		_minPriceController.dispose();
		_maxPriceController.dispose();
		_minQuantityController.dispose();
		_maxQuantityController.dispose();
		_fadeController?.dispose();
		_slideController?.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey.shade50,
			appBar: AppBar(
				title: Text(
					"إدارة تفاصيل الطلبات",
					style: TextStyle(fontWeight: FontWeight.bold),
				),
				backgroundColor: Colors.deepPurple.shade600,
				foregroundColor: Colors.white,
				elevation: 0,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchOrderDetails,
						tooltip: "تحديث",
					),
					IconButton(
						icon: Icon(Icons.info_outline),
						onPressed: () {
							showDialog(
								context: context,
								builder: (context) => AlertDialog(
									title: Text("معلومات التطبيق"),
									content: Text("تطبيق إدارة تفاصيل الطلبات مع لوحة إحصائيات وطرق فلترة متقدمة"),
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
							valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade600),
						),
						SizedBox(height: 16),
						Text("جاري التحميل...", style: TextStyle(color: Colors.grey.shade600)),
					],
				),
			)
					: _orderDetails.isEmpty
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.list_alt_outlined, size: 80, color: Colors.grey.shade400),
						SizedBox(height: 16),
						Text(
							"لا توجد تفاصيل طلبات متاحة",
							style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
						),
						SizedBox(height: 8),
						Text(
							"اضغط على زر الإضافة لبدء إضافة تفاصيل الطلبات",
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
								"عرض ${_filteredOrderDetails.length} من ${_orderDetails.length} تفاصيل طلب",
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
				backgroundColor: Colors.deepPurple.shade600,
				foregroundColor: Colors.white,
				icon: Icon(Icons.add),
				label: Text("إضافة تفاصيل"),
				tooltip: "إضافة تفاصيل طلب جديدة",
			),
		);
	}
}

