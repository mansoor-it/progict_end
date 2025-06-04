import 'package:intl/intl.dart';

class CartItemModel {
	final String id;
	final String userId;
	final String productId;
	final String? productSizeId;
	final String? productColorId;
	final String? productImage; // يمكن أن تكون Base64 أو URL
	final String unitPrice;
	final String quantity;
	final String totalPrice;
	final String? sessionId;
	final String? warningMessage;
	final String createdAt;
	final String updatedAt;
	final String? storeId;

	final String? colorId;    // Keep ID if needed
	final String? colorName;  // Add name
	final String? sizeId;     // Keep ID if needed
	final String? sizeName;   // Add name
	final String? productName; // Add product name

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
		this.storeId,
		this.colorId,
		this.colorName,
		this.sizeId,
		this.sizeName,
		this.productName,
	});

	factory CartItemModel.create({
		required String id,
		required String userId,
		required String productId,
		String? productSizeId,
		String? productColorId,
		String? productImage,
		required String unitPrice,
		required String quantity,
		required String color, // Added color parameter
		required String size,   // Added size parameter
		String? sessionId,
		String? warningMessage,
		String? storeId,
	}) {
		final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

		// حساب الإجمالي
		double total;
		try {
			total = double.parse(unitPrice) * int.parse(quantity);
		} catch (e) {
			total = 0.0;
		}

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
			storeId: storeId,
			colorId: color, // Corrected to colorId
			sizeId: size,   // Corrected to sizeId
		);
	}

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
		String? storeId,
		String? colorId, // Updated parameter name
		String? sizeId,  // Updated parameter name
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
			storeId: storeId ?? this.storeId,
			colorId: colorId ?? this.colorId, // Updated parameter name
			sizeId: sizeId ?? this.sizeId,     // Updated parameter name
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
			storeId: json['store_id']?.toString(),
			colorName: json['color_name']?.toString(), // Get color name
			sizeId: json['size_id']?.toString(),       // Get size ID
			sizeName: json['size_name']?.toString(),   // Get size name
			productName: json['product_name']?.toString(), // Get product name
		);
	}

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
			'store_id': storeId,
			'color_id': colorId, // Corrected key name
			'color_name': colorName,
			'size_id': sizeId,   // Corrected key name
			'size_name': sizeName,
			'product_name': productName,
		};
	}

	Map<String, dynamic> toJson() => toJsonForRequest();
}