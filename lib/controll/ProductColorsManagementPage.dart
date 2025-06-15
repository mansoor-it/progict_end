import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import '../ApiConfig.dart';

// تعريف كلاس الألوان بناءً على جدول product_colors
class ProductColor {
	final String id;
	final String productId;
	final String colorName;
	final String colorCode;
	final String stockQuantity;
	final String? imageBase64;
	final String createdAt;

	ProductColor({
		required this.id,
		required this.productId,
		required this.colorName,
		required this.colorCode,
		required this.stockQuantity,
		this.imageBase64,
		required this.createdAt,
	});

	factory ProductColor.fromJson(Map<String, dynamic> json) {
		return ProductColor(
			id: json['id']?.toString() ?? '',
			productId: json['product_id']?.toString() ?? '',
			colorName: json['color_name'] ?? '',
			colorCode: json['color_code'] ?? '',
			stockQuantity: json['stock_quantity']?.toString() ?? '',
			imageBase64: json['image'] != null ? json['image'] as String : null,
			createdAt: json['created_at'] ?? '',
		);
	}
}

// كلاس للإحصائيات
class DashboardStats {
	final int totalColors;
	final int totalStock;
	final int uniqueProducts;
	final String mostCommonColor;
	final int lowStockItems;
	final int colorsWithImages;

	DashboardStats({
		required this.totalColors,
		required this.totalStock,
		required this.uniqueProducts,
		required this.mostCommonColor,
		required this.lowStockItems,
		required this.colorsWithImages,
	});
}

class ProductColorsManagementPage extends StatefulWidget {
	@override
	_ProductColorsManagementPageState createState() => _ProductColorsManagementPageState();
}

