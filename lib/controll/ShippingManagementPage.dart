import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';

class ShippingDetail {
	final String id;
	final String orderId;
	final String recipientName;
	final String addressLine1;
	final String? addressLine2;
	final String city;
	final String state;
	final String postalCode;
	final String country;
	final String phone;
	final String? notes;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	ShippingDetail({
		required this.id,
		required this.orderId,
		required this.recipientName,
		required this.addressLine1,
		this.addressLine2,
		required this.city,
		required this.state,
		required this.postalCode,
		required this.country,
		required this.phone,
		this.notes,
		required this.status,
		this.createdAt,
		this.updatedAt,
	});

	factory ShippingDetail.fromJson(Map<String, dynamic> json) {
		return ShippingDetail(
			id: json['id'].toString(),
			orderId: json['order_id'].toString(),
			recipientName: json['recipient_name'] ?? '',
			addressLine1: json['address_line1'] ?? '',
			addressLine2: json['address_line2'],
			city: json['city'] ?? '',
			state: json['state'] ?? '',
			postalCode: json['postal_code'] ?? '',
			country: json['country'] ?? '',
			phone: json['phone'] ?? '',
			notes: json['notes'],
			status: json['status'] ?? '',
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'order_id': orderId,
			'recipient_name': recipientName,
			'address_line1': addressLine1,
			'address_line2': addressLine2 ?? '',
			'city': city,
			'state': state,
			'postal_code': postalCode,
			'country': country,
			'phone': phone,
			'notes': notes ?? '',
			'status': status,
		};
	}
}

class ShippingDetailsPage extends StatefulWidget {
	@override
	_ShippingDetailsPageState createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
	List<ShippingDetail> _shippingList = [];
	final String apiUrl = ApiHelper.url('shippings_api.php');

	@override
	void initState() {
		super.initState();
		fetchShippingDetails();
	}

	Future<void> fetchShippingDetails() async {
		final response = await http.get(Uri.parse('$apiUrl?action=fetch'));
		if (response.statusCode == 200) {
			final List<dynamic> data = json.decode(response.body);
			setState(() {
				_shippingList = data.map((e) => ShippingDetail.fromJson(e)).toList();
			});
			print('تم جلب بيانات الشحن بنجاح');
		} else {
			print('فشل في تحميل بيانات الشحن');
			_showMessage('فشل في تحميل البيانات', isError: true);
		}
	}

	Future<void> deleteShipping(String id) async {
		final response = await http.post(Uri.parse(apiUrl), body: {
			'action': 'delete',
			'id': id,
		});

		if (response.statusCode == 200) {
			fetchShippingDetails();
			print('تم حذف الشحنة');
			_showMessage('تم الحذف بنجاح');
		} else {
			print('فشل في حذف الشحنة');
			_showMessage('فشل في الحذف', isError: true);
		}
	}

