import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

class PaymentsManagementPage extends StatefulWidget {
	const PaymentsManagementPage({Key? key}) : super(key: key);

	@override
	State<PaymentsManagementPage> createState() => _PaymentsManagementPageState();
}

class _PaymentsManagementPageState extends State<PaymentsManagementPage> {
	final String apiUrl = ApiHelper.url('payments_api.php');

	List<dynamic> payments = [];
	final _formKey = GlobalKey<FormState>();

	int? paymentId;
	TextEditingController orderIdController = TextEditingController();
	TextEditingController userIdController = TextEditingController();
	TextEditingController amountController = TextEditingController();
	TextEditingController paymentMethodController = TextEditingController();
	TextEditingController statusController = TextEditingController();

	@override
	void initState() {
		super.initState();
		fetchPayments();
	}

	Future<void> fetchPayments() async {
		try {
			final response = await http.get(Uri.parse('$apiUrl?action=fetch'));
			if (response.statusCode == 200) {
				setState(() {
					payments = json.decode(response.body);
				});
			}
		} catch (e) {
			print('Error fetching payments: $e');
		}
	}

	Future<void> savePayment() async {
		if (!_formKey.currentState!.validate()) return;

		final isUpdate = paymentId != null;
		final response = await http.post(Uri.parse(apiUrl), body: {
			'action': isUpdate ? 'update' : 'add',
			'id': paymentId?.toString() ?? '',
			'order_id': orderIdController.text,
			'user_id': userIdController.text,
			'amount': amountController.text,
			'payment_method': paymentMethodController.text,
			'status': statusController.text,
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
		clearForm();
		fetchPayments();
	}

	Future<void> deletePayment(int id) async {
		final response = await http.post(Uri.parse(apiUrl), body: {
			'action': 'delete',
			'id': id.toString(),
		});

		final data = json.decode(response.body);
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
		fetchPayments();
	}

	void fillForm(Map<String, dynamic> payment) {
		setState(() {
			paymentId = int.tryParse(payment['id'].toString());
			orderIdController.text = payment['order_id'].toString();
			userIdController.text = payment['user_id'].toString();
			amountController.text = payment['amount'].toString();
			paymentMethodController.text = payment['payment_method'].toString();
			statusController.text = payment['status'].toString();
		});
	}

	void clearForm() {
		setState(() {
			paymentId = null;
			orderIdController.clear();
			userIdController.clear();
			amountController.clear();
			paymentMethodController.clear();
			statusController.clear();
		});
	}

	Widget buildTextField(String label, TextEditingController controller, TextInputType type) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6.0),
			child: TextFormField(
				controller: controller,
				keyboardType: type,
				validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
				decoration: InputDecoration(
					labelText: label,
					border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
					filled: true,
					fillColor: Colors.grey[100],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة المدفوعات'),
				centerTitle: true,
				backgroundColor: Colors.teal,
			),
			body: Padding(
				padding: const EdgeInsets.all(12.0),
				child: Column(
					children: [
						Form(
							key: _formKey,
							child: Column(
								children: [
									buildTextField('رقم الطلب', orderIdController, TextInputType.number),
									buildTextField('رقم المستخدم', userIdController, TextInputType.number),
									buildTextField('المبلغ', amountController, TextInputType.number),
									buildTextField('طريقة الدفع', paymentMethodController, TextInputType.text),
									buildTextField('الحالة', statusController, TextInputType.text),
									const SizedBox(height: 10),
									Row(
										children: [
											ElevatedButton.icon(
												onPressed: savePayment,
												icon: Icon(paymentId == null ? Icons.add : Icons.save),
												label: Text(paymentId == null ? 'إضافة مدفوع' : 'تحديث المدفوع'),
												style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
											),
											const SizedBox(width: 10),
											if (paymentId != null)
												OutlinedButton(
													onPressed: clearForm,
													child: const Text('إلغاء'),
												),
										],
									),
								],
							),
						),
						const Divider(height: 30),
						const Text('قائمة المدفوعات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
						const SizedBox(height: 10),
						Expanded(
							child: ListView.builder(
								itemCount: payments.length,
								itemBuilder: (context, index) {
									final payment = payments[index];
									return Card(
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
										margin: const EdgeInsets.symmetric(vertical: 6),
										child: ListTile(
											title: Text('مدفوع #${payment['id']} - الطلب: ${payment['order_id']}'),
											subtitle: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text('المستخدم: ${payment['user_id']}'),
													Text('المبلغ: ${payment['amount']}'),
													Text('طريقة الدفع: ${payment['payment_method']}'),
													Text('الحالة: ${payment['status']}'),
													Text('تاريخ الإنشاء: ${payment['created_at']}'),
												],
											),
											trailing: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													IconButton(
														icon: const Icon(Icons.edit, color: Colors.blue),
														onPressed: () => fillForm(payment),
													),
													IconButton(
														icon: const Icon(Icons.delete, color: Colors.red),
														onPressed: () => deletePayment(int.parse(payment['id'].toString())),
													),
												],
											),
										),
									);
								},
							),
						)
					],
				),
			),
		);
	}
}
