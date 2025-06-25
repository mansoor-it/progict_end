import 'dart:convert';
import 'dart:ui';  // لـ BackdropFilter
import 'package:flutter/material.dart';
import '../model/stor_model.dart';
import 'ProductDetailsPage.dart';
import '../model/user_model.dart';
import 'AllProductsPage.dart';

class StoreDetailsScreen extends StatelessWidget {
	final Store store;
	final User user;

	const StoreDetailsScreen({
		Key? key,
		required this.store,
		required this.user,
	}) : super(key: key);

	String _cleanBase64(String base64Image) {
		final regex = RegExp(r'^data:image/[^;]+;base64,');
		return base64Image.replaceAll(regex, '');
	}

	List<Widget> _buildStarRating(double rating) {
		final stars = <Widget>[];
		final full = rating.floor();
		final half = (rating - full) >= 0.5;
		for (var i = 0; i < full; i++) stars.add(const Icon(Icons.star, size: 26));
		if (half) stars.add(const Icon(Icons.star_half, size: 26));
		while (stars.length < 5) stars.add(const Icon(Icons.star_border, size: 26));
		return stars;
	}

	@override
	Widget build(BuildContext context) {
		// ألوان موحدة وخلفية بيضاء
		const backgroundColor = Colors.white;
		const cardBg        = Colors.white;
		const iconCol       = Color(0xFF1E88E5);   // لون الأيقونات وزر المنتجات
		const headerBg      = Color(0xFFBBDEFB);   // نفس لون الزر لكن فاتح أكثر
		const titleCol      = Color(0xFF004D40);
		const textCol       = Color(0xFF263238);
		const shadowCol     = Color(0x1A000000);
		const radius        = 20.0;

		return Scaffold(
			backgroundColor: backgroundColor,
			body: SafeArea(
				child: Column(
					children: [
						// شريط الأدوات
						Container(
							color: headerBg,
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
							child: Row(
								children: [
									IconButton(
										icon: const Icon(Icons.arrow_back, size: 28),
										color: iconCol,
										onPressed: () => Navigator.pop(context),
									),
									const Spacer(),
									Text(
										'تفاصيل المتجر',
										style: TextStyle(color: titleCol, fontSize: 20, fontWeight: FontWeight.bold),
									),
									const Spacer(),
									IconButton(
										icon: const Icon(Icons.close, size: 28),
										color: iconCol,
										onPressed: () => Navigator.pop(context),
									),
								],
							),
						),

						// صورة المتجر مع طمس خفيف
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 16),
							child: Stack(
								alignment: Alignment.center,
								children: [
									ClipRect(
										child: BackdropFilter(
											filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
											child: Container(
												height: 200,
												width: double.infinity,
												decoration: store.storeImage.isNotEmpty
														? BoxDecoration(
													image: DecorationImage(
														image: MemoryImage(base64Decode(_cleanBase64(store.storeImage))),
														fit: BoxFit.cover,
													),
												)
														: const BoxDecoration(color: Colors.grey),
												foregroundDecoration: BoxDecoration(
													color: Colors.black.withOpacity(0.1),
												),
											),
										),
									),
									CircleAvatar(
										radius: 80,
										backgroundColor: Colors.white,
										child: CircleAvatar(
											radius: 76,
											backgroundImage: store.storeImage.isNotEmpty
													? MemoryImage(base64Decode(_cleanBase64(store.storeImage)))
													: null,
											child: store.storeImage.isEmpty
													? const Icon(Icons.store, size: 60, color: Colors.grey)
													: null,
										),
									),
								],
							),
						),

						// اسم المتجر
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
							child: Text(
								store.name,
								textAlign: TextAlign.center,
								style: TextStyle(color: titleCol, fontSize: 24, fontWeight: FontWeight.w700),
							),
						),

						// المحتوى الرئيسي
						Expanded(
							child: Container(
								width: double.infinity,
								decoration: BoxDecoration(
									color: cardBg,
									borderRadius: const BorderRadius.only(
										topLeft: Radius.circular(radius),
										topRight: Radius.circular(radius),
									),
								),
								padding: const EdgeInsets.all(24),
								child: SingleChildScrollView(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'وصف المتجر',
												style: TextStyle(color: textCol, fontSize: 20, fontWeight: FontWeight.w600),
											),
											const SizedBox(height: 8),
											Text(
												store.description,
												style: TextStyle(color: textCol.withOpacity(0.8), fontSize: 16, height: 1.5),
											),
											const SizedBox(height: 24),

											Row(
												children: [
													Expanded(
														child: _InfoCard(
															title: 'العنوان',
															content: store.address,
															colorBg: cardBg,
															colorText: textCol,
															radius: radius,
															shadow: shadowCol,
														),
													),
													const SizedBox(width: 16),
													Expanded(
														child: _InfoCard(
															title: 'التقييم',
															contentWidget: Row(
																mainAxisAlignment: MainAxisAlignment.center,
																children: _buildStarRating(double.tryParse(store.rating) ?? 0.0)
																		.map((w) => w is Icon
																		? Icon(w.icon, color: iconCol, size: 28)
																		: w)
																		.toList(),
															),
															colorBg: cardBg,
															colorText: textCol,
															radius: radius,
															shadow: shadowCol,
														),
													),
												],
											),

											const SizedBox(height: 32),

											Center(
												child: ElevatedButton.icon(
													onPressed: () => Navigator.push(
														context,
														MaterialPageRoute(
															builder: (_) => AllProductsPage(
																storeId: store.id,
																storeName: store.name,
																user: user,
															),
														),
													),
													icon: const Icon(Icons.shopping_cart, size: 26),
													label: const Text('عرض المنتجات', style: TextStyle(fontSize: 18)),
													style: ElevatedButton.styleFrom(
														backgroundColor: iconCol,
														padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(30),
														),
														elevation: 6,
													),
												),
											),

											const SizedBox(height: 24),
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

class _InfoCard extends StatelessWidget {
	final String title;
	final String? content;
	final Widget? contentWidget;
	final Color colorBg;
	final Color colorText;
	final double radius;
	final Color shadow;

	const _InfoCard({
		Key? key,
		required this.title,
		this.content,
		this.contentWidget,
		required this.colorBg,
		required this.colorText,
		required this.radius,
		required this.shadow,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: colorBg,
				borderRadius: BorderRadius.circular(radius),
				boxShadow: [BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 4))],
			),
			child: Column(
				children: [
					Text(title, style: TextStyle(color: colorText.withOpacity(0.7), fontWeight: FontWeight.bold)),
					const SizedBox(height: 8),
					contentWidget ??
							Text(
								content ?? '',
								textAlign: TextAlign.center,
								style: TextStyle(color: colorText, fontSize: 16),
							),
				],
			),
		);
	}
}
