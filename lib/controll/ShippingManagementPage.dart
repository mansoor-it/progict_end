import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/orders_payments_model.dart';

class ShippingManagementPage extends StatefulWidget {
	const ShippingManagementPage({Key? key}) : super(key: key);

	@override
	State<ShippingManagementPage> createState() => _ShippingManagementPageState();
}

class _ShippingManagementPageState extends State<ShippingManagementPage> {
	List<Shipping> shippings = [];
	final _formKey = GlobalKey<FormState>();

	final TextEditingController idController = TextEditingController();
	final TextEditingController orderIdController = TextEditingController();
	final TextEditingController userIdController = TextEditingController();
	final TextEditingController addressController = TextEditingController();
	final TextEditingController cityController = TextEditingController();
	final TextEditingController postalCodeController = TextEditingController();
	final TextEditingController methodController = TextEditingController();
	final TextEditingController statusController = TextEditingController();

	void _addOrEditShipping({Shipping? existing}) {
		if (existing != null) {
			idController.text = existing.id;
			orderIdController.text = existing.orderId;
			userIdController.text = existing.userId;
			addressController.text = existing.address;
			cityController.text = existing.city;
			postalCodeController.text = existing.postalCode;
			methodController.text = existing.shippingMethod;
			statusController.text = existing.status;
		} else {
			idController.clear();
			orderIdController.clear();
			userIdController.clear();
			addressController.clear();
			cityController.clear();
			postalCodeController.clear();
			methodController.clear();
			statusController.clear();
		}

		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(existing == null ? 'إضافة شحن' : 'تعديل الشحن'),
				content: Form(
					key: _formKey,
					child: SingleChildScrollView(
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								TextFormField(controller: idController, decoration: InputDecoration(labelText: 'رقم الشحن')),
								TextFormField(controller: orderIdController, decoration: InputDecoration(labelText: 'رقم الطلب')),
								TextFormField(controller: userIdController, decoration: InputDecoration(labelText: 'رقم المستخدم')),
								TextFormField(controller: addressController, decoration: InputDecoration(labelText: 'العنوان')),
								TextFormField(controller: cityController, decoration: InputDecoration(labelText: 'المدينة')),
								TextFormField(controller: postalCodeController, decoration: InputDecoration(labelText: 'الرمز البريدي')),
								TextFormField(controller: methodController, decoration: InputDecoration(labelText: 'طريقة الشحن')),
								TextFormField(controller: statusController, decoration: InputDecoration(labelText: 'الحالة')),
							],
						),
					),
				),
				actions: [
					TextButton(
							onPressed: () => Navigator.pop(context),
							child: const Text('إلغاء')),
					ElevatedButton(
						onPressed: () {
							if (_formKey.currentState!.validate()) {
								final shipping = Shipping.create(
									id: idController.text,
									orderId: orderIdController.text,
									userId: userIdController.text,
									address: addressController.text,
									city: cityController.text,
									postalCode: postalCodeController.text,
									shippingMethod: methodController.text,
									status: statusController.text,
								);

								setState(() {
									if (existing != null) {
										final index = shippings.indexOf(existing);
										shippings[index] = shipping;
									} else {
										shippings.add(shipping);
									}
								});
								Navigator.pop(context);
							}
						},
						child: const Text('حفظ'),
					)
				],
			),
		);
	}

	void _deleteShipping(Shipping shipping) {
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: const Text('تأكيد الحذف'),
				content: const Text('هل أنت متأكد من حذف هذا الشحن؟'),
				actions: [
					TextButton(
							onPressed: () => Navigator.pop(context),
							child: const Text('إلغاء')),
					ElevatedButton(
						onPressed: () {
							setState(() => shippings.remove(shipping));
							Navigator.pop(context);
						},
						child: const Text('حذف'),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة الشحن'),
				actions: [
					IconButton(
						icon: const Icon(Icons.add),
						onPressed: () => _addOrEditShipping(),
					)
				],
			),
			body: ListView.builder(
				itemCount: shippings.length,
				itemBuilder: (context, index) {
					final s = shippings[index];
					return Card(
						margin: const EdgeInsets.all(8.0),
						child: ListTile(
							title: Text('رقم الطلب: ${s.orderId} - المستخدم: ${s.userId}'),
							subtitle: Text('${s.address}, ${s.city} - ${s.status}'),
							trailing: Row(
								mainAxisSize: MainAxisSize.min,
								children: [
									IconButton(
										icon: const Icon(Icons.edit),
										onPressed: () => _addOrEditShipping(existing: s),
									),
									IconButton(
										icon: const Icon(Icons.delete),
										onPressed: () => _deleteShipping(s),
									),
								],
							),
						),
					);
				},
			),
		);
	}
}
