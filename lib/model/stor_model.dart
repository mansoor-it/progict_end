
class Store {
	final String id;
	final String categoryId;
	final String name;
	final String description;
	final String address;
	final String storeImage;

	Store({
		required this.id,
		required this.categoryId,
		required this.name,
		required this.description,
		required this.address,
		required this.storeImage,
	});

	factory Store.fromJson(Map<String, dynamic> json) {
		return Store(
			id: json['id'].toString(),
			categoryId: json['category_id'].toString(),
			name: json['name'],
			description: json['description'],
			address: json['address'],
			storeImage: json['store_image'],
		);
	}
}