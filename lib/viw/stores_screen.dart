import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../ApiConfig.dart';
import '../model/stor_model.dart';
import 'store_details_screen.dart';

class StoresScreen extends StatefulWidget {
	final String categoryId;
	final String categoryName;

	StoresScreen({required this.categoryId, required this.categoryName});

	@override
	_StoresScreenState createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
	List<Store> stores = [];
	bool isLoading = false;
	bool hasError = false;
	final TextEditingController _searchController = TextEditingController();
	List<Store> filteredStores = [];
	final ScrollController _scrollController = ScrollController();
	double _scrollOffset = 0.0;

	@override
	void initState() {
		super.initState();
		_scrollController.addListener(_onScroll);
		fetchStores();
	}

	void _onScroll() {
		setState(() {
			_scrollOffset = _scrollController.offset;
		});
	}

	Future<void> fetchStores() async {
		setState(() {
			isLoading = true;
			hasError = false;
		});

		try {
			final response = await http.get(Uri.parse(
					"${ApiHelper.url('api.php')}?action=stores&category_id=${widget.categoryId}"));

			await Future.delayed(Duration(seconds: 1)); // لمحاكاة التحميل

			if (response.statusCode == 200) {
				final jsonResponse = json.decode(response.body);
				if (jsonResponse['success'] == true) {
					List data = jsonResponse['data'];
					setState(() {
						stores = data.map((item) => Store.fromJson(item)).toList();
						filteredStores = stores;
						isLoading = false;
					});
				} else {
					setState(() {
						isLoading = false;
						hasError = true;
					});
				}
			} else {
				setState(() {
					isLoading = false;
					hasError = true;
				});
			}
		} catch (e) {
			setState(() {
				isLoading = false;
				hasError = true;
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('حدث خطأ في تحميل المحلات'),
					behavior: SnackBarBehavior.floating,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(10),
					),
				),
			);
		}
	}

	void filterStores(String query) {
		setState(() {
			filteredStores = stores.where((store) {
				final name = store.name.toLowerCase();
				final description = store.description.toLowerCase();
				final searchLower = query.toLowerCase();
				return name.contains(searchLower) || description.contains(searchLower);
			}).toList();
		});
	}

	void navigateToStoreDetails(Store store) {
		Navigator.push(
			context,
			PageRouteBuilder(
				transitionDuration: Duration(milliseconds: 500),
				pageBuilder: (context, animation, secondaryAnimation) =>
						StoreDetailsScreen(store: store),
				transitionsBuilder: (context, animation, secondaryAnimation, child) {
					return FadeTransition(
						opacity: animation,
						child: child,
					);
				},
			),
		);
	}

	String cleanBase64(String base64Image) {
		final regex = RegExp(r'data:image/[^;]+;base64,');
		return base64Image.replaceAll(regex, '');
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final isDarkMode = theme.brightness == Brightness.dark;
		final screenHeight = MediaQuery.of(context).size.height;

		return Scaffold(
			backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF5F5F5),
			body: CustomScrollView(
				controller: _scrollController,
				slivers: [
					SliverAppBar(
						expandedHeight: screenHeight * 0.2,
						floating: false,
						pinned: true,
						flexibleSpace: FlexibleSpaceBar(
							title: Text(
								"محلات ${widget.categoryName}",
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.bold,
									shadows: [
										Shadow(
											color: Colors.black.withOpacity(0.5),
											blurRadius: 4,
											offset: Offset(1, 1),
										),
									],
								),
							),
							centerTitle: true,
							background: Stack(
								fit: StackFit.expand,
								children: [
									Image.asset(
										'assets/store_banner.jpg',
										fit: BoxFit.cover,
										color: Colors.black.withOpacity(0.3),
										colorBlendMode: BlendMode.darken,
									),
									Container(
										decoration: BoxDecoration(
											gradient: LinearGradient(
												begin: Alignment.bottomCenter,
												end: Alignment.topCenter,
												colors: [
													Colors.black.withOpacity(0.7),
													Colors.transparent,
												],
											),
										),
									),
								],
							),
						),
					),

					SliverToBoxAdapter(
						child: Padding(
							padding: const EdgeInsets.all(16.0),
							child: AnimatedContainer(
								duration: Duration(milliseconds: 300),
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(20),
									boxShadow: [
										BoxShadow(
											color: Colors.black.withOpacity(0.1),
											blurRadius: 10,
											offset: Offset(0, 5),
										),
									],
								),
								child: TextField(
									controller: _searchController,
									onChanged: filterStores,
									decoration: InputDecoration(
										hintText: '🔍 ابحث عن محل...',
										filled: true,
										fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(20),
											borderSide: BorderSide.none,
										),
										contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
										suffixIcon: _searchController.text.isNotEmpty
												? IconButton(
											icon: Icon(Icons.clear, color: Colors.grey),
											onPressed: () {
												_searchController.clear();
												filterStores('');
											},
										)
												: null,
									),
								),
							),
						),
					),

					_buildStoresList(isDarkMode, theme),
				],
			),
		);
	}

	Widget _buildStoresList(bool isDarkMode, ThemeData theme) {
		if (isLoading) {
			return SliverList(
				delegate: SliverChildBuilderDelegate(
							(context, index) => Padding(
						padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
						child: Shimmer.fromColors(
							baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
							highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
							child: Container(
								height: 120,
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(16),
								),
							),
						),
					),
					childCount: 6,
				),
			);
		}

		if (hasError) {
			return SliverFillRemaining(
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(Icons.error_outline, size: 60, color: Colors.red),
							SizedBox(height: 16),
							Text(
								'حدث خطأ في تحميل البيانات',
								style: TextStyle(fontSize: 18),
							),
							SizedBox(height: 16),
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: theme.primaryColor,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(20),
									),
									padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
								),
								onPressed: fetchStores,
								child: Text('إعادة المحاولة'),
							),
						],
					),
				),
			);
		}

		if (filteredStores.isEmpty) {
			return SliverFillRemaining(
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(Icons.store_mall_directory, size: 60, color: Colors.grey),
							SizedBox(height: 16),
							Text(
								_searchController.text.isEmpty
										? 'لا توجد محلات متاحة'
										: 'لا توجد نتائج بحث',
								style: TextStyle(fontSize: 18, color: Colors.grey),
							),
							if (_searchController.text.isNotEmpty)
								TextButton(
									onPressed: () {
										_searchController.clear();
										filterStores('');
									},
									child: Text('مسح البحث'),
								),
						],
					),
				),
			);
		}

		return SliverPadding(
			padding: EdgeInsets.symmetric(horizontal: 16),
			sliver: AnimationLimiter(
				child: SliverList(
					delegate: SliverChildBuilderDelegate(
								(context, index) {
							final store = filteredStores[index];
							return AnimationConfiguration.staggeredList(
								position: index,
								duration: Duration(milliseconds: 500),
								child: SlideAnimation(
									verticalOffset: 50.0,
									child: FadeInAnimation(
										child: _buildStoreCard(store, isDarkMode, theme),
									),
								),
							);
						},
						childCount: filteredStores.length,
					),
				),
			),
		);
	}

	Widget _buildStoreCard(Store store, bool isDarkMode, ThemeData theme) {
		return Padding(
			padding: EdgeInsets.only(bottom: 16),
			child: InkWell(
				borderRadius: BorderRadius.circular(20),
				onTap: () => navigateToStoreDetails(store),
				child: Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(20),
						color: isDarkMode ? Colors.grey[800] : Colors.white,
						boxShadow: [
							BoxShadow(
								color: Colors.black.withOpacity(0.1),
								blurRadius: 10,
								offset: Offset(0, 5),
							),
						],
					),
					child: Stack(
						children: [
							if (store.storeImage.isNotEmpty)
								Positioned.fill(
									child: ClipRRect(
										borderRadius: BorderRadius.circular(20),
										child: Opacity(
											opacity: 0.2,
											child: Image.memory(
												base64Decode(cleanBase64(store.storeImage)),
												fit: BoxFit.cover,
											),
										),
									),
								),
							Padding(
								padding: EdgeInsets.all(16),
								child: Row(
									children: [
										Hero(
											tag: 'store_image_${store.id}',
											child: Container(
												width: 80,
												height: 80,
												decoration: BoxDecoration(
													borderRadius: BorderRadius.circular(12),
													color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
													boxShadow: [
														BoxShadow(
															color: Colors.black.withOpacity(0.2),
															blurRadius: 6,
															offset: Offset(0, 3),
														),
													],
												),
												child: store.storeImage.isNotEmpty
														? ClipRRect(
													borderRadius: BorderRadius.circular(12),
													child: Image.memory(
														base64Decode(cleanBase64(store.storeImage)),
														fit: BoxFit.cover,
													),
												)
														: Center(
													child: Icon(
														Icons.store,
														size: 40,
														color: isDarkMode ? Colors.white : Colors.grey[600],
													),
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
														style: TextStyle(
															fontSize: 18,
															fontWeight: FontWeight.bold,
															color: isDarkMode ? Colors.white : Colors.black,
														),
														maxLines: 1,
														overflow: TextOverflow.ellipsis,
													),
													SizedBox(height: 8),
													Text(
														store.description,
														style: TextStyle(
															fontSize: 14,
															color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
														),
														maxLines: 2,
														overflow: TextOverflow.ellipsis,
													),
													SizedBox(height: 12),
													Row(
														children: [
															Icon(
																Icons.star,
																size: 16,
																color: Colors.amber,
															),
															SizedBox(width: 4),
															Text(
																'4.5', // يمكن استبدالها بتقييم حقيقي من البيانات
																style: TextStyle(
																	fontSize: 14,
																	color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
																),
															),
															Spacer(),
															Text(
																'عرض التفاصيل',
																style: TextStyle(
																	fontSize: 14,
																	color: theme.primaryColor,
																	fontWeight: FontWeight.bold,
																),
															),
															Icon(
																Icons.arrow_back_ios_new,
																size: 14,
																color: theme.primaryColor,
															),
														],
													),
												],
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