class _ProductColorsManagementPageState extends State<ProductColorsManagementPage>
		with TickerProviderStateMixin {
	List<ProductColor> _colors = [];
	List<ProductColor> _filteredColors = [];
	bool _isLoading = false;
	DashboardStats? _stats;

	// Controllers للنموذج
	final TextEditingController _productIdController = TextEditingController();
	final TextEditingController _colorNameController = TextEditingController();
	final TextEditingController _colorCodeController = TextEditingController();
	final TextEditingController _stockQuantityController = TextEditingController();
	String? _pickedImageBase64;

	// Controllers للفلترة والبحث
	final TextEditingController _searchController = TextEditingController();
	final TextEditingController _productIdFilterController = TextEditingController();
	String _selectedColorFilter = 'الكل';
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

	// رابط API الخاص بالألوان
	final String apiUrl = ApiHelper.url('product_colors_api.php');

	@override
	void initState() {
		super.initState();
		_initializeAnimations();
		_fetchColors();
		_searchController.addListener(_filterColors);
		_productIdFilterController.addListener(_filterColors);
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

	Future<void> _fetchColors() async {
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				setState(() {
					_colors = data.map((item) => ProductColor.fromJson(item)).toList();
					_filteredColors = List.from(_colors);
					_stats = _calculateStats();
					_isLoading = false;
				});
				_filterColors();
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
		if (_colors.isEmpty) {
			return DashboardStats(
				totalColors: 0,
				totalStock: 0,
				uniqueProducts: 0,
				mostCommonColor: 'غير متوفر',
				lowStockItems: 0,
				colorsWithImages: 0,
			);
		}

		int totalStock = _colors.fold(0, (sum, color) => sum + int.parse(color.stockQuantity));
		Set<String> uniqueProducts = _colors.map((color) => color.productId).toSet();

		// حساب اللون الأكثر شيوعاً
		Map<String, int> colorCount = {};
		for (var color in _colors) {
			colorCount[color.colorName] = (colorCount[color.colorName] ?? 0) + 1;
		}
		String mostCommonColor = colorCount.entries.isNotEmpty
				? colorCount.entries
				.reduce((a, b) => a.value > b.value ? a : b)
				.key
				: 'غير متوفر';

		// حساب العناصر منخفضة المخزون (أقل من 10)
		int lowStockItems = _colors.where((color) => int.parse(color.stockQuantity) < 10).length;

		// حساب الألوان التي تحتوي على صور
		int colorsWithImages = _colors.where((color) => color.imageBase64 != null && color.imageBase64!.isNotEmpty).length;

		return DashboardStats(
			totalColors: _colors.length,
			totalStock: totalStock,
			uniqueProducts: uniqueProducts.length,
			mostCommonColor: mostCommonColor,
			lowStockItems: lowStockItems,
			colorsWithImages: colorsWithImages,
		);
	}

	void _filterColors() {
		setState(() {
			_filteredColors = _colors.where((color) {
				bool matchesSearch = _searchController.text.isEmpty ||
						color.colorName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
						color.productId.contains(_searchController.text) ||
						color.colorCode.toLowerCase().contains(_searchController.text.toLowerCase());

				bool matchesProductId = _productIdFilterController.text.isEmpty ||
						color.productId.contains(_productIdFilterController.text);

				bool matchesColor = _selectedColorFilter == 'الكل' ||
						color.colorName == _selectedColorFilter;

				bool matchesStock = _selectedStockFilter == 'الكل' ||
						(_selectedStockFilter == 'متوفر' && int.parse(color.stockQuantity) > 0) ||
						(_selectedStockFilter == 'غير متوفر' && int.parse(color.stockQuantity) == 0) ||
						(_selectedStockFilter == 'مخزون منخفض' && int.parse(color.stockQuantity) < 10);

				bool matchesImage = _selectedImageFilter == 'الكل' ||
						(_selectedImageFilter == 'مع صورة' && color.imageBase64 != null && color.imageBase64!.isNotEmpty) ||
						(_selectedImageFilter == 'بدون صورة' && (color.imageBase64 == null || color.imageBase64!.isEmpty));

				return matchesSearch && matchesProductId && matchesColor && matchesStock && matchesImage;
			}).toList();

			_sortColors();
		});
	}

	void _sortColors() {
		_filteredColors.sort((a, b) {
			int comparison = 0;
			switch (_sortBy) {
				case 'id':
					comparison = int.parse(a.id).compareTo(int.parse(b.id));
					break;
				case 'productId':
					comparison = int.parse(a.productId).compareTo(int.parse(b.productId));
					break;
				case 'colorName':
					comparison = a.colorName.compareTo(b.colorName);
					break;
				case 'colorCode':
					comparison = a.colorCode.compareTo(b.colorCode);
					break;
				case 'stockQuantity':
					comparison = int.parse(a.stockQuantity).compareTo(int.parse(b.stockQuantity));
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

	Future<void> _addColor() async {
		final Map<String, String> data = {
			"action": "add",
			"product_id": _productIdController.text.trim(),
			"color_name": _colorNameController.text.trim(),
			"color_code": _colorCodeController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"image": _pickedImageBase64 ?? '',
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
				_showSnackBar("تم إضافة اللون بنجاح", Colors.green);
				_fetchColors();
			} else {
				_showSnackBar("فشل في إضافة اللون: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _updateColor(String id) async {
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"product_id": _productIdController.text.trim(),
			"color_name": _colorNameController.text.trim(),
			"color_code": _colorCodeController.text.trim(),
			"stock_quantity": _stockQuantityController.text.trim(),
			"image": _pickedImageBase64 ?? '',
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
				_showSnackBar("تم تحديث اللون بنجاح", Colors.green);
				_fetchColors();
			} else {
				_showSnackBar("فشل في تحديث اللون: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _deleteColor(String id) async {
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
				_showSnackBar("تم حذف اللون بنجاح", Colors.green);
				_fetchColors();
			} else {
				_showSnackBar("فشل في حذف اللون: ${responseBody['message']}", Colors.red);
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

	void _showAddEditDialog({ProductColor? colorObj}) {
		if (colorObj != null) {
			_productIdController.text = colorObj.productId;
			_colorNameController.text = colorObj.colorName;
			_colorCodeController.text = colorObj.colorCode;
			_stockQuantityController.text = colorObj.stockQuantity;
			_pickedImageBase64 = colorObj.imageBase64;
		} else {
			_productIdController.clear();
			_colorNameController.clear();
			_colorCodeController.clear();
			_stockQuantityController.clear();
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
								colors: [Colors.purple.shade600, Colors.purple.shade800],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(15),
						),
						child: Text(
							colorObj == null ? "إضافة لون جديد" : "تعديل اللون",
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
									_buildDialogTextField(_colorNameController, "اسم اللون", Icons.palette, TextInputType.text),
									SizedBox(height: 16),
									_buildDialogTextField(_colorCodeController, "كود اللون", Icons.color_lens, TextInputType.text),
									SizedBox(height: 16),
									_buildDialogTextField(_stockQuantityController, "كمية المخزون", Icons.storage, TextInputType.number),
									SizedBox(height: 16),
									Container(
										width: double.infinity,
										child: ElevatedButton.icon(
											onPressed: _pickImage,
											icon: Icon(Icons.image, color: Colors.purple.shade600),
											label: Text("اختيار صورة من المعرض"),
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.purple.shade50,
												foregroundColor: Colors.purple.shade600,
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
								if (colorObj == null) {
									_addColor();
								} else {
									_updateColor(colorObj.id);
								}
								Navigator.of(context).pop();
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.purple.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text(
								colorObj == null ? "إضافة" : "تحديث",
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
					prefixIcon: Icon(icon, color: Colors.purple.shade600),
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
							colors: [Colors.purple.shade50, Colors.purple.shade100],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
						borderRadius: BorderRadius.circular(20),
						boxShadow: [
							BoxShadow(
								color: Colors.purple.shade200.withOpacity(0.5),
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
										Icon(Icons.dashboard, color: Colors.purple.shade700, size: 28),
										SizedBox(width: 12),
										Text(
											"لوحة الإحصائيات",
											style: TextStyle(
												fontSize: 24,
												fontWeight: FontWeight.bold,
												color: Colors.purple.shade800,
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
										_buildStatCard("إجمالي الألوان", _stats!.totalColors.toString(), Icons.palette, Colors.green),
										_buildStatCard("إجمالي المخزون", _stats!.totalStock.toString(), Icons.storage, Colors.orange),
										_buildStatCard("المنتجات الفريدة", _stats!.uniqueProducts.toString(), Icons.inventory, Colors.blue),
										_buildStatCard("مخزون منخفض", _stats!.lowStockItems.toString(), Icons.warning, Colors.red),
										_buildStatCard("اللون الأكثر شيوعاً", _stats!.mostCommonColor, Icons.trending_up, Colors.purple),
										_buildStatCard("ألوان مع صور", _stats!.colorsWithImages.toString(), Icons.image, Colors.teal),
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
							Icon(Icons.filter_list, color: Colors.purple.shade600),
							SizedBox(width: 8),
							Text(
								"البحث والفلترة",
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.purple.shade800,
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
										hintText: "البحث في الألوان...",
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
									value: _selectedColorFilter,
									decoration: InputDecoration(
										labelText: "فلترة باللون",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', ...(_colors.map((c) => c.colorName).toSet().toList())]
											.map((color) => DropdownMenuItem(value: color, child: Text(color)))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedColorFilter = value!;
											_filterColors();
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
											_filterColors();
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
								_filterColors();
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
								DropdownMenuItem(value: 'productId', child: Text('معرف المنتج')),
								DropdownMenuItem(value: 'colorName', child: Text('اسم اللون')),
								DropdownMenuItem(value: 'colorCode', child: Text('كود اللون')),
								DropdownMenuItem(value: 'stockQuantity', child: Text('كمية المخزون')),
								DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإنشاء')),
							],
							onChanged: (value) {
								setState(() {
									_sortBy = value!;
									_filterColors();
								});
							},
						),
					),
					IconButton(
						icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
						onPressed: () {
							setState(() {
								_sortAscending = !_sortAscending;
								_filterColors();
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
							headingRowColor: MaterialStateProperty.all(Colors.purple.shade50),
							headingTextStyle: TextStyle(
								fontWeight: FontWeight.bold,
								color: Colors.purple.shade800,
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
											_filterColors();
										});
									},
								),
								DataColumn(
									label: Text("معرف المنتج"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'productId';
											_sortAscending = ascending;
											_filterColors();
										});
									},
								),
								DataColumn(
									label: Text("اسم اللون"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'colorName';
											_sortAscending = ascending;
											_filterColors();
										});
									},
								),
								DataColumn(
									label: Text("كود اللون"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'colorCode';
											_sortAscending = ascending;
											_filterColors();
										});
									},
								),
								DataColumn(
									label: Text("كمية المخزون"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'stockQuantity';
											_sortAscending = ascending;
											_filterColors();
										});
									},
								),
								DataColumn(label: Text("الصورة")),
								DataColumn(label: Text("تاريخ الإنشاء")),
								DataColumn(label: Text("الإجراءات")),
							],
							rows: _filteredColors.map((colorObj) {
								int stockQuantity = int.parse(colorObj.stockQuantity);
								Color stockColor = stockQuantity == 0
										? Colors.red
										: stockQuantity < 10
										? Colors.orange
										: Colors.green;

								Uint8List? imageBytes;
								if (colorObj.imageBase64 != null && colorObj.imageBase64!.isNotEmpty) {
									try {
										imageBytes = base64Decode(colorObj.imageBase64!);
									} catch (_) {}
								}

								// تحويل كود اللون إلى لون فعلي
								Color? actualColor;
								try {
									if (colorObj.colorCode.startsWith('#')) {
										actualColor = Color(int.parse(colorObj.colorCode.substring(1), radix: 16) + 0xFF000000);
									}
								} catch (_) {}

								return DataRow(
									color: MaterialStateProperty.resolveWith<Color?>(
												(Set<MaterialState> states) {
											if (states.contains(MaterialState.hovered)) {
												return Colors.purple.shade50;
											}
											return null;
										},
									),
									cells: [
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.purple.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													colorObj.id,
													style: TextStyle(fontWeight: FontWeight.bold),
												),
											),
										),
										DataCell(Text(colorObj.productId)),
										DataCell(
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													if (actualColor != null)
														Container(
															width: 20,
															height: 20,
															margin: EdgeInsets.only(right: 8),
															decoration: BoxDecoration(
																color: actualColor,
																borderRadius: BorderRadius.circular(10),
																border: Border.all(color: Colors.grey.shade300),
															),
														),
													Flexible(
														child: Container(
															padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
															decoration: BoxDecoration(
																color: Colors.grey.shade200,
																borderRadius: BorderRadius.circular(20),
															),
															child: Text(
																colorObj.colorName,
																style: TextStyle(fontWeight: FontWeight.w500),
															),
														),
													),
												],
											),
										),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.grey.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													colorObj.colorCode,
													style: TextStyle(
														fontFamily: 'monospace',
														fontWeight: FontWeight.w500,
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
													colorObj.stockQuantity,
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
														width: 50,
														height: 50,
														fit: BoxFit.cover,
													),
												),
											)
													: Container(
												width: 50,
												height: 50,
												decoration: BoxDecoration(
													color: Colors.grey.shade100,
													borderRadius: BorderRadius.circular(8),
													border: Border.all(color: Colors.grey.shade300),
												),
												child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
											),
										),
										DataCell(Text(colorObj.createdAt)),
										DataCell(
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														decoration: BoxDecoration(
															color: Colors.purple.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.edit, size: 18, color: Colors.purple.shade600),
															tooltip: "تعديل",
															onPressed: () => _showAddEditDialog(colorObj: colorObj),
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
															onPressed: () => _showDeleteConfirmation(colorObj),
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

	void _showDeleteConfirmation(ProductColor colorObj) {
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
					content: Text("هل أنت متأكد من حذف اللون '${colorObj.colorName}' للمنتج ${colorObj.productId}؟"),
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
								_deleteColor(colorObj.id);
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
		_colorNameController.dispose();
		_colorCodeController.dispose();
		_stockQuantityController.dispose();
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
					"إدارة ألوان المنتجات",
					style: TextStyle(fontWeight: FontWeight.bold),
				),
				backgroundColor: Colors.purple.shade600,
				foregroundColor: Colors.white,
				elevation: 0,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchColors,
						tooltip: "تحديث",
					),
					IconButton(
						icon: Icon(Icons.info_outline),
						onPressed: () {
							showDialog(
								context: context,
								builder: (context) => AlertDialog(
									title: Text("معلومات التطبيق"),
									content: Text("تطبيق إدارة ألوان المنتجات مع لوحة إحصائيات وطرق فلترة متقدمة"),
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
							valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
						),
						SizedBox(height: 16),
						Text("جاري التحميل...", style: TextStyle(color: Colors.grey.shade600)),
					],
				),
			)
					: _colors.isEmpty
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.palette_outlined, size: 80, color: Colors.grey.shade400),
						SizedBox(height: 16),
						Text(
							"لا توجد ألوان متاحة",
							style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
						),
						SizedBox(height: 8),
						Text(
							"اضغط على زر الإضافة لبدء إضافة الألوان",
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
								"عرض ${_filteredColors.length} من ${_colors.length} لون",
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
				backgroundColor: Colors.purple.shade600,
				foregroundColor: Colors.white,
				icon: Icon(Icons.add),
				label: Text("إضافة لون"),
				tooltip: "إضافة لون جديد",
			),
		);
	}
}

