import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
	const AboutUsPage({super.key});

	@override
	Widget build(BuildContext context) {
		// نظام الألوان
		const Color primaryBrown = Color(0xFF795548);
		const Color lightBrown = Color(0xFFD7CCC8);
		const Color darkBrown = Color(0xFF5D4037);
		const Color accentColor = Color(0xFFFFAB91);

		return Scaffold(
			appBar: AppBar(
				title: const Text("من نحن", style: TextStyle(color: Colors.white)),
				centerTitle: true,
				backgroundColor: primaryBrown,
				iconTheme: const IconThemeData(color: Colors.white),
			),
			body: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [Colors.white, Color(0xFFEFEBE9)],
					),
				),
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(20),
					child: Column(
						children: [
							// بطاقة الشعار والترحيب
							Card(
								elevation: 4,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(20),
								),
								child: Container(
									padding: const EdgeInsets.all(20),
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.circular(20),
										boxShadow: [
											BoxShadow(
												color: primaryBrown.withOpacity(0.1),
												blurRadius: 10,
												spreadRadius: 2,
											),
										],
									),
									child: Column(
										children: [
											// الشعار مع تأثير الظل
											Container(
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													boxShadow: [
														BoxShadow(
															color: primaryBrown.withOpacity(0.2),
															blurRadius: 10,
															spreadRadius: 3,
														),
													],
												),
												child: const CircleAvatar(
													radius: 60,
													backgroundImage: AssetImage('assets/logo.jpg'),
													backgroundColor: Colors.transparent,
												),
											),
											const SizedBox(height: 20),
											const Text(
												"فريق التميز التقني",
												style: TextStyle(
													fontSize: 24,
													fontWeight: FontWeight.bold,
													color: darkBrown,
												),
											),
											const SizedBox(height: 15),
											const Text(
												"نحن فريق متخصص في تقديم حلول تكنولوجية متكاملة تهدف إلى تحسين تجربة المستخدم وتوفير خدمات رقمية عالية الجودة. نعمل بشغف لتطوير تطبيقات ذكية تلبي احتياجات السوق وتحقق رضا العملاء.",
												style: TextStyle(fontSize: 16, height: 1.6),
												textAlign: TextAlign.center,
											),
										],
									),
								),
							),
							const SizedBox(height: 25),

							// بطاقة الرؤية
							_buildInfoCard(
								icon: Icons.lightbulb_outline,
								iconColor: accentColor,
								title: "رؤيتنا",
								content: "أن نكون روادًا في مجال التجارة الإلكترونية الذكية والتحول الرقمي في العالم العربي.",
							),
							const SizedBox(height: 20),

							// بطاقة الرسالة
							_buildInfoCard(
								icon: Icons.flag_outlined,
								iconColor: Colors.blue,
								title: "رسالتنا",
								content: "تقديم خدمات تقنية متميزة بأحدث الأساليب لتسهيل الحياة اليومية للمستخدمين وتوفير تجربة سلسة وآمنة.",
							),
							const SizedBox(height: 20),

							// بطاقة الخدمات
							Card(
								elevation: 3,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(15),
								),
								child: Container(
									padding: const EdgeInsets.all(20),
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.circular(15),
									),
									child: Column(
										children: [
											Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													Icon(Icons.build, color: darkBrown, size: 28),
													const SizedBox(width: 10),
													const Text(
														"ماذا نقدم؟",
														style: TextStyle(
															fontSize: 20,
															fontWeight: FontWeight.bold,
															color: darkBrown,
														),
													),
												],
											),
											const SizedBox(height: 15),
											_buildServiceItem(Icons.shopping_cart, "منصات تجارة إلكترونية متعددة البائعين"),
											_buildServiceItem(Icons.dashboard, "لوحات تحكم إدارية متقدمة"),
											_buildServiceItem(Icons.phone_iphone, "تطبيقات موبايل سهلة الاستخدام"),
											_buildServiceItem(Icons.payment, "تكامل مع أنظمة الدفع والتوصيل"),
											_buildServiceItem(Icons.support_agent, "دعم فني وتقني مستمر"),
										],
									),
								),
							),
							const SizedBox(height: 25),

							// بطاقة القيم
							Container(
								padding: const EdgeInsets.all(20),
								decoration: BoxDecoration(
									color: primaryBrown.withOpacity(0.1),
									borderRadius: BorderRadius.circular(15),
									border: Border.all(color: lightBrown, width: 2),
								),
								child: Column(
									children: [
										const Icon(Icons.favorite, size: 40, color: primaryBrown),
										const SizedBox(height: 10),
										const Text(
											"قيمنا",
											style: TextStyle(
												fontSize: 22,
												fontWeight: FontWeight.bold,
												color: darkBrown,
											),
										),
										const SizedBox(height: 15),
										Wrap(
											alignment: WrapAlignment.center,
											spacing: 12,
											runSpacing: 12,
											children: [
												_buildValueChip("الشفافية", Icons.visibility),
												_buildValueChip("الابتكار", Icons.auto_awesome),
												_buildValueChip("الالتزام", Icons.handshake),
												_buildValueChip("الجودة", Icons.star),
												_buildValueChip("العمل الجماعي", Icons.people),
												_buildValueChip("رضا العملاء", Icons.emoji_emotions),
											],
										),
									],
								),
							),
							const SizedBox(height: 25),

							// خاتمة مع زر التواصل
							Card(
								elevation: 3,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(15),
								),
								child: Container(
									padding: const EdgeInsets.all(20),
									decoration: BoxDecoration(
										gradient: LinearGradient(
											begin: Alignment.topLeft,
											end: Alignment.bottomRight,
											colors: [lightBrown.withOpacity(0.3), Colors.white],
										),
										borderRadius: BorderRadius.circular(15),
									),
									child: Column(
										children: [
											const Text(
												"نحن نطمح إلى بناء علاقة ثقة طويلة الأمد مع عملائنا من خلال تقديم أفضل الحلول التقنية.",
												style: TextStyle(
													fontSize: 18,
													fontWeight: FontWeight.w500,
													color: darkBrown,
													height: 1.6,
												),
												textAlign: TextAlign.center,
											),
											const SizedBox(height: 20),
											ElevatedButton(
												onPressed: () async {
													final Uri whatsappUrl = Uri.parse('https://wa.me/message/Y2FEOQNKSFH4J1');
													if (await canLaunchUrl(whatsappUrl)) {
														await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
													} else {
														// يمكنك عرض رسالة خطأ إذا لم يتمكن من فتح الرابط
														print("Could not launch WhatsApp link");
													}
												},
												style: ElevatedButton.styleFrom(
													backgroundColor: primaryBrown,
													foregroundColor: Colors.white,
													padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(25),
													),
													elevation: 5,
												),
												child: const Row(
													mainAxisSize: MainAxisSize.min,
													children: [
														Icon(Icons.contact_page),
														SizedBox(width: 8),
														Text("تواصل معنا"),
													],
												),
											),

										],
									),
								),
							),
							const SizedBox(height: 20),
						],
					),
				),
			),
		);
	}

	// بطاقة المعلومات
	Widget _buildInfoCard({
		required IconData icon,
		required Color iconColor,
		required String title,
		required String content,
	}) {
		return Card(
			elevation: 3,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(15),
			),
			child: Container(
				padding: const EdgeInsets.all(20),
				decoration: BoxDecoration(
					color: Colors.white,
					borderRadius: BorderRadius.circular(15),
					boxShadow: [
						BoxShadow(
							color: Colors.brown.withOpacity(0.05),
							blurRadius: 8,
							spreadRadius: 2,
						),
					],
				),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Container(
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: iconColor.withOpacity(0.2),
								shape: BoxShape.circle,
							),
							child: Icon(icon, size: 30, color: iconColor),
						),
						const SizedBox(width: 15),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										title,
										style: const TextStyle(
											fontSize: 18,
											fontWeight: FontWeight.bold,
											color: Color(0xFF5D4037),
										),
									),
									const SizedBox(height: 8),
									Text(
										content,
										style: const TextStyle(fontSize: 16, height: 1.5),
									),
								],
							),
						),
					],
				),
			),
		);
	}

	// عنصر الخدمة
	Widget _buildServiceItem(IconData icon, String text) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Icon(icon, size: 22, color: const Color(0xFF5D4037)),
					const SizedBox(width: 12),
					Expanded(
						child: Text(
							text,
							style: const TextStyle(fontSize: 16, height: 1.5),
						),
					),
				],
			),
		);
	}

	// شريحة القيم
	Widget _buildValueChip(String value, IconData icon) {
		return Chip(
			avatar: Icon(icon, size: 20, color: const Color(0xFF5D4037)),
			label: Text(value, style: const TextStyle(fontSize: 15)),
			backgroundColor: const Color(0xFFD7CCC8).withOpacity(0.3),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(20),
				side: const BorderSide(color: Color(0xFFD7CCC8)),
			),
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
		);
	}
}