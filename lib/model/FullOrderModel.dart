class OrderItem {
	final int productId;
	final String productName;
	final String productImage;
	final int quantity;
	final double price;

	OrderItem({
		required this.productId,
		required this.productName,
		required this.productImage,
		required this.quantity,
		required this.price,
	});

	Map<String, dynamic> toJson() => {
		'product_id': productId,
		'product_name': productName,
		'product_imag': productImage,
		'quantity': quantity,
		'price': price,
	};
}

class Payment {
	final double amount;
	final String paymentMethod;
	final String status;

	Payment({
		required this.amount,
		required this.paymentMethod,
		this.status = 'pending',
	});

	Map<String, dynamic> toJson() => {
		'amount': amount,
		'payment_method': paymentMethod,
		'status': status,
	};
}

class Shipping {
	final String recipientName;
	final String addressLine1;
	final String? addressLine2;
	final String city;
	final String? state;
	final String? postalCode;
	final String country;
	final String phone;
	final String? notes;
	final String status;

	Shipping({
		required this.recipientName,
		required this.addressLine1,
		this.addressLine2,
		required this.city,
		this.state,
		this.postalCode,
		required this.country,
		required this.phone,
		this.notes,
		this.status = 'pending',
	});

	Map<String, dynamic> toJson() => {
		'recipient_name': recipientName,
		'address_line1': addressLine1,
		'address_line2': addressLine2,
		'city': city,
		'state': state,
		'postal_code': postalCode,
		'country': country,
		'phone': phone,
		'notes': notes,
		'status': status,
	};
}
