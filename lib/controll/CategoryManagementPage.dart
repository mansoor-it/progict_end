import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/category_model.dart';
import '../service/category_service.dart';

// Dashboard Card Widget
class DashboardCard extends StatelessWidget {
	final String title;
	final String value;
	final IconData icon;
	final Color color;

	const DashboardCard({
		Key? key,
		required this.title,
		required this.value,
		required this.icon,
		required this.color,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Card(
			color: color,
			elevation: 8,
			shadowColor: color.withOpacity(0.3),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(16),
					gradient: LinearGradient(
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
						colors: [
							color,
							color.withOpacity(0.8),
						],
					),
				),
				padding: const EdgeInsets.all(20.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Container(
							padding: EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: Colors.white.withOpacity(0.2),
								borderRadius: BorderRadius.circular(12),
							),
							child: Icon(icon, size: 32, color: Colors.white),
						),
						SizedBox(height: 16),
						Text(
							title,
							style: TextStyle(
								color: Colors.white,
								fontSize: 14,
								fontWeight: FontWeight.w600,
							),
						),
						SizedBox(height: 8),
						Text(
							value,
							style: TextStyle(
								color: Colors.white,
								fontSize: 28,
								fontWeight: FontWeight.bold,
							),
						),
					],
				),
			),
		);
	}
}

// Categories Dashboard Widget
class CategoriesDashboard extends StatelessWidget {
	final int totalCategories;
	final int categoriesWithImages;
	final int categoriesWithoutImages;

	const CategoriesDashboard({
		Key? key,
		required this.totalCategories,
		required this.categoriesWithImages,
		required this.categoriesWithoutImages,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			height: 200,
			child: Scrollbar(
				thumbVisibility: true,
				child: SingleChildScrollView(
					scrollDirection: Axis.horizontal,
					child: Row(
						children: [
							SizedBox(
								width: 200,
								child: DashboardCard(
									title: 'إجمالي الأقسام',
									value: totalCategories.toString(),
									icon: Icons.category,
									color: Colors.blueAccent,
								),
							),
							SizedBox(width: 16),
							SizedBox(
								width: 200,
								child: DashboardCard(
									title: 'أقسام بالصور',
									value: categoriesWithImages.toString(),
									icon: Icons.image,
									color: Colors.green,
								),
							),
							SizedBox(width: 16),
							SizedBox(
								width: 200,
								child: DashboardCard(
									title: 'أقسام بدون صور',
									value: categoriesWithoutImages.toString(),
									icon: Icons.image_not_supported,
									color: Colors.orange,
								),
							),
							SizedBox(width: 16),
							SizedBox(
								width: 200,
								child: DashboardCard(
									title: 'نسبة الأقسام بالصور',
									value: totalCategories > 0
											? '${((categoriesWithImages / totalCategories) * 100).toStringAsFixed(1)}%'
											: '0%',
									icon: Icons.pie_chart,
									color: Colors.purple,
								),
							),
						],
					),
				),
			),
		);
	}
}

// Main Categories Management Screen
class CategoriesManagementScreen extends StatefulWidget {
	@override
	_CategoriesManagementScreenState createState() =>
			_CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
		extends State<CategoriesManagementScreen> with TickerProviderStateMixin {
	List<Category> categories = [];
	List<Category> filteredCategories = [];
	bool isLoading = false;
	final CategoryController _controller = CategoryController();
	final ImagePicker _picker = ImagePicker();
	String base64Image = '';

	TextEditingController searchController = TextEditingController();
	String selectedFilter = 'الكل';

	late AnimationController _fadeController;
	late AnimationController _slideController;
	late Animation<double> _fadeAnimation;
	late Animation<Offset> _slideAnimation;

	@override
	void initState() {
		super.initState();
		_fadeController =
				AnimationController(duration: Duration(milliseconds: 800), vsync: this);
		_slideController =
				AnimationController(duration: Duration(milliseconds: 600), vsync: this);

		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
		);
		_slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
			CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
		);

		fetchCategories();
		searchController.addListener(_filterCategories);

