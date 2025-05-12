import 'package:intl/intl.dart';

class CartItemModel {
	final String id;
	final String userId;
	final String productId;
	final String? productSizeId;
	final String? productColorId;
	final String? productImage;
	final String unitPrice;
	final String quantity;
	final String totalPrice;
	final String? sessionId;
	final String? warningMessage;
	final String createdAt;
	final String updatedAt;

	CartItemModel({
		required this.id,
		required this.userId,
		required this.productId,
		this.productSizeId,
		this.productColorId,
		this.productImage,
		required this.unitPrice,
		required this.quantity,
		required this.totalPrice,
		this.sessionId,
		this.warningMessage,
		required this.createdAt,
		required this.updatedAt,
	});

	/// ننشئ عنصر جديد مع حساب totalPrice وتوليد timestamps
	factory CartItemModel.create({
		required String id,
		required String userId,
		required String productId,
		String? productSizeId,
		String? productColorId,
		String? productImage,
		required String unitPrice,
		required String quantity,
		String? sessionId,
		String? warningMessage,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		final total = double.parse(unitPrice) * int.parse(quantity);
		return CartItemModel(
			id: id,
			userId: userId,
			productId: productId,
			productSizeId: productSizeId,
			productColorId: productColorId,
			productImage: productImage,
			unitPrice: unitPrice,
			quantity: quantity,
			totalPrice: total.toStringAsFixed(2),
			sessionId: sessionId,
			warningMessage: warningMessage,
			createdAt: now,
			updatedAt: now,
		);
	}

	/// لتحديث الكمية أو السعر مثلاً وتحديث updated_at تلقائيًّا
	CartItemModel copyWith({
		String? id,
		String? userId,
		String? productId,
		String? productSizeId,
		String? productColorId,
		String? productImage,
		String? unitPrice,
		String? quantity,
		String? totalPrice,
		String? sessionId,
		String? warningMessage,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		final newTotal = (unitPrice ?? this.unitPrice) != null && (quantity ?? this.quantity) != null
				? (double.parse(unitPrice ?? this.unitPrice) * int.parse(quantity ?? this.quantity)).toStringAsFixed(2)
				: this.totalPrice;
		return CartItemModel(
			id: id ?? this.id,
			userId: userId ?? this.userId,
			productId: productId ?? this.productId,
			productSizeId: productSizeId ?? this.productSizeId,
			productColorId: productColorId ?? this.productColorId,
			productImage: productImage ?? this.productImage,
			unitPrice: unitPrice ?? this.unitPrice,
			quantity: quantity ?? this.quantity,
			totalPrice: totalPrice ?? newTotal,
			sessionId: sessionId ?? this.sessionId,
			warningMessage: warningMessage ?? this.warningMessage,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory CartItemModel.fromJson(Map<String, dynamic> json) {
		return CartItemModel(
			id: json['id'].toString(),
			userId: json['user_id'].toString(),
			productId: json['product_id'].toString(),
			productSizeId: json['product_size_id']?.toString(),
			productColorId: json['product_color_id']?.toString(),
			productImage: json['product_image'],
			unitPrice: json['unit_price'].toString(),
			quantity: json['quantity'].toString(),
			totalPrice: json['total_price'].toString(),
			sessionId: json['session_id'],
			warningMessage: json['warning_message'],
			createdAt: json['created_at'] ?? '',
			updatedAt: json['updated_at'] ?? '',
		);
	}

	/// هذه الدالة تُستخدم عند الإرسال إلى API (POST/PUT)
	Map<String, dynamic> toJsonForRequest() {
		return {
			'id': id,
			'user_id': userId,
			'product_id': productId,
			'product_size_id': productSizeId,
			'product_color_id': productColorId,
			'product_image': productImage,
			'unit_price': unitPrice,
			'quantity': quantity,
			'total_price': totalPrice,
			'session_id': sessionId,
			'warning_message': warningMessage,
			'created_at': createdAt,
			'updated_at': updatedAt,
		};
	}

	/// هذه الدالة العامة إذا احتجت لكل الحقول
	Map<String, dynamic> toJson() => toJsonForRequest();
}
