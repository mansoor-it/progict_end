class SizeItem {
	final String productId;
	final String size;

	SizeItem({required this.productId, required this.size});

	factory SizeItem.fromJson(Map<String, dynamic> json) => SizeItem(
		productId: json['product_id'],
		size: json['size'],
	);
}
class ColorItem {
	final String productId;
	final String colorName;

	ColorItem({required this.productId, required this.colorName});

	factory ColorItem.fromJson(Map<String, dynamic> json) => ColorItem(
		productId: json['product_id'],
		colorName: json['color_name'],
	);
}
