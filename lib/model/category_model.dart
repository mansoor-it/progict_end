class Category {
	final String id;
	final String name;
	final String description;
	final String image;

	Category({
		required this.id,
		required this.name,
		required this.description,
		required this.image,
	});

	factory Category.fromJson(Map<String, dynamic> json) {
		return Category(
			id: json['id'].toString(),
			name: json['name'],
			description: json['description'] ?? '',
			image: json['image'] ?? '',
		);
	}
}
