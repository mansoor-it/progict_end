import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig.dart';
import '../model/orders_payments_model.dart';

class OrderPaymentService {
	static final String _baseUrl = ApiHelper.url('orders_payments_api.php');

	/// -----------------------------
	/// Orders
	/// -----------------------------

	static Future<List<Order>> getAllOrders() async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'orders'}),
			);

			print('getAllOrders: ${response.body}');

			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = json.decode(response.body);
				if (jsonResponse['success'] == true) {
					final List<dynamic> data = jsonResponse['data'];
					final List<Order> orders = data
							.map<Order>((json) => Order.fromJson(json as Map<String, dynamic>))
							.toList();
					return orders;
				} else {
					print('getAllOrders: Server returned failure');
				}
			} else {
				print('getAllOrders: HTTP error ${response.statusCode}');
			}
		} catch (e) {
			print('Error in getAllOrders: $e');
		}
		return [];
	}

	static Future<String> addOrder(Order order) async {
		try {
			final body = {
				'action': 'add_order',
				...order.toJson(),
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in addOrder: $e');
			return 'error';
		}
	}

	static Future<String> updateOrder(Order order) async {
		try {
			final body = {
				'action': 'update_order',
				...order.toJson(),
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in updateOrder: $e');
			return 'error';
		}
	}

	static Future<String> deleteOrder(String id) async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'delete_order', 'id': id}),
			);
			return response.body;
		} catch (e) {
			print('Error in deleteOrder: $e');
			return 'error';
		}
	}

	/// -----------------------------
	/// OrderItems
	/// -----------------------------

	static Future<List<OrderItem>> getAllOrderItems(String orderId) async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'order_items', 'order_id': orderId}),
			);

			print('getAllOrderItems: ${response.body}');

			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = json.decode(response.body);
				if (jsonResponse['success'] == true) {
					final List<dynamic> data = jsonResponse['data'];
					final List<OrderItem> items = data
							.map<OrderItem>((json) => OrderItem.fromJson(json as Map<String, dynamic>))
							.toList();
					return items;
				}
			}
		} catch (e) {
			print('Error in getAllOrderItems: $e');
		}
		return [];
	}

	static Future<String> addOrderItem(OrderItem item) async {
		try {
			final body = {
				'action': 'add_order_item',
				...item.toJson(),
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in addOrderItem: $e');
			return 'error';
		}
	}

	static Future<String> updateOrderItem(OrderItem item) async {
		try {
			final body = {
				'action': 'update_order_item',
				...item.toJson(),
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in updateOrderItem: $e');
			return 'error';
		}
	}

	static Future<String> deleteOrderItem(String id) async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'delete_order_item', 'id': id}),
			);
			return response.body;
		} catch (e) {
			print('Error in deleteOrderItem: $e');
			return 'error';
		}
	}

	/// -----------------------------
	/// Payments
	/// -----------------------------

	static Future<List<Payment>> getAllPayments() async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'payments'}),
			);

			print('getAllPayments: ${response.body}');

			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = json.decode(response.body);
				if (jsonResponse['success'] == true) {
					final List<dynamic> data = jsonResponse['data'];
					final List<Payment> payments = data
							.map<Payment>((json) => Payment.fromJson(json as Map<String, dynamic>))
							.toList();
					return payments;
				}
			}
		} catch (e) {
			print('Error in getAllPayments: $e');
		}
		return [];
	}

	static Future<String> addPayment(Payment payment) async {
		final data = payment.toJson();
		data.remove('created_at');
		data.remove('updated_at');

		try {
			final body = {
				'action': 'add_payment',
				...data,
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in addPayment: $e');
			return 'error';
		}
	}

	static Future<String> updatePayment(Payment payment) async {
		final data = payment.toJson();
		data.remove('created_at');
		data.remove('updated_at');

		try {
			final body = {
				'action': 'update_payment',
				...data,
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in updatePayment: $e');
			return 'error';
		}
	}

	static Future<String> deletePayment(String id) async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'delete_payment', 'id': id}),
			);
			return response.body;
		} catch (e) {
			print('Error in deletePayment: $e');
			return 'error';
		}
	}

	/// -----------------------------
	/// Shipping
	/// -----------------------------

	static Future<List<Shipping>> getAllShippings() async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'shippings'}),
			);

			print('getAllShippings: ${response.body}');

			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = json.decode(response.body);
				if (jsonResponse['success'] == true) {
					final List<dynamic> data = jsonResponse['data'];
					final List<Shipping> shippings = data
							.map<Shipping>((json) => Shipping.fromJson(json as Map<String, dynamic>))
							.toList();
					return shippings;
				}
			}
		} catch (e) {
			print('Error in getAllShippings: $e');
		}
		return [];
	}

	static Future<String> addShipping(Shipping shipping) async {
		final data = shipping.toJson();
		data.remove('created_at');
		data.remove('updated_at');

		try {
			final body = {
				'action': 'add_shipping',
				...data,
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in addShipping: $e');
			return 'error';
		}
	}

	static Future<String> updateShipping(Shipping shipping) async {
		final data = shipping.toJson();
		data.remove('created_at');
		data.remove('updated_at');

		try {
			final body = {
				'action': 'update_shipping',
				...data,
			};
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(body),
			);
			return response.body;
		} catch (e) {
			print('Error in updateShipping: $e');
			return 'error';
		}
	}

	static Future<String> deleteShipping(String id) async {
		try {
			final response = await http.post(
				Uri.parse(_baseUrl),
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({'action': 'delete_shipping', 'id': id}),
			);
			return response.body;
		} catch (e) {
			print('Error in deleteShipping: $e');
			return 'error';
		}
	}
}
