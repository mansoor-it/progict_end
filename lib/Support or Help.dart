import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
	const SupportPage({super.key});

	void _launchURL(String url) async {
		final uri = Uri.parse(url);
		if (await canLaunchUrl(uri)) {
			await launchUrl(uri, mode: LaunchMode.externalApplication);
		} else {
			throw 'لا يمكن فتح الرابط: $url';
		}
	}

	@override
	Widget build(BuildContext context) {
		// الألوان الأساسية
		const Color primaryBrown = Color(0xFF795548);
		const Color lightBrown = Color(0xFFD7CCC8);
		const Color darkBrown = Color(0xFF5D4037);
		const Color accentColor = Color(0xFFFFAB91);

		return Scaffold(
			appBar: AppBar(
				title: const Text("الدعم الفني", style: TextStyle(color: Colors.white)),
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
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// بطاقة الترحيب
							Card(
								elevation: 4,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(15),
								),
								child: Container(
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.circular(15),
										boxShadow: [
											BoxShadow(
												color: primaryBrown.withOpacity(0.1),
												blurRadius: 10,
												spreadRadius: 2,
											)
										],
									),
									padding: const EdgeInsets.all(20),
									child: Column(
										children: [
											const Icon(Icons.support_agent,
													size: 48, color: primaryBrown),
											const SizedBox(height: 15),
											const Text(
												'مرحبًا بك في مركز الدعم',
												style: TextStyle(
													fontSize: 22,
													fontWeight: FontWeight.bold,
													color: darkBrown,
												),
												textAlign: TextAlign.center,
											),
											const SizedBox(height: 10),
											Text(
												'نحن هنا لمساعدتك والإجابة على جميع استفساراتك (733494291)',
												style: TextStyle(
													fontSize: 16,
													color: Colors.grey[700],
												),
												textAlign: TextAlign.center,
											),
										],
									),
								),
							),
							const SizedBox(height: 25),

							// بطاقة وسائل التواصل
							const Padding(
								padding: EdgeInsets.only(bottom: 12, right: 8),
								child: Text(
									'وسائل التواصل',
									style: TextStyle(
										fontSize: 20,
										fontWeight: FontWeight.bold,
										color: darkBrown,
									),
								),
							),
							Card(
								elevation: 3,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
								child: Padding(
									padding: const EdgeInsets.symmetric(vertical: 8),
									child: Column(
										children: [
											_buildContactTile(
												icon: FontAwesomeIcons.facebook,
												color: const Color(0xFF1877F2),
												label: 'فيسبوك',
												onTap: () => _launchURL('https://www.facebook.com/mansoor.alkahtani.2025?mibextid=ZbWKwL'),
											),
											const Divider(height: 0, indent: 70, endIndent: 20),
											_buildContactTile(
												icon: FontAwesomeIcons.whatsapp,
												color: const Color(0xFF25D366),
												label: 'واتساب',
												onTap: () => _launchURL('https://wa.me/966733494291?text=مرحبًا،%20أحتاج%20مساعدة%20من%20الدعم%20الفني'),
											),
											const Divider(height: 0, indent: 70, endIndent: 20),
											_buildContactTile(
												icon: FontAwesomeIcons.instagram,
												color: const Color(0xFFE4405F),
												label: 'إنستغرام',
												onTap: () => _launchURL('https://www.instagram.com/x.s.9.8?igsh=MXFtY21qb2NuNXVkMg=='),
											),
											const Divider(height: 0, indent: 70, endIndent: 20),
											_buildContactTile(
												icon: FontAwesomeIcons.envelope,
												color: const Color(0xFFEA4335),
												label: 'البريد الإلكتروني',
												onTap: () => _launchURL('mailto:mansooranes73349@gmail.com'),
											),
										],
									),
								),
							),
							const SizedBox(height: 25),

							// بطاقة معلومات الدعم
							Row(
								children: [
									Expanded(
										child: _buildInfoCard(
											icon: Icons.access_time,
											title: 'أوقات العمل',
											content: 'من السبت إلى الخميس\n9 صباحًا - 5 مساءً',
											color: lightBrown,
										),
									),
									const SizedBox(width: 15),
									Expanded(
										child: _buildInfoCard(
											icon: Icons.help_center,
											title: 'خدمات الدعم',
											content: 'حل المشاكل الفنية\nالرد على الاستفسارات\nاستقبال الاقتراحات',
											color: lightBrown,
										),
									),
								],
							),
							const SizedBox(height: 25),

							// بطاقة الإرشادات
							Card(
								elevation: 3,
								shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(12)),
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											const Text(
												'كيف يمكننا مساعدتك؟',
												style: TextStyle(
													fontSize: 18,
													fontWeight: FontWeight.bold,
													color: darkBrown,
												),
											),
											const SizedBox(height: 12),
											_buildBulletPoint('- الإبلاغ عن مشكلة أو خلل في التطبيق'),
											_buildBulletPoint('- تقديم اقتراح لتحسين الخدمة'),
											_buildBulletPoint('- الاستفسار عن المنتجات أو الطلبات'),
											_buildBulletPoint('- متابعة حالة طلب سابق'),
										],
									),
								),
							),
							const SizedBox(height: 25),

							// بطاقة التواصل الفوري
							Container(
								padding: const EdgeInsets.all(20),
								decoration: BoxDecoration(
									color: primaryBrown.withOpacity(0.9),
									borderRadius: BorderRadius.circular(15),
									boxShadow: [
										BoxShadow(
											color: primaryBrown.withOpacity(0.2),
											blurRadius: 8,
											spreadRadius: 2,
										)
									],
								),
								child: Column(
									children: [
										const Text(
											'هل تحتاج مساعدة فورية؟',
											style: TextStyle(
												fontSize: 20,
												fontWeight: FontWeight.bold,
												color: Colors.white,
											),
											textAlign: TextAlign.center,
										),
										const SizedBox(height: 10),
										const Text(
											'تواصل معنا الآن وسنقوم بالرد عليك في أسرع وقت ممكن',
											style: TextStyle(
												fontSize: 16,
												color: Colors.white70,
											),
											textAlign: TextAlign.center,
										),
										const SizedBox(height: 20),
										ElevatedButton.icon(
											icon: const Icon(Icons.message, size: 20),
											label: const Text('ابدأ المحادثة الآن'),
											style: ElevatedButton.styleFrom(
												backgroundColor: accentColor,
												foregroundColor: darkBrown,
												padding: const EdgeInsets.symmetric(
														horizontal: 20, vertical: 12),
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(25),
												),
											),
											onPressed: () => _launchURL(
													'https://wa.me/message/Y2FEOQNKSFH4J1'),
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

	// عنصر وسيلة التواصل
	Widget _buildContactTile({
		required IconData icon,
		required Color color,
		required String label,
		required VoidCallback onTap,
	}) {
		return ListTile(
			contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			leading: Container(
				width: 50,
				height: 50,
				decoration: BoxDecoration(
					color: color.withOpacity(0.1),
					shape: BoxShape.circle,
				),
				child: Icon(icon, color: color),
			),
			title: Text(label,
					style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
			trailing: Container(
				padding: const EdgeInsets.all(6),
				decoration: const BoxDecoration(
					color: Color(0xFFEFEBE9),
					shape: BoxShape.circle,
				),
				child: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF5D4037)),
			),
			onTap: onTap,
		);
	}

	// بطاقة المعلومات
	Widget _buildInfoCard({
		required IconData icon,
		required String title,
		required String content,
		required Color color,
	}) {
		return Card(
			elevation: 3,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
			child: Container(
				decoration: BoxDecoration(
					color: color.withOpacity(0.3),
					borderRadius: BorderRadius.circular(12),
				),
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Icon(icon, size: 32, color: const Color(0xFF5D4037)),
						const SizedBox(height: 10),
						Text(title,
								style: const TextStyle(
										fontSize: 17,
										fontWeight: FontWeight.bold,
										color: Color(0xFF5D4037))),
						const SizedBox(height: 8),
						Text(content,
								style: const TextStyle(fontSize: 15, color: Color(0xFF5D4037))),
					],
				),
			),
		);
	}

	// نقطة القائمة
	Widget _buildBulletPoint(String text) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 8),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Padding(
						padding: EdgeInsets.only(top: 5, right: 8),
						child: Icon(Icons.circle, size: 8, color: Color(0xFF795548)),
					),
					Expanded(
						child: Text(text,
								style: const TextStyle(fontSize: 16, height: 1.4)),
					),
				],
			),
		);
	}
}