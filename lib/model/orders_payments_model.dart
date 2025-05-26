import 'package:intl/intl.dart';
import 'package:intl/intl.dart';

/// ==============================
/// Shipping Model
/// ==============================
class Shipping {
	final String id;
	final String orderId;
	final String userId;
	final String address;
	final String city;
	final String postalCode;
	final String shippingMethod;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	Shipping({
		required this.id,
		required this.orderId,
		required this.userId,
		required this.address,
		required this.city,
		required this.postalCode,
		required this.shippingMethod,
		required this.status,
		this.createdAt,
		this.updatedAt,
	});

	factory Shipping.create({
		required String id,
		required String orderId,
		required String userId,
		required String address,
		required String city,
		required String postalCode,
		required String shippingMethod,
		required String status,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Shipping(
			id: id,
			orderId: orderId,
			userId: userId,
			address: address,
			city: city,
			postalCode: postalCode,
			shippingMethod: shippingMethod,
			status: status,
			createdAt: now,
			updatedAt: now,
		);
	}

	Shipping copyWith({
		String? id,
		String? orderId,
		String? userId,
		String? address,
		String? city,
		String? postalCode,
		String? shippingMethod,
		String? status,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Shipping(
			id: id ?? this.id,
			orderId: orderId ?? this.orderId,
			userId: userId ?? this.userId,
			address: address ?? this.address,
			city: city ?? this.city,
			postalCode: postalCode ?? this.postalCode,
			shippingMethod: shippingMethod ?? this.shippingMethod,
			status: status ?? this.status,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory Shipping.fromJson(Map<String, dynamic> json) {
		return Shipping(
			id: json['id'].toString(),
			orderId: json['order_id'].toString(),
			userId: json['user_id'].toString(),
			address: json['address'] ?? '',
			city: json['city'] ?? '',
			postalCode: json['postal_code'] ?? '',
			shippingMethod: json['shipping_method'] ?? '',
			status: json['status'] ?? '',
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'order_id': orderId,
			'user_id': userId,
			'address': address,
			'city': city,
			'postal_code': postalCode,
			'shipping_method': shippingMethod,
			'status': status,
			'created_at': createdAt ?? '',
			'updated_at': updatedAt ?? '',
		};
	}
}

/// ==============================
/// Order Model
/// ==============================
class Order {
	final String id;
	final String userId;
	final String totalPrice;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	Order({
		required this.id,
		required this.userId,
		required this.totalPrice,
		required this.status,
		this.createdAt,
		this.updatedAt,
	});

	factory Order.create({
		required String id,
		required String userId,
		required String totalPrice,
		required String status,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Order(
			id: id,
			userId: userId,
			totalPrice: totalPrice,
			status: status,
			createdAt: now,
			updatedAt: now,
		);
	}

	Order copyWith({
		String? id,
		String? userId,
		String? totalPrice,
		String? status,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Order(
			id: id ?? this.id,
			userId: userId ?? this.userId,
			totalPrice: totalPrice ?? this.totalPrice,
			status: status ?? this.status,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory Order.fromJson(Map<String, dynamic> json) {
		return Order(
			id: json['id'].toString(),
			userId: json['user_id'].toString(),
			totalPrice: json['total_price'].toString(),
			status: json['status'],
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'user_id': userId,
			'total_price': totalPrice,
			'status': status,
			'created_at': createdAt ?? '',
			'updated_at': updatedAt ?? '',
		};
	}
}

/// ==============================
/// OrderItem Model
/// ==============================
class OrderItem {
	final String id;
	final String orderId;
	final String productId;
	final String productName;
	final String productImage;
	final String quantity;
	final String price;
	final String? createdAt;
	final String? updatedAt;

	OrderItem({
		required this.id,
		required this.orderId,
		required this.productId,
		required this.productName,
		required this.productImage,
		required this.quantity,
		required this.price,
		this.createdAt,
		this.updatedAt,
	});

	factory OrderItem.create({
		required String id,
		required String orderId,
		required String productId,
		required String productName,
		required String productImage,
		required String quantity,
		required String price,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return OrderItem(
			id: id,
			orderId: orderId,
			productId: productId,
			productName: productName,
			productImage: productImage,
			quantity: quantity,
			price: price,
			createdAt: now,
			updatedAt: now,
		);
	}

	OrderItem copyWith({
		String? id,
		String? orderId,
		String? productId,
		String? productName,
		String? productImage,
		String? quantity,
		String? price,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return OrderItem(
			id: id ?? this.id,
			orderId: orderId ?? this.orderId,
			productId: productId ?? this.productId,
			productName: productName ?? this.productName,
			productImage: productImage ?? this.productImage,
			quantity: quantity ?? this.quantity,
			price: price ?? this.price,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory OrderItem.fromJson(Map<String, dynamic> json) {
		return OrderItem(
			id: json['id'].toString(),
			orderId: json['order_id'].toString(),
			productId: json['product_id'].toString(),
			productName: json['product_name'].toString(),
			productImage: json['product_imag'],
			quantity: json['quantity'].toString(),
			price: json['price'].toString(),
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'order_id': orderId,
			'product_id': productId,
			'product_name': productName,
			'product_imag': productImage,
			'quantity': quantity,
			'price': price,
			'created_at': createdAt ?? '',
			'updated_at': updatedAt ?? '',
		};
	}
}

/// =================ئ=============
/// Payment Model
/// ==============================
class Payment {
	final String id;
	final String orderId;
	final String userId;
	final String amount;
	final String paymentMethod;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	Payment({
		required this.id,
		required this.orderId,
		required this.userId,
		required this.amount,
		required this.paymentMethod,
		required this.status,
		this.createdAt,
		this.updatedAt,
	});

	factory Payment.create({
		required String id,
		required String orderId,
		required String userId,
		required String amount,
		required String paymentMethod,
		required String status,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Payment(
			id: id,
			orderId: orderId,
			userId: userId,
			amount: amount,
			paymentMethod: paymentMethod,
			status: status,
			createdAt: now,
			updatedAt: now,
		);
	}

	Payment copyWith({
		String? id,
		String? orderId,
		String? userId,
		String? amount,
		String? paymentMethod,
		String? status,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Payment(
			id: id ?? this.id,
			orderId: orderId ?? this.orderId,
			userId: userId ?? this.userId,
			amount: amount ?? this.amount,
			paymentMethod: paymentMethod ?? this.paymentMethod,
			status: status ?? this.status,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory Payment.fromJson(Map<String, dynamic> json) {
		return Payment(
			id: json['id'].toString(),
			orderId: json['order_id'].toString(),
			userId: json['user_id'].toString(),
			amount: json['amount'].toString(),
			paymentMethod: json['payment_method'],
			status: json['status'],
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'order_id': orderId,
			'user_id': userId,
			'amount': amount,
			'payment_method': paymentMethod,
			'status': status,
			'created_at': createdAt ?? '',
			'updated_at': updatedAt ?? '',
		};
	}
}