		_fadeController.forward();
		_slideController.forward();
	}

	@override
	void dispose() {
		searchController.dispose();
		_fadeController.dispose();
		_slideController.dispose();
		super.dispose();
	}

	Future<void> fetchCategories() async {
		setState(() => isLoading = true);
		final fetched = await _controller.fetchCategories();
		setState(() {
			categories = fetched;
			filteredCategories = fetched;
			isLoading = false;
		});
	}

	void _filterCategories() {
		final query = searchController.text.toLowerCase();
		setState(() {
			filteredCategories = categories.where((cat) {
				final matchesSearch = cat.name.toLowerCase().contains(query) ||
						cat.description.toLowerCase().contains(query);
				bool matchesFilter = true;
				if (selectedFilter == 'بصور') matchesFilter = cat.image.isNotEmpty;
				if (selectedFilter == 'بدون صور') matchesFilter = cat.image.isEmpty;
				return matchesSearch && matchesFilter;
			}).toList();
		});
	}

	Future<void> showDeleteDialog(String categoryId) async {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				shape:
				RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				title: Row(
					children: [
						Icon(Icons.warning, color: Colors.red),
						SizedBox(width: 8),
						Text("حذف القسم"),
					],
				),
				content: Text("هل أنت متأكد من أنك تريد حذف هذا القسم؟"),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: Text("إلغاء", style: TextStyle(color: Colors.grey)),
					),
					ElevatedButton(
						style: ElevatedButton.styleFrom(
								backgroundColor: Colors.red,
								shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(8))),
						onPressed: () async {
							Navigator.pop(context);
							await _controller.deleteCategory(categoryId);
							fetchCategories();
						},
						child: Text("حذف", style: TextStyle(color: Colors.white)),
					),
				],
			),
		);
	}

	Future<void> pickImage() async {
		final file = await _picker.pickImage(source: ImageSource.gallery);
		if (file != null) {
			final bytes = await file.readAsBytes();
			setState(() => base64Image = base64Encode(bytes));
		}
	}

	Future<void> showCategoryDialog({Category? category}) async {
		final nameCtl = TextEditingController(text: category?.name ?? '');
		final descCtl = TextEditingController(text: category?.description ?? '');
		final img = category?.image ?? '';

		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				shape:
				RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				title: Row(
					children: [
						Icon(category == null ? Icons.add : Icons.edit,
								color: Colors.teal),
						SizedBox(width: 8),
						Text(category == null ? "إضافة قسم" : "تعديل قسم"),
					],
				),
				content: SingleChildScrollView(
					child: Column(mainAxisSize: MainAxisSize.min, children: [
						TextField(
							controller: nameCtl,
							decoration: InputDecoration(
								labelText: "اسم القسم",
								border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8)),
								prefixIcon: Icon(Icons.title),
							),
						),
						SizedBox(height: 16),
						TextField(
							controller: descCtl,
							maxLines: 3,
							decoration: InputDecoration(
								labelText: "وصف القسم",
								border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(8)),
								prefixIcon: Icon(Icons.description),
							),
						),
						SizedBox(height: 16),
						ElevatedButton.icon(
							onPressed: pickImage,
							icon: Icon(Icons.image),
							label: Text("اختيار صورة من المعرض"),
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.teal,
								shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(8)),
							),
						),
						SizedBox(height: 16),
						Container(
							height: 120,
							width: 120,
							decoration: BoxDecoration(
								border: Border.all(color: Colors.grey.shade300),
								borderRadius: BorderRadius.circular(8),
							),
							child: (img.isNotEmpty || base64Image.isNotEmpty)
									? ClipRRect(
								borderRadius: BorderRadius.circular(8),
								child: Image.memory(
									base64Decode(
											base64Image.isNotEmpty ? base64Image : img),
									width: 120,
									height: 120,
									fit: BoxFit.cover,
								),
							)
									: Icon(Icons.image, size: 60, color: Colors.grey),
						),
					]),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: Text("إلغاء", style: TextStyle(color: Colors.grey)),
					),
					ElevatedButton(
						style: ElevatedButton.styleFrom(
								backgroundColor: Colors.teal,
								shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(8))),
						onPressed: () async {
							final finalImg = base64Image.isNotEmpty ? base64Image : img;
							if (category == null) {
								final newCat = Category(
									id: DateTime.now().millisecondsSinceEpoch.toString(),
									name: nameCtl.text,
									description: descCtl.text,
									image: finalImg,
									createdAt: DateTime.now().toString(),
									updatedAt: DateTime.now().toString(),
								);
								await _controller.addCategory(newCat);
							} else {
								final updated = category.copyWith(
									name: nameCtl.text,
									description: descCtl.text,
									image: finalImg,
									updatedAt: DateTime.now().toString(),
								);
								await _controller.updateCategory(updated);
							}
							Navigator.pop(context);
							fetchCategories();
						},
						child: Text(category == null ? "إضافة" : "تعديل",
								style: TextStyle(color: Colors.white)),
					),
				],
			),
		);
	}

	Widget buildSearchAndFilter() {
		return Card(
			elevation: 8,
			shadowColor: Colors.teal.withOpacity(0.2),
			margin: EdgeInsets.only(bottom: 20),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(16),
					gradient: LinearGradient(
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
						colors: [Colors.white, Colors.teal.withOpacity(0.05)],
					),
				),
				padding: EdgeInsets.all(20),
				child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
					Text('البحث والتصفية',
							style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.teal.shade700)),
					SizedBox(height: 16),
					TextField(
						controller: searchController,
						decoration: InputDecoration(
							labelText: 'البحث في الأقسام',
							hintText: 'ابحث بالاسم أو الوصف...',
							prefixIcon: Icon(Icons.search, color: Colors.teal),
							border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(12),
									borderSide: BorderSide(color: Colors.teal.shade200)),
							focusedBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(12),
									borderSide: BorderSide(color: Colors.teal, width: 2)),
							suffixIcon: searchController.text.isNotEmpty
									? IconButton(
								icon: Icon(Icons.clear, color: Colors.grey),
								onPressed: () {
									searchController.clear();
									_filterCategories();
								},
							)
									: null,
						),
					),
					SizedBox(height: 16),
					Row(children: [
						Icon(Icons.filter_list, color: Colors.teal),
						SizedBox(width: 8),
						Text('تصفية حسب: ',
								style: TextStyle(
										fontWeight: FontWeight.w600,
										color: Colors.teal.shade700)),
						SizedBox(width: 12),
						Expanded(
							child: Container(
								padding: EdgeInsets.symmetric(horizontal: 12),
								decoration: BoxDecoration(
										border: Border.all(color: Colors.teal.shade200),
										borderRadius: BorderRadius.circular(8)),
								child: DropdownButton<String>(
									value: selectedFilter,
									isExpanded: true,
									underline: SizedBox(),
									items: ['الكل', 'بصور', 'بدون صور']
											.map((v) => DropdownMenuItem(value: v, child: Text(v)))
											.toList(),
									onChanged: (v) {
										setState(() {
											selectedFilter = v!;
											_filterCategories();
										});
									},
								),
							),
						),
					]),
					SizedBox(height: 12),
					Text(
						'عدد النتائج: ${filteredCategories.length} من أصل ${categories.length}',
						style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
					),
				]),
			),
		);
	}

	Widget buildTable() {
		return Card(
			elevation: 8,
			shadowColor: Colors.grey.withOpacity(0.2),
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
				Padding(
					padding: EdgeInsets.all(20),
					child: Row(children: [
						Icon(Icons.table_chart, color: Colors.teal),
						SizedBox(width: 8),
						Text('جدول الأقسام',
								style: TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.bold,
										color: Colors.teal.shade700)),
					]),
				),
				Container(
					height: 400,
					child: Scrollbar(
						thumbVisibility: true,
						thickness: 8,
						radius: Radius.circular(4),
						child: SingleChildScrollView(
							scrollDirection: Axis.horizontal,
							child: Scrollbar(
								thumbVisibility: true,
								thickness: 8,
								radius: Radius.circular(4),
								child: SingleChildScrollView(
									scrollDirection: Axis.vertical,
									child: DataTable(
										columnSpacing: 24,
										headingRowColor:
										MaterialStateProperty.all(Colors.teal.shade50),
										headingTextStyle:
										TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700),
										columns: [
											DataColumn(label: Text('رقم')),
											DataColumn(label: Text('الاسم')),
											DataColumn(label: Text('الوصف')),
											DataColumn(label: Text('الصورة')),
											DataColumn(label: Text('تاريخ الإنشاء')),
											DataColumn(label: Text('آخر تعديل')),
											DataColumn(label: Text('الخيارات')),
										],
										rows: filteredCategories.asMap().entries.map((e) {
											final i = e.key;
											final cat = e.value;
											return DataRow(
												color: MaterialStateProperty.resolveWith((_) => i % 2 == 0 ? Colors.grey.shade50 : null),
												cells: [
													DataCell(Container(
														padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
														decoration: BoxDecoration(
																color: Colors.teal.shade100,
																borderRadius: BorderRadius.circular(4)),
														child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
													)),
													DataCell(Text(cat.name, style: TextStyle(fontWeight: FontWeight.w600))),
													DataCell(Container(
														width: 200,
														child: Text(cat.description,
																overflow: TextOverflow.ellipsis, maxLines: 2),
													)),
													DataCell(Container(
														width: 60,
														height: 60,
														decoration: BoxDecoration(
																borderRadius: BorderRadius.circular(8),
																border: Border.all(color: Colors.grey.shade300)),
														child: cat.image.isNotEmpty
																? ClipRRect(
															borderRadius: BorderRadius.circular(8),
															child: Image.memory(base64Decode(cat.image),
																	width: 60, height: 60, fit: BoxFit.cover),
														)
																: Icon(Icons.image, color: Colors.grey),
													)),
													DataCell(Text(cat.createdAt?.substring(0, 10) ?? '-', style: TextStyle(fontSize: 12))),
													DataCell(Text(cat.updatedAt?.substring(0, 10) ?? '-', style: TextStyle(fontSize: 12))),
													DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
														IconButton(
															icon: Icon(Icons.edit, color: Colors.blue),
															onPressed: () => showCategoryDialog(category: cat),
															tooltip: 'تعديل',
														),
														IconButton(
															icon: Icon(Icons.delete, color: Colors.red),
															onPressed: () => showDeleteDialog(cat.id),
															tooltip: 'حذف',
														),
													])),
												],
											);
										}).toList(),
									),
								),
							),
						),
					),
				),
			]),
		);
	}

	@override
	Widget build(BuildContext context) {
		final total = categories.length;
		final withImg = categories.where((c) => c.image.isNotEmpty).length;
		final withoutImg = total - withImg;

		return Scaffold(
			backgroundColor: Colors.grey[50],
			appBar: AppBar(
				title:
				Text("إدارة الأقسام", style: TextStyle(fontWeight: FontWeight.bold)),
				backgroundColor: Colors.teal,
				elevation: 0,
				flexibleSpace: Container(
					decoration: BoxDecoration(
						gradient: LinearGradient(
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
							colors: [Colors.teal, Colors.teal.shade700],
						),
					),
				),
				actions: [
					Container(
						margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
						child: ElevatedButton.icon(
							onPressed: () => showCategoryDialog(),
							icon: Icon(Icons.add, color: Colors.teal),
							label: Text('إضافة قسم',
									style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.white,
								shape:
								RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
								elevation: 4,
							),
						),
					),
				],
			),
			body: isLoading
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						CircularProgressIndicator(color: Colors.teal),
						SizedBox(height: 16),
						Text('جاري تحميل البيانات...',
								style: TextStyle(color: Colors.teal.shade700)),
					],
				),
			)
					: FadeTransition(
				opacity: _fadeAnimation,
				child: SlideTransition(
					position: _slideAnimation,
					child: Scrollbar(
						thumbVisibility: true,
						thickness: 12,
						radius: Radius.circular(6),
						child: SingleChildScrollView(
							padding: const EdgeInsets.all(16.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('لوحة الإحصائيات',
											style: TextStyle(
													fontSize: 24,
													fontWeight: FontWeight.bold,
													color: Colors.teal.shade700)),
									SizedBox(height: 16),
									CategoriesDashboard(
										totalCategories: total,
										categoriesWithImages: withImg,
										categoriesWithoutImages: withoutImg,
									),
									SizedBox(height: 32),
									buildSearchAndFilter(),
									buildTable(),
								],
							),
						),
					),
				),
			),
		);
	}
}
