import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig.dart';

// تعريف كلاس المقاسات بناءً على جدول product_sizes
class ProductSize {
	final String id;
	final String productId;
	final String size;
	final String stockQuantity;
	final String additionalPrice;
	final String createdAt;

	ProductSize({
		required this.id,
		required this.productId,
		required this.size,
		required this.stockQuantity,
		required this.additionalPrice,
		required this.createdAt,
	});

	factory ProductSize.fromJson(Map<String, dynamic> json) {
		return ProductSize(
			id: json['id'].toString(),
			productId: json['product_id'].toString(),
			size: json['size'],
			stockQuantity: json['stock_quantity'].toString(),
			additionalPrice: json['additional_price'].toString(),
			createdAt: json['created_at'] ?? '',
		);
	}
}

// كلاس للإحصائيات
class DashboardStats {
	final int totalSizes;
	final int totalStock;
	final double totalAdditionalPrice;
	final int uniqueProducts;
	final String mostCommonSize;
	final int lowStockItems;

	DashboardStats({
		required this.totalSizes,
		required this.totalStock,
		required this.totalAdditionalPrice,
		required this.uniqueProducts,
		required this.mostCommonSize,
		required this.lowStockItems,
	});
}

class ProductSizesManagementPage extends StatefulWidget {
	@override
	_ProductSizesManagementPageState createState() => _ProductSizesManagementPageState();
}

