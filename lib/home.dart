import 'package:flutter/material.dart';

import 'controll/admin_control.dart';
import 'controll/aimg.dart';
import 'controll/banners_control.dart';
import 'controll/user_control.dart';
import 'controll/vendors_control.dart';


class NavigationHomePage extends StatelessWidget {
	const NavigationHomePage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('لوحة التحكم'),
				centerTitle: true,
				backgroundColor: Colors.blueAccent,
			),
			body: ListView(
				padding: const EdgeInsets.all(16),
				children: [
					_buildNavButton(
						context,
						label: 'إدارة البائعين',
						page: const VendorManagementPage(),
					),
					_buildNavButton(
						context,
						label: 'إدارة المستخدمين',
						page: const UserManagementPage(),
					),
					_buildNavButton(
						context,
						label: 'إدارة البنرات',
						page: const BannerManagementPage(),
					),
					_buildNavButton(
						context,
						label: 'الصفحة الرئيسية',
						page: const MyHomePage(),
					),
					_buildNavButton(
						context,
						label: 'إدارة الإداريين',
						page: const AdminHomePage(),
					),
				],
			),
		);
	}

	Widget _buildNavButton(BuildContext context, {required String label, required Widget page}) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: ElevatedButton(
				style: ElevatedButton.styleFrom(
					padding: const EdgeInsets.symmetric(vertical: 16),
					backgroundColor: Colors.indigo,
					foregroundColor: Colors.white,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(16),
					),
				),
				onPressed: () {
					Navigator.push(
						context,
						MaterialPageRoute(builder: (_) => page),
					);
				},
				child: Text(
					label,
					style: const TextStyle(fontSize: 18),
				),
			),
		);
	}
}
