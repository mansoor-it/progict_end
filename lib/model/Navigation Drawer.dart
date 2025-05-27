import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Drawer(
			child: ListView(
				padding: EdgeInsets.zero,
				children: <Widget>[
					_createHeader(),
					_createDrawerItem(
						icon: Icons.home,
						text: 'الصفحة الرئيسية',
						onTap: () => Navigator.pushReplacementNamed(context, '/home'),
					),
					_createDrawerItem(
						icon: Icons.store,
						text: 'المتاجر',
						onTap: () => Navigator.pushNamed(context, '/stores'),
					),
					_createDrawerItem(
						icon: Icons.category,
						text: 'الفئات',
						onTap: () => Navigator.pushNamed(context, '/categories'),
					),
					_createDrawerItem(
						icon: Icons.shopping_cart,
						text: 'سلة التسوق',
						onTap: () => Navigator.pushNamed(context, '/CartPage'),
					),
					Divider(),
					_createDrawerItem(
						icon: Icons.person,
						text: 'تسجيل الدخول',
						onTap: () => Navigator.pushNamed(context, '/login'),
					),
					_createDrawerItem(
						icon: Icons.admin_panel_settings,
						text: 'تسجيل دخول الأدمن',
						onTap: () => Navigator.pushNamed(context, '/admin/login'),
					),
					_createDrawerItem(
						icon: Icons.info,
						text: 'نبذة عن التطبيق',
						onTap: () => Navigator.pushNamed(context, '/about'),
					),
					_createDrawerItem(
						icon: Icons.settings,
						text: 'الإعدادات',
						onTap: () => Navigator.pushNamed(context, '/settings'),
					),
				],
			),
		);
	}

	Widget _createHeader() {
		return DrawerHeader(
			margin: EdgeInsets.zero,
			padding: EdgeInsets.zero,
			decoration: BoxDecoration(
				color: Colors.blue,
			),
			child: Stack(
				children: <Widget>[
					Positioned(
						bottom: 12.0,
						left: 16.0,
						child: Text("اسم التطبيق",
							style: TextStyle(
									color: Colors.white,
									fontSize: 20.0,
									fontWeight: FontWeight.w500
							),
						),
					),
				],
			),
		);
	}

	Widget _createDrawerItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
		return ListTile(
			title: Row(
				children: <Widget>[
					Icon(icon),
					Padding(
						padding: EdgeInsets.only(left: 8.0),
						child: Text(text),
					)
				],
			),
			onTap: onTap,
		);
	}
}