class _ProductSizesManagementPageState extends State<ProductSizesManagementPage>
		with TickerProviderStateMixin {
	List<ProductSize> _sizes = [];
	List<ProductSize> _filteredSizes = [];
	bool _isLoading = false;
	DashboardStats? _stats;

	// Controllers للنموذج
	final TextEditingController _productIdController = TextEditingController();
	final TextEditingController _sizeController = TextEditingController();
	final TextEditingController _stockQuantityController = TextEditingController();
	final TextEditingController _additionalPriceController = TextEditingController();

	// Controllers للفلترة والبحث
	final TextEditingController _searchController = TextEditingController();
	final TextEditingController _productIdFilterController = TextEditingController();
	String _selectedSizeFilter = 'الكل';
	String _selectedStockFilter = 'الكل';
	String _sortBy = 'id';
	bool _sortAscending = true;

	// Animation Controllers
	late AnimationController _fadeController;
	late AnimationController _slideController;
	late Animation<double> _fadeAnimation;
	late Animation<Offset> _slideAnimation;

	// رابط API الخاص بالمقاسات
	final String apiUrl = ApiHelper.url('product_sizes_api.php');

	@override
	void initState() {
		super.initState();
		_initializeAnimations();
		_fetchSizes();
		_searchController.addListener(_filterSizes);
		_productIdFilterController.addListener(_filterSizes);
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

	Future<void> _fetchSizes() async {
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				setState(() {
					_sizes = data.map((item) => ProductSize.fromJson(item)).toList();
					_filteredSizes = List.from(_sizes);
					_stats = _calculateStats();
					_isLoading = false;
				});
				_filterSizes();
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
		if (_sizes.isEmpty) {
			return DashboardStats(
				totalSizes: 0,
				totalStock: 0,
				totalAdditionalPrice: 0.0,
				uniqueProducts: 0,
				mostCommonSize: 'غير متوفر',
				lowStockItems: 0,
			);
		}

		int totalStock = _sizes.fold(0, (sum, size) => sum + int.parse(size.stockQuantity));
		double totalAdditionalPrice = _sizes.fold(0.0, (sum, size) => sum + double.parse(size.additionalPrice));
		Set<String> uniqueProducts = _sizes.map((size) => size.productId).toSet();

		// حساب المقاس الأكثر شيوعاً
		Map<String, int> sizeCount = {};
		for (var size in _sizes) {
			sizeCount[size.size] = (sizeCount[size.size] ?? 0) + 1;
		}
		String mostCommonSize = sizeCount.entries
				.reduce((a, b) => a.value > b.value ? a : b)
				.key;

		// حساب العناصر منخفضة المخزون (أقل من 10)
		int lowStockItems = _sizes.where((size) => int.parse(size.stockQuantity) < 10).length;

		return DashboardStats(
			totalSizes: _sizes.length,
			totalStock: totalStock,
			totalAdditionalPrice: totalAdditionalPrice,
			uniqueProducts: uniqueProducts.length,
			mostCommonSize: mostCommonSize,
			lowStockItems: lowStockItems,
		);
	}

	void _filterSizes() {
		setState(() {
			_filteredSizes = _sizes.where((size) {
				bool matchesSearch = _searchController.text.isEmpty ||
						size.size.toLowerCase().contains(_searchController.text.toLowerCase()) ||
						size.productId.contains(_searchController.text);

				bool matchesProductId = _productIdFilterController.text.isEmpty ||
						size.productId.contains(_productIdFilterController.text);

				bool matchesSize = _selectedSizeFilter == 'الكل' ||
						size.size == _selectedSizeFilter;

				bool matchesStock = _selectedStockFilter == 'الكل' ||
						(_selectedStockFilter == 'متوفر' && int.parse(size.stockQuantity) > 0) ||
						(_selectedStockFilter == 'غير متوفر' && int.parse(size.stockQuantity) == 0) ||
						(_selectedStockFilter == 'مخزون منخفض' && int.parse(size.stockQuantity) < 10);

				return matchesSearch && matchesProductId && matchesSize && matchesStock;
			}).toList();

			_sortSizes();
		});
	}

	void _sortSizes() {
		_filteredSizes.sort((a, b) {
			int comparison = 0;
			switch (_sortBy) {
				case 'id':
					comparison = int.parse(a.id).compareTo(int.parse(b.id));
					break;
				case 'productId':
					comparison = int.parse(a.productId).compareTo(int.parse(b.productId));
					break;
				case 'size':
					comparison = a.size.compareTo(b.size);
					break;
				case 'stockQuantity':
					comparison = int.parse(a.stockQuantity).compareTo(int.parse(b.stockQuantity));
					break;
				case 'additionalPrice':
					comparison = double.parse(a.additionalPrice).compareTo(double.parse(b.additionalPrice));
					break;
				case 'createdAt':
					comparison = a.createdAt.compareTo(b.createdAt);
					break;
			}
			return _sortAscending ? comparison : -comparison;
		});
	}

	Future<void> _addSize() async {
		final Map<String, String> data = {
			"action": "add",
			"product_id": _productIdController.text.trim(),
			"size": _sizeController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"additional_price": _additionalPriceController.text.trim(),
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
			if (responseBody['message'] == "Product size added successfully") {
				_showSnackBar("تم إضافة المقاس بنجاح", Colors.green);
				_fetchSizes();
			} else {
				_showSnackBar("فشل في إضافة المقاس: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _updateSize(String id) async {
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"product_id": _productIdController.text.trim(),
			"size": _sizeController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"additional_price": _additionalPriceController.text.trim(),
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
			if (responseBody['message'] == "Product size updated successfully") {
				_showSnackBar("تم تحديث المقاس بنجاح", Colors.green);
				_fetchSizes();
			} else {
				_showSnackBar("فشل في تحديث المقاس: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _deleteSize(String id) async {
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
			if (responseBody['message'] == "Product size deleted successfully") {
				_showSnackBar("تم حذف المقاس بنجاح", Colors.green);
				_fetchSizes();
			} else {
				_showSnackBar("فشل في حذف المقاس: ${responseBody['message']}", Colors.red);
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

	void _showAddEditDialog({ProductSize? sizeObj}) {
		if (sizeObj != null) {
			_productIdController.text = sizeObj.productId;
			_sizeController.text = sizeObj.size;
			_stockQuantityController.text = sizeObj.stockQuantity;
			_additionalPriceController.text = sizeObj.additionalPrice;
		} else {
			_productIdController.clear();
			_sizeController.clear();
			_stockQuantityController.clear();
			_additionalPriceController.clear();
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
								colors: [Colors.blue.shade600, Colors.blue.shade800],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(15),
						),
						child: Text(
							sizeObj == null ? "إضافة مقاس جديد" : "تعديل المقاس",
							style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
						),
					),
					content: Container(
						width: double.maxFinite,
						child: SingleChildScrollView(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildDialogTextField(_productIdController, "معرف المنتج", Icons.inventory, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_sizeController, "المقاس", Icons.straighten, TextInputType.text),
									SizedBox(height: 16),
									_buildDialogTextField(_stockQuantityController, "كمية المخزون", Icons.storage, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_additionalPriceController, "السعر الإضافي", Icons.attach_money, TextInputType.number),
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
								if (sizeObj == null) {
									_addSize();
								} else {
									_updateSize(sizeObj.id);
								}
								Navigator.of(context).pop();
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.blue.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text(
								sizeObj == null ? "إضافة" : "تحديث",
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
					prefixIcon: Icon(icon, color: Colors.blue.shade600),
					border: InputBorder.none,
					contentPadding: EdgeInsets.all(16),
				),
				keyboardType: keyboardType,
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
							colors: [Colors.blue.shade50, Colors.blue.shade100],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
						borderRadius: BorderRadius.circular(20),
						boxShadow: [
							BoxShadow(
								color: Colors.blue.shade200.withOpacity(0.5),
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
										Icon(Icons.dashboard, color: Colors.blue.shade700, size: 28),
										SizedBox(width: 12),
										Text(
											"لوحة الإحصائيات",
											style: TextStyle(
												fontSize: 24,
												fontWeight: FontWeight.bold,
												color: Colors.blue.shade800,
											),
										),
									],
								),
								SizedBox(height: 20),
								GridView.count(
									shrinkWrap: true,
									physics: NeverScrollableScrollPhysics(), // لإيقاف التمرير
									crossAxisCount: 2,
									childAspectRatio: 1.5,
									crossAxisSpacing: 16,
									mainAxisSpacing: 16,
									children: [
										_buildStatCard("إجمالي المقاسات", _stats!.totalSizes.toString(), Icons.straighten, Colors.green),
										_buildStatCard("إجمالي المخزون", _stats!.totalStock.toString(), Icons.storage, Colors.orange),
										_buildStatCard("المنتجات الفريدة", _stats!.uniqueProducts.toString(), Icons.inventory, Colors.purple),
										_buildStatCard("مخزون منخفض", _stats!.lowStockItems.toString(), Icons.warning, Colors.red),
										_buildStatCard("المقاس الأكثر شيوعاً", _stats!.mostCommonSize, Icons.trending_up, Colors.blue),
										_buildStatCard("إجمالي السعر الإضافي", _stats!.totalAdditionalPrice.toStringAsFixed(2), Icons.attach_money, Colors.teal),
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
				mainAxisSize: MainAxisSize.min, // يمنع التمدد الزائد
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(icon, color: color, size: 26), // تقليل الحجم قليلاً
					SizedBox(height: 6),
					Text(
						value,
						style: TextStyle(
							fontSize: 18,
							fontWeight: FontWeight.bold,
							color: color,
						),
					),
					SizedBox(height: 2),
					Text(
						title,
						textAlign: TextAlign.center,
						style: TextStyle(
							fontSize: 11,
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
							Icon(Icons.filter_list, color: Colors.blue.shade600),
							SizedBox(width: 8),
							Text(
								"البحث والفلترة",
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.blue.shade800,
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
										hintText: "البحث في المقاسات...",
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
									controller: _productIdFilterController,
									decoration: InputDecoration(
										hintText: "فلترة بمعرف المنتج...",
										prefixIcon: Icon(Icons.inventory),
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
								child: DropdownButtonFormField<String>(
									value: _selectedSizeFilter,
									decoration: InputDecoration(
										labelText: "فلترة بالمقاس",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', ...(_sizes.map((s) => s.size).toSet().toList())]
											.map((size) => DropdownMenuItem(value: size, child: Text(size)))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedSizeFilter = value!;
											_filterSizes();
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
											_filterSizes();
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
								DropdownMenuItem(value: 'productId', child: Text('معرف المنتج')),
								DropdownMenuItem(value: 'size', child: Text('المقاس')),
								DropdownMenuItem(value: 'stockQuantity', child: Text('كمية المخزون')),
								DropdownMenuItem(value: 'additionalPrice', child: Text('السعر الإضافي')),
								DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإنشاء')),
							],
							onChanged: (value) {
								setState(() {
									_sortBy = value!;
									_filterSizes();
								});
							},
						),
					),
					IconButton(
						icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
						onPressed: () {
							setState(() {
								_sortAscending = !_sortAscending;
								_filterSizes();
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
							headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
							headingTextStyle: TextStyle(
								fontWeight: FontWeight.bold,
								color: Colors.blue.shade800,
							),
							dataRowHeight: 60,
							columnSpacing: 20,
							columns: [
								DataColumn(
									label: Text("المعرف"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'id';
											_sortAscending = ascending;
											_filterSizes();
										});
									},
								),
								DataColumn(
									label: Text("معرف المنتج"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'productId';
											_sortAscending = ascending;
											_filterSizes();
										});
									},
								),
								DataColumn(
									label: Text("المقاس"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'size';
											_sortAscending = ascending;
											_filterSizes();
										});
									},
								),
								DataColumn(
									label: Text("كمية المخزون"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'stockQuantity';
											_sortAscending = ascending;
											_filterSizes();
										});
									},
								),
								DataColumn(
									label: Text("السعر الإضافي"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'additionalPrice';
											_sortAscending = ascending;
											_filterSizes();
										});
									},
								),
								DataColumn(label: Text("تاريخ الإنشاء")),
								DataColumn(label: Text("الإجراءات")),
							],
							rows: _filteredSizes.map((sizeObj) {
								int stockQuantity = int.parse(sizeObj.stockQuantity);
								Color stockColor = stockQuantity == 0
										? Colors.red
										: stockQuantity < 10
										? Colors.orange
										: Colors.green;

								return DataRow(
									color: MaterialStateProperty.resolveWith<Color?>(
												(Set<MaterialState> states) {
											if (states.contains(MaterialState.hovered)) {
												return Colors.blue.shade50;
											}
											return null;
										},
									),
									cells: [
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.blue.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													sizeObj.id,
													style: TextStyle(fontWeight: FontWeight.bold),
												),
											),
										),
										DataCell(Text(sizeObj.productId)),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
												decoration: BoxDecoration(
													color: Colors.grey.shade200,
													borderRadius: BorderRadius.circular(20),
												),
												child: Text(
													sizeObj.size,
													style: TextStyle(fontWeight: FontWeight.w500),
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
													sizeObj.stockQuantity,
													style: TextStyle(
														color: stockColor,
														fontWeight: FontWeight.bold,
													),
												),
											),
										),
										DataCell(Text("${sizeObj.additionalPrice} ر.س")),
										DataCell(Text(sizeObj.createdAt)),
										DataCell(
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														decoration: BoxDecoration(
															color: Colors.blue.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.edit, size: 18, color: Colors.blue.shade600),
															tooltip: "تعديل",
															onPressed: () => _showAddEditDialog(sizeObj: sizeObj),
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
															onPressed: () => _showDeleteConfirmation(sizeObj),
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

	void _showDeleteConfirmation(ProductSize sizeObj) {
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
					content: Text("هل أنت متأكد من حذف المقاس '${sizeObj.size}' للمنتج ${sizeObj.productId}؟"),
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
								_deleteSize(sizeObj.id);
							},
						),
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_productIdController.dispose();
		_sizeController.dispose();
		_stockQuantityController.dispose();
		_additionalPriceController.dispose();
		_searchController.dispose();
		_productIdFilterController.dispose();
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
					"إدارة مقاسات المنتجات",
					style: TextStyle(fontWeight: FontWeight.bold),
				),
				backgroundColor: Colors.blue.shade600,
				foregroundColor: Colors.white,
				elevation: 0,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchSizes,
						tooltip: "تحديث",
					),
					IconButton(
						icon: Icon(Icons.info_outline),
						onPressed: () {
							showDialog(
								context: context,
								builder: (context) => AlertDialog(
									title: Text("معلومات التطبيق"),
									content: Text("تطبيق إدارة مقاسات المنتجات مع لوحة إحصائيات وطرق فلترة متقدمة"),
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
							valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
						),
						SizedBox(height: 16),
						Text("جاري التحميل...", style: TextStyle(color: Colors.grey.shade600)),
					],
				),
			)
					: _sizes.isEmpty
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
						SizedBox(height: 16),
						Text(
							"لا توجد مقاسات متاحة",
							style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
						),
						SizedBox(height: 8),
						Text(
							"اضغط على زر الإضافة لبدء إضافة المقاسات",
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
								"عرض ${_filteredSizes.length} من ${_sizes.length} مقاس",
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
				backgroundColor: Colors.blue.shade600,
				foregroundColor: Colors.white,
				icon: Icon(Icons.add),
				label: Text("إضافة مقاس"),
				tooltip: "إضافة مقاس جديد",
			),
		);
	}
}