	void _showMessage(String message, {bool isError = false}) {
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(
					isError ? 'خطأ' : 'تم',
					style: TextStyle(
						color: isError ? Colors.red : Colors.green,
						fontWeight: FontWeight.bold,
					),
				),
				content: Text(
					message,
					style: TextStyle(fontSize: 16),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: Text(
							'موافق',
							style: TextStyle(
								color: Colors.blue,
								fontSize: 16,
							),
						),
					),
				],
			),
		);
	}

	void showForm({ShippingDetail? detail}) {
		final formKey = GlobalKey<FormState>();
		final Map<String, TextEditingController> controllers = {
			'order_id': TextEditingController(text: detail?.orderId ?? ''),
			'recipient_name': TextEditingController(text: detail?.recipientName ?? ''),
			'address_line1': TextEditingController(text: detail?.addressLine1 ?? ''),
			'address_line2': TextEditingController(text: detail?.addressLine2 ?? ''),
			'city': TextEditingController(text: detail?.city ?? ''),
			'state': TextEditingController(text: detail?.state ?? ''),
			'postal_code': TextEditingController(text: detail?.postalCode ?? ''),
			'country': TextEditingController(text: detail?.country ?? ''),
			'phone': TextEditingController(text: detail?.phone ?? ''),
			'notes': TextEditingController(text: detail?.notes ?? ''),
			'status': TextEditingController(text: detail?.status ?? ''),
		};

		final Map<String, String> arabicLabels = {
			'order_id': 'رقم الطلب',
			'recipient_name': 'اسم المستلم',
			'address_line1': 'العنوان الرئيسي',
			'address_line2': 'العنوان الثانوي (اختياري)',
			'city': 'المدينة',
			'state': 'المحافظة',
			'postal_code': 'الرمز البريدي',
			'country': 'الدولة',
			'phone': 'رقم الهاتف',
			'notes': 'ملاحظات (اختياري)',
			'status': 'حالة الشحنة',
		};

		showDialog(
			context: context,
			builder: (_) => Dialog(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(16),
				),
				elevation: 8,
				child: Container(
					padding: EdgeInsets.all(20),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(16),
					),
					child: SingleChildScrollView(
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Text(
									detail == null ? 'إضافة شحنة جديدة' : 'تعديل بيانات الشحنة',
									style: TextStyle(
										fontSize: 22,
										fontWeight: FontWeight.bold,
										color: Colors.blue[800],
									),
								),
								SizedBox(height: 20),
								Form(
									key: formKey,
									child: Column(
										children: controllers.entries.map((entry) {
											return Padding(
												padding: const EdgeInsets.only(bottom: 15),
												child: TextFormField(
													controller: entry.value,
													decoration: InputDecoration(
														labelText: arabicLabels[entry.key],
														labelStyle: TextStyle(color: Colors.blue[700]),
														border: OutlineInputBorder(
															borderRadius: BorderRadius.circular(10),
															borderSide: BorderSide(color: Colors.blue),
														),
														focusedBorder: OutlineInputBorder(
															borderRadius: BorderRadius.circular(10),
															borderSide: BorderSide(color: Colors.blue, width: 2),
														),
														filled: true,
														fillColor: Colors.blue[50],
														contentPadding: EdgeInsets.symmetric(
																vertical: 15, horizontal: 20),
													),
													style: TextStyle(fontSize: 16),
													validator: (val) =>
													val == null || val.isEmpty ? 'هذا الحقل مطلوب' : null,
												),
											);
										}).toList(),
									),
								),
								SizedBox(height: 10),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceAround,
									children: [
										ElevatedButton(
											onPressed: () async {
												if (!formKey.currentState!.validate()) return;

												final map = {
													'action': detail == null ? 'add' : 'update',
													if (detail != null) 'id': detail.id,
												};
												controllers.forEach((key, value) {
													map[key] = value.text;
												});

												final response = await http.post(Uri.parse(apiUrl), body: map);

												Navigator.pop(context);

												if (response.statusCode == 200) {
													print(detail == null ? 'تمت الإضافة' : 'تم التحديث');
													_showMessage(detail == null
															? 'تمت إضافة الشحنة بنجاح'
															: 'تم تحديث بيانات الشحنة بنجاح');
													fetchShippingDetails();
												} else {
													print('فشل العملية');
													_showMessage('حدث خطأ أثناء حفظ البيانات', isError: true);
												}
											},
											child: Text(
												'حفظ',
												style: TextStyle(fontSize: 18),
											),
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.green,
												padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
												shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(10)),
											),
										),
										TextButton(
											onPressed: () => Navigator.pop(context),
											child: Text(
												'إلغاء',
												style: TextStyle(fontSize: 18, color: Colors.red),
											),
										),
									],
								),
							],
						),
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(
					'إدارة بيانات الشحن',
					style: TextStyle(
						fontSize: 22,
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
				),
				centerTitle: true,
				backgroundColor: Colors.blue[800],
				iconTheme: IconThemeData(color: Colors.white),
			),
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [Colors.blue[50]!, Colors.white],
					),
				),
				child: RefreshIndicator(
					onRefresh: fetchShippingDetails,
					child: _shippingList.isEmpty
							? Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(Icons.local_shipping, size: 80, color: Colors.blue[300]),
								SizedBox(height: 20),
								Text(
									'لا توجد بيانات شحن متاحة',
									style: TextStyle(fontSize: 20, color: Colors.grey),
								),
							],
						),
					)
							: ListView.builder(
						padding: EdgeInsets.all(12),
						itemCount: _shippingList.length,
						itemBuilder: (_, index) {
							final shipping = _shippingList[index];
							return Container(
								margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(15),
									boxShadow: [
										BoxShadow(
											color: Colors.blue.withOpacity(0.1),
											blurRadius: 10,
											offset: Offset(0, 4),
										),
									],
								),
								child: ListTile(
									contentPadding: EdgeInsets.all(16),
									title: Text(
										shipping.recipientName,
										style: TextStyle(
											fontSize: 20,
											fontWeight: FontWeight.bold,
											color: Colors.blue[800],
										),
									),
									subtitle: Padding(
										padding: const EdgeInsets.only(top: 10),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													children: [
														Icon(Icons.location_on, size: 18, color: Colors.grey),
														SizedBox(width: 5),
														Flexible(
															child: Text(
																'${shipping.addressLine1}, ${shipping.city}',
																style: TextStyle(fontSize: 16),
															),
														),
													],
												),
												SizedBox(height: 5),
												Row(
													children: [
														Icon(Icons.phone, size: 18, color: Colors.grey),
														SizedBox(width: 5),
														Text(
															shipping.phone,
															style: TextStyle(fontSize: 16),
														),
													],
												),
												SizedBox(height: 5),
												Row(
													children: [
														Icon(Icons.circle, size: 14, color: _getStatusColor(shipping.status)),
														SizedBox(width: 5),
														Text(
															'حالة الشحنة: ${shipping.status}',
															style: TextStyle(
																fontSize: 16,
																fontWeight: FontWeight.bold,
																color: _getStatusColor(shipping.status),
															),
														),
													],
												),
											],
										),
									),
									trailing: Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											IconButton(
												icon: Icon(Icons.edit, color: Colors.blue),
												onPressed: () => showForm(detail: shipping),
											),
											IconButton(
												icon: Icon(Icons.delete, color: Colors.red),
												onPressed: () => deleteShipping(shipping.id),
											),
										],
									),
								),
							);
						},
					),
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => showForm(),
				child: Icon(Icons.add, size: 32),
				backgroundColor: Colors.blue[800],
				shape: CircleBorder(),
				elevation: 8,
			),
		);
	}

	Color _getStatusColor(String status) {
		switch (status.toLowerCase()) {
			case 'تم التسليم':
				return Colors.green;
			case 'قيد التوصيل':
				return Colors.orange;
			case 'ملغاة':
				return Colors.red;
			default:
				return Colors.grey;
		}
	}
}