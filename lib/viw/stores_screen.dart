import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../ApiConfig.dart';
import '../model/stor_model.dart';
import '../model/user_model.dart'; // <-- إضافة استيراد لنموذج المستخدم
import 'store_details_screen.dart';

class StoresScreen extends StatefulWidget {
	final String categoryId;
	final String categoryName;
	final User user; // <-- إضافة متغير لاستقبال المستخدم

	StoresScreen({required this.categoryId, required this.categoryName, required this.user}); // <-- تعديل المنشئ

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
	Timer? _debounce;

	int gridColumnCount = 3;
	double gridChildAspectRatio = 0.8;
	double gridSpacing = 12.0;

	@override
	void initState() {
		super.initState();
		_scrollController.addListener(_onScroll);
		fetchStores();
	}

	@override
	void dispose() {
		_scrollController.removeListener(_onScroll);
		_scrollController.dispose();
		_searchController.dispose();
		_debounce?.cancel();
		super.dispose();
	}

	void _onScroll() {
		if (mounted) {
			setState(() {
				_scrollOffset = _scrollController.offset;
			});
		}
	}

	Future<void> fetchStores() async {
		if (!mounted) return;
		setState(() {
			isLoading = true;
			hasError = false;
		});

		try {
			final response = await http.get(Uri.parse(
					"${ApiHelper.url('api.php')}?action=stores&category_id=${widget.categoryId}"));

			// Simulate network delay for testing shimmer effect
			// await Future.delayed(Duration(seconds: 1));

			if (!mounted) return;

			if (response.statusCode == 200) {
				final jsonResponse = json.decode(response.body);
				if (jsonResponse['success'] == true) {
					List data = jsonResponse['data'] ?? [];
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
			if (!mounted) return;
			setState(() {
				isLoading = false;
				hasError = true;
			});
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('حدث خطأ في تحميل المحلات: ${e.toString()}'),
					behavior: SnackBarBehavior.floating,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(10),
					),
				),
			);
		}
	}

	void filterStores(String query) {
		if (_debounce?.isActive ?? false) _debounce!.cancel();
		_debounce = Timer(const Duration(milliseconds: 300), () {
			if (!mounted) return;
			setState(() {
				filteredStores = stores.where((store) {
					final name = store.name.toLowerCase();
					final description = store.description.toLowerCase();
					final searchLower = query.toLowerCase();
					return name.contains(searchLower) || description.contains(searchLower);
				}).toList();
			});
		});
	}

	void navigateToStoreDetails(Store store) {
		Navigator.push(
			context,
			PageRouteBuilder(
				// <-- تمرير المستخدم هنا
				pageBuilder: (context, animation, secondaryAnimation) => StoreDetailsScreen(store: store, user: widget.user),
				transitionsBuilder: (context, animation, secondaryAnimation, child) {
					const begin = Offset(1.0, 0.0);
					const end = Offset.zero;
					const curve = Curves.easeInOut;

					var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
					var offsetAnimation = animation.drive(tween);

					return SlideTransition(
						position: offsetAnimation,
						child: child,
					);
				},
			),
		);
	}

	String cleanBase64(String base64Image) {
		final regex = RegExp(r'^data:image/[^;]+;base64,');
		return base64Image.replaceAll(regex, '');
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final isDarkMode = theme.brightness == Brightness.dark;
		final screenHeight = MediaQuery.of(context).size.height;
		final screenWidth = MediaQuery.of(context).size.width;

		// Adjust grid based on screen width
		if (screenWidth > 1200) {
			gridColumnCount = 5;
			gridChildAspectRatio = 0.9;
		} else if (screenWidth > 800) {
			gridColumnCount = 4;
			gridChildAspectRatio = 0.85;
		} else if (screenWidth > 600) {
			gridColumnCount = 3;
			gridChildAspectRatio = 0.8;
		} else {
			gridColumnCount = 2;
			gridChildAspectRatio = 0.75;
		}

		return Scaffold(
			backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF5F5F5),
			body: RefreshIndicator(
				onRefresh: fetchStores,
				color: theme.primaryColor,
				child: CustomScrollView(
					controller: _scrollController,
					slivers: [
						SliverAppBar(
							expandedHeight: screenHeight * 0.2,
							floating: false,
							pinned: true,
							backgroundColor: theme.primaryColor,
							flexibleSpace: FlexibleSpaceBar(
								title: Text(
									"محلات ${widget.categoryName}",
									style: TextStyle(
										fontSize: 20,
										fontWeight: FontWeight.bold,
										color: Colors.white,
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
											'assets/store_banner.jpg', // تأكد من وجود هذا الملف
											fit: BoxFit.cover,
											errorBuilder: (context, error, stackTrace) => Container(color: theme.primaryColorDark), // Fallback color
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
														stops: [0.0, 0.5] // Adjust gradient stop
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
								child: Column(
									children: [
										// SizedBox(height: 16), // Removed extra space
										// Row for layout buttons (optional)
										/*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              gridColumnCount = 3; // عرض شبكي
                            });
                          },
                          child: Text('عرض شبكي'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              gridColumnCount = 1; // عرض قائمة
                            });
                          },
                          child: Text('عرض قائمة'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    */
										AnimatedContainer(
											duration: Duration(milliseconds: 300),
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
											child: TextField(
												controller: _searchController,
												onChanged: filterStores,
												decoration: InputDecoration(
													hintText: '🔍 ابحث عن محل...',
													filled: true,
													fillColor: Colors.transparent, // Use container color
													border: OutlineInputBorder(
														borderRadius: BorderRadius.circular(20),
														borderSide: BorderSide.none,
													),
													contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Adjusted padding
													suffixIcon: _searchController.text.isNotEmpty
															? IconButton(
														icon: Icon(Icons.clear, color: Colors.grey),
														onPressed: () {
															_searchController.clear();
															filterStores('');
														},
													)
															: null,
													prefixIcon: Icon(Icons.search, color: Colors.grey), // Added search icon
												),
											),
										),
									],
								),
							),
						),
						_buildStoresGrid(isDarkMode, theme),
					],
				),
			),
		);
	}

	Widget _buildStoresGrid(bool isDarkMode, ThemeData theme) {
		if (isLoading) {
			return SliverPadding(
				padding: EdgeInsets.all(16),
				sliver: SliverGrid(
					gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: gridColumnCount,
						crossAxisSpacing: gridSpacing,
						mainAxisSpacing: gridSpacing,
						childAspectRatio: gridChildAspectRatio,
					),
					delegate: SliverChildBuilderDelegate(
								(context, index) => Shimmer.fromColors(
							baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
							highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
							child: Container(
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(16),
								),
							),
						),
						childCount: 6, // Show a few shimmer items
					),
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
							Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey),
							SizedBox(height: 16),
							Text(
								_searchController.text.isEmpty
										? 'لا توجد محلات متاحة في هذا القسم'
										: 'لا توجد نتائج مطابقة لبحثك',
								style: TextStyle(fontSize: 18, color: Colors.grey),
								textAlign: TextAlign.center,
							),
							if (_searchController.text.isNotEmpty)
								Padding(
									padding: const EdgeInsets.only(top: 8.0),
									child: TextButton(
										onPressed: () {
											_searchController.clear();
											filterStores('');
										},
										child: Text('مسح البحث وعرض الكل'),
									),
								),
						],
					),
				),
			);
		}

		return SliverPadding(
			padding: EdgeInsets.all(16),
			sliver: AnimationLimiter(
				child: SliverGrid(
					gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
						crossAxisCount: gridColumnCount,
						crossAxisSpacing: gridSpacing,
						mainAxisSpacing: gridSpacing,
						childAspectRatio: gridChildAspectRatio,
					),
					delegate: SliverChildBuilderDelegate(
								(context, index) {
							final store = filteredStores[index];
							return AnimationConfiguration.staggeredGrid(
								position: index,
								duration: Duration(milliseconds: 500),
								columnCount: gridColumnCount,
								child: ScaleAnimation(
									duration: Duration(milliseconds: 600),
									curve: Curves.easeOutExpo,
									child: FadeInAnimation(
										duration: Duration(milliseconds: 600),
										curve: Curves.easeOutExpo,
										child: _buildStoreGridItem(store, isDarkMode, theme),
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

	Widget _buildStoreGridItem(Store store, bool isDarkMode, ThemeData theme) {
		return InkWell(
			borderRadius: BorderRadius.circular(16),
			onTap: () => navigateToStoreDetails(store),
			child: Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(16),
					color: isDarkMode ? Colors.grey[850] : Colors.white,
					boxShadow: [
						BoxShadow(
							color: Colors.black.withOpacity(0.08),
							blurRadius: 10,
							offset: Offset(0, 4),
						),
					],
				),
				clipBehavior: Clip.antiAlias, // Clip content to rounded corners
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							flex: 3,
							child: Hero(
								tag: 'store_image_${store.id}', // Unique tag for Hero animation
								child: store.storeImage.isNotEmpty
										? Image.memory(
									base64Decode(cleanBase64(store.storeImage)),
									fit: BoxFit.cover,
									errorBuilder: (context, error, stackTrace) =>
											_buildPlaceholderIcon(isDarkMode),
								)
										: _buildPlaceholderIcon(isDarkMode),
							),
						),
						Padding(
							padding: EdgeInsets.all(10),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.center,
								children: [
									Text(
										store.name,
										textAlign: TextAlign.center,
										style: TextStyle(
											fontSize: 15,
											fontWeight: FontWeight.bold,
											color: isDarkMode ? Colors.white : Colors.black87,
										),
										maxLines: 1, // Ensure name fits
										overflow: TextOverflow.ellipsis,
									),
									SizedBox(height: 4),
									// Optional: Add rating stars here if needed
									/*
                  if (store.rating != null && double.tryParse(store.rating) != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildStarRating(double.parse(store.rating)),
                    )
                  */
								],
							),
						),
					],
				),
			),
		);
	}

	Widget _buildPlaceholderIcon(bool isDarkMode) {
		return Container(
			color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
			child: Center(
				child: Icon(
					Icons.storefront_outlined,
					size: 40,
					color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
				),
			),
		);
	}

	// Helper for star rating (if needed in grid item)
	List<Widget> _buildStarRating(double rating) {
		List<Widget> stars = [];
		int fullStars = rating.floor();
		bool hasHalfStar = (rating - fullStars) >= 0.5;

		for (int i = 0; i < 5; i++) {
			if (i < fullStars) {
				stars.add(Icon(Icons.star, color: Colors.amber, size: 16));
			} else if (i == fullStars && hasHalfStar) {
				stars.add(Icon(Icons.star_half, color: Colors.amber, size: 16));
			} else {
				stars.add(Icon(Icons.star_border, color: Colors.amber, size: 16));
			}
		}
		return stars;
	}
}

