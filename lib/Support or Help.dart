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
		return Scaffold(
			appBar: AppBar(
				title: const Text("الدعم الفني"),
				centerTitle: true,
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const Text(
							'مرحبًا بك في مركز الدعم الخاص بنا! نحن هنا لمساعدتك والإجابة على جميع استفساراتك.',
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
							textAlign: TextAlign.start,
						),
						const SizedBox(height: 20),

						const Text(
							'📞 وسائل التواصل:',
							style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 10),
						_buildContactTile(
							icon: FontAwesomeIcons.facebook,
							color: Colors.blue,
							label: 'فيسبوك',
							onTap: () => _launchURL('https://www.facebook.com/mansoor.alkahtani.2025?mibextid=ZbWKwL'),
						),
						_buildContactTile(
							icon: FontAwesomeIcons.whatsapp,
							color: Colors.green,
							label: 'واتساب',
							onTap: () => _launchURL('https://wa.me/966733494291?text=مرحبًا،%20أحتاج%20مساعدة%20من%20الدعم%20الفني'),
						),
						_buildContactTile(
							icon: FontAwesomeIcons.instagram,
							color: Colors.pink,
							label: 'إنستغرام',
							onTap: () => _launchURL('https://www.instagram.com/x.s.9.8?igsh=MXFtY21qb2NuNXVkMg=='),
						),
						_buildContactTile(
							icon: FontAwesomeIcons.envelope,
							color: Colors.redAccent,
							label: 'البريد الإلكتروني',
							onTap: () => _launchURL('mailto:mansooranes73349@gmail.com'),
						),

						const SizedBox(height: 24),
						const Text(
							'🕐 أوقات العمل:',
							style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 8),
						const Text(
							'من السبت إلى الخميس، من 9 صباحًا حتى 5 مساءً',
							style: TextStyle(fontSize: 15),
						),

						const SizedBox(height: 24),
						const Text(
							'📋 ماذا يمكنك أن تفعل هنا؟',
							style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 8),
						const Text('- الإبلاغ عن مشكلة أو خلل في التطبيق'),
						const Text('- تقديم اقتراح لتحسين الخدمة'),
						const Text('- الاستفسار عن المنتجات أو الطلبات'),
						const Text('- متابعة حالة طلب سابق'),

						const SizedBox(height: 24),
						const Text(
							'📨 هل لديك مشكلة؟ تواصل معنا الآن وسنقوم بالرد عليك في أسرع وقت ممكن.',
							style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
						),
					],
				),
			),
		);
	}

	Widget _buildContactTile({
		required IconData icon,
		required Color color,
		required String label,
		required VoidCallback onTap,
	}) {
		return Container(
			margin: const EdgeInsets.symmetric(vertical: 6),
			decoration: BoxDecoration(
				color: Colors.grey[100],
				borderRadius: BorderRadius.circular(12),
			),
			child: ListTile(
				contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
				leading: FaIcon(icon, color: color, size: 28),
				title: Text(label, style: const TextStyle(fontSize: 17)),
				onTap: onTap,
				trailing: const Icon(Icons.arrow_forward_ios, size: 16),
			),
		);
	}
}
