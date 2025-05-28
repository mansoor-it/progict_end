import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/stor_model.dart';
import 'ProductDetailsPage.dart';

class StoreDetailsScreen extends StatelessWidget {
	final Store store;

	StoreDetailsScreen({required this.store});

	String cleanBase64(String base64Image) {
		final regex = RegExp(r'data:image/[^;]+;base64,');
		return base64Image.replaceAll(regex, '');
	}

	List<Widget> _buildStarRating(double rating) {
		List<Widget> stars = [];
		int fullStars = rating.floor();
		bool hasHalfStar = (rating - fullStars) >= 0.5;

		for (int i = 0; i < fullStars; i++) {
			stars.add(Icon(Icons.star, color: Color(0xFFFFC107), size: 30));
		}

		if (hasHalfStar) {
			stars.add(Icon(Icons.star_half, color: Color(0xFFFFC107), size: 30));
		}

		while (stars.length < 5) {
			stars.add(Icon(Icons.star_border, color: Color(0xFFFFC107), size: 30));
		}

		return stars;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [Color(0xFF2E0249), Color(0xFF0F3057)],
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
				),
				child: SafeArea(
					child: Column(
						children: [
							Container(
								padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
								width: double.infinity,
								decoration: BoxDecoration(
									color: Colors.white.withOpacity(0.1),
									borderRadius: BorderRadius.only(
										bottomLeft: Radius.circular(30),
										bottomRight: Radius.circular(30),
									),
									boxShadow: [
										BoxShadow(
											color: Colors.purpleAccent.withOpacity(0.3),
											blurRadius: 12,
											offset: Offset(0, 3),
										),
									],
								),
								child: Row(
									children: [
										BackButton(color: Color(0xFFFFC107)),
										Expanded(
											child: Text(
												store.name,
												textAlign: TextAlign.center,
												style: TextStyle(
													color: Color(0xFFFFC107),
													fontSize: 22,
													fontWeight: FontWeight.bold,
													letterSpacing: 1.2,
													shadows: [
														Shadow(
															blurRadius: 6,
															color: Colors.black45,
															offset: Offset(2, 2),
														)
													],
												),
											),
										),
										SizedBox(width: 48),
									],
								),
							),
							Expanded(
								child: SingleChildScrollView(
									padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											if (store.storeImage.isNotEmpty)
												Center(
													child: Container(
														width: 180,
														height: 180,
														decoration: BoxDecoration(
															shape: BoxShape.circle,
															boxShadow: [
																BoxShadow(
																	color: Colors.deepPurple.withOpacity(0.6),
																	blurRadius: 20,
																	offset: Offset(0, 8),
																)
															],
															image: DecorationImage(
																image: MemoryImage(
																	base64Decode(cleanBase64(store.storeImage)),
																),
																fit: BoxFit.cover,
															),
														),
													),
												),
											SizedBox(height: 30),

											Text(
												"وصف المتجر",
												style: TextStyle(
													color: Colors.white.withOpacity(0.95),
													fontSize: 22,
													fontWeight: FontWeight.bold,
													letterSpacing: 1.1,
													shadows: [
														Shadow(
															blurRadius: 5,
															color: Colors.black54,
															offset: Offset(1, 1),
														),
													],
												),
											),
											SizedBox(height: 12),
											Container(
												padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
												decoration: BoxDecoration(
													color: Colors.white24,
													borderRadius: BorderRadius.circular(20),
													boxShadow: [
														BoxShadow(
															color: Colors.deepPurple.withOpacity(0.3),
															blurRadius: 12,
															offset: Offset(0, 6),
														),
													],
												),
												child: Text(
													store.description,
													style: TextStyle(
														color: Colors.white.withOpacity(0.9),
														fontSize: 17,
														height: 1.6,
														shadows: [
															Shadow(
																blurRadius: 1,
																color: Colors.black26,
																offset: Offset(1, 1),
															),
														],
													),
												),
											),
											SizedBox(height: 30),

											Row(
												children: [
													Expanded(
														child: Container(
															padding: EdgeInsets.all(20),
															decoration: BoxDecoration(
																color: Colors.white.withOpacity(0.15),
																borderRadius: BorderRadius.circular(22),
																boxShadow: [
																	BoxShadow(
																		color: Colors.deepPurple.withOpacity(0.5),
																		blurRadius: 15,
																		offset: Offset(0, 7),
																	),
																],
															),
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: [
																	Text(
																		"العنوان",
																		style: TextStyle(
																			color: Colors.white70,
																			fontWeight: FontWeight.bold,
																			fontSize: 20,
																		),
																	),
																	SizedBox(height: 12),
																	Text(
																		store.address,
																		style: TextStyle(
																			color: Colors.white.withOpacity(0.95),
																			fontSize: 16,
																		),
																	),
																],
															),
														),
													),
													SizedBox(width: 24),
													Expanded(
														child: Container(
															padding: EdgeInsets.all(20),
															decoration: BoxDecoration(
																color: Colors.white.withOpacity(0.15),
																borderRadius: BorderRadius.circular(22),
																boxShadow: [
																	BoxShadow(
																		color: Colors.deepPurple.withOpacity(0.5),
																		blurRadius: 15,
																		offset: Offset(0, 7),
																	),
																],
															),
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.center,
																children: [
																	Text(
																		"التقييم",
																		style: TextStyle(
																			color: Colors.white70,
																			fontWeight: FontWeight.bold,
																			fontSize: 20,
																		),
																	),
																	SizedBox(height: 12),
																	store.rating != null
																			? Row(
																		mainAxisAlignment: MainAxisAlignment.center,
																		children: _buildStarRating(double.tryParse("${store.rating}") ?? 0.0),
																	)
																			: Text(
																		"غير متوفر",
																		style: TextStyle(
																			color: Colors.white70,
																			fontSize: 18,
																		),
																	),
																],
															),
														),
													),
												],
											),
											SizedBox(height: 45),

											Center(
												child: ElevatedButton.icon(
													onPressed: () {
														Navigator.push(
															context,
															MaterialPageRoute(
																builder: (context) => AllProductsPage(
																	storeId: store.id,
																	storeName: store.name,
																),
															),
														);
													},
													icon: Icon(Icons.storefront_outlined, size: 28, color: Color(0xFF4A2900)),
													label: Text(
														"عرض المنتجات",
														style: TextStyle(
															fontSize: 20,
															fontWeight: FontWeight.bold,
															color: Color(0xFF4A2900),
														),
													),
													style: ElevatedButton.styleFrom(
														padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18),
														backgroundColor: Color(0xFFFFC107),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(40),
														),
														elevation: 18,
														shadowColor: Colors.amberAccent.withOpacity(0.9),
														foregroundColor: Colors.brown.shade800,
													),
												),
											),
											SizedBox(height: 40),
										],
									),
								),
							),
						],
					),
				),
			),
		);
	}